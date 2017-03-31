#!/usr/bin/env julia
# script to populate test dependencies of registered packages
# in the same format as metadata-v2

using ProgressMeter
cd(Pkg.dir("METADATA")) do
    old_branch = readchomp(`git rev-parse --abbrev-ref HEAD`)
    old_upstream = readchomp(ignorestatus(`git config --get remote.upstream.url`))
    try
        old_upstream == "" || run(`git remote rm upstream`)
        run(`git remote add -f upstream https://github.com/JuliaLang/METADATA.jl`)
        sha_upstream = readchomp(`git rev-parse upstream/metadata-v2`)
        startpoint = strip(readchomp(ignorestatus(`git log -1 --format=%B testdeps --`)))
        run(`git checkout upstream/metadata-v2`)
        newtags = cd(Pkg.dir()) do
            Pkg.Read.available()
        end
        urls = Dict{String, String}()
        for pkg in keys(newtags) # need to pre-populate this for newly registered pkg urls
            urls[pkg] = Pkg.Read.url(pkg)
        end
        if startpoint == ""
            run(`git checkout --orphan testdeps`)
        else
            changedfiles = chomp.(readlines(`git diff --name-only $startpoint HEAD`))
            for pkg in keys(newtags)
                anyverschanged = false
                vers = newtags[pkg]
                for ver in keys(vers)
                    if "$pkg/versions/$ver/sha1" in changedfiles
                        anyverschanged = true
                    else
                        delete!(vers, ver)
                    end
                end
                if !anyverschanged
                    delete!(newtags, pkg)
                end
            end
            run(`git checkout testdeps`)
        end
        @showprogress for pkg in keys(newtags)
            url = urls[pkg]
            vers = newtags[pkg]
            filestoadd = [$pkg/url]
            if !isfile("$pkg/url") || readchomp("$pkg/url") != url
                run(`mkdir -p $pkg`)
                open("$pkg/url", "w") do f
                    println(f, url)
                end
            end
            for ver in keys(vers)
                tagsha = vers[ver].sha1
                sha1file = "$pkg/versions/$ver/sha1"
                push!(filestoadd, sha1file)
                if !isfile(sha1file) || readchomp(sha1file) != tagsha
                    run(`mkdir -p $pkg/versions/$ver`)
                    open(sha1file, "w") do f
                        println(f, tagsha)
                    end
                end
            end
            if !ismatch(Pkg.Cache.GITHUB_REGEX, url)
                # non-github package, do the hard way with an actual clone
                run(`git clone -q $url $pkg-tmp`)
                cd("$pkg-tmp") do
                    for ver in keys(vers)
                        tagsha = vers[ver].sha1
                        run(`git checkout -q $tagsha`)
                        reqfile = "$pkg/versions/$ver/requires"
                        hasREQUIRE = isfile("../$reqfile")
                        if isfile("test/REQUIRE")
                            cp("test/REQUIRE", "../$reqfile")
                            if !hasREQUIRE && startpoint == ""
                                println()
                                warn("$pkg v$ver has a test/REQUIRE but no REQUIRE")
                            end
                        elseif hasREQUIRE
                            rm(reqfile)
                        end
                    end
                end
                rm("$pkg-tmp", recursive=true)
                continue
            end
            url = Pkg.Cache.normalize_url(url)
            if endswith(url, ".git")
                url = url[1:end-4]
            end
            @sync for ver in keys(vers)
                tagsha = vers[ver].sha1
                @async begin
                    # check if tagged sha's exist - only github counterexample
                    # so far is ProjectiveDictionaryPairLearning v0.2.2
                    #status = readstring(`curl -s -o /dev/null -I -L -w "%{http_code}" $url/tree/$tagsha`)
                    #if status != "200"
                    #    println()
                    #    warn("Status $status returned for $pkg v$ver at $url/tree/$tagsha")
                    #end
                    reqfile = "$pkg/versions/$ver/requires"
                    hasREQUIRE = isfile(reqfile)
                    status = readstring(`curl -s -o $reqfile -L $url/raw/$tagsha/test/REQUIRE`)
                    if readchomp(reqfile) == "Not Found"
                        rm(reqfile)
                    elseif !hasREQUIRE
                        if startpoint == ""
                            println()
                            warn("$pkg v$ver has a test/REQUIRE but no REQUIRE")
                        end
                        push!(filestoadd, reqfile) # is this safe?
                    end
                end
            end
            for reqfile in filestoadd
                run(`git add $reqfile`)
            end
        end
        isempty(newtags) || run(`git commit -a -m "$sha_upstream"`)
    finally
        run(`git checkout $old_branch`)
        run(`git remote rm upstream`)
        old_upstream == "" || run(`git remote add upstream $old_upstream`)
    end
end
