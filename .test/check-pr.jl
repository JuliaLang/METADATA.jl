const BUILD_DIR = ENV["BUILD_DIR"]
const PR_COMMIT_SHA = ENV["TRAVIS_PULL_REQUEST_SHA"]

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
            return ismatch(Base.VERSION_REGEX, tag)
        end
    end

    n = length(lines)

    tags = Vector{VersionNumber}(n)
    shas = Vector{AbstractString}(n)
    peel = Vector{Bool}(n)

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
            shas[findfirst(ispeeled)]
        elseif count(t -> t == tag, tags) == 1
            shas[findfirst(tags, tag)]
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

filter_diff(commit1, commit2, filt) =
    readchomp(`git diff --name-only --diff-filter=$filt $commit1 $commit2`)

changed, added = cd(ENV["TRAVIS_BUILD_DIR"]) do
    # Ensure that JuliaLang/METADATA.jl is a registered remote by adding it
    # explicitly (this is okay even if it's the same as an existing remote)
    run(`git remote add _upstream https://github.com/JuliaLang/METADATA.jl.git`)
    run(`git fetch _upstream`)
    upstream_commit = readchomp(`git rev-parse _upstream/metadata-v2`)

    # Compare the current commit with the default branch upstream, returning
    # a string containing a newline-delimited list of files changed. We only
    # care about additions (A) and modifications (M).
    _changed = filter_diff(upstream_commit, PR_COMMIT_SHA, "M")
    _added = filter_diff(upstream_commit, PR_COMMIT_SHA, "A")

    # Separate each list into a vector and return both changed and added
    (split(_changed, '\n'), split(_added, '\n'))
end

if isempty(changed) && isempty(added) && ENV["TRAVIS_EVENT_TYPE"] == "pull_request"
    warn("No changes between the PR and the base branch have been detected, which is " *
         "probably wrong.")
else
    info("Files modified in this PR: $changed")
    info("Files added in this PR: $added")
    for file in changed
        if endswith(file, "sha1")
            # policy 8, do not modify existing published tag sha1's
            error(string("Do not modify existing published tag sha1 files (policy 8).\n",
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
    if isdir(joinpath(BUILD_DIR, pkg)) && pkg != ".test" && ismatch(RGX, file) && endswith(file, "sha1")
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
