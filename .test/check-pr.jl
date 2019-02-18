# The full path where the repository is cloned and where the job is run
const BUILD_DIR = ENV["BUILD_DIR"]

# Avoid using the merge commit when checking for changes as sometimes this can result
# in extra changes being found during the diff.
const DIFF_HEAD = get(ENV, "TRAVIS_PULL_REQUEST_SHA", "HEAD")

function get_remote_tags(url)
    ls = try
        readchomp(`git ls-remote --tags -q $url`)
    catch
        error("The specified URL does not correspond to a valid Git repository")
    end
    lines = split(ls, "\n")

    filter!(lines) do line
        m = match(r"^\w+\trefs/tags/(v[^\^]+)(\^{})?$", line)
        if m === nothing
            return false
        else
            tag = m.captures[1]
            return occursin(Base.VERSION_REGEX, tag)
        end
    end

    n = length(lines)

    tags = fill(VersionNumber(0), n)
    shas = fill("", n)
    peel = fill(false, n)

    for (i, line) in enumerate(lines)
        sha, tag = split(line, "\trefs/tags/")

        peeled = endswith(tag, "^{}")
        peeled && (tag = tag[1:end-3])

        tags[i] = VersionNumber(tag)
        shas[i] = sha
        peel[i] = peeled
    end

    remotetags = Dict{VersionNumber,AbstractString}()

    for tag in unique(tags)
        ispeeled = map((t, p) -> t == tag && p, tags, peel)

        sha = if count(identity, ispeeled) == 1
            shas[findfirst(t -> t != 0, ispeeled)]
        elseif count(t -> t == tag, tags) == 1
            shas[findfirst(t -> t == tag, tags)]
        else
            error("Upstream tag $tag is possibly malformed.\nRemote tags:\n$ls")
        end

        push!(remotetags, tag => sha)
    end

    return remotetags
end

function get_local_tags(dir)
    localtags = Dict{VersionNumber,AbstractString}()
    for v in readdir(joinpath(dir, "versions"))
        sha = readchomp(joinpath(dir, "versions", v, "sha1"))
        push!(localtags, VersionNumber(v) => sha)
    end
    return localtags
end

function filter_diff(filt, commit1="origin/HEAD", commit2=DIFF_HEAD)
    # Determine what files have changed between `commit2` and the common ancestor of
    # `commit1` and `commit2`. The common ancestor is used avoid returning extra files
    # when `commit1` is ahead of `commit2`.
    # See: https://git-scm.com/docs/git-diff#git-diff-emgitdiffem--optionsltcommitgtltcommitgt--ltpathgt82308203
    split(readchomp(`git diff --name-only --diff-filter=$filt $commit1...$commit2`), '\n')
end

# Compare the current commit with the default branch upstream, returning a list of files
# changed. We only care about additions (A) and modifications (M).
changed, added = cd(BUILD_DIR) do
    (filter_diff("M"), filter_diff("A"))
end

if isempty(changed) && isempty(added) && get(ENV, "TRAVIS_EVENT_TYPE", "unknown") == "pull_request"
    warn("No changes between the PR and the base branch have been detected, which is " *
         "probably wrong.")
else
    println("INFO: Files modified in this PR:\n$(join(changed, '\n'))")
    println("INFO: Files added in this PR:\n$(join(added, '\n'))")
    for file in changed
        if endswith(file, "sha1")
            # policy 8, do not modify existing published tag sha1's
            error(string("Do not modify existing published tag $file (policy 8).\n",
                         "Ask for an exception if absolutely necessary, but tag commits\n",
                         "should be immutable once published for reproducibility."))
        end
    end
end

const RGX = r"^[^/]+/versions/([\d.]+)"

# Get the associated package and version for each added file
modified = Dict{AbstractString,Vector{VersionNumber}}() # package => [versions...]
for file in added
    pkg = split(file, "/")[1]
    # Only look at changes to tagged versions
    if isdir(joinpath(BUILD_DIR, pkg)) && pkg != ".test" && occursin(RGX, file) && endswith(file, "sha1")
        v = VersionNumber(match(RGX, file).captures[1])
        if haskey(modified, pkg)
            in(v, modified[pkg]) || push!(modified[pkg], v)
        else
            push!(modified, pkg => VersionNumber[v])
        end
    end
end

# Check that tagging makes sense
for pkg in keys(modified)
    dir = joinpath(BUILD_DIR, pkg)

    remote_url = readchomp(joinpath(dir, "url"))

    remotetags = get_remote_tags(remote_url)
    localtags = get_local_tags(dir)

    notpushed = setdiff(keys(localtags), keys(remotetags))
    getmad = intersect(modified[pkg], notpushed)

    if isempty(notpushed)
        # Tags match, so we can compare SHAs 1-1
        for tag in modified[pkg]
            if localtags[tag] != remotetags[tag]
                msg = string("The commit SHA for $pkg $tag does not match between METADATA ",
                             "and the upstream package repository.\nMETADATA SHA: ",
                             localtags[tag], "\nUpstream SHA: ", remotetags[tag])
                error(msg)
            end
        end
    elseif !isempty(getmad) # just those added in this PR
        msg = string("The following tags for $pkg have not been pushed to upstream ",
                     "repository: ", join(getmad, ", "), ".\nTo fix this, navigate to ",
                     "the package directory and run `git push --tags`.\nAfterward, ",
                     "close then reopen your METADATA pull request to restart the ",
                     "$(ENV["CI_NAME"]) build.")
        error(msg)
    end
end

if VERSION >= v"0.7.0"
    if VERSION < v"1.1.0-DEV.857"
        using Pkg.Types: read_project
    else
        read_project(x) = Pkg.Types.read_project(x).other
    end
    for pkg in keys(modified)
        url = readchomp(joinpath(BUILD_DIR, pkg, "url"))
        for tag in modified[pkg]
            mktempdir() do d
                run(`git clone $url $d --quiet --depth 1 --branch v$tag`)
                if isfile(joinpath(d, "JuliaProject.toml"))
                    proj = read_project(joinpath(d, "JuliaProject.toml"))
                elseif isfile(joinpath(d, "Project.toml"))
                    proj = read_project(joinpath(d, "Project.toml"))
                else
                    return
                end
                compatible = Pkg.METADATA_compatible_uuid(String(pkg))
                if haskey(proj, "uuid")
                    declared = Base.UUID(proj["uuid"])
                    if declared != compatible
                        error("Tagged version $tag of $pkg declares the package UUID to be ",
                              "\"$declared\" in its Project file, which does not match the ",
                              "package's METADATA-compatible UUID \"$compatible\".\nTo fix ",
                              "this error, change the UUID to be \"$compatible\" and retag.")
                    end
                else
                    error("Tagged version $tag of $pkg has a Project file with no UUID for ",
                          "the package.\nAdd a line `uuid = \"$compatible\"` near the top ",
                          "of the Project file and retag.")
                end
                haskey(proj, "version") || return
                v = VersionNumber(proj["version"])
                if v != tag
                    error("Tagged version $tag of $pkg lists version $v in its Project file.\n",
                          "The versions must match.")
                end
            end
        end
    end
end

# Ensure no stdlibs are listed in REQUIRE
if VERSION >= v"0.7.0"
    const STDLIBS = readdir(Pkg.Types.stdlib_dir())
    for (pkg, versions) in modified, ver in versions
        reqs = joinpath(BUILD_DIR, pkg, "versions", string(ver), "requires")
        # Do a first pass over the file to get the Julia version. We'll do this as two
        # separate loops just in case things are listed in a weird order (e.g. Julia
        # listed after the things we want to detect)
        jlver = v"0.0.0"
        for line in eachline(reqs)
            if startswith(line, "julia")
                _, ver, = split(line, ' ')
                jlver = VersionNumber(ver)
            end
        end
        for line in eachline(reqs)
            dep = first(split(line, ' '))
            # It's okay to list SHA as a requirement iff Julia versions before SHA was
            # added as a stdlib are allowed
            if jlver < v"0.7.0-DEV.3861" && dep == "SHA"
                continue
            elseif dep in STDLIBS
                error("Tagged version $ver of $pkg lists the standard library module $dep in ",
                      "its REQUIRE file. Stdlibs should not be listed in REQUIRE, only in ",
                      "Project.toml.\nRemove $dep from REQUIRE and retag.")
            end
        end
    end
end
