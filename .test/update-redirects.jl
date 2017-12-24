#!/usr/bin/env julia
# Script to check if registered packages have changed url's

using Requests, URIParser
fix = true && !("--dry-run" in ARGS)
tofix = []
asyncmap(readdir(Pkg.dir("METADATA"))) do pkg
    urlfile = Pkg.dir("METADATA", pkg, "url")
    if isfile(urlfile)
        url = readchomp(urlfile)
        req = get(replace(replace(url, "git://", "https://"),
            ".jl.git", ".jl"); allow_redirects = false)
        if !(endswith(url, "/$pkg.jl.git") #= || endswith(url, "/$pkg.jl") =# )
            warn("Unexpected end of url for $pkg: $url")
        end
        if statuscode(req) == 404
            info("$pkg Not Found")
            push!(tofix, (pkg, urlfile, url, req))
        elseif statuscode(req) == 301
            info("$pkg relocated from $url to $(req.headers["Location"])")
            push!(tofix, (pkg, urlfile, url, req))
        elseif statuscode(req) != 200
            warn("$pkg unexpected status: $req")
        end
    elseif isdir(Pkg.dir("METADATA", pkg)) && pkg != ".test" && pkg != ".git"
        println("No url file for $pkg")
    end
end
if fix
    info("Fixing redirects")
    for (pkg, urlfile, url, req) in tofix
        uri = URI(url)
        if uri.host != "github.com"
            warn("Skipping non-github package at $url")
            continue
        end
        status = statuscode(req)
        if endswith(uri.path, "/$pkg.jl.git")
            if status == 404
                newurl = "$(uri.scheme)://github.com/JuliaPackageMirrors/$pkg.jl.git"
            elseif status == 301
                reluri = URI(req.headers["Location"])
                if reluri.host != "github.com"
                    warn("Skipping non-github redirect at $reluri")
                    continue
                end
                if endswith(reluri.path, "/$pkg.jl")
                    newurl = "$(uri.scheme)://github.com$(reluri.path).git"
                else
                    warn("Not changing $url to $reluri because of unexpected end of new url")
                    continue
                end
            end
            newreq = get(replace(replace(newurl, "git://", "https://"),
                ".jl.git", ".jl"); allow_redirects = false)
            if statuscode(newreq) == 200
                info("Replacing $url with $newurl")
                open(urlfile, "w") do f
                    println(f, newurl)
                end
            else
                warn("Package from $url returned $status but not found at $newurl")
            end
        else
            warn("Not fixing $status from $url because of unexpected end of url")
        end
    end
end
