#!/usr/bin/env julia
# script to populate test dependencies of registered packages

using JSON

# wrapper around a Dict that iterates over keys in sorted order
immutable SortedDictWrapper{K,V} <: Associative{K,V}
    d::Dict{K,V}
    sortedkeys::Vector{K}
end
SortedDictWrapper(d) = SortedDictWrapper(d, sort!(collect(keys(d))))
Base.get(sd::SortedDictWrapper, key, default) = get(sd.d, key, default)
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
function taginfo(json::Dict)
    if haskey(json, "sha1")
        return TagInfo(json["sha1"], json["requires"], json["testrequires"])
    else
        return map(kv -> VersionNumber(first(kv)) => taginfo(last(kv)), json)
    end
end
type PkgInfo
    url::String
    versions::Associative{VersionNumber, TagInfo}
end
function pkginfo(json::Dict)
    if haskey(json, "url")
        return PkgInfo(json["url"], taginfo(json["versions"]))
    else
        return map(kv -> first(kv) => pkginfo(last(kv)), json)
    end
end
Base.sort(p::PkgInfo) = PkgInfo(p.url, SortedDictWrapper(p.versions))

# standard dependencies from REQUIRE, already saved in METADATA
# TODO: can skip reading requires files here, this version
# drops OS annotations which we want to keep
stdreqs = Pkg.cd(Pkg.Read.available)

if isfile(Pkg.dir("METADATA", ".test", "allreqs.json"))
    # load requirements from existing saved json file, if any
    allreqs = pkginfo(JSON.parsefile(Pkg.dir("METADATA", ".test", "allreqs.json")))
else
    allreqs = Dict{String, PkgInfo}()
end

cd(Pkg.dir("METADATA")) do
    ghpkgs = String[]
    nonghpkgs = String[]
    for pkg in keys(stdreqs)
        url = Pkg.Read.url(pkg)
        if haskey(allreqs, pkg)
            allreqs[pkg].url = url # update in case METADATA url has changed
        else
            allreqs[pkg] = PkgInfo(url, Dict{VersionNumber, TagInfo}())
        end
        if ismatch(Pkg.Cache.GITHUB_REGEX, url)
            push!(ghpkgs, pkg)
        else
            push!(nonghpkgs, pkg)
        end
    end

    asyncmap((pkg, ver) for pkg in ghpkgs for ver in keys(stdreqs[pkg])) do pv
        # use curl for github packages
        pkg, ver = pv
        url = Pkg.Cache.normalize_url(Pkg.Read.url(pkg)) # normalize to https
        if endswith(url, ".git")
            url = url[1:end-4]
        end
        tagsha = stdreqs[pkg][ver].sha1
        @assert tagsha != ""
        reqfile = Pkg.dir("METADATA", pkg, "versions", string(ver), "requires")
        requires = isfile(reqfile) ? readstring(reqfile) : ""
        allvers = allreqs[pkg].versions
        if get(allvers, ver, TagInfo("", "", "")).sha1 == tagsha
            # no change in sha since saved version
            # but metadata requires may have changed, so update just in case
            allvers[ver].requires = requires
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
            allvers[ver] = TagInfo(tagsha, requires, testrequires)
            if !isempty(testrequires) && isempty(requires)
                warn("$pkg v$ver has a test/REQUIRE but no REQUIRE")
            end
        else
            if !isempty(get(allvers, ver, TagInfo("", "", "")).testrequires)
                warn("$pkg v$ver previously had a nonempty test/REQUIRE but sha changed?")
            end
            allvers[ver] = TagInfo(tagsha, requires, "")
        end
    end

    # for non-github packages, do the hard way with an actual clone
    for pkg in nonghpkgs
        url = Pkg.Read.url(pkg)
        stdvers = stdreqs[pkg]
        allvers = allreqs[pkg].versions
        for ver in keys(stdvers)
            tagsha = stdvers[ver].sha1
            @assert tagsha != ""
            reqfile = Pkg.dir("METADATA", pkg, "versions", string(ver), "requires")
            requires = isfile(reqfile) ? readstring(reqfile) : ""
            if get(allvers, ver, TagInfo("", "", "")).sha1 == tagsha
                # no change in sha since saved version
                # but metadata requires may have changed, so update just in case
                allvers[ver].requires = requires
                continue
            end
            # else, new tag or changed sha, update test reqs
            isdir("$pkg-tmp") || run(`git clone $url $pkg-tmp`)
            cd("$pkg-tmp") do
                run(`git checkout -q $tagsha`)
                if isfile("test/REQUIRE")
                    testrequires = readstring("test/REQUIRE")
                    allvers[ver] = TagInfo(tagsha, requires, testrequires)
                    if !isempty(testrequires) && isempty(requires)
                        warn("$pkg v$ver has a test/REQUIRE but no REQUIRE")
                    end
                else
                    if !isempty(get(allvers, ver, TagInfo("", "", "")).testrequires)
                        warn("$pkg v$ver previously had a nonempty test/REQUIRE but sha changed?")
                    end
                    allvers[ver] = TagInfo(tagsha, requires, "")
                end
            end
        end
        isdir("$pkg-tmp") && rm("$pkg-tmp", recursive=true)
    end

    sortversions = map(pv -> first(pv) => sort(last(pv)), allreqs)
    open(Pkg.dir("METADATA", ".test", "allreqs.json"), "w") do f
        JSON.print(f, SortedDictWrapper(sortversions), 1)
    end
end
