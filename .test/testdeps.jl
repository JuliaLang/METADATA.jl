#!/usr/bin/env julia
# script to populate test dependencies of registered packages

using JSON

# wrapper around a Dict that iterates over keys in sorted order
immutable SortedDictWrapper{K,V} <: Associative{K,V}
    d::Dict{K,V}
    sortedkeys::Vector{K}
end
SortedDictWrapper(d) = SortedDictWrapper(d, sort!(collect(keys(d))))
Base.start(sd::SortedDictWrapper) = 1
function Base.next(sd::SortedDictWrapper, i)
    key = sd.sortedkeys[i]
    (key => sd.d[key], i+1)
end
Base.done(sd::SortedDictWrapper, i) = (i == length(sd.sortedkeys)+1)

type TagInfo
    sha1::String
    requires::String
    testrequires::String
end
TagInfo(d::Dict) = TagInfo(d["sha1"], d["requires"], d["testrequires"])
type PkgInfo
    url::String
    versions::Associative{VersionNumber, TagInfo}
end
PkgInfo(d::Dict) = PkgInfo(d["url"],
    map(kv -> VersionNumber(first(kv)) => TagInfo(last(kv)), d["versions"]))
Base.sort(p::PkgInfo) = PkgInfo(p.url, SortedDictWrapper(p.versions))

allreqs = cd(Pkg.dir("METADATA")) do
    jsonfile = joinpath(".test", "allreqs.json")
    # load requirements from existing saved json file, if any
    allreqs = isfile(jsonfile) ?
        map(kv -> first(kv) => PkgInfo(last(kv)), JSON.parsefile(jsonfile)) :
        Dict{String, PkgInfo}()

    ghpkgs = String[]
    nonghpkgs = String[]
    for pkg in readdir()
        isfile(pkg, "url") || continue
        url = strip(readstring(joinpath(pkg, "url")))
        if haskey(allreqs, pkg)
            allreqs[pkg].url = url # update in case METADATA url has changed
        else
            allreqs[pkg] = PkgInfo(url, Dict{VersionNumber, TagInfo}())
        end
        isdir(pkg, "versions") || continue # if no tagged versions, save url only
        if ismatch(Pkg.Cache.GITHUB_REGEX, url)
            push!(ghpkgs, pkg)
        else
            push!(nonghpkgs, pkg)
        end
    end

    ntasks = haskey(ENV, "CI") ? 20 : 100
    asyncmap((pkg, ver) for pkg in ghpkgs
            for ver in readdir(joinpath(pkg, "versions")), ntasks=ntasks) do pv
        # use curl for github packages
        pkg, ver = pv
        ismatch(Base.VERSION_REGEX, ver) || return
        vn = VersionNumber(ver)
        url = Pkg.Cache.normalize_url(allreqs[pkg].url) # normalize to https
        if endswith(url, ".git")
            url = url[1:end-4]
        end
        tagsha = readchomp(joinpath(pkg, "versions", ver, "sha1"))
        @assert tagsha != ""
        reqfile = joinpath(pkg, "versions", ver, "requires")
        requires = isfile(reqfile) ? readstring(reqfile) : ""
        allvers = allreqs[pkg].versions
        if get(allvers, vn, TagInfo("", "", "")).sha1 == tagsha
            # no change in sha since saved version
            # but metadata requires may have changed, so update just in case
            allvers[vn].requires = requires
            return
        end
        # else, new tag or changed sha, update test reqs
        # check if tagged sha's exist - only github counterexample
        # so far is ProjectiveDictionaryPairLearning v0.2.2
        #status = readstring(`curl -s -o /dev/null -I -L -w "%{http_code}" $url/tree/$tagsha`)
        #if status != "200"
        #    warn("$pkg v$ver at $url/tree/$tagsha returned status $status")
        #end
        testrequires = readstring(`curl -s -L $url/raw/$tagsha/test/REQUIRE`)
        if !startswith(testrequires, "Not Found")
            if !isempty(testrequires) && isempty(requires)
                warn("$pkg v$ver has a test/REQUIRE but no REQUIRE")
            end
            allvers[vn] = TagInfo(tagsha, requires, testrequires)
        else
            if !isempty(get(allvers, vn, TagInfo("", "", "")).testrequires)
                warn("$pkg v$ver previously had a nonempty test/REQUIRE but sha changed?")
            end
            allvers[vn] = TagInfo(tagsha, requires, "")
        end
        return
    end

    # for non-github packages, do the hard way with an actual clone
    for pkg in nonghpkgs
        url = allreqs[pkg].url
        allvers = allreqs[pkg].versions
        for ver in readdir(joinpath(pkg, "versions"))
            ismatch(Base.VERSION_REGEX, ver) || continue
            vn = VersionNumber(ver)
            tagsha = readchomp(joinpath(pkg, "versions", ver, "sha1"))
            @assert tagsha != ""
            reqfile = joinpath(pkg, "versions", ver, "requires")
            requires = isfile(reqfile) ? readstring(reqfile) : ""
            if get(allvers, vn, TagInfo("", "", "")).sha1 == tagsha
                # no change in sha since saved version
                # but metadata requires may have changed, so update just in case
                allvers[vn].requires = requires
                continue
            end
            # else, new tag or changed sha, update test reqs
            isdir("$pkg-tmp") || run(`git clone $url $pkg-tmp`)
            cd("$pkg-tmp") do
                run(`git checkout -q $tagsha`)
                if isfile(joinpath("test", "REQUIRE"))
                    testrequires = readstring(joinpath("test", "REQUIRE"))
                    if !isempty(testrequires) && isempty(requires)
                        warn("$pkg v$ver has a test/REQUIRE but no REQUIRE")
                    end
                    allvers[vn] = TagInfo(tagsha, requires, testrequires)
                else
                    if !isempty(get(allvers, vn, TagInfo("", "", "")).testrequires)
                        warn("$pkg v$ver previously had a nonempty test/REQUIRE but sha changed?")
                    end
                    allvers[vn] = TagInfo(tagsha, requires, "")
                end
            end
        end
        isdir("$pkg-tmp") && rm("$pkg-tmp", recursive=true)
    end

    sortversions = map(pv -> first(pv) => sort(last(pv)), allreqs)
    open(jsonfile, "w") do f
        JSON.print(f, SortedDictWrapper(sortversions), 1) # also sort by pkg name
    end
    return allreqs
end
