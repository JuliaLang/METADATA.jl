const url_reg = r"^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?"
const gh_path_reg_git=r"^/(.*)?/(.*)?.git$"

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

        #Issue #2057 - naming convention check
        @assert !endswith(pkg, ".jl") "Package name $pkg should not end in .jl"
        @assert endswith(repo, ".jl") "Repository name $repo does not end in .jl"

        sha1_file = joinpath("METADATA", pkg, "versions", string(maxv), "sha1")
        @assert isfile(sha1_file) "File not found: $sha1_file"

    end
end

println("Checking that all entries in METADATA are recognized packages...")
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

println("Verifying METADATA...")
@time Pkg.Entry.check_metadata()
