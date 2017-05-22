#!/usr/bin/env julia
# script to populate test dependencies of registered packages

using JSON

type TagInfo
    sha1::String
    requires::String
    testrequires::String
end
function taginfo(tags::Dict)
    if haskey(tags, "sha1")
        return TagInfo(tags["sha1"], tags["requires"], tags["testrequires"])
    else
        return map(kv -> first(kv) => taginfo(last(kv)), tags)
    end
end

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

# standard dependencies from REQUIRE, already saved in METADATA
# TODO: can skip reading requires files here, this version
# drops OS annotations which we want to keep
stdreqs = Pkg.cd(Pkg.Read.available)

if isfile(Pkg.dir("METADATA", ".test", "allreqs.json"))
    # load requirements from existing saved json file, if any
    allreqs = taginfo(JSON.parsefile(Pkg.dir("METADATA", ".test", "allreqs.json")))
else
    allreqs = Dict{String, Any}()
end

cd(Pkg.dir("METADATA")) do
    ghpkgs = String[]
    nonghpkgs = String[]
    for pkg in keys(stdreqs)
        haskey(allreqs, pkg) || (allreqs[pkg] = Dict())
        if ismatch(Pkg.Cache.GITHUB_REGEX, Pkg.Read.url(pkg))
            push!(ghpkgs, pkg)
        else
            push!(nonghpkgs, pkg)
        end
    end

    asyncmap((pkg, vn) for pkg in ghpkgs for vn in keys(stdreqs[pkg])) do pv
        # use curl for github packages
        pkg, vn = pv
        ver = string(vn)
        url = Pkg.Cache.normalize_url(Pkg.Read.url(pkg)) # normalize to https
        if endswith(url, ".git")
            url = url[1:end-4]
        end
        tagsha = stdreqs[pkg][vn].sha1
        @assert tagsha != ""
        reqfile = Pkg.dir("METADATA", pkg, "versions", ver, "requires")
        requires = isfile(reqfile) ? readstring(reqfile) : ""
        allvers = allreqs[pkg]
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
        allvers = allreqs[pkg]
        for vn in keys(stdvers)
            ver = string(vn)
            tagsha = stdvers[vn].sha1
            @assert tagsha != ""
            reqfile = Pkg.dir("METADATA", pkg, "versions", ver, "requires")
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

    sortversions = map(pv -> first(pv) => SortedDictWrapper(last(pv)), allreqs)
    open(Pkg.dir("METADATA", ".test", "allreqs.json"), "w") do f
        JSON.print(f, SortedDictWrapper(sortversions), 1)
    end
end
