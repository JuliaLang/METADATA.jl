using JSON

const PR_NUM = ENV["TRAVIS_PULL_REQUEST"]
const BUILD_DIR = ENV["TRAVIS_BUILD_DIR"]
const API_URL = "https://api.github.com/repos/JuliaLang/METADATA.jl"
const CURL_URL = "$API_URL/pulls/$PR_NUM/files?per_page=100"

# Get files modified in the PR from the GitHub API
changes = JSON.parse(readchomp(`curl "$CURL_URL"`))

# If all went well, `changes` will be an array, or a dict without that key
if typeof(changes) <: Dict && haskey(changes, "message")
    msg = changes["message"]
    error("GitHub API gave result \"$msg\" from `$CURL_URL` GET request")
end

const RGX = r"^[^/]+/versions/([\d.]+)"

# Get the associated package and version for each affected file
modified = Dict() # package => [versions...]
for diff in changes
    fname = diff["filename"]
    pkg = split(fname, "/")[1]
    # Only look at changes to tagged versions
    if isdir(joinpath(BUILD_DIR, pkg)) && pkg != ".test" && ismatch(RGX, fname)
        v = VersionNumber(match(RGX, fname).captures[1])
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
    lines = split(readchomp(`git ls-remote --tags -q $remote_url`), "\n")

    # We want the peeled tag if it's there, otherwise we'll take what we can get
    remotetags = Dict()
    _rmt = Array{Any,2}(length(lines), 3)
    for (i, line) in enumerate(lines)
        sha, _tag = split(line, "\trefs/tags/")
        if endswith(_tag, "^{}")
            _tag = _tag[1:end-3]
            peeled = true
        else
            peeled = false
        end
        tag = VersionNumber(_tag)
        _rmt[i,:] = [tag, sha, peeled]
    end
    for t in unique(_rmt[:,1])
        if any(_rmt[_rmt[:,1] .== t, 3]) # any peeled
            push!(remotetags, t => _rmt[(_rmt[:,1] .== t) & _rmt[:,3], 2])
        else
            push!(remotetags, t => _rmt[_rmt[:,1] .== t, 2])
        end
    end

    localtags = Dict(map(readdir(joinpath(dir, "versions"))) do v
        sha = readchomp(joinpath(dir, "versions", v, "sha1"))
        VersionNumber(v) => sha
    end)

    notpushed = setdiff(localtags, remotetags)
    getmad = intersect(modified[pkg], map(first, notpushed))

    if isempty(notpushed)
        # Tags match, so we can compare SHAs 1-1
        for tag in keys(localtags)
            if localtags[tag] != remotetags[tag]
                msg = string("The commit SHA for $pkg $tag does not match between METADATA ",
                             "and the upstream package repository.")
                error(msg)
            end
        end
    elseif !isempty(getmad) # just those added in this PR
        msg = string("The following tags for $pkg have not been pushed to upstream ",
                     "repository: ", join(getmad, ", "), ".\nTo fix this, navigate to ",
                     "the package directory and run `git push --tags`.")
        error(msg)
    end
end
