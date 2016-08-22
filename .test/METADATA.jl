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

# Issue #3582 - check that all versions of a package newer than the grandfathered
# list below are at least minpkgver and furthermore have a requires file listing
# a minimum Julia version that is at least minjuliaver
maxver_list_3582 = Dict([ # List of grandfathered packages
            ("ASCIIPlots", v"0.0.3"),
            ("AWS", v"0.1.13"),
            ("AbstractDomains", v"0.0.2"),
            ("ActiveAppearanceModels", v"0.1.2"),
            ("AffineTransforms", v"0.1.3"),
            ("AnsiColor", v"0.0.2"),
            ("AppConf", v"0.0.1"),
            ("AppleAccelerate", v"0.1.0"),
            ("ApproxFun", v"0.0.7"),
            ("Arbiter", v"0.0.2"),
            ("Arduino", v"0.1.2"),
            ("ArgParse", v"0.2.11"),
            ("ArrayViews", v"0.6.3"),
            ("Arrowhead", v"0.0.1"),
            ("Atom", v"0.1.1"),
            ("AudioIO", v"0.1.1"),
            ("AutoHashEquals", v"0.0.10"),
            ("AutoTypeParameters", v"0.0.3"),
            ("Autoreload", v"0.2.0"),
            ("AverageShiftedHistograms", v"0.1.0"),
            ("AxisAlgorithms", v"0.1.4"),
            ("BDF", v"0.1.2"),
            ("BEncode", v"0.1.1"),
            ("BIGUQ", v"0.1.0"),
            ("BSplines", v"0.0.3"),
            ("BackpropNeuralNet", v"0.0.3"),
            ("BaseTestDeprecated", v"0.1.0"),
            ("BayesNets", v"0.1.0"),
            ("BayesianDataFusion", v"0.3.5"),
            ("Bebop", v"0.0.1"),
            ("Benchmark", v"0.1.0"),
            ("BenchmarkLite", v"0.1.2"),
            ("BinDeps", v"0.3.16"),
            ("Bio", v"0.1.0"),
            ("BioSeq", v"0.4.0"),
            ("BiomolecularStructures", v"0.0.1"),
            ("Biryani", v"0.2.0"),
            ("BlackBoxOptim", v"0.1.0"),
            ("Blink", v"0.1.4"),
            ("Blocks", v"0.1.0"),
            ("BloomFilters", v"0.0.1"),
            ("Blosc", v"0.0.6"),
            ("BlossomV", v"0.0.3"),
            ("Bokeh", v"0.0.1"),
            ("Boltzmann", v"0.2.0"),
            ("Bootstrap", v"0.1.1"),
            ("BoundingBoxes", v"0.1.0"),
            ("Brim", v"1.0.0"),
            ("Brownian", v"0.0.1"),
            ("BufferedStreams", v"0.0.2"),
            ("BusinessDays", v"0.0.5"),
            ("CLBLAS", v"0.1.0"),
            ("CLFFT", v"0.1.0"),
            ("CPLEX", v"0.0.9"),
            ("CPUTime", v"0.0.4"),
            ("CRC", v"1.0.0"),
            ("CRC32", v"0.0.2"),
            ("CRF", v"0.1.1"),
            ("CRlibm", v"0.1.0"),
            ("CUBLAS", v"0.0.2"),
            ("CUDA", v"0.1.0"),
            ("CUDArt", v"0.2.3"),
            ("CUDNN", v"0.3.0"),
            ("CUFFT", v"0.0.4"),
            ("CURAND", v"0.0.4"),
            ("CUSOLVER", v"0.0.1"),
            ("CUSPARSE", v"0.3.1"),
            ("Cairo", v"0.2.34"),
            ("Calculus", v"0.1.15"),
            ("Calendar", v"0.4.3"),
            ("Cartesian", v"0.2.3"),
            ("CasaCore", v"0.0.3"),
            ("Catalan", v"0.0.3"),
            ("CauseMap", v"0.0.3"),
            ("Cbc", v"0.0.8"),
            ("CellularAutomata", v"0.1.2"),
            ("ChainedVectors", v"0.0.0"),
            ("ChaosCommunications", v"0.0.1"),
            ("ChemicalKinetics", v"0.1.0"),
            ("Chipmunk", v"0.0.5"),
            ("Church", v"0.0.1"),
            ("CirruParser", v"0.0.2"),
            ("Clang", v"0.1.0"),
            ("Cliffords", v"0.2.3"),
            ("Clp", v"0.0.9"),
            ("ClusterManagers", v"0.0.5"),
            ("Clustering", v"0.4.0"),
            ("CodeTools", v"0.1.0"),
            ("Codecs", v"0.1.4"),
            ("Color", v"0.4.5"),
            ("ColorBrewer", v"0.2.0"),
            ("ColorTypes", v"0.0.1"),
            ("Combinatorics", v"0.0.1"),
            ("CommonCrawl", v"0.0.1"),
            ("Compat", v"0.7.5"),
            ("CompilerOptions", v"0.1.0"),
            ("Compose", v"0.3.13"),
            ("CompressedSensing", v"0.0.2"),
            ("ConfParser", v"0.0.7"),
            ("ConfidenceWeighted", v"0.0.2"),
            ("ConnectSDK", v"0.1.5"),
            ("ContinuedFractions", v"0.0.0"),
            ("Contour", v"0.0.8"),
            ("CoreNLP", v"0.1.0"),
            ("Cosmology", v"0.1.4"),
            ("CovarianceMatrices", v"0.0.1"),
            ("Coverage", v"0.2.3"),
            ("CoverageBase", v"0.0.3"),
            ("Cpp", v"0.1.0"),
            ("CrossDecomposition", v"0.0.1"),
            ("Cubature", v"1.0.5"),
            ("Curl", v"0.0.3"),
            ("CurveFit", v"0.0.1"),
            ("DASSL", v"0.0.4"),
            ("DCEMRI", v"0.1.2"),
            ("DICOM", v"0.0.1"),
            ("DReal", v"0.0.2"),
            ("DSGE", v"0.1.1"),
            ("DSP", v"0.0.9"),
            ("DWARF", v"0.0.3"),
            ("DataArrays", v"0.2.16"),
            ("DataFrames", v"0.6.0"),
            ("DataFramesMeta", v"0.1.0"),
            ("DataStructures", v"0.3.9"),
            ("Dates", v"0.4.4"),
            ("Datetime", v"0.1.7"),
            ("Debug", v"0.1.4"),
            ("DecFP", v"0.1.1"),
            ("DecisionTree", v"0.3.9"),
            ("DeclarativePackages", v"0.1.2"),
            ("DevIL", v"0.3.0"),
            ("Devectorize", v"0.4.0"),
            ("DictFiles", v"0.1.0"),
            ("DictUtils", v"0.0.2"),
            ("Dierckx", v"0.1.4"),
            ("Digits", v"0.1.2"),
            ("DimensionalityReduction", v"0.1.2"),
            ("DirichletProcessMixtures", v"0.0.1"),
            ("DiscreteFactor", v"0.0.0"),
            ("Discretizers", v"0.0.1"),
            ("Distance", v"0.5.1"),
            ("Distances", v"0.2.0"),
            ("DistributedArrays", v"0.1.5"),
            ("Distributions", v"0.6.3"),
            ("Diversity", v"0.2.8"),
            ("DocOpt", v"0.0.3"),
            ("Docile", v"0.1.0"),
            ("Docker", v"0.0.1"),
            ("DoubleDouble", v"0.1.0"),
            ("Drawing", v"0.1.4"),
            ("DualNumbers", v"0.1.3"),
            ("Dynare", v"0.0.1"),
            ("ECOS", v"0.3.0"),
            ("ELF", v"0.0.3"),
            ("ERFA", v"0.1.2"),
            ("EcologicalNetwork", v"1.0.1"),
            ("EconDatasets", v"0.0.1"),
            ("ElasticFDA", v"0.0.5"),
            ("Elliptic", v"0.2.0"),
            ("Elly", v"0.0.4"),
            ("Equations", v"0.1.0"),
            ("Escher", v"0.0.3"),
            ("Etcd", v"0.0.1"),
            ("Example", v"0.3.3"),
            ("ExcelReaders", v"0.2.0"),
            ("Expect", v"0.1.1"),
            ("ExpressionUtils", v"0.0.0"),
            ("ExtremelyRandomizedTrees", v"0.1.0"),
            ("FITSIO", v"0.5.2"),
            ("FLANN", v"0.0.3"),
            ("FMIndexes", v"0.0.1"),
            ("FTPClient", v"0.1.1"),
            ("FaceDatasets", v"0.1.4"),
            ("FactCheck", v"0.1.2"),
            ("FactorModels", v"0.0.2"),
            ("Faker", v"0.0.3"),
            ("FastAnonymous", v"0.3.2"),
            ("FastArrayOps", v"0.1.0"),
            ("FastaIO", v"0.1.5"),
            ("FileFind", v"0.0.0"),
            ("FinancialMarkets", v"0.1.1"),
            ("FiniteStateMachine", v"0.1.0"),
            ("FixedEffectModels", v"0.2.2"),
            ("FixedPoint", v"0.0.1"),
            ("FixedPointNumbers", v"0.0.8"),
            ("FixedSizeArrays", v"0.0.7"),
            ("Fixtures", v"0.0.2"),
            ("Fontconfig", v"0.0.2"),
            ("Formatting", v"0.1.5"),
            ("ForwardDiff", v"0.1.2"),
            ("FreeType", v"1.0.1"),
            ("FunctionalCollections", v"0.1.3"),
            ("FunctionalData", v"0.1.0"),
            ("FunctionalDataUtils", v"0.1.0"),
            ("FunctionalUtils", v"0.0.0"),
            ("GARCH", v"0.1.2"),
            ("GLAbstraction", v"0.0.6"),
            ("GLFW", v"1.0.0-alpha.3"),
            ("GLM", v"0.4.6"),
            ("GLMNet", v"0.0.5"),
            ("GLPK", v"0.2.16"),
            ("GLPKMathProgInterface", v"0.1.14"),
            ("GLPlot", v"0.0.5"),
            ("GLText", v"0.0.4"),
            ("GLUT", v"0.4.0"),
            ("GLVisualize", v"0.0.2"),
            ("GLWindow", v"0.0.6"),
            ("GR", v"0.9.8"),
            ("GSL", v"0.2.0"),
            ("GZip", v"0.2.20"),
            ("Gadfly", v"0.3.13"),
            ("Gaston", v"0.0.0"),
            ("GaussianMixtures", v"0.0.8"),
            ("GaussianProcesses", v"0.1.2"),
            ("GeneticAlgorithms", v"0.0.3"),
            ("GeoIP", v"0.2.2"),
            ("GeoStats", v"0.0.2"),
            ("GeoStatsImages", v"0.0.2"),
            ("GeometricalPredicates", v"0.0.5"),
            ("GeometryTypes", v"0.0.3"),
            ("GetC", v"1.1.1"),
            ("Gettext", v"0.1.0"),
            ("GibbsSeaWater", v"0.0.4"),
            ("GitHub", v"0.0.6"),
            ("Glob", v"1.0.2"),
            ("GnuTLS", v"0.0.5"),
            ("GoogleCharts", v"0.0.7"),
            ("GradientBoost", v"0.0.1"),
            ("GraphLayout", v"0.2.0"),
            ("GraphViz", v"0.0.4"),
            ("Graphics", v"0.1.3"),
            ("Graphs", v"0.4.3"),
            ("GreatCircle", v"0.0.1"),
            ("Grid", v"0.4.0"),
            ("Gtk", v"0.9.3"),
            ("GtkUtilities", v"0.0.7"),
            ("Gumbo", v"0.1.0"),
            ("Gurobi", v"0.1.19"),
            ("HDF5", v"0.4.9"),
            ("HDFS", v"0.0.0"),
            ("HTTP", v"0.0.2"),
            ("HTTPClient", v"0.1.6"),
            ("Hadamard", v"0.1.2"),
            ("Helpme", v"0.0.13"),
            ("HexEdit", v"0.0.5"),
            ("Hexagons", v"0.0.4"),
            ("Hiccup", v"0.0.3"),
            ("Homebrew", v"0.1.14"),
            ("HopfieldNets", v"0.0.0"),
            ("HttpCommon", v"0.2.5"),
            ("HttpParser", v"0.1.1"),
            ("HttpServer", v"0.1.5"),
            ("Humanize", v"0.4.0"),
            ("Hwloc", v"0.3.0"),
            ("HyperDualNumbers", v"0.1.7"),
            ("HyperLogLog", v"0.0.0"),
            ("HypothesisTests", v"0.2.9"),
            ("ICU", v"0.4.4"),
            ("IDRsSolver", v"0.1.3"),
            ("IDXParser", v"0.1.0"),
            ("IJulia", v"0.2.2"),
            ("IPNets", v"0.1.0"),
            ("IPPCore", v"0.2.1"),
            ("IPPDSP", v"0.0.1"),
            ("IProfile", v"0.3.1"),
            ("ImageQuilting", v"0.2.3"),
            ("ImageView", v"0.1.12"),
            ("Images", v"0.4.37"),
            ("Immerse", v"0.0.8"),
            ("ImmutableArrays", v"0.0.12"),
            ("ImplicitEquations", v"0.0.1"),
            ("IndexableBitVectors", v"0.1.0"),
            ("IndexedArrays", v"0.1.0"),
            ("InformedDifferentialEvolution", v"0.1.0"),
            ("IniFile", v"0.2.5"),
            ("InplaceOps", v"0.0.5"),
            ("Instruments", v"0.0.1"),
            ("IntArrays", v"0.0.1"),
            ("IntModN", v"0.0.1"),
            ("Interact", v"0.1.6"),
            ("InterestRates", v"0.0.2"),
            ("Interfaces", v"0.0.4"),
            ("Interpolations", v"0.3.3"),
            ("IntervalTrees", v"0.0.4"),
            ("Ipopt", v"0.1.4"),
            ("Isotonic", v"0.0.1"),
            ("IterationManagers", v"0.0.1"),
            ("IterativeSolvers", v"0.2.1"),
            ("Iterators", v"0.1.10"),
            ("Ito", v"0.0.2"),
            ("JFVM", v"0.0.1"),
            ("JLDArchives", v"0.0.6"),
            ("JPLEphemeris", v"0.2.1"),
            ("JSON", v"0.4.0"),
            ("JWAS", v"0.0.2"),
            ("Jacobi", v"0.1.0"),
            ("Jags", v"0.0.3"),
            ("JavaCall", v"0.2.2"),
            ("JellyFish", v"0.0.1"),
            ("Jewel", v"1.0.8"),
            ("JointMoments", v"0.2.5"),
            ("JuMP", v"0.5.8"),
            ("JudyDicts", v"0.0.0"),
            ("JuliaFEM", v"0.0.1"),
            ("JuliaParser", v"0.6.3"),
            ("JuliaWebRepl", v"0.0.0"),
            ("JulieTest", v"0.0.2"),
            ("Jumos", v"0.2.1"),
            ("KDTrees", v"0.5.2"),
            ("KLDivergence", v"0.0.0"),
            ("KShiftsClustering", v"0.1.0"),
            ("KernSmooth", v"0.0.3"),
            ("KernelDensity", v"0.1.1"),
            ("KernelEstimator", v"0.1.3"),
            ("LARS", v"0.0.3"),
            ("LIBSVM", v"0.0.1"),
            ("LMDB", v"0.0.4"),
            ("LNR", v"0.0.2"),
            ("LRUCache", v"0.0.1"),
            ("LaTeX", v"0.1.0"),
            ("LaTeXStrings", v"0.1.2"),
            ("LambertW", v"0.0.4"),
            ("Languages", v"0.0.5"),
            ("Lazy", v"0.9.0"),
            ("LazySequences", v"0.1.0"),
            ("LeastSquaresOptim", v"0.0.1"),
            ("Lens", v"0.0.2"),
            ("LevelDB", v"1.0.1"),
            ("LibBSON", v"0.1.5"),
            ("LibCURL", v"0.1.6"),
            ("LibExpat", v"0.0.5"),
            ("LibGEOS", v"0.0.4"),
            ("LibGit2", v"0.3.8"),
            ("LibHealpix", v"0.0.1"),
            ("LibTrading", v"0.0.1"),
            ("Libz", v"0.0.2"),
            ("LightXML", v"0.1.11"),
            ("LineEdit", v"0.0.1"),
            ("LinearLeastSquares", v"0.0.4"),
            ("LinearMaps", v"0.1.1"),
            ("LinguisticData", v"0.0.2"),
            ("Lint", v"0.1.69"),
            ("Loess", v"0.0.7"),
            ("LogParser", v"0.2.0"),
            ("Logging", v"0.0.5"),
            ("Lora", v"0.5.0"),
            ("Loss", v"0.0.1"),
            ("LowDimNearestNeighbors", v"0.0.1"),
            ("LowRankModels", v"0.1.2"),
            ("LsqFit", v"0.0.2"),
            ("Lumberjack", v"0.0.4"),
            ("Lumira", v"0.0.2"),
            ("MAT", v"0.2.14"),
            ("MATLAB", v"0.1.2"),
            ("MATLABCluster", v"0.0.1"),
            ("MCMC", v"0.3.0"),
            ("MDCT", v"0.0.2"),
            ("MDPs", v"0.1.1"),
            ("MFCC", v"0.0.1"),
            ("MIToS", v"0.1.0"),
            ("MLBase", v"0.5.1"),
            ("MLKernels", v"0.0.1"),
            ("MNIST", v"0.0.2"),
            ("MPFI", v"0.0.1"),
            ("MPI", v"0.3.2"),
            ("MachineLearning", v"0.0.3"),
            ("MacroTools", v"0.1.0"),
            ("Mads", v"0.1.0"),
            ("Mamba", v"0.6.3"),
            ("ManifoldLearning", v"0.1.0"),
            ("MapLight", v"0.0.2"),
            ("Markdown", v"0.3.0"),
            ("MarketData", v"0.3.6"),
            ("MarketTechnicals", v"0.4.1"),
            ("Match", v"0.0.5"),
            ("MathProgBase", v"0.3.1"),
            ("Mathematica", v"0.2.0"),
            ("MatlabCompat", v"0.0.1"),
            ("MatrixDepot", v"0.2.7"),
            ("MatrixMarket", v"0.0.1"),
            ("MbedTLS", v"0.2.0"),
            ("MeCab", v"0.1.7"),
            ("Meddle", v"0.0.6"),
            ("Media", v"0.1.1"),
            ("MelGeneralizedCepstrums", v"0.0.1"),
            ("Memcache", v"0.0.2"),
            ("Memoize", v"0.0.1"),
            ("MeshIO", v"0.0.2"),
            ("Meshes", v"0.0.4"),
            ("Meshing", v"0.0.0"),
            ("MessageUtils", v"0.0.2"),
            ("MetaTools", v"0.0.1"),
            ("Metis", v"0.0.10"),
            ("Millboard", v"0.0.6"),
            ("MinimalPerfectHashes", v"0.1.2"),
            ("MixedModels", v"0.4.0"),
            ("MixtureModels", v"0.2.0"),
            ("Mocha", v"0.0.8"),
            ("Mocking", v"0.0.1"),
            ("ModernGL", v"0.0.8"),
            ("MolecularDynamics", v"0.1.3"),
            ("Monads", v"0.0.0"),
            ("Mongo", v"0.1.4"),
            ("Mongrel2", v"0.0.0"),
            ("Morsel", v"0.0.6"),
            ("Mosek", v"0.1.3"),
            ("MsgPack", v"0.0.5"),
            ("MsgPackRpcClient", v"0.0.0"),
            ("MultiNest", v"0.2.0"),
            ("MultiPoly", v"0.0.1"),
            ("Multirate", v"0.0.2"),
            ("MultivariateStats", v"0.1.3"),
            ("Munkres", v"0.1.0"),
            ("Murmur3", v"0.1.0"),
            ("Mustache", v"0.0.15"),
            ("MutableStrings", v"0.0.0"),
            ("Mux", v"0.0.0"),
            ("NFFT", v"0.0.2"),
            ("NHST", v"0.0.2"),
            ("NIDAQ", v"0.0.2"),
            ("NIfTI", v"0.0.4"),
            ("NLopt", v"0.2.0"),
            ("NLreg", v"0.1.1"),
            ("NLsolve", v"0.3.3"),
            ("NMEA", v"0.0.5"),
            ("NMF", v"0.2.4"),
            ("NPZ", v"0.0.1"),
            ("NURBS", v"0.0.1"),
            ("NaiveBayes", v"0.1.0"),
            ("Named", v"0.0.0"),
            ("NamedArrays", v"0.4.4"),
            ("NamedDimensions", v"0.0.3"),
            ("NamedTuples", v"0.0.3"),
            ("Nemo", v"0.4.1"),
            ("Neovim", v"0.0.2"),
            ("NetCDF", v"0.2.1"),
            ("Nettle", v"0.1.7"),
            ("NeuralynxNCS", v"0.0.1"),
            ("NullableArrays", v"0.0.2"),
            ("NumericExtensions", v"0.6.2"),
            ("NumericFuns", v"0.2.3"),
            ("OAuth", v"0.3.0"),
            ("OCCA", v"0.0.1"),
            ("ODBC", v"0.3.10"),
            ("ODE", v"0.2.1"),
            ("OEIS", v"0.0.2"),
            ("OIFITS", v"0.1.0"),
            ("OSC", v"0.0.1"),
            ("OSXNotifier", v"0.0.1"),
            ("OnlineStats", v"0.3.0"),
            ("OpenCL", v"0.3.3"),
            ("OpenGL", v"2.0.3"),
            ("OpenSSL", v"0.0.0"),
            ("OpenSecrets", v"0.0.1"),
            ("OpenSlide", v"0.0.1"),
            ("OpenStreetMap", v"0.7.0"),
            ("Optim", v"0.4.2"),
            ("OptimPack", v"0.2.0"),
            ("Options", v"0.2.6"),
            ("Orchestra", v"0.0.5"),
            ("PAINTER", v"0.1.2"),
            ("PDMats", v"0.3.4"),
            ("PEGParser", v"0.1.2"),
            ("PGFPlots", v"1.2.2"),
            ("PGM", v"0.0.1"),
            ("PLX", v"0.0.5"),
            ("PTools", v"0.0.0"),
            ("PValueAdjust", v"2.0.0"),
            ("Packing", v"0.0.4"),
            ("PairwiseListMatrices", v"0.1.1"),
            ("Pandas", v"0.2.0"),
            ("ParallelSparseMatMul", v"0.0.1"),
            ("Pardiso", v"0.0.2"),
            ("ParserCombinator", v"0.0.1"),
            ("Patchwork", v"0.1.5"),
            ("PatternDispatch", v"0.0.2"),
            ("Pcap", v"0.0.2"),
            ("Pedigrees", v"0.0.1"),
            ("Permutations", v"0.0.1"),
            ("Phylogenetics", v"0.0.2"),
            ("PicoSAT", v"0.1.0"),
            ("PiecewiseIncreasingRanges", v"0.0.4"),
            ("Pipe", v"0.0.3"),
            ("Playground", v"0.0.4"),
            ("Plotly", v"0.0.3"),
            ("Plots", v"0.3.0"),
            ("PolarFact", v"0.0.5"),
            ("Polynomial", v"0.1.1"),
            ("Polynomials", v"0.0.6"),
            ("PowerSeries", v"0.1.14"),
            ("ProfileView", v"0.1.1"),
            ("ProgressMeter", v"0.2.1"),
            ("ProjectTemplate", v"0.0.1"),
            ("ProjectiveDictionaryPairLearning", v"0.3.4"),
            ("PropertyGraph", v"0.1.0"),
            ("ProtoBuf", v"0.0.7"),
            ("PublicSuffix", v"0.0.2"),
            ("Push", v"0.0.1"),
            ("PyCall", v"0.7.3"),
            ("PyLexYacc", v"0.0.2"),
            ("PyPlot", v"1.5.1"),
            ("PySide", v"0.0.2"),
            ("Quandl", v"0.5.4"),
            ("QuantEcon", v"0.1.1"),
            ("QuantumLab", v"0.0.1"),
            ("Quaternions", v"0.0.4"),
            ("QuickCheck", v"0.0.0"),
            ("QuickShiftClustering", v"0.1.0"),
            ("RCall", v"0.2.1"),
            ("RDF", v"0.0.1"),
            ("RDatasets", v"0.1.3"),
            ("REPL", v"0.0.2"),
            ("REPLCompletions", v"0.0.3"),
            ("RLEVectors", v"0.1.0"),
            ("RNGTest", v"0.0.3"),
            ("Rainflow", v"0.0.1"),
            ("RandomFerns", v"0.1.0"),
            ("RandomMatrices", v"0.0.2"),
            ("Ratios", v"0.0.4"),
            ("RdRand", v"0.0.0"),
            ("React", v"0.1.6"),
            ("Reactive", v"0.2.2"),
            ("Redis", v"0.0.1"),
            ("Reel", v"0.1.0"),
            ("Reexport", v"0.0.3"),
            ("RegERMs", v"0.0.2"),
            ("Regression", v"0.0.0"),
            ("Requests", v"0.3.3"),
            ("Requires", v"0.1.3"),
            ("Resampling", v"0.0.0"),
            ("ReverseDiffOverload", v"0.0.1"),
            ("ReverseDiffSource", v"0.1.3"),
            ("ReverseDiffSparse", v"0.1.2"),
            ("Rif", v"0.0.12"),
            ("Rmath", v"0.0.0"),
            ("RobotOS", v"0.1.0"),
            ("RobustShortestPath", v"0.2.2"),
            ("RobustStats", v"0.0.1"),
            ("RomanNumerals", v"0.1.0"),
            ("Roots", v"0.1.8"),
            ("RudeOil", v"0.1.0"),
            ("RunTests", v"0.0.3"),
            ("SALSA", v"0.0.1"),
            ("SCS", v"0.1.1"),
            ("SDE", v"0.3.1"),
            ("SDL", v"0.1.5"),
            ("SFML", v"0.1.0"),
            ("SHA", v"0.1.0"),
            ("SIUnits", v"0.0.6"),
            ("SMTPClient", v"0.0.0"),
            ("SQLite", v"0.1.6"),
            ("SVM", v"0.0.1"),
            ("SVMLightLoader", v"0.2.0"),
            ("Sampling", v"0.0.8"),
            ("SaveREPL", v"0.0.1"),
            ("Seismic", v"0.0.1"),
            ("SemidefiniteProgramming", v"0.1.0"),
            ("SerialPorts", v"0.0.7"),
            ("Shannon", v"0.2.4"),
            ("ShapeModels", v"0.0.3"),
            ("Shapefile", v"0.0.3"),
            ("ShowSet", v"0.0.1"),
            ("Showoff", v"0.0.4"),
            ("SigmoidalProgramming", v"0.0.1"),
            ("Silo", v"0.1.0"),
            ("SimJulia", v"0.2.0"),
            ("Sims", v"0.1.0"),
            ("SkyCoords", v"0.1.0"),
            ("SliceSampler", v"0.0.0"),
            ("Slugify", v"0.1.1"),
            ("Smile", v"0.1.3"),
            ("SmoothingKernels", v"0.0.0"),
            ("Snappy", v"0.0.1"),
            ("Sobol", v"0.1.3"),
            ("Sodium", v"0.0.0"),
            ("SoftConfidenceWeighted", v"0.1.2"),
            ("SortingAlgorithms", v"0.0.2"),
            ("Soundex", v"0.0.0"),
            ("Sparklines", v"0.1.2"),
            ("SparseGrids", v"0.1.0"),
            ("SpecialMatrices", v"0.1.3"),
            ("StackedNets", v"0.0.1"),
            ("Stan", v"0.3.1"),
            ("Stats", v"0.1.0"),
            ("StatsBase", v"0.7.0"),
            ("StatsdClient", v"0.0.1"),
            ("StochasticSearch", v"0.2.0"),
            ("StrPack", v"0.0.1"),
            ("StreamStats", v"0.0.2"),
            ("StructsOfArrays", v"0.0.3"),
            ("SuffixArrays", v"0.0.1"),
            ("Sundials", v"0.2.0"),
            ("SunlightAPIs", v"0.0.3"),
            ("Switch", v"0.0.1"),
            ("SymPy", v"0.2.20"),
            ("Synchrony", v"0.0.1"),
            ("SynthesisFilters", v"0.0.1"),
            ("TOML", v"0.2.0"),
            ("Taro", v"0.2.0"),
            ("Tau", v"0.0.3"),
            ("TaylorSeries", v"0.0.1"),
            ("TensorOperations", v"0.3.1"),
            ("TermWin", v"0.0.31"),
            ("TerminalExtensions", v"0.0.3"),
            ("Terminals", v"0.0.1"),
            ("TestImages", v"0.0.8"),
            ("TexExtensions", v"0.0.3"),
            ("TextAnalysis", v"0.0.5"),
            ("TextPlots", v"0.3.0"),
            ("TextWrap", v"0.1.6"),
            ("ThermodynamicsTable", v"0.0.4"),
            ("ThingSpeak", v"0.0.2"),
            ("Thrift", v"0.0.6"),
            ("TikzGraphs", v"0.0.1"),
            ("TikzPictures", v"0.2.1"),
            ("TimeData", v"0.6.0"),
            ("TimeModels", v"0.0.3"),
            ("TimeSeries", v"0.7.4"),
            ("TimeZones", v"0.1.0"),
            ("Timestamps", v"0.0.2"),
            ("Tk", v"0.2.17"),
            ("TopicModels", v"0.0.1"),
            ("TrafficAssignment", v"0.2.1"),
            ("Trie", v"0.0.0"),
            ("Twitter", v"0.2.2"),
            ("TypeCheck", v"0.0.3"),
            ("Typeclass", v"0.0.1"),
            ("UAParser", v"0.3.0"),
            ("URIParser", v"0.1.1"),
            ("URITemplate", v"0.0.1"),
            ("URLParse", v"0.0.0"),
            ("UTF16", v"0.3.0"),
            ("UUID", v"0.0.4"),
            ("Units", v"0.2.6"),
            ("VML", v"0.0.1"),
            ("VStatistic", v"1.0.0"),
            ("ValidatedNumerics", v"0.0.3"),
            ("ValueDispatch", v"0.0.1"),
            ("Vega", v"0.3.1"),
            ("VennEuler", v"0.0.1"),
            ("VideoIO", v"0.0.13"),
            ("VoronoiDelaunay", v"0.0.3"),
            ("Voting", v"0.0.1"),
            ("WAV", v"0.5.0"),
            ("WCSLIB", v"0.1.5"),
            ("WORLD", v"0.0.3"),
            ("Wallace", v"0.0.1"),
            ("Watcher", v"0.1.0"),
            ("WaveletMatrices", v"0.1.0"),
            ("Wavelets", v"0.3.0"),
            ("Weave", v"0.0.3"),
            ("WebSockets", v"0.0.6"),
            ("WinRPM", v"0.1.6"),
            ("Winston", v"0.11.13"),
            ("WoodburyMatrices", v"0.1.1"),
            ("WorldBankData", v"0.0.5"),
            ("WriteVTK", v"0.3.0"),
            ("XClipboard", v"0.0.3"),
            ("XGBoost", v"0.1.0"),
            ("XSV", v"0.0.2"),
            ("XSim", v"0.0.2"),
            ("YAML", v"0.1.10"),
            ("YT", v"0.2.0"),
            ("Yelp", v"0.3.0"),
            ("Yeppp", v"0.0.10"),
            ("ZChop", v"0.0.2"),
            ("ZMQ", v"0.1.20"),
            ("ZVSimulator", v"0.0.0"),
            ("ZipFile", v"0.2.6"),
            ("Zlib", v"0.1.12"),
            ("kNN", v"0.0.0"),
            ])

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
        # list below are at least minpkgver and furthermore have a requires file listing
        # a minimum Julia version that is at least minjuliaver
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
                    majmin(x::VersionNumber) = VersionNumber(x.major, x.minor, 0)
                    same_minor(x::VersionNumber) = (majmin(x) == majmin(ver) &&
                        juliaver_in_require(pkg, x; check=false) < juliaver)
                    ind_same_minor = findfirst(same_minor, sortedversions)
                    ind_same_minor == 0 && continue
                    first_same_minor = sortedversions[ind_same_minor]
                    juliaver_prev = juliaver_in_require(pkg, first_same_minor; check=false)
                    if majmin(juliaver) > majmin(juliaver_prev)
                        nextminor = VersionNumber(ver.major, ver.minor+1, 0)
                        error("New tag $ver of package $pkg requires julia $juliaver, ",
                            "but version $first_same_minor of $pkg requires julia ",
                            "$juliaver_prev. Use a new minor package version when support ",
                            "for an old version of Julia is dropped. Re-tag the package ",
                            "as $nextminor using `Pkg.tag(\"$pkg\", :minor)`.")
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
if isdefined(Pkg.Entry, :check_metadata)
    Pkg.Entry.check_metadata()
else
    Pkg.add("PkgDev")
    import PkgDev
    PkgDev.Entry.check_metadata()
end
