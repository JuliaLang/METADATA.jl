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
            sha1_file = "METADATA/$pkg/versions/$ver/sha1"
            @assert isfile(sha1_file) "Not a file: $sha1_file"
            sha1fromfile = open(sha1_file) do f
                readchomp(f)
            end
            @assert sha1fromfile == avail.sha1
        end

        #Traverse the 'versions' directory and make sure that we understand its contents
	#The only allowed subdirectories must be semvers and the only allowed
        #files within are 'sha1' and 'requires'
        #
        #Ref: #2040
        verinfodir = "METADATA/$pkg/versions"
        for verdir in readdir(verinfodir)
            if VersionNumber(verdir) in keys(versions)
               for filename in readdir(verinfodir * "/" * verdir)
                   if !(filename=="sha1" || filename=="requires")
                       error("Unknown file $verinfodir/$verdir/$filename encountered. Valid filenames are 'sha1' and 'requires'.")
                   end
               end
            else
                error("v$verdir of $pkg is not configured correctly. Check that METADATA/$pkg/versions/$verdir/sha1 exists.")
            end
        end

        #TODO Replace warnings with assertions below once packages in Issue #2057 have been addressed.
        !endswith(pkg, ".jl") || warn("Package name $pkg should not end in .jl")
        endswith(repo, ".jl") || warn("Repository name $repo does not end in .jl")
        #@assert !endswith(pkg, ".jl") "Package name $pkg should not end in .jl"
        #@assert endswith(repo, ".jl") "Repository name $repo does not end in .jl"
        
        sha1_file = "METADATA/$pkg/versions/$(maxv)/sha1"
        @assert isfile(sha1_file) "File not found: $sha1_file" 
        
    end
end

Pkg.Entry.check_metadata()
