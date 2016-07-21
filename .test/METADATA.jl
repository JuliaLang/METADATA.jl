if VERSION < v"0.4-"
    startswith = beginswith
end

const url_reg = r"^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?"
const gh_path_reg_git=r"^/(.*)?/(.*)?.git$"

const releasejuliaver = v"0.4" # Current release version of Julia
const minjuliaver = v"0.3.0" # Oldest Julia version allowed to be registered
const minpkgver = v"0.0.1"   # Oldest package version allowed to be registered

print_list_3582 = false # set this to true to generate the list of grandfathered
                        # packages permitted under Issue #3582
list_3582 = Any[]

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

for (pkg, versions) in Pkg.Read.available()
    url = Pkg.Read.url(pkg)
    if length(versions) <= 0
        error("Package $pkg has no tagged versions.")
    end
    sortedversions = sort(collect(keys(versions)))
    maxv = sortedversions[end]
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

        for (ver, avail) in versions
            # Check that all sha1 files have the correct version hashes
            sha1_file = joinpath("METADATA", pkg, "versions", string(ver), "sha1")
            if !isfile(sha1_file)
                error("Not a file: $sha1_file")
            end
            sha1fromfile = open(readchomp, sha1_file)
            @assert sha1fromfile == avail.sha1
        end

        #Issue #2057 - naming convention check
        if endswith(pkg, ".jl")
            error("Package name $pkg should not end in .jl")
        end
        if !endswith(repo, ".jl")
            error("Repository name $repo does not end in .jl")
        end

        sha1_file = joinpath("METADATA", pkg, "versions", string(maxv), "sha1")
        if !isfile(sha1_file)
            error("File not found: $sha1_file")
        end

        # Issue #3582 - check that newest version of a package is at least minpkgver
        # and furthermore has a requires file listing a minimum Julia version
        # that is at least minjuliaver
        if print_list_3582 || !((pkg, maxv) in ( # List of grandfathered packages
            ("ASCIIPlots", v"0.0.3"),
            ("ActiveAppearanceModels", v"0.1.2"),
            ("AnsiColor", v"0.0.2"),
            ("Arbiter", v"0.0.2"),
            ("Arduino", v"0.1.2"),
            ("Arrowhead", v"0.0.1"),
            ("AudioIO", v"0.1.1"),
            ("Autoreload", v"0.2.0"),
            ("AxisAlgorithms", v"0.1.4"),
            ("BSplines", v"0.0.3"),
            ("BaseTestDeprecated", v"0.1.0"),
            ("Bebop", v"0.0.1"),
            ("Benchmark", v"0.1.0"),
            ("BenchmarkLite", v"0.1.2"),
            ("BioSeq", v"0.4.0"),
            ("Biryani", v"0.2.0"),
            ("Blocks", v"0.1.0"),
            ("BoundingBoxes", v"0.1.0"),
            ("Brownian", v"0.0.1"),
            ("CLBLAS", v"0.1.0"),
            ("CRC32", v"0.0.2"),
            ("CRF", v"0.1.1"),
            ("CUBLAS", v"0.0.2"),
            ("CUDArt", v"0.2.3"),
            ("CUDNN", v"0.3.0"),
            ("CURAND", v"0.0.4"),
            ("Calendar", v"0.4.3"),
            ("Catalan", v"0.0.3"),
            ("CauseMap", v"0.0.3"),
            ("CellularAutomata", v"0.1.2"),
            ("ChainedVectors", v"0.0.0"),
            ("ChaosCommunications", v"0.0.1"),
            ("ChemicalKinetics", v"0.1.0"),
            ("Chipmunk", v"0.0.5"),
            ("Church", v"0.0.1"),
            ("CirruParser", v"0.0.2"),
            ("Clang", v"0.1.0"),
            ("Cliffords", v"0.2.3"),
            ("ClusterManagers", v"0.0.6"),
            ("CommonCrawl", v"0.0.1"),
            ("CompilerOptions", v"0.1.0"),
            ("CompressedSensing", v"0.0.2"),
            ("ConfParser", v"0.0.7"),
            ("ConfidenceWeighted", v"0.0.2"),
            ("ContinuedFractions", v"0.0.0"),
            ("CoreNLP", v"0.1.0"),
            ("CoverageBase", v"0.0.3"),
            ("Cpp", v"0.1.0"),
            ("CrossDecomposition", v"0.0.1"),
            ("Curl", v"0.0.3"),
            ("DASSL", v"0.0.4"),
            ("DCEMRI", v"0.1.2"),
            ("DICOM", v"0.0.1"),
            ("Dates", v"0.4.4"),
            ("Datetime", v"0.1.7"),
            ("DeclarativePackages", v"0.1.2"),
            ("DevIL", v"0.3.0"),
            ("DictFiles", v"0.1.0"),
            ("DictUtils", v"0.0.2"),
            ("DimensionalityReduction", v"0.1.2"),
            ("DirichletProcessMixtures", v"0.0.1"),
            ("DiscreteFactor", v"0.0.0"),
            ("Distance", v"0.5.1"),
            ("Docker", v"0.0.0"),
            ("Dynare", v"0.0.1"),
            ("EEG", v"0.0.3"),
            ("Elliptic", v"0.2.0"),
            ("Etcd", v"0.0.1"),
            ("ExtremelyRandomizedTrees", v"0.1.0"),
            ("FMIndexes", v"0.0.1"),
            ("FTPClient", v"0.1.1"),
            ("Faker", v"0.0.3"),
            ("FastAnonymous", v"0.3.2"),
            ("FastArrayOps", v"0.1.0"),
            ("FileFind", v"0.0.0"),
            ("FinancialMarkets", v"0.1.1"),
            ("FixedEffectModels", v"0.2.2"),
            ("FixedPoint", v"0.0.1"),
            ("Fixtures", v"0.0.2"),
            ("FunctionalData", v"0.1.0"),
            ("FunctionalDataUtils", v"0.1.0"),
            ("FunctionalUtils", v"0.0.0"),
            ("GARCH", v"0.1.2"),
            ("GLPlot", v"0.0.5"),
            ("GLText", v"0.0.4"),
            ("GLUT", v"0.4.0"),
            ("Gaston", v"0.0.0"),
            ("GeneticAlgorithms", v"0.0.3"),
            ("GeometricalPredicates", v"0.0.4"),
            ("GetC", v"1.1.1"),
            ("Gettext", v"0.1.0"),
            ("GibbsSeaWater", v"0.0.4"),
            ("GradientBoost", v"0.0.1"),
            ("Graphics", v"0.1.3"),
            ("GreatCircle", v"0.0.1"),
            ("Grid", v"0.4.0"),
            ("GtkUtilities", v"0.0.9"),
            ("HTTP", v"0.0.2"),
            ("Hadamard", v"0.1.2"),
            ("Helpme", v"0.0.13"),
            ("HexEdit", v"0.0.5"),
            ("Hexagons", v"0.0.4"),
            ("HopfieldNets", v"0.0.0"),
            ("HttpParser", v"0.1.1"),
            ("HttpServer", v"0.1.5"),
            ("Humanize", v"0.4.0"),
            ("Hwloc", v"0.2.0"),
            ("HyperLogLog", v"0.0.0"),
            ("ICU", v"0.4.4"),
            ("IDRsSolver", v"0.1.3"),
            ("IDXParser", v"0.1.0"),
            ("IPPCore", v"0.2.1"),
            ("IPPDSP", v"0.0.1"),
            ("IndexedArrays", v"0.1.0"),
            ("InformedDifferentialEvolution", v"0.1.0"),
            ("InplaceOps", v"0.0.5"),
            ("IntArrays", v"0.0.1"),
            ("Interfaces", v"0.0.4"),
            ("Isotonic", v"0.0.1"),
            ("IterationManagers", v"0.0.1"),
            ("Ito", v"0.0.2"),
            ("JellyFish", v"0.0.1"),
            ("Jewel", v"1.0.8"),
            ("JointMoments", v"0.2.5"),
            ("JudyDicts", v"0.0.0"),
            ("JuliaWebRepl", v"0.0.0"),
            ("JulieTest", v"0.0.2"),
            ("Jumos", v"0.2.1"),
            ("KLDivergence", v"0.0.0"),
            ("KShiftsClustering", v"0.1.0"),
            ("KernSmooth", v"0.0.3"),
            ("LARS", v"0.0.3"),
            ("LIBSVM", v"0.0.1"),
            ("LMDB", v"0.0.4"),
            ("LRUCache", v"0.0.1"),
            ("LaTeX", v"0.1.0"),
            ("LambertW", v"0.0.4"),
            ("LazySequences", v"0.1.0"),
            ("LibGit2", v"0.3.8"),
            ("LibTrading", v"0.0.1"),
            ("LineEdit", v"0.0.1"),
            ("LinguisticData", v"0.0.2"),
            ("Loss", v"0.0.1"),
            ("LowDimNearestNeighbors", v"0.0.1"),
            ("LowRankModels", v"0.1.2"),
            ("Lumira", v"0.0.2"),
            ("MATLABCluster", v"0.0.1"),
            ("MCMC", v"0.3.0"),
            ("MDCT", v"0.0.2"),
            ("MDPs", v"0.1.1"),
            ("MPFI", v"0.0.1"),
            ("MachineLearning", v"0.0.3"),
            ("ManifoldLearning", v"0.1.0"),
            ("MapLight", v"0.0.2"),
            ("Markdown", v"0.3.0"),
            ("MarketData", v"0.3.6"),
            ("MarketTechnicals", v"0.4.1"),
            ("Mathematica", v"0.2.0"),
            ("MessageUtils", v"0.0.2"),
            ("MetaTools", v"0.0.1"),
            ("Millboard", v"0.0.6"),
            ("MinimalPerfectHashes", v"0.1.2"),
            ("MixtureModels", v"0.2.0"),
            ("MolecularDynamics", v"0.1.3"),
            ("Monads", v"0.0.0"),
            ("Mongrel2", v"0.0.0"),
            ("MsgPackRpcClient", v"0.0.0"),
            ("MultiNest", v"0.2.0"),
            ("Multirate", v"0.0.2"),
            ("Munkres", v"0.1.0"),
            ("MutableStrings", v"0.0.0"),
            ("NHST", v"0.0.2"),
            ("NLreg", v"0.1.1"),
            ("NMEA", v"0.0.5"),
            ("NMF", v"0.2.4"),
            ("NURBS", v"0.0.1"),
            ("Named", v"0.0.0"),
            ("NamedDimensions", v"0.0.3"),
            ("Nemo", v"0.4.1"),
            ("Neovim", v"0.0.2"),
            ("NeuralynxNCS", v"0.0.1"),
            ("NumericExtensions", v"0.6.2"),
            ("OCCA", v"0.0.1"),
            ("OSC", v"0.0.1"),
            ("OSXNotifier", v"0.0.1"),
            ("OpenGL", v"2.0.3"),
            ("OpenSSL", v"0.0.0"),
            ("OpenSecrets", v"0.0.1"),
            ("OpenSlide", v"0.0.1"),
            ("OptimPack", v"0.2.0"),
            ("Orchestra", v"0.0.5"),
            ("PEGParser", v"0.1.2"),
            ("PGM", v"0.0.1"),
            ("PLX", v"0.0.5"),
            ("PTools", v"0.0.0"),
            ("PValueAdjust", v"2.0.0"),
            ("Pandas", v"0.2.0"),
            ("Pcap", v"0.0.2"),
            ("Pedigrees", v"0.0.1"),
            ("Permutations", v"0.0.1"),
            ("Phylogenetics", v"0.0.2"),
            ("PicoSAT", v"0.1.0"),
            ("Playground", v"0.0.5"),
            ("Polynomial", v"0.1.1"),
            ("ProjectTemplate", v"0.0.1"),
            ("PropertyGraph", v"0.1.0"),
            ("Push", v"0.0.1"),
            ("PyLexYacc", v"0.0.2"),
            ("PySide", v"0.0.2"),
            ("Quandl", v"0.5.4"),
            ("QuickCheck", v"0.0.0"),
            ("QuickShiftClustering", v"0.1.0"),
            ("RDF", v"0.0.1"),
            ("REPL", v"0.0.2"),
            ("REPLCompletions", v"0.0.3"),
            ("RandomFerns", v"0.1.0"),
            ("RdRand", v"0.0.0"),
            ("React", v"0.1.6"),
            ("Reel", v"0.1.0"),
            ("Reexport", v"0.0.3"),
            ("Requires", v"0.2.2"),
            ("Resampling", v"0.0.0"),
            ("ReverseDiffOverload", v"0.0.1"),
            ("Rif", v"0.0.12"),
            ("RobustStats", v"0.0.1"),
            ("RomanNumerals", v"0.1.0"),
            ("RudeOil", v"0.1.0"),
            ("RunTests", v"0.0.3"),
            ("SDE", v"0.3.1"),
            ("SDL", v"0.1.5"),
            ("SFML", v"0.1.0"),
            ("SVM", v"0.0.1"),
            ("Sampling", v"0.0.8"),
            ("SaveREPL", v"0.0.1"),
            ("ShapeModels", v"0.0.3"),
            ("ShowSet", v"0.0.1"),
            ("SigmoidalProgramming", v"0.0.1"),
            ("Silo", v"0.1.0"),
            ("Sims", v"0.1.0"),
            ("SkyCoords", v"0.1.0"),
            ("SliceSampler", v"0.0.0"),
            ("Slugify", v"0.1.1"),
            ("SmoothingKernels", v"0.0.0"),
            ("Sodium", v"0.0.0"),
            ("Soundex", v"0.0.0"),
            ("Sparklines", v"0.1.0"),
            ("SparseGrids", v"0.1.0"),
            ("SpecialMatrices", v"0.1.3"),
            ("StackedNets", v"0.0.1"),
            ("Stats", v"0.1.0"),
            ("StrPack", v"0.0.1"),
            ("StreamStats", v"0.0.2"),
            ("StructsOfArrays", v"0.0.3"),
            ("SuffixArrays", v"0.0.1"),
            ("Sundials", v"0.2.0"),
            ("SunlightAPIs", v"0.0.3"),
            ("Switch", v"0.0.1"),
            ("Synchrony", v"0.0.1"),
            ("Tau", v"0.0.3"),
            ("TermWin", v"0.0.31"),
            ("Terminals", v"0.0.1"),
            ("TextPlots", v"0.3.0"),
            ("ThingSpeak", v"0.0.2"),
            ("TopicModels", v"0.0.1"),
            ("Trie", v"0.0.0"),
            ("TypeCheck", v"0.0.3"),
            ("Typeclass", v"0.0.1"),
            ("URITemplate", v"0.0.1"),
            ("URLParse", v"0.0.0"),
            ("UTF16", v"0.3.0"),
            ("Units", v"0.2.6"),
            ("VML", v"0.0.1"),
            ("VStatistic", v"1.0.0"),
            ("VennEuler", v"0.0.1"),
            ("VoronoiDelaunay", v"0.0.1"),
            ("Voting", v"0.0.1"),
            ("Wallace", v"0.0.1"),
            ("Watcher", v"0.1.0"),
            ("WaveletMatrices", v"0.1.0"),
            ("Winston", v"0.11.13"),
            ("XClipboard", v"0.0.3"),
            ("XSV", v"0.0.2"),
            ("Yelp", v"0.3.0"),
            ("ZChop", v"0.0.2"),
            ("ZVSimulator", v"0.0.0"),
            ("kNN", v"0.0.0"),
            ))
            try
                if maxv < minpkgver
                    error("$pkg: version $maxv no longer allowed (>= $minpkgver needed)")
                end
                juliaver = juliaver_in_require(pkg, maxv; check=true)
                # check if minimum minor julia version has changed within the same
                # minor package version (requirements below julia 0.3.0- get a pass)
                same_minor = ver->(ver.major==maxv.major && ver.minor==maxv.minor &&
                    v"0.3.0-" <= juliaver_in_require(pkg, ver; check=false) < juliaver)
                ind_same_minor = findfirst(same_minor, sortedversions)
                ind_same_minor == 0 && continue
                first_same_minor = sortedversions[ind_same_minor]
                juliaver_prev = juliaver_in_require(pkg, first_same_minor; check=false)
                if juliaver.major == juliaver_prev.major && juliaver.minor > juliaver_prev.minor
                    nextminor = VersionNumber(maxv.major, maxv.minor+1, 0)
                    error("New tag $maxv of package $pkg requires julia $juliaver, ",
                        "but version $first_same_minor of $pkg requires julia ",
                        "$juliaver_prev. Use a new minor package version when support ",
                        "for an old version of Julia is dropped. Re-tag the package ",
                        "as $nextminor using `Pkg.tag(\"$pkg\", :minor)`.")
                end
            catch err
                if print_list_3582
                    push!(list_3582, (pkg, maxv))
                else
                    rethrow(err)
                end
            end
        end
    end
end
if print_list_3582
    sort!(list_3582, by=first)
    for npkg in 1:length(list_3582)
        pkg, maxv = list_3582[npkg]
        println("""            ("$pkg", v"$maxv"),""")
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

info("Verifying METADATA...")
Pkg.Entry.check_metadata()
