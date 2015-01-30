const url_reg = r"^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?"
const gh_path_reg_git=r"^/(.*)?/(.*)?.git$"

for (pkg, versions) in Pkg.Read.available()
    url = (Pkg.Read.url(pkg))
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
        
        @assert endswith(repo, ".jl") "Repository name $repo does not end in .jl"
        
        sha1_file = "METADATA/$pkg/versions/$(maxv)/sha1"
        @assert isfile(sha1_file)
    end
end

Pkg.Entry.check_metadata()
