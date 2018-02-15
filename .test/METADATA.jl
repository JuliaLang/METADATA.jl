@static if VERSION < v"0.7.0-DEV.3656"
    const Pkg = Base.Pkg
else
    import Pkg
end

cd(Pkg.dir()) # Required by some Pkg functions

const url_reg = r"^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?"
const gh_path_reg_git=r"^/(.*)?/(.*)?.git$"

const releasejuliaver = v"0.6" # Current release version of Julia
const minjuliaver = v"0.5.0" # Oldest Julia version allowed to be registered
const minpkgver = v"0.0.1"   # Oldest package version allowed to be registered

print_list_3582 = false # set this to true to generate the list of grandfathered
                        # packages permitted under Issue #3582
list_3582 = Any[]
include("list_3582.jl")

# Issue 2064 - check that all listed packages have at least one tagged version
#2064## Uncomment the #2064# code blocks to generate the list of grandfathered
#2064## packages permitted
for pkg in readdir("METADATA")
    startswith(pkg, ".") && continue
    isfile(joinpath("METADATA", pkg)) && continue
    pkg in [
        "AuditoryFilters",
        "CorpusTools",
        "ErrorFreeTransforms",
        "Evapotranspiration",
        "GtkSourceWidget",
        "HiRedis",
        "KyotoCabinet",
        "LatexPrint",
        "MathLink",
        "ObjectiveC",
        "Processing",
        "RaggedArrays",
        "RationalExtensions",
        "SolveBio",
        "SortPerf",
    ] && continue
    if !("versions" in readdir(joinpath("METADATA", pkg)))
        #2064#println("        \"", pkg, "\","); continue
        error("Package $pkg has no tagged versions")
    end
end

# return julia version requirement for pkg, version
# if check is true, throw errors for metadata policy violations
function juliaver_in_require(pkg, version; check=true)
    requires_file = joinpath("METADATA", pkg, "versions", string(version), "requires")
    if !isfile(requires_file)
        if check
            error("File not found: $requires_file")
        else
            return v"0.0.0"
        end
    end
    open(requires_file) do f
        juliaver = v"0.0.0"
        hasjuliaver = false
        for line in eachline(f)
            if startswith(line, "julia")
                tokens = split(line)
                if length(tokens) <= 1
                    if check
                        error("$requires_file: oldest allowed julia version not specified (>= $minjuliaver needed)")
                    end
                else
                    juliaver = max(juliaver, convert(VersionNumber, tokens[2]))
                    hasjuliaver = true
                end
                if check && juliaver < minjuliaver
                    error("$requires_file: oldest allowed julia version $juliaver too old (>= $minjuliaver needed)")
                end
                if check && (juliaver < releasejuliaver && juliaver.patch==0 &&
                        (juliaver.prerelease != () || juliaver.build != ()))
                    # No prereleases older than current release allowed
                    error("$requires_file: prerelease $juliaver not allowed (>= $releasejuliaver needed)")
                end
            end
        end
        if check && !hasjuliaver
            error("$requires_file: no julia entry (>= $minjuliaver needed)")
        end
        return juliaver
    end
end

majmin(x::VersionNumber) = VersionNumber(x.major, x.minor, 0)

for (pkg, versions) in Pkg.Read.available()
    # Issue #2057 - naming convention check
    if endswith(pkg, ".jl")
        error("Package name $pkg should not end in .jl")
    end
    url = Pkg.Read.url(pkg)
    if length(versions) <= 0
        error("Package $pkg has no tagged versions.")
    end
    sortedversions = sort(collect(keys(versions)))
    maxver = sortedversions[end]

    m = match(url_reg, url)
    if m === nothing || length(m.captures) < 5
        error("Invalid url $url for package $pkg. Should satisfy $url_reg")
    end
    host = m.captures[4]
    if host === nothing
        error("Invalid url $url for package $pkg. Cannot extract host")
    end
    path = m.captures[5]
    if path === nothing
        error("Invalid url $url for package $pkg. Cannot extract path")
    end
    scheme = m.captures[2]
    if !(ismatch(r"git", scheme) || ismatch(r"https", scheme))
        error("Invalid url scheme $scheme for package $pkg. Should be 'git' or 'https'")
    end
    if ismatch(r"github\.com", host)
        m2 = match(gh_path_reg_git, path)
        if m2 == nothing
            error("Invalid GitHub url pattern $url for package $pkg. Should satisfy $gh_path_reg_git")
        end
        user = m2.captures[1]
        repo = m2.captures[2]

        # Issue #2057 - naming convention check
        if !endswith(repo, ".jl")
            error("Repository name $repo does not end in .jl")
        end
    end

    for (ver, avail) in versions
        # Check that all sha1 files have the correct version hashes
        sha1_file = joinpath("METADATA", pkg, "versions", string(ver), "sha1")
        if !isfile(sha1_file)
            error("File not found: $sha1_file")
        end
        sha1fromfile = open(readchomp, sha1_file)
        @assert sha1fromfile == avail.sha1

        # Issue #3582 - check that all versions of a package newer than the grandfathered
        # list in list_3582.jl are at least minpkgver and furthermore have a
        # requires file listing a minimum Julia version that is at least minjuliaver
        if print_list_3582 || !haskey(maxver_list_3582, pkg) || (ver > maxver_list_3582[pkg])
            try
                if ver < minpkgver
                    error("$pkg: version $ver no longer allowed (>= $minpkgver needed)")
                end
                # run with check=true for all versions more recent than grandfathered list
                juliaver = juliaver_in_require(pkg, ver; check=true)
                if ver == maxver
                    # check if minimum minor julia version has changed within the same
                    # minor package version (only check this for latest tag, it's okay
                    # for tags in old minor series to have too-high minimum requirements)
                    same_minor(x::VersionNumber) = (majmin(x) == majmin(ver) &&
                        juliaver_in_require(pkg, x; check=false) < juliaver)
                    ind_same_minor = findfirst(same_minor, sortedversions)
                    if ind_same_minor == (VERSION < v"0.7.0-DEV.3399" ? 0 : nothing)
                        continue
                    end
                    first_same_minor = sortedversions[ind_same_minor]
                    juliaver_prev = juliaver_in_require(pkg, first_same_minor; check=false)
                    if majmin(juliaver) > majmin(juliaver_prev)
                        nextminor = VersionNumber(ver.major, ver.minor+1, 0)
                        error("New tag $ver of package $pkg requires julia $juliaver, ",
                            "but version $first_same_minor of $pkg requires julia ",
                            "$juliaver_prev. Use a new minor package version when support ",
                            "for an old version of Julia is dropped. Re-tag the package ",
                            "as $nextminor using `PkgDev.tag(\"$pkg\", :minor)`.")
                    end
                end
            catch err
                if print_list_3582
                    if isempty(list_3582) || list_3582[end][1] != pkg
                        push!(list_3582, (pkg, ver))
                    else
                        maxv = max(list_3582[end][2], ver)
                        list_3582[end] = (pkg, maxv)
                    end
                else
                    rethrow(err)
                end
            end
        end
    end
end
if print_list_3582
    sort!(list_3582, by=first)
    open(joinpath(dirname(@__FILE__), "list_3582.jl"), "w") do f
        println(f, """
# Issue #3582 - check that all versions of a package newer than the
# grandfathered list below are at least minpkgver and furthermore have a
# requires file listing a minimum Julia version that is at least minjuliaver
maxver_list_3582 = Dict([ # List of grandfathered packages""")
        for npkg in 1:length(list_3582)
            pkg, maxv = list_3582[npkg]
            println(f, """    ("$pkg", v"$maxv"),""")
        end
        println(f, "    ])")
    end
end

info("Checking that all entries in METADATA are recognized packages...")

# Scan all entries in METADATA for possibly unrecognized packages
const pkgs = [pkg for (pkg, versions) in Pkg.Read.available()]

for pkg in readdir("METADATA")
    # Traverse the 'versions' directory and make sure that we understand its contents
    # The only allowed subdirectories must be semvers and the only allowed
    # files within are 'sha1' and 'requires'
    #
    # Ref: #2040
    verinfodir = joinpath("METADATA", pkg, "versions")
    isdir(verinfodir) || continue # Some packages are registered but have no tagged versions. See #2064

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

if get(ENV, "PULL_REQUEST", "false") != "false"
    info("Checking repository tags...")
    include("check-pr.jl")
end

info("Verifying METADATA...")
if isdefined(Pkg.Entry, :check_metadata)
    Pkg.Entry.check_metadata()
else
    Pkg.add("PkgDev")
    import PkgDev
    PkgDev.Entry.check_metadata()
end
