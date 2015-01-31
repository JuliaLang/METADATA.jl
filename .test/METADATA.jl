const url_reg = r"^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?"
const gh_path_reg_git=r"^/(.*)?/(.*)?.git$"

#We don't have a mechanism for installing packages required for testing
#purposes only when the repo being tested is METADATA
Pkg.installed("Requests")==nothing && Pkg.add("Requests")

using Requests

for (pkg, versions) in Pkg.Read.available()
    url = (Pkg.Read.url(pkg))
    @assert length(versions) > 0 "Package $pkg has no tagged versions."
    maxv = sort([keys(versions)...])[end]
    m=match(url_reg, url)
    @assert  m != null  "Invalid url $url for package $(pkg). Should satisfy $url_reg"
    host=m.captures[4]
    @assert  host!=nothing "Invalid url $url for package $(pkg). Cannot extract host"
    path=m.captures[5]
    @assert path!=nothing "Invalid url $url for package $(pkg). Cannot extract path"
    scheme=m.captures[2]
    @assert ismatch(r"git", scheme) "Invalid url scheme $scheme for package $(pkg). Should be 'git' "
    if ismatch(r"github\.com", host)
        m2 = match(gh_path_reg_git, path)
        @assert m2 != nothing "Invalid GitHub url pattern $url for package $(pkg). Should satisfy $gh_path_reg_git"
        user=m2.captures[1]
        repo=m2.captures[2]

        for (ver, avail) in versions
            #Check that all sha1 files have the correct version hashes
            sha1_file = joinpath("METADATA", pkg, "versions", string(ver), "sha1")
            @assert isfile(sha1_file) "Not a file: $sha1_file"
            sha1fromfile = open(sha1_file) do f
                readchomp(f)
            end
            @assert sha1fromfile == avail.sha1
        end

        #Check naming conventions. Issue #2057
        @assert !endswith(pkg, ".jl") "Package name $pkg should not end in .jl"
        @assert endswith(repo, ".jl") "Repository name $repo does not end in .jl"

        #Check that SHA1 hash exists
        sha1_file = joinpath("METADATA", pkg, "versions", string(maxv), "sha1")
        @assert isfile(sha1_file) "File not found: $sha1_file"

        #Check that requires and REQUIRE are consistent in the most recent tagged
        #version
        maxverreqs = versions[maxv].requires
        sha1 = versions[maxv].sha1
        pathwogit = path[1:end-4]
        require_url = "https://raw.githubusercontent.com$pathwogit/$sha1/REQUIRE"
        packet = get(require_url)
        @assert packet.finished "HTTP request from $require_url did not complete"
        data = if packet.status == 200
                packet.data
            elseif packet.status == 404
                warn("404 Not found: $require_url")
                ""
            end
        currentreqs = Pkg.Reqs.parse(IOBuffer(data))
        #Check explicitly for Julia version tags
        "julia" in keys(currentreqs) || warn("No Julia version tagged in $pkg REQUIRE")
        "julia" in keys(maxverreqs)  || warn("No Julia version tagged in $pkg $maxv requires")
        if maxverreqs != currentreqs
            println("-"^78)
            warn("Inconsistent requirements for $pkg v$maxv:\n")
            println("$pkg $sha1 REQUIRE:\n")
            display(currentreqs)
            println("\n\n\n$pkg $maxv requires:\n")
            display(maxverreqs)
            println("\n", "-"^78)
        end
    end
end

#Scan all entries in METADATA for possibly unrecognized packages
const pkgs = [pkg for (pkg, versions) in Pkg.Read.available()]
for pkg in readdir("METADATA")
    #Traverse the 'versions' directory and make sure that we understand its contents
    #The only allowed subdirectories must be semvers and the only allowed
    #files within are 'sha1' and 'requires'
    #
    #Ref: #2040
    verinfodir = joinpath("METADATA", pkg, "versions")
    isdir(verinfodir) || continue #Some packages are registered but have no tagged versions. See #2064

    for verdir in readdir(verinfodir)
        version = try
            convert(VersionNumber, verdir)
        catch ArgumentError
            error("Invalid version number $verdir found in $verinfodir")
        end

        versions = Pkg.Read.available(pkg)
        if version in keys(versions)
           for filename in readdir(joinpath(verinfodir, verdir))
               if !(filename=="sha1" || filename=="requires")
                   relpath = joinpath(verinfodir, verdir, filename)
                   error("Unknown file $relpath encountered. Valid filenames are 'sha1' and 'requires'.")
               end
           end
        else
            relpath = joinpath("METADATA", pkg, "versions", verdir, "sha1")
            error("Version v$verdir of $pkg is not configured correctly. Check that $relpath exists.")
        end
    end

end

Pkg.Entry.check_metadata()
