#!/usr/bin/env julia
# script to populate test dependencies of registered packages

using JSON

# little bit of type piracy here to output Pkg.Types.Available compactly
JSON.lower(avail::Pkg.Types.Available) =
    (avail.sha1, sprint(io -> Pkg.Reqs.write(io, avail.requires)))
# translate from String=>Tuple{String,String} to VersionNumber=>Pkg.Types.Available
versavail(va) = VersionNumber(first(va)) =>
    Pkg.Types.Available(last(va)[1], Pkg.Reqs.parse(IOBuffer(last(va)[2])))

# wrapper around a Dict that iterates over keys in sorted order
immutable SortedDictWrapper{K,V} <: Associative{K,V}
    d::Dict{K,V}
    sortedkeys::Vector{K}
end
SortedDictWrapper(d) = SortedDictWrapper(d, sort!(collect(keys(d))))
Base.length(sd::SortedDictWrapper) = length(sd.d)
Base.eltype(sd::SortedDictWrapper) = eltype(sd.d)
Base.get(sd::SortedDictWrapper, key, default) = get(sd.d, key, default)
Base.start(sd::SortedDictWrapper) = 1
function Base.next(sd::SortedDictWrapper, i)
    key = sd.sortedkeys[i]
    (key => sd.d[key], i+1)
end
Base.done(sd::SortedDictWrapper, i) = (i == length(sd.sortedkeys)+1)

# standard dependencies from REQUIRE, already saved in METADATA
stdreqs = cd(Pkg.dir()) do
    Pkg.Read.available()
end

testreqs = cd(Pkg.dir("METADATA")) do
    empty_version(sha) = Pkg.Types.Available(sha, Dict())

    if isfile(Pkg.dir("METADATA",".test","testreqs.json"))
        # load testreqs from existing saved json file, if any
        testreqs = map(pv -> first(pv) => map(versavail, last(pv)),
            JSON.parsefile(Pkg.dir("METADATA",".test","testreqs.json")))
    else
        testreqs = Dict{String, Dict{VersionNumber, Pkg.Types.Available}}()
    end

    ghpkgs = String[]
    nonghpkgs = String[]
    for pkg in keys(stdreqs)
        haskey(testreqs, pkg) || (testreqs[pkg] = Dict())
        if ismatch(Pkg.Cache.GITHUB_REGEX, Pkg.Read.url(pkg))
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
        testvers = testreqs[pkg]
        if get(testvers, ver, empty_version("")).sha1 == tagsha
            # no change in sha since saved version
            return
        end
        # else, new tag or changed sha, update test reqs
        # check if tagged sha's exist - only github counterexample
        # so far is ProjectiveDictionaryPairLearning v0.2.2
        #status = readstring(`curl -s -o /dev/null -I -L -w "%{http_code}" $url/tree/$tagsha`)
        #if status != "200"
        #    warn("$pkg v$ver at $url/tree/$tagsha returned status $status")
        #end
        content = readlines(`curl -s -L $url/raw/$tagsha/test/REQUIRE`)
        if length(content) != 1 || chomp(content[1]) != "Not Found"
            parsedreqs = Pkg.Reqs.parse(content)
            testvers[ver] = Pkg.Types.Available(tagsha, parsedreqs)
            if !isempty(parsedreqs) && isempty(stdreqs[pkg][ver].requires)
                warn("$pkg v$ver has a test/REQUIRE but no REQUIRE")
            end
        else
            if !isempty(get(testvers, ver, empty_version("")).requires)
                warn("$pkg v$ver previously had a nonempty test/REQUIRE but sha changed?")
            end
            testvers[ver] = empty_version(tagsha)
        end
    end

    # for non-github packages, do the hard way with an actual clone
    for pkg in nonghpkgs
        url = Pkg.Read.url(pkg)
        stdvers = stdreqs[pkg]
        testvers = testreqs[pkg]
        for ver in keys(stdvers)
            tagsha = stdvers[ver].sha1
            @assert tagsha != ""
            if get(testvers, ver, empty_version("")).sha1 == tagsha
                # no change in sha since saved version
                continue
            end
            # else, new tag or changed sha, update test reqs
            isdir("$pkg-tmp") || run(`git clone $url $pkg-tmp`)
            cd("$pkg-tmp") do
                run(`git checkout -q $tagsha`)
                if isfile("test/REQUIRE")
                    parsedreqs = Pkg.Reqs.parse("test/REQUIRE")
                    testvers[ver] = Pkg.Types.Available(tagsha, parsedreqs)
                    if !isempty(parsedreqs) && isempty(stdvers[ver].requires)
                        warn("$pkg v$ver has a test/REQUIRE but no REQUIRE")
                    end
                else
                    if !isempty(get(testvers, ver, empty_version("")).requires)
                        warn("$pkg v$ver previously had a nonempty test/REQUIRE but sha changed?")
                    end
                    testvers[ver] = empty_version(tagsha)
                end
            end
        end
        isdir("$pkg-tmp") && rm("$pkg-tmp", recursive=true)
    end

    sortversions = map(pv -> first(pv) => SortedDictWrapper(last(pv)), testreqs)
    open(Pkg.dir("METADATA",".test","testreqs.json"), "w") do f
        JSON.print(f, SortedDictWrapper(sortversions), 1)
    end
    return testreqs
end
