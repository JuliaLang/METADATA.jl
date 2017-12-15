# Issue #3582 - check that all versions of a package newer than the
# grandfathered list below are at least minpkgver and furthermore have a
# requires file listing a minimum Julia version that is at least minjuliaver
maxver_list_3582 = Dict([ # List of grandfathered packages
    ("ACME", v"0.5.0"),
    ("AMD", v"0.1.0"),
    ("ASCIIPlots", v"0.0.3"),
    ("ASTInterpreter", v"0.0.4"),
    ("AWS", v"0.2.0"),
    ("AWSCore", v"0.0.17"),
    ("AWSEC2", v"0.0.7"),
    ("AWSIAM", v"0.0.5"),
    ("AWSLambda", v"0.0.17"),
    ("AWSS3", v"0.0.9"),
    ("AWSSDB", v"0.0.3"),
    ("AWSSES", v"0.0.1"),
    ("AWSSNS", v"0.0.7"),
    ("AWSSQS", v"0.0.5"),
    ("AbstractDomains", v"0.1.0"),
    ("AbstractFFTs", v"0.1.0"),
    ("AbstractTrees", v"0.0.4"),
    ("Accumulo", v"0.0.1"),
    ("ActiveAppearanceModels", v"0.1.2"),
    ("Actors", v"0.0.1"),
    ("AffineInvariantMCMC", v"0.1.4"),
    ("AffineTransforms", v"0.1.5"),
    ("AmplNLReader", v"0.1.0"),
    ("AmplNLWriter", v"0.2.3"),
    ("Anasol", v"0.1.11"),
    ("AndorSIF", v"0.0.3"),
    ("AnsiColor", v"0.0.2"),
    ("AppConf", v"0.1.1"),
    ("AppleAccelerate", v"0.2.1"),
    ("ApproxFun", v"0.4.1"),
    ("ArbFloats", v"0.1.8"),
    ("Arbiter", v"0.0.2"),
    ("ArcadeLearningEnvironment", v"0.0.1"),
    ("Arduino", v"0.1.2"),
    ("ArgParse", v"0.4.0"),
    ("ArrayFire", v"0.0.4"),
    ("ArrayViews", v"0.6.4"),
    ("Arrowhead", v"0.0.1"),
    ("AstroLib", v"0.1.0"),
    ("Atom", v"0.6.5"),
    ("AudioIO", v"0.1.1"),
    ("Augur", v"0.1.1"),
    ("AutoGrad", v"0.0.10"),
    ("AutoHashEquals", v"0.0.10"),
    ("AutoTypeParameters", v"0.0.3"),
    ("Autoreload", v"0.2.0"),
    ("AverageShiftedHistograms", v"0.5.2"),
    ("AxisAlgorithms", v"0.1.6"),
    ("BARON", v"0.1.2"),
    ("BDF", v"0.2.0"),
    ("BEncode", v"0.2.0"),
    ("BGZFStreams", v"0.1.2"),
    ("BIGUQ", v"0.2.1"),
    ("BSplines", v"0.0.3"),
    ("BackpropNeuralNet", v"0.2.0"),
    ("BandedMatrices", v"0.1.2"),
    ("BaseTestDeprecated", v"0.1.0"),
    ("BaseTestNext", v"0.2.2"),
    ("BasisMatrices", v"0.2.0"),
    ("BayesNets", v"1.0.5"),
    ("BayesianDataFusion", v"1.2.0"),
    ("BeaData", v"0.0.3"),
    ("Bebop", v"0.0.1"),
    ("Benchmark", v"0.1.0"),
    ("BenchmarkLite", v"0.1.2"),
    ("BenchmarkTools", v"0.0.8"),
    ("Bezier", v"0.0.1"),
    ("BinDeps", v"0.4.7"),
    ("Bio", v"0.4.1"),
    ("BioEnergeticFoodWebs", v"0.1.1"),
    ("BioMedQuery", v"0.1.1"),
    ("BioSeq", v"0.4.0"),
    ("BiomolecularStructures", v"0.2.3"),
    ("Biryani", v"0.2.0"),
    ("BlackBoxOptim", v"0.2.1"),
    ("Blink", v"0.5.4"),
    ("BlockArrays", v"0.1.1"),
    ("Blocks", v"0.1.0"),
    ("BloomFilters", v"0.2.0"),
    ("Blosc", v"0.2.1"),
    ("BlossomV", v"0.2.1"),
    ("BlsData", v"0.0.2"),
    ("Bokeh", v"0.2.0"),
    ("Boltzmann", v"0.5.0"),
    ("Bootstrap", v"1.0.0"),
    ("BoundingBoxes", v"0.1.0"),
    ("Box0", v"0.2.0"),
    ("Brim", v"1.2.2"),
    ("Brownian", v"0.0.1"),
    ("BufferedStreams", v"0.3.3"),
    ("BuildExecutable", v"0.1.2"),
    ("Bukdu", v"0.0.4"),
    ("BusinessDays", v"0.5.0"),
    ("CBOR", v"0.0.2"),
    ("CDDLib", v"0.0.1"),
    ("CLBLAS", v"0.1.0"),
    ("CLFFT", v"0.3.0"),
    ("COFF", v"0.0.2"),
    ("COMTRADE", v"0.1.0"),
    ("CPLEX", v"0.1.7"),
    ("CPUTime", v"0.0.5"),
    ("CQL", v"0.0.1"),
    ("CRC", v"1.2.0"),
    ("CRC32", v"0.0.2"),
    ("CRF", v"0.1.1"),
    ("CRlibm", v"0.5.0"),
    ("CSTParser", v"0.2.0"),
    ("CSV", v"0.0.14"),
    ("CSVFiles", v"0.1.1"),
    ("CUBLAS", v"0.0.2"),
    ("CUDA", v"0.3.0"),
    ("CUDAdrv", v"0.2.0"),
    ("CUDAnative", v"0.3.0"),
    ("CUDAnativelib", v"0.0.1"),
    ("CUDArt", v"0.2.3"),
    ("CUDNN", v"0.3.0"),
    ("CUFFT", v"0.0.4"),
    ("CURAND", v"0.0.4"),
    ("CUSOLVER", v"0.1.0"),
    ("CUSPARSE", v"0.4.1"),
    ("CVXOPT", v"0.1.0"),
    ("Cairo", v"0.3.1"),
    ("Calc", v"0.1.1"),
    ("Calculus", v"0.2.2"),
    ("Calendar", v"0.4.3"),
    ("Cartesian", v"0.3.0"),
    ("CasaCore", v"0.0.5"),
    ("Cascadia", v"0.1.0"),
    ("CatIndices", v"0.0.1"),
    ("CatViews", v"0.0.1"),
    ("Catalan", v"0.0.3"),
    ("CategoricalArrays", v"0.1.0"),
    ("CauseMap", v"0.0.3"),
    ("Cbc", v"0.2.5"),
    ("Celeste", v"0.3.0"),
    ("CellularAutomata", v"0.1.2"),
    ("ChainMap", v"0.0.10"),
    ("ChainedVectors", v"0.0.0"),
    ("Changepoints", v"0.2.0"),
    ("ChaosCommunications", v"0.0.1"),
    ("Chemfiles", v"0.6.0"),
    ("ChemicalKinetics", v"0.1.0"),
    ("Chipmunk", v"0.0.5"),
    ("ChunkedArrays", v"0.1.0"),
    ("Church", v"0.0.1"),
    ("CirruParser", v"0.0.2"),
    ("Clang", v"0.1.0"),
    ("ClassicalCiphers", v"0.2.0"),
    ("Cliffords", v"0.3.0"),
    ("ClinicalTrialSampleSize", v"0.0.1"),
    ("Clipper", v"0.0.2"),
    ("ClobberingReload", v"0.0.1"),
    ("Clockwork", v"0.1.1"),
    ("Clp", v"0.2.2"),
    ("ClusterDicts", v"0.1.0"),
    ("ClusterManagers", v"0.1.2"),
    ("ClusterUtils", v"0.0.3"),
    ("Clustering", v"0.7.0"),
    ("CmplxRoots", v"0.0.2"),
    ("CodeTools", v"0.4.3"),
    ("CodecBzip2", v"0.2.2"),
    ("CodecXz", v"0.2.0"),
    ("CodecZlib", v"0.2.0"),
    ("CodecZstd", v"0.2.0"),
    ("Codecs", v"0.3.0"),
    ("CoinOptServices", v"0.1.2"),
    ("Color", v"0.4.8"),
    ("ColorBrewer", v"0.3.1"),
    ("ColorSchemes", v"1.2.1"),
    ("ColorTypes", v"0.2.12"),
    ("ColorVectorSpace", v"0.1.12"),
    ("Colors", v"0.6.9"),
    ("Combinatorics", v"0.3.2"),
    ("CommonCrawl", v"0.0.1"),
    ("CompEcon", v"0.2.1"),
    ("Compat", v"0.26.0"),
    ("CompilerOptions", v"0.1.0"),
    ("CompilerTools", v"0.2.1"),
    ("Complementarity", v"0.0.9"),
    ("Compose", v"0.4.5"),
    ("ComposeDiff", v"0.0.2"),
    ("CompressedSensing", v"0.0.2"),
    ("ComputationalResources", v"0.1.0"),
    ("Conda", v"0.6.2"),
    ("ConfParser", v"0.0.9"),
    ("ConfidenceWeighted", v"0.0.2"),
    ("ConicNonlinearBridge", v"0.0.4"),
    ("ConjugatePriors", v"0.1.2"),
    ("ConnectSDK", v"0.1.5"),
    ("ConnectionPools", v"0.0.2"),
    ("ContinuedFractions", v"0.1.0"),
    ("Contour", v"0.2.0"),
    ("ControlCore", v"0.0.1"),
    ("ControlSystems", v"0.3.0"),
    ("Convex", v"0.4.0"),
    ("CoordinateDescent", v"0.0.1"),
    ("CoordinateTransformations", v"0.3.2"),
    ("CoreNLP", v"0.1.0"),
    ("Cosmology", v"0.2.1"),
    ("CovarianceMatrices", v"0.3.1"),
    ("Coverage", v"0.3.3"),
    ("CoverageBase", v"0.0.3"),
    ("Cpp", v"0.1.0"),
    ("Crayons", v"0.4.0"),
    ("CrossDecomposition", v"0.0.1"),
    ("CrossfilterCharts", v"0.1.1"),
    ("Crypto", v"0.0.1"),
    ("Cuba", v"0.2.0"),
    ("Cubature", v"1.2.2"),
    ("Curl", v"0.0.3"),
    ("Currencies", v"0.4.0"),
    ("CurveFit", v"0.1.1"),
    ("CustomUnitRanges", v"0.0.3"),
    ("Cxx", v"0.0.2"),
    ("CxxWrap", v"0.2.3"),
    ("DASSL", v"0.1.0"),
    ("DBAPI", v"0.1.0"),
    ("DCEMRI", v"0.1.2"),
    ("DICOM", v"0.0.1"),
    ("DReal", v"0.1.0"),
    ("DSGE", v"0.2.0"),
    ("DSP", v"0.3.4"),
    ("DWARF", v"0.1.0"),
    ("DataArrays", v"0.5.3"),
    ("DataAssim", v"0.0.2"),
    ("DataCubes", v"0.0.6"),
    ("DataFlow", v"0.2.0"),
    ("DataFrames", v"0.10.1"),
    ("DataFramesMeta", v"0.1.3"),
    ("DataStreams", v"0.0.15"),
    ("DataStructures", v"0.5.3"),
    ("DataValueArrays", v"0.0.1"),
    ("DataValues", v"0.1.1"),
    ("DateParser", v"0.1.1"),
    ("Dates", v"0.4.4"),
    ("Datetime", v"0.1.7"),
    ("Debug", v"0.1.6"),
    ("DecFP", v"0.1.5"),
    ("Decimals", v"0.1.0"),
    ("DecisionTree", v"0.5.1"),
    ("DeclarativePackages", v"0.1.2"),
    ("Deconvolution", v"0.0.1"),
    ("DeepDiffs", v"1.0.1"),
    ("Defer", v"0.0.1"),
    ("DeferredFutures", v"0.1.1"),
    ("Deldir", v"0.0.3"),
    ("DetectionTheory", v"0.1.0"),
    ("DeterminantalPointProcesses", v"0.0.1"),
    ("DeterministicPolicyGradient", v"0.0.1"),
    ("DevIL", v"0.4.2"),
    ("Devectorize", v"0.4.2"),
    ("DictFiles", v"0.1.0"),
    ("DictUtils", v"0.0.2"),
    ("Dierckx", v"0.2.1"),
    ("DiffBase", v"0.2.0"),
    ("DiffEqBase", v"1.13.0"),
    ("DiffEqCallbacks", v"0.2.1"),
    ("DiffEqDevTools", v"0.9.5"),
    ("DiffEqMonteCarlo", v"0.7.0"),
    ("DiffEqParamEstim", v"0.5.0"),
    ("DifferentialDynamicProgramming", v"0.2.0"),
    ("DifferentialEquations", v"0.3.0"),
    ("Digits", v"0.1.4"),
    ("DimensionalityReduction", v"0.1.2"),
    ("DirichletProcessMixtures", v"0.0.1"),
    ("DiscreteFactor", v"0.0.0"),
    ("Discretizers", v"0.3.1"),
    ("DiscriminantAnalysis", v"0.1.0"),
    ("Displaz", v"0.0.1"),
    ("Distance", v"0.5.1"),
    ("Distances", v"0.3.2"),
    ("DistributedArrays", v"0.3.0"),
    ("Distributions", v"0.11.1"),
    ("Divergences", v"0.1.0"),
    ("Diversity", v"0.2.8"),
    ("DocOpt", v"0.2.1"),
    ("DocStringExtensions", v"0.3.4"),
    ("Docile", v"0.5.23"),
    ("Docker", v"0.0.1"),
    ("Documenter", v"0.8.10"),
    ("Dopri", v"0.3.0"),
    ("DoubleDouble", v"0.2.1"),
    ("Drawing", v"0.1.5"),
    ("DriftDiffusionPoissonSystems", v"0.0.1"),
    ("Dtree", v"0.0.1"),
    ("DualNumbers", v"0.3.0"),
    ("DustExtinction", v"0.2.1"),
    ("DynMultiply", v"0.0.1"),
    ("DynamicDiscreteModels", v"0.0.3"),
    ("DynamicMovementPrimitives", v"0.2.0"),
    ("DynamoDB", v"0.0.1"),
    ("Dynare", v"0.0.1"),
    ("ECOS", v"0.6.7"),
    ("EEG", v"0.2.0"),
    ("ELF", v"0.1.0"),
    ("EMIRT", v"0.0.1"),
    ("ERFA", v"0.2.2"),
    ("EasyPkg", v"0.3.0"),
    ("EcologicalNetwork", v"1.0.1"),
    ("EconDatasets", v"0.0.2"),
    ("EconModels", v"0.0.1"),
    ("EgyptianFractions", v"0.0.1"),
    ("Einsum", v"0.1.0"),
    ("ElasticFDA", v"0.3.4"),
    ("Elemental", v"0.1.2"),
    ("EllipsisNotation", v"0.0.2"),
    ("Elliptic", v"0.2.0"),
    ("EllipticFEM", v"0.0.2"),
    ("Elly", v"0.0.9"),
    ("EmpiricalRisks", v"0.2.4"),
    ("EndpointRanges", v"0.0.1"),
    ("Ensemble", v"0.0.1"),
    ("Equations", v"0.2.1"),
    ("EscapeString", v"0.0.1"),
    ("Escher", v"0.3.3"),
    ("Etcd", v"0.0.1"),
    ("EventHistory", v"0.0.2"),
    ("Evolutionary", v"0.1.2"),
    ("EvolvingGraphs", v"0.1.0"),
    ("Example", v"0.4.1"),
    ("ExcelFiles", v"0.1.0"),
    ("ExcelReaders", v"0.8.0"),
    ("Expect", v"0.1.2"),
    ("ExperimentalAnalysis", v"0.0.2"),
    ("ExpressionUtils", v"0.1.0"),
    ("Extern", v"0.0.2"),
    ("ExtractMacro", v"0.1.0"),
    ("ExtremelyRandomizedTrees", v"0.1.0"),
    ("FFTViews", v"0.0.1"),
    ("FFTW", v"0.0.2"),
    ("FITSIO", v"0.10.0"),
    ("FLAC", v"0.1.0"),
    ("FLANN", v"0.0.4"),
    ("FMIndexes", v"0.0.1"),
    ("FNVHash", v"0.0.3"),
    ("FPTControl", v"0.0.1"),
    ("FTPClient", v"0.2.1"),
    ("FaSTLMM", v"0.0.1"),
    ("FaceDatasets", v"0.2.0"),
    ("FactCheck", v"0.4.3"),
    ("FactorModels", v"0.0.2"),
    ("Faker", v"0.0.3"),
    ("FastAnonymous", v"0.3.3"),
    ("FastArrayOps", v"0.1.0"),
    ("FastCombinations", v"0.0.1"),
    ("FastGaussQuadrature", v"0.1.0"),
    ("FastTransforms", v"0.0.7"),
    ("FastaIO", v"0.2.0"),
    ("Feather", v"0.1.5"),
    ("FeatherFiles", v"0.0.2"),
    ("FileFind", v"0.0.0"),
    ("FileIO", v"0.2.2"),
    ("FilePaths", v"0.0.1"),
    ("FinancialMarkets", v"0.1.1"),
    ("FiniteStateMachine", v"0.1.1"),
    ("FixedEffectModels", v"0.4.0"),
    ("FixedPoint", v"0.0.1"),
    ("FixedPointNumbers", v"0.2.1"),
    ("FixedSizeArrays", v"0.2.5"),
    ("FixedSizeDictionaries", v"0.0.1"),
    ("FixedSizeStrings", v"0.0.1"),
    ("Fixtures", v"0.0.2"),
    ("FlatBuffers", v"0.1.4"),
    ("FlexibleArrays", v"1.1.0"),
    ("Flux", v"0.2.1"),
    ("Fontconfig", v"0.1.1"),
    ("Formatting", v"0.2.1"),
    ("ForwardDiff", v"0.5.0"),
    ("FredData", v"0.1.4"),
    ("FreeType", v"1.3.0"),
    ("FreqTables", v"0.0.2"),
    ("FunctionWrappers", v"0.1.0"),
    ("FunctionalCollections", v"0.2.0"),
    ("FunctionalData", v"0.1.2"),
    ("FunctionalDataUtils", v"0.1.0"),
    ("FunctionalUtils", v"0.0.0"),
    ("FusionDirect", v"0.2.3"),
    ("GARCH", v"0.2.1"),
    ("GLAbstraction", v"0.2.1"),
    ("GLFW", v"1.1.4"),
    ("GLM", v"0.5.6"),
    ("GLMNet", v"0.2.0"),
    ("GLPK", v"0.3.0"),
    ("GLPKMathProgInterface", v"0.2.3"),
    ("GLPlot", v"0.0.5"),
    ("GLText", v"0.0.4"),
    ("GLUT", v"0.4.0"),
    ("GLVisualize", v"0.1.2"),
    ("GLWindow", v"0.2.1"),
    ("GMT", v"0.0.4"),
    ("GR", v"0.19.0"),
    ("GSL", v"0.3.6"),
    ("GUITestRunner", v"0.0.2"),
    ("GZip", v"0.2.20"),
    ("Gadfly", v"0.5.3"),
    ("GadflyDiff", v"0.0.1"),
    ("Gallium", v"0.0.4"),
    ("Gaston", v"0.0.0"),
    ("GaussQuadrature", v"0.3.1"),
    ("GaussianMixtureTest", v"0.0.4"),
    ("GaussianMixtures", v"0.1.0"),
    ("GaussianProcesses", v"0.3.1"),
    ("GeneralizedMetropolisHastings", v"0.2.1"),
    ("GeneralizedSampling", v"0.0.6"),
    ("GeneralizedSchurAlgorithm", v"0.0.2"),
    ("GenericSVD", v"0.0.2"),
    ("GeneticAlgorithms", v"0.0.3"),
    ("GeoEfficiency", v"0.8.7"),
    ("GeoIP", v"0.2.2"),
    ("GeoInterface", v"0.1.0"),
    ("GeoJSON", v"0.1.0"),
    ("GeoStats", v"0.0.4"),
    ("GeoStatsImages", v"0.0.6"),
    ("Geodesy", v"0.3.0"),
    ("GeographicLibPy", v"0.0.3"),
    ("GeometricalPredicates", v"0.0.6"),
    ("GeometryTypes", v"0.4.0"),
    ("GetC", v"1.1.1"),
    ("Gettext", v"0.1.0"),
    ("GibbsSeaWater", v"0.0.4"),
    ("Gillespie", v"0.0.2"),
    ("Git", v"0.1.0"),
    ("GitHub", v"2.1.1"),
    ("GitLab", v"0.0.2"),
    ("Glob", v"1.0.2"),
    ("GnuTLS", v"0.0.5"),
    ("GoogleCharts", v"0.0.7"),
    ("GracePlot", v"0.2.0"),
    ("GradientBoost", v"0.0.1"),
    ("Graft", v"0.0.2"),
    ("GraphCentrality", v"0.1.0"),
    ("GraphIO", v"0.0.1"),
    ("GraphLayout", v"0.3.1"),
    ("GraphMatrices", v"0.1.0"),
    ("GraphPlot", v"0.1.0"),
    ("GraphViz", v"0.0.4"),
    ("Graphics", v"0.1.5"),
    ("Graphs", v"0.7.1"),
    ("GreatCircle", v"0.1.0"),
    ("Grid", v"0.4.2"),
    ("GridInterpolations", v"0.0.2"),
    ("GroupSlices", v"0.0.1"),
    ("GrowableArrays", v"0.0.5"),
    ("Gtk", v"0.11.0"),
    ("GtkBuilderAid", v"0.0.7"),
    ("GtkUtilities", v"0.1.0"),
    ("Gumbo", v"0.2.2"),
    ("Gunrock", v"0.0.2"),
    ("Gurobi", v"0.2.8"),
    ("HDF5", v"0.7.3"),
    ("HDFS", v"0.1.0"),
    ("HPAT", v"0.0.4"),
    ("HPack", v"0.1.0"),
    ("HSA", v"0.0.1"),
    ("HTSLIB", v"0.0.2"),
    ("HTTP", v"0.0.2"),
    ("HTTP2", v"0.1.0"),
    ("HTTPClient", v"0.2.1"),
    ("Hadamard", v"0.2.2"),
    ("HarwellRutherfordBoeing", v"0.0.1"),
    ("Hecke", v"0.1.5"),
    ("Helpme", v"0.0.13"),
    ("HexEdit", v"0.0.6"),
    ("Hexagons", v"0.1.0"),
    ("Hiccup", v"0.0.3"),
    ("HiddenMarkovModels", v"0.0.2"),
    ("Highlights", v"0.2.1"),
    ("Hinton", v"0.1.1"),
    ("Hive", v"0.0.3"),
    ("Homebrew", v"0.5.9"),
    ("HopfieldNets", v"0.0.0"),
    ("HttpCommon", v"0.2.7"),
    ("HttpParser", v"0.2.0"),
    ("HttpServer", v"0.2.0"),
    ("Humanize", v"0.4.1"),
    ("Hwloc", v"0.5.0"),
    ("HyperDualNumbers", v"1.0.0"),
    ("HyperLogLog", v"0.0.0"),
    ("HypothesisTests", v"0.4.0"),
    ("ICOADSDict", v"0.0.1"),
    ("ICU", v"0.4.4"),
    ("IDRsSolver", v"0.1.3"),
    ("IDXParser", v"0.1.0"),
    ("IJulia", v"1.4.1"),
    ("IJuliaPortrayals", v"0.0.4"),
    ("IOIndents", v"0.1.0"),
    ("IPNets", v"0.2.0"),
    ("IPPCore", v"0.2.1"),
    ("IPPDSP", v"0.0.1"),
    ("IProfile", v"0.4.0"),
    ("ISPC", v"0.0.1"),
    ("ImageCore", v"0.0.5"),
    ("ImageFiltering", v"0.0.2"),
    ("ImageMagick", v"0.1.8"),
    ("ImageProjectiveGeometry", v"0.1.2"),
    ("ImageQuilting", v"0.3.2"),
    ("ImageRegistration", v"0.0.1"),
    ("ImageView", v"0.2.0"),
    ("Images", v"0.5.14"),
    ("ImagineFormat", v"0.6.0"),
    ("Immerse", v"0.0.13"),
    ("ImmutableArrays", v"0.0.12"),
    ("ImplicitEquations", v"0.3.0"),
    ("ImputeNaNs", v"0.0.2"),
    ("IncGammaBeta", v"0.0.1"),
    ("IncrementalInference", v"0.1.0"),
    ("IndependentRandomSequences", v"0.0.1"),
    ("IndexableBitVectors", v"0.1.2"),
    ("IndexedArrays", v"0.2.0"),
    ("Indicators", v"0.1.4"),
    ("IndirectArrays", v"0.0.1"),
    ("InfoZIP", v"0.0.9"),
    ("InformationMeasures", v"0.0.1"),
    ("InformedDifferentialEvolution", v"0.2.0"),
    ("IniFile", v"0.3.1"),
    ("InplaceOps", v"0.1.0"),
    ("InspectDR", v"0.2.3"),
    ("Instruments", v"0.1.0"),
    ("IntArrays", v"0.0.1"),
    ("IntModN", v"0.0.2"),
    ("Interact", v"0.4.5"),
    ("InteractiveFixedEffectModels", v"0.2.1"),
    ("InterestRates", v"0.0.8"),
    ("Interfaces", v"0.0.4"),
    ("Interpolations", v"0.3.8"),
    ("IntervalArithmetic", v"0.11.0"),
    ("IntervalConstraintProgramming", v"0.5.0"),
    ("IntervalLinearEquations", v"0.2.0"),
    ("IntervalSets", v"0.0.2"),
    ("IntervalTrees", v"0.1.1"),
    ("IntervalWavelets", v"0.0.4"),
    ("Ipopt", v"0.2.6"),
    ("Isotonic", v"0.0.1"),
    ("IterTools", v"0.1.0"),
    ("IterableTables", v"0.4.2"),
    ("IterationManagers", v"0.0.1"),
    ("IterativeSolvers", v"0.2.2"),
    ("Iterators", v"0.3.1"),
    ("Ito", v"0.0.2"),
    ("JACKAudio", v"0.1.1"),
    ("JDBC", v"0.1.0"),
    ("JFVM", v"0.2.0"),
    ("JLD", v"0.6.11"),
    ("JLDArchives", v"0.1.0"),
    ("JPLEphemeris", v"0.4.1"),
    ("JSON", v"0.9.1"),
    ("JWAS", v"0.1.1"),
    ("Jackknife", v"0.1.0"),
    ("Jacobi", v"0.3.0"),
    ("Jags", v"1.0.2"),
    ("JavaCall", v"0.4.4"),
    ("JellyFish", v"0.0.1"),
    ("Jewel", v"1.0.8"),
    ("JointMoments", v"0.2.5"),
    ("JuLIP", v"0.0.1"),
    ("JuMP", v"0.14.2"),
    ("JuMPChance", v"0.3.0"),
    ("JuMPeR", v"0.4.0"),
    ("JudyDicts", v"0.0.0"),
    ("JuliaDB", v"0.1.2"),
    ("JuliaFEM", v"0.1.0"),
    ("JuliaParser", v"0.7.4"),
    ("JuliaWebAPI", v"0.2.2"),
    ("JuliaWebRepl", v"0.0.0"),
    ("JulieTest", v"0.0.2"),
    ("Jumos", v"0.2.1"),
    ("Juno", v"0.3.2"),
    ("KCores", v"0.0.3"),
    ("KDTrees", v"0.6.0"),
    ("KLDivergence", v"0.0.0"),
    ("KNITRO", v"0.2.0"),
    ("KShiftsClustering", v"0.1.0"),
    ("Kafka", v"0.1.0"),
    ("KernSmooth", v"0.0.3"),
    ("KernelDensity", v"0.3.2"),
    ("KernelDensityEstimate", v"0.1.0"),
    ("KernelEstimator", v"0.1.7"),
    ("Klara", v"0.6.1"),
    ("Knet", v"0.8.5"),
    ("KrylovMethods", v"0.2.1"),
    ("LARS", v"0.0.3"),
    ("LCA", v"0.0.1"),
    ("LCIO", v"0.4.1"),
    ("LCMGL", v"0.0.2"),
    ("LIBLINEAR", v"0.3.0"),
    ("LIBSVM", v"0.0.1"),
    ("LLLplus", v"0.1.1"),
    ("LLVM", v"0.2.1"),
    ("LMDB", v"0.0.4"),
    ("LNR", v"0.0.2"),
    ("LRUCache", v"0.0.1"),
    ("LaTeX", v"0.1.1"),
    ("LaTeXStrings", v"0.2.1"),
    ("LambertW", v"0.2.0"),
    ("LanguageServer", v"0.2.2"),
    ("Languages", v"0.1.0"),
    ("Laplacians", v"0.0.2"),
    ("Lasso", v"0.0.4"),
    ("Lazy", v"0.11.7"),
    ("LazySequences", v"0.1.0"),
    ("LearnBase", v"0.0.2"),
    ("LeastSquaresOptim", v"0.4.0"),
    ("LegacyStrings", v"0.2.2"),
    ("Lens", v"0.0.3"),
    ("LevelDB", v"1.0.1"),
    ("Levenshtein", v"0.0.2"),
    ("Lexicon", v"0.1.18"),
    ("LibArchive", v"0.0.2"),
    ("LibBSON", v"0.2.8"),
    ("LibCURL", v"0.2.2"),
    ("LibCloud", v"0.0.2"),
    ("LibExpat", v"0.2.8"),
    ("LibGEOS", v"0.1.2"),
    ("LibGit2", v"0.3.8"),
    ("LibHealpix", v"0.2.4"),
    ("LibPSF", v"0.2.0"),
    ("LibSndFile", v"1.0.0"),
    ("LibTrading", v"0.0.1"),
    ("Libz", v"0.2.4"),
    ("LifeTable", v"0.0.2"),
    ("LightGraphs", v"0.10.2"),
    ("LightGraphsExtras", v"0.1.0"),
    ("LightXML", v"0.5.0"),
    ("LineEdit", v"0.0.1"),
    ("LineSearches", v"2.2.1"),
    ("LinearLeastSquares", v"0.1.0"),
    ("LinearMaps", v"0.2.0"),
    ("LinearOperators", v"0.3.1"),
    ("LinearResponseVariationalBayes", v"0.0.1"),
    ("LinguisticData", v"0.0.2"),
    ("Lint", v"0.2.5"),
    ("LispSyntax", v"0.1.5"),
    ("LittleEndianBase128", v"0.0.1"),
    ("Loess", v"0.1.0"),
    ("LogParser", v"0.3.0"),
    ("LoggedDicts", v"0.0.2"),
    ("Logging", v"0.3.1"),
    ("LombScargle", v"0.3.0"),
    ("Lora", v"0.5.6"),
    ("Loss", v"0.0.1"),
    ("LossFunctions", v"0.2.0"),
    ("LowDimNearestNeighbors", v"0.0.1"),
    ("LowRankModels", v"0.1.2"),
    ("LsqFit", v"0.2.0"),
    ("Lumberjack", v"2.1.1"),
    ("Lumira", v"0.0.2"),
    ("Luxor", v"0.8.6"),
    ("MAT", v"0.3.2"),
    ("MATLAB", v"0.3.0"),
    ("MATLABCluster", v"0.0.1"),
    ("MCMC", v"0.3.0"),
    ("MDCT", v"1.0.1"),
    ("MDPs", v"0.1.1"),
    ("MFCC", v"0.1.1"),
    ("MIDI", v"0.0.3"),
    ("MIToS", v"1.2.3"),
    ("MLBase", v"0.6.1"),
    ("MLDataUtils", v"0.0.2"),
    ("MLKernels", v"0.1.0"),
    ("MLLabelUtils", v"0.1.4"),
    ("MNIST", v"0.0.2"),
    ("MP3", v"1.0.0"),
    ("MPFI", v"0.0.1"),
    ("MPI", v"0.5.1"),
    ("MUMPS", v"0.0.2"),
    ("MXNet", v"0.1.0"),
    ("MachO", v"0.0.4"),
    ("MachineLearning", v"0.0.3"),
    ("MachineLearningMetrics", v"0.0.1"),
    ("MacroTools", v"0.3.7"),
    ("Mads", v"0.2.19"),
    ("Maker", v"0.3.1"),
    ("Mamba", v"0.11.1"),
    ("Mandrill", v"0.1.0"),
    ("ManifoldLearning", v"0.1.0"),
    ("MapLight", v"0.0.2"),
    ("MappedArrays", v"0.0.5"),
    ("Markdown", v"0.3.0"),
    ("MarketData", v"0.4.0"),
    ("MarketTechnicals", v"0.4.1"),
    ("Match", v"0.3.0"),
    ("MathProgBase", v"0.5.10"),
    ("MathToolkit", v"0.0.1"),
    ("Mathematica", v"0.2.0"),
    ("MatlabCompat", v"0.1.2"),
    ("MatpowerCases", v"0.5.0"),
    ("MatrixDepot", v"0.5.6"),
    ("MatrixMarket", v"0.1.0"),
    ("MatrixNetworks", v"0.0.1"),
    ("Maxima", v"0.0.4"),
    ("Mayday", v"0.0.3"),
    ("MbedTLS", v"0.3.0"),
    ("MeCab", v"0.1.7"),
    ("Measurements", v"0.4.0"),
    ("Measures", v"0.0.3"),
    ("Meddle", v"0.0.6"),
    ("Media", v"0.3.0"),
    ("MelGeneralizedCepstrums", v"0.0.4"),
    ("Memcache", v"0.1.1"),
    ("Memoize", v"0.1.0"),
    ("MergedMethods", v"0.0.3"),
    ("Merly", v"0.0.2"),
    ("MeshIO", v"0.0.6"),
    ("Meshes", v"0.2.0"),
    ("Meshing", v"0.0.3"),
    ("MessageUtils", v"0.0.2"),
    ("MetaProgTools", v"0.1.6"),
    ("MetaTools", v"0.0.1"),
    ("MetadataTools", v"0.3.2"),
    ("Metamath", v"0.0.1"),
    ("Metis", v"0.0.10"),
    ("Microbiome", v"0.1.0"),
    ("Microeconometrics", v"0.1.2"),
    ("Millboard", v"0.1.0"),
    ("Mimi", v"0.2.3"),
    ("Miniball", v"0.0.1"),
    ("MinimalPerfectHashes", v"0.1.2"),
    ("MixedModels", v"0.5.8"),
    ("MixtureModels", v"0.2.0"),
    ("Mocha", v"0.1.2"),
    ("Mocking", v"0.3.4"),
    ("ModernGL", v"0.1.1"),
    ("MolecularDataType", v"0.0.2"),
    ("MolecularDynamics", v"0.1.3"),
    ("MolecularPDB", v"0.0.1"),
    ("Monads", v"0.0.0"),
    ("Mongo", v"0.2.3"),
    ("Mongrel2", v"0.0.0"),
    ("Morsel", v"0.0.6"),
    ("Mosek", v"0.5.0"),
    ("MsgPack", v"0.0.5"),
    ("MsgPackRpcClient", v"0.0.0"),
    ("MsgPackRpcServer", v"0.0.1"),
    ("MuKanren", v"0.1.0"),
    ("MultiNest", v"0.2.0"),
    ("MultiPoly", v"0.1.0"),
    ("MultidimensionalTables", v"0.0.3"),
    ("MultipleTesting", v"0.0.2"),
    ("Multirate", v"0.0.2"),
    ("MultivariateStats", v"0.3.1"),
    ("Munkres", v"0.1.1"),
    ("Murmur3", v"0.2.0"),
    ("Mustache", v"0.1.4"),
    ("MutableStrings", v"0.0.0"),
    ("Mux", v"0.2.3"),
    ("MySQL", v"0.1.0"),
    ("NBInclude", v"1.2.0"),
    ("NEOS", v"0.1.0"),
    ("NFFT", v"0.1.4"),
    ("NHST", v"0.0.2"),
    ("NIDAQ", v"0.1.1"),
    ("NIfTI", v"0.1.1"),
    ("NKLandscapes", v"0.3.0"),
    ("NLPModels", v"0.0.1"),
    ("NLSolversBase", v"0.0.1"),
    ("NLopt", v"0.3.6"),
    ("NLreg", v"0.1.1"),
    ("NLsolve", v"0.12.1"),
    ("NMEA", v"0.0.6"),
    ("NMF", v"0.2.5"),
    ("NOAAData", v"0.0.2"),
    ("NPZ", v"0.2.0"),
    ("NRRD", v"0.1.0"),
    ("NURBS", v"0.0.1"),
    ("NaNMath", v"0.2.6"),
    ("NaiveBayes", v"0.3.1"),
    ("Named", v"0.0.0"),
    ("NamedArrays", v"0.5.3"),
    ("NamedDimensions", v"0.0.3"),
    ("NamedTuples", v"4.0.0"),
    ("Napier", v"0.0.2"),
    ("NaturalSort", v"0.0.1"),
    ("NearestNeighbors", v"0.3.0"),
    ("Nemo", v"0.5.1"),
    ("Neo4j", v"1.0.0"),
    ("Neovim", v"0.0.2"),
    ("NetCDF", v"0.3.1"),
    ("Netpbm", v"0.1.1"),
    ("Nettle", v"0.3.0"),
    ("NetworkFlows", v"0.0.1"),
    ("NetworkLayout", v"0.1.1"),
    ("NetworkViz", v"0.0.2"),
    ("NeuralynxNCS", v"0.0.1"),
    ("NodeJS", v"0.0.1"),
    ("NonNegLeastSquares", v"0.0.1"),
    ("NormalizeQuantiles", v"0.3.2"),
    ("NoveltyColors", v"0.3.0"),
    ("NullableArrays", v"0.0.10"),
    ("Nulls", v"0.0.2"),
    ("NumFormat", v"0.0.4"),
    ("NumericExtensions", v"0.6.2"),
    ("NumericFuns", v"0.2.4"),
    ("NumericIO", v"0.2.0"),
    ("NumericSuffixes", v"0.0.3"),
    ("OAuth", v"0.4.1"),
    ("OCCA", v"0.0.1"),
    ("ODBC", v"0.4.2"),
    ("ODE", v"0.2.1"),
    ("ODEInterface", v"0.1.5"),
    ("OEIS", v"0.0.2"),
    ("OIFITS", v"0.3.1"),
    ("OSC", v"0.0.1"),
    ("OSXNotifier", v"0.0.1"),
    ("ObjFileBase", v"0.0.4"),
    ("OffsetArrays", v"0.2.11"),
    ("Ogg", v"0.0.2"),
    ("OhMyREPL", v"0.2.6"),
    ("OnlineMoments", v"0.1.0"),
    ("OnlineStats", v"0.8.0"),
    ("OpenCL", v"0.5.0"),
    ("OpenDSSDirect", v"0.2.0"),
    ("OpenFOAM", v"0.0.1"),
    ("OpenGL", v"2.0.3"),
    ("OpenGene", v"0.1.11"),
    ("OpenSSL", v"0.0.0"),
    ("OpenSecrets", v"0.0.1"),
    ("OpenSlide", v"0.0.1"),
    ("OpenStreetMap", v"0.8.2"),
    ("OptiMimi", v"0.0.2"),
    ("Optim", v"0.9.3"),
    ("OptimPack", v"0.3.0"),
    ("Options", v"0.2.6"),
    ("Opus", v"0.0.2"),
    ("Orchestra", v"0.0.5"),
    ("OrdinaryDiffEq", v"2.9.0"),
    ("PAINTER", v"0.3.0"),
    ("PATHSolver", v"0.0.6"),
    ("PDMats", v"0.6.0"),
    ("PEGParser", v"0.1.2"),
    ("PGFPlots", v"1.4.3"),
    ("PGFPlotsX", v"0.1.5"),
    ("PGM", v"0.0.1"),
    ("PLX", v"0.0.5"),
    ("POMDPs", v"0.2.3"),
    ("PTools", v"0.0.0"),
    ("PValueAdjust", v"2.0.0"),
    ("Packing", v"0.0.4"),
    ("Pages", v"0.0.7"),
    ("PairwiseListMatrices", v"0.3.0"),
    ("Pajarito", v"0.2.1"),
    ("Pandas", v"0.4.0"),
    ("ParSpMatVec", v"0.0.1"),
    ("ParallelAccelerator", v"0.2.2"),
    ("ParallelDataTransfer", v"0.0.1"),
    ("ParallelSparseMatMul", v"0.0.2"),
    ("Parameters", v"0.5.0"),
    ("Pardiso", v"0.1.3"),
    ("ParserCombinator", v"1.7.11"),
    ("Pastebin", v"0.0.3"),
    ("Patchwork", v"0.3.1"),
    ("PathDistribution", v"0.0.1"),
    ("PatternDispatch", v"0.2.0"),
    ("Pcap", v"0.0.4"),
    ("PdbTool", v"0.1.0"),
    ("Pedigrees", v"0.0.1"),
    ("PenaltyFunctions", v"0.0.2"),
    ("PerceptualColourMaps", v"0.1.2"),
    ("Permutations", v"0.0.1"),
    ("Persist", v"1.0.0"),
    ("Phonetics", v"0.1.0"),
    ("PhyloNetworks", v"0.3.0"),
    ("PhyloTrees", v"0.4.0"),
    ("Phylogenetics", v"0.0.2"),
    ("PicoSAT", v"0.1.0"),
    ("PiecewiseAffineTransforms", v"0.2.0"),
    ("PiecewiseIncreasingRanges", v"0.0.4"),
    ("Pipe", v"1.0.0"),
    ("PkgDev", v"0.1.3"),
    ("PlanOut", v"0.1.0"),
    ("Playground", v"0.2.0"),
    ("PlotRecipes", v"0.1.0"),
    ("PlotUtils", v"0.1.1"),
    ("Plotly", v"0.1.1"),
    ("PlotlyJS", v"0.5.2"),
    ("Plots", v"0.12.3"),
    ("PolarFact", v"0.0.6"),
    ("Polyglot", v"0.0.1"),
    ("Polyhedra", v"0.0.1"),
    ("Polynomial", v"0.1.1"),
    ("PolynomialFactors", v"0.0.6"),
    ("PolynomialMatrices", v"0.1.1"),
    ("PolynomialRoots", v"0.0.4"),
    ("Polynomials", v"0.1.6"),
    ("PooledArrays", v"0.1.1"),
    ("PortAudio", v"1.0.0"),
    ("PositiveFactorizations", v"0.0.4"),
    ("PotentialFlow", v"0.0.1"),
    ("PowerLaws", v"0.0.3"),
    ("PowerModels", v"0.2.3"),
    ("PowerSeries", v"0.2.0"),
    ("Primes", v"0.1.3"),
    ("PrivateModules", v"0.0.3"),
    ("PrivateMultiplicativeWeights", v"0.0.2"),
    ("ProfileView", v"0.1.5"),
    ("ProgressMeter", v"0.4.0"),
    ("ProgressiveAligner", v"0.4.0"),
    ("Proj4", v"0.0.1"),
    ("ProjectTemplate", v"0.0.1"),
    ("ProjectiveDictionaryPairLearning", v"0.4.3"),
    ("PropertyGraph", v"0.1.0"),
    ("ProtoBuf", v"0.3.2"),
    ("ProximalBase", v"0.0.3"),
    ("ProximalOperators", v"0.0.1"),
    ("PublicSuffix", v"0.0.2"),
    ("Push", v"0.0.1"),
    ("PyAMG", v"0.0.9"),
    ("PyCall", v"1.11.1"),
    ("PyLCM", v"0.0.4"),
    ("PyLexYacc", v"0.0.2"),
    ("PyLogging", v"0.0.1"),
    ("PyPlot", v"2.3.2"),
    ("PyProj", v"0.0.1"),
    ("PySide", v"0.0.2"),
    ("PyX", v"0.0.1"),
    ("Pyramids", v"0.0.1"),
    ("QDXML", v"0.0.1"),
    ("QML", v"0.1.0"),
    ("QRupdate", v"1.0.1"),
    ("QWTwPlot", v"0.0.2"),
    ("QuDirac", v"0.1.3"),
    ("QuadGK", v"0.1.3"),
    ("Quandl", v"0.5.4"),
    ("QuantEcon", v"0.9.0"),
    ("QuantumInfo", v"0.0.2"),
    ("QuantumLab", v"0.0.3"),
    ("QuantumOptics", v"0.1.0"),
    ("QuantumTomography", v"0.0.2"),
    ("QuartzImageIO", v"0.3.1"),
    ("Quaternions", v"0.1.1"),
    ("Query", v"0.6.0"),
    ("Queueing", v"0.0.3"),
    ("QuickCheck", v"0.0.0"),
    ("QuickHull", v"0.1.0"),
    ("QuickShiftClustering", v"0.1.1"),
    ("Qwt", v"0.0.1"),
    ("RCall", v"0.5.2"),
    ("RDF", v"0.0.1"),
    ("RData", v"0.0.4"),
    ("RDatasets", v"0.2.0"),
    ("REPL", v"0.0.2"),
    ("REPLCompletions", v"0.0.3"),
    ("RLEVectors", v"0.2.9"),
    ("RNGTest", v"1.2.0"),
    ("ROCAnalysis", v"0.1.0"),
    ("ROOT", v"0.0.1"),
    ("Rainflow", v"0.1.0"),
    ("RandomCorrelationMatrices", v"0.3.0"),
    ("RandomFerns", v"0.1.0"),
    ("RandomMatrices", v"0.2.1"),
    ("RandomNumbers", v"0.1.0"),
    ("RandomQuantum", v"0.0.1"),
    ("RangeArrays", v"0.1.2"),
    ("RationalFunctions", v"0.1.1"),
    ("Ratios", v"0.1.0"),
    ("RawArray", v"0.0.2"),
    ("RdRand", v"0.0.0"),
    ("React", v"0.1.6"),
    ("Reactive", v"0.3.7"),
    ("ReadWriteDlm2", v"0.6.1"),
    ("ReadWriteLocks", v"0.0.2"),
    ("RealInterface", v"0.0.3"),
    ("RecipesBase", v"0.2.0"),
    ("RecurrenceAnalysis", v"0.1.0"),
    ("RecursiveArrayTools", v"0.12.4"),
    ("Redis", v"0.1.1"),
    ("Reel", v"0.2.2"),
    ("Reexport", v"0.0.3"),
    ("RegERMs", v"0.0.2"),
    ("Regression", v"0.3.0"),
    ("Remez", v"0.0.1"),
    ("Requests", v"0.4.1"),
    ("RequestsCache", v"0.0.1"),
    ("Requires", v"0.4.3"),
    ("Resampling", v"0.0.0"),
    ("ResettableStacks", v"0.0.1"),
    ("Restful", v"0.4.0"),
    ("ResultTypes", v"0.2.0"),
    ("Retry", v"0.0.5"),
    ("ReusableFunctions", v"0.1.15"),
    ("Revealables", v"0.0.1"),
    ("ReverseDiffOverload", v"0.0.1"),
    ("ReverseDiffSource", v"0.2.3"),
    ("ReverseDiffSparse", v"0.5.8"),
    ("Rif", v"0.0.12"),
    ("RigidBodyDynamics", v"0.4.0"),
    ("RingArrays", v"0.1.0"),
    ("RingBuffers", v"1.1.2"),
    ("Rmath", v"0.1.7"),
    ("RobotOS", v"0.4.3"),
    ("Robotlib", v"0.2.1"),
    ("RobustLeastSquares", v"0.0.1"),
    ("RobustPmap", v"0.1.13"),
    ("RobustShortestPath", v"0.2.3"),
    ("RobustStats", v"0.0.1"),
    ("RollingFunctions", v"0.2.1"),
    ("RomanNumerals", v"0.1.0"),
    ("Roots", v"0.3.1"),
    ("Rotations", v"0.5.0"),
    ("RouletteWheels", v"0.0.6"),
    ("Rsvg", v"0.1.0"),
    ("RudeOil", v"0.1.0"),
    ("RunTests", v"0.0.3"),
    ("SALSA", v"0.1.0"),
    ("SCIP", v"0.1.2"),
    ("SCS", v"0.2.8"),
    ("SDE", v"0.3.1"),
    ("SDL", v"0.1.5"),
    ("SDWBA", v"0.0.2"),
    ("SFML", v"0.2.0"),
    ("SGDOptim", v"0.2.2"),
    ("SGP4", v"0.4.0"),
    ("SHA", v"0.3.3"),
    ("SIMD", v"0.1.1"),
    ("SIUnits", v"0.1.0"),
    ("SMTPClient", v"0.1.0"),
    ("SPTK", v"0.1.2"),
    ("SQLite", v"0.3.7"),
    ("SVM", v"0.0.1"),
    ("SVMLightLoader", v"0.3.1"),
    ("SampledSignals", v"1.1.0"),
    ("Sampling", v"0.0.8"),
    ("SaveREPL", v"0.0.1"),
    ("SchattenNorms", v"0.0.3"),
    ("SchumakerSpline", v"0.0.1"),
    ("ScikitLearn", v"0.2.4"),
    ("ScikitLearnBase", v"0.2.2"),
    ("SecureSessions", v"0.0.2"),
    ("Seismic", v"0.1.1"),
    ("SemidefiniteProgramming", v"0.2.0"),
    ("SeqMaker", v"0.1.1"),
    ("SerialPorts", v"0.1.0"),
    ("Shannon", v"0.3.0"),
    ("ShapeModels", v"0.0.3"),
    ("Shapefile", v"0.0.3"),
    ("Shoco", v"0.0.3"),
    ("ShowSet", v"0.0.1"),
    ("Showoff", v"0.0.7"),
    ("Sigma", v"0.0.1"),
    ("SigmoidalProgramming", v"0.0.1"),
    ("SignalView", v"0.0.1"),
    ("SignedDistanceFields", v"0.1.0"),
    ("Silo", v"0.2.0"),
    ("SimJulia", v"0.3.14"),
    ("SimilaritySearch", v"0.1.5"),
    ("SimpleStructs", v"0.0.2"),
    ("SimpleTasks", v"0.0.12"),
    ("SimpleTraits", v"0.1.1"),
    ("Sims", v"0.1.0"),
    ("SingularIntegralEquations", v"0.1.5"),
    ("SkyCoords", v"0.1.1"),
    ("SliceSampler", v"0.0.0"),
    ("SloanDigitalSkySurvey", v"0.1.1"),
    ("Slugify", v"0.1.1"),
    ("Smile", v"0.2.0"),
    ("SmoothingKernels", v"0.0.0"),
    ("SmoothingSplines", v"0.0.1"),
    ("SnFFT", v"0.0.1"),
    ("Snappy", v"0.0.2"),
    ("SnoopCompile", v"0.1.0"),
    ("Sobol", v"0.2.2"),
    ("Sodium", v"0.0.0"),
    ("SoftConfidenceWeighted", v"0.1.3"),
    ("SolarSystemLib", v"0.0.2"),
    ("SolveDSGE", v"0.0.1"),
    ("SortingAlgorithms", v"0.1.1"),
    ("Soundex", v"0.0.0"),
    ("Spark", v"0.1.0"),
    ("Sparklines", v"0.1.2"),
    ("Sparrow", v"0.0.1"),
    ("SparseGrids", v"0.1.1"),
    ("SparseVectors", v"0.4.2"),
    ("SpatialEcology", v"0.1.0"),
    ("SpecialMatrices", v"0.1.3"),
    ("Spectra", v"0.2.3"),
    ("SpiceData", v"0.2.0"),
    ("SpikingNetworks", v"0.0.4"),
    ("StackTraces", v"0.1.1"),
    ("StackedNets", v"0.0.1"),
    ("Stan", v"1.0.2"),
    ("StandardizedMatrices", v"0.2.0"),
    ("StatFiles", v"0.0.2"),
    ("StatPlots", v"0.4.2"),
    ("StateSpaceRoutines", v"0.0.1"),
    ("StatefulIterators", v"0.1.0"),
    ("StaticArrays", v"0.6.1"),
    ("Stats", v"0.1.0"),
    ("StatsBase", v"0.12.0"),
    ("StatsFuns", v"0.4.0"),
    ("StatsdClient", v"0.0.2"),
    ("StochDynamicProgramming", v"0.2.2"),
    ("StochasticDiffEq", v"2.6.0"),
    ("StochasticSearch", v"0.3.0"),
    ("Stochy", v"0.0.2"),
    ("StrPack", v"0.0.1"),
    ("StreamStats", v"0.0.2"),
    ("StringDistances", v"0.1.1"),
    ("StringEncodings", v"0.1.1"),
    ("StringInterpolation", v"0.0.1"),
    ("StructIO", v"0.0.2"),
    ("StructsOfArrays", v"0.0.3"),
    ("Subsequences", v"0.0.1"),
    ("SuffixArrays", v"0.0.1"),
    ("SugarBLAS", v"0.0.4"),
    ("SuiteSparse", v"0.0.1"),
    ("Sundials", v"0.3.0"),
    ("SunlightAPIs", v"0.0.3"),
    ("Suppressor", v"0.0.5"),
    ("SweepOperator", v"0.0.2"),
    ("Swifter", v"0.0.8"),
    ("Switch", v"0.0.1"),
    ("SwitchTimeOpt", v"0.0.2"),
    ("SymDict", v"0.0.5"),
    ("SymEngine", v"0.2.0"),
    ("SymPy", v"0.5.4"),
    ("Symata", v"0.2.0"),
    ("Synchrony", v"0.0.1"),
    ("SynthesisFilters", v"0.0.4"),
    ("SystemImageBuilder", v"0.0.7"),
    ("TOML", v"0.3.0"),
    ("Taro", v"0.4.0"),
    ("Tau", v"0.0.3"),
    ("TaylorIntegration", v"0.0.2"),
    ("TaylorSeries", v"0.3.1"),
    ("Temporal", v"0.1.2"),
    ("TensorDecompositions", v"0.1.0"),
    ("TensorFlow", v"0.4.1"),
    ("TensorOperations", v"0.4.1"),
    ("Tensors", v"0.7.0"),
    ("TermWin", v"0.0.31"),
    ("TerminalExtensions", v"0.2.0"),
    ("TerminalUI", v"0.0.2"),
    ("Terminals", v"0.0.1"),
    ("TestImages", v"0.1.3"),
    ("TestRunner", v"0.0.3"),
    ("TestSetExtensions", v"1.0.0"),
    ("TexExtensions", v"0.1.0"),
    ("TextAnalysis", v"0.1.0"),
    ("TextModel", v"0.1.3"),
    ("TextPlots", v"0.3.0"),
    ("TextWrap", v"0.1.6"),
    ("ThermodynamicsTable", v"0.0.4"),
    ("ThingSpeak", v"0.0.2"),
    ("ThreeJS", v"0.3.0"),
    ("Thrift", v"0.1.0"),
    ("TikzGraphs", v"0.5.1"),
    ("TikzPictures", v"0.4.0"),
    ("TiledIteration", v"0.0.1"),
    ("TimeData", v"0.7.0"),
    ("TimeModels", v"0.0.3"),
    ("TimeSeries", v"0.9.0"),
    ("TimeZones", v"0.4.2"),
    ("TimerOutputs", v"0.0.1"),
    ("Timestamps", v"0.0.4"),
    ("TinySegmenter", v"0.0.4"),
    ("Tk", v"0.4.0"),
    ("ToeplitzMatrices", v"0.1.1"),
    ("TopicModels", v"0.0.1"),
    ("TopicModelsVB", v"0.0.1"),
    ("TrafficAssignment", v"0.4.1"),
    ("TranscodingStreams", v"0.2.0"),
    ("TransformUtils", v"0.0.7"),
    ("Transit", v"0.8.1"),
    ("TravelingSalesmanHeuristics", v"0.0.5"),
    ("Trie", v"0.0.0"),
    ("Turing", v"0.0.4"),
    ("Twitter", v"0.3.0"),
    ("TwoBasedIndexing", v"0.0.1"),
    ("TypeCheck", v"0.0.3"),
    ("Typeclass", v"0.0.1"),
    ("TypedTables", v"0.1.2"),
    ("UAParser", v"0.4.0"),
    ("ULID", v"0.1.0"),
    ("URIParser", v"0.1.8"),
    ("URITemplate", v"0.0.1"),
    ("URLParse", v"0.0.0"),
    ("UTF16", v"0.3.0"),
    ("UUID", v"0.1.0"),
    ("UnalignedVectors", v"0.0.2"),
    ("UnicodeFun", v"0.1.0"),
    ("UnicodePlots", v"0.2.2"),
    ("Units", v"0.2.6"),
    ("Unums", v"0.2.1"),
    ("VLFeat", v"0.0.6"),
    ("VML", v"0.1.0"),
    ("VSL", v"0.0.1"),
    ("VStatistic", v"1.0.0"),
    ("VT100", v"0.0.2"),
    ("ValidatedNumerics", v"0.7.0"),
    ("ValueDispatch", v"0.0.1"),
    ("ValueHistories", v"0.1.0"),
    ("ValueOrientedRiskManagementInsurance", v"0.0.4"),
    ("ValueSymbols", v"1.0.0"),
    ("VarianceComponentTest", v"0.1.3"),
    ("VariationalInequality", v"0.0.4"),
    ("Vectorize", v"0.0.1"),
    ("VectorizedRoutines", v"0.0.2"),
    ("Vega", v"0.6.8"),
    ("VegaLite", v"0.0.3"),
    ("VennEuler", v"0.0.1"),
    ("VideoIO", v"0.1.0"),
    ("VirtualArrays", v"0.1.1"),
    ("VisualRegressionTests", v"0.0.6"),
    ("Voronoi", v"0.0.1"),
    ("VoronoiCells", v"0.1.4"),
    ("VoronoiDelaunay", v"0.1.0"),
    ("Voting", v"0.0.1"),
    ("VulkanCore", v"1.0.0"),
    ("WAV", v"0.8.5"),
    ("WCS", v"0.1.3"),
    ("WCSLIB", v"0.2.1"),
    ("WORLD", v"0.3.0"),
    ("Wallace", v"0.0.1"),
    ("Watcher", v"0.1.1"),
    ("Watershed", v"0.0.1"),
    ("WaveletMatrices", v"0.1.0"),
    ("Wavelets", v"0.5.2"),
    ("WeakRefStrings", v"0.2.0"),
    ("Weave", v"0.1.2"),
    ("WebSockets", v"0.3.0"),
    ("Weber", v"0.5.4"),
    ("WeberCedrus", v"0.1.0"),
    ("WeberDAQmx", v"0.1.0"),
    ("WiltonInts84", v"0.0.2"),
    ("WinRPM", v"0.2.5"),
    ("WinReg", v"0.2.0"),
    ("Winston", v"0.12.1"),
    ("WoodburyMatrices", v"0.2.2"),
    ("Word2Vec", v"0.0.3"),
    ("WordNet", v"0.1.0"),
    ("WorldBankData", v"0.0.5"),
    ("WriteVTK", v"0.5.2"),
    ("XClipboard", v"0.0.3"),
    ("XGBoost", v"0.2.0"),
    ("XMLDict", v"0.0.10"),
    ("XMLRPC", v"0.0.1"),
    ("XMLconvert", v"0.0.1"),
    ("XSV", v"0.0.2"),
    ("XSim", v"0.1.0"),
    ("Xpress", v"0.2.1"),
    ("YAML", v"0.1.10"),
    ("YT", v"0.3.0"),
    ("Yelp", v"0.3.0"),
    ("Yeppp", v"0.1.0"),
    ("ZChop", v"0.1.2"),
    ("ZMQ", v"0.4.3"),
    ("ZVSimulator", v"0.0.0"),
    ("ZipFile", v"0.4.0"),
    ("Zlib", v"0.1.12"),
    ("kNN", v"0.0.0"),
    ("mPulseAPI", v"1.0.6"),
    ])
