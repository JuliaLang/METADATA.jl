if VERSION < v"0.4-"
    startswith = beginswith
end

const url_reg = r"^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?"
const gh_path_reg_git=r"^/(.*)?/(.*)?.git$"

const minjuliaver = v"0.3.0" #Oldest Julia version allowed to be registered
const minpkgver = v"0.0.1"   #Oldest package version allowed to be registered

print_list_3582 = false # set this to true to generate the list of grandfathered
                        # packages permitted under Issue #3582
list_3582 = Any[]

#Issue 2064 - check that all listed packages at at least one tagged version
#2064## Uncomment the #2064# code blocks to generate the list of grandfathered
#2064## packages permitted
for pkg in readdir("METADATA")
    startswith(pkg, ".") && continue
    isfile(joinpath("METADATA", pkg)) && continue
    pkg in [
        "AuditoryFilters",
        "CorpusTools",
        "Elemental",
        "ErrorFreeTransforms",
        "Evapotranspiration",
        "GtkSourceWidget",
        "HiRedis",
        "KrylovMethods",
        "KyotoCabinet",
        "LatexPrint",
        "MachO",
        "MathLink",
        "ObjectiveC",
        "OffsetArrays",
        "Processing",
        "RaggedArrays",
        "RationalExtensions",
        "SignedDistanceFields",
        "SolveBio",
        "SortPerf",
    ] && continue
    if !("versions" in readdir(joinpath("METADATA", pkg)))
        #2064#println("        \"", pkg, "\","); continue
        error("Package $pkg has no tagged versions")
    end
end

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
    @assert (ismatch(r"git", scheme) || ismatch(r"https", scheme)) "Invalid url scheme $scheme for package $(pkg). Should be 'git' or 'https'"
    if ismatch(r"github\.com", host)
        m2 = match(gh_path_reg_git, path)
        @assert m2 != nothing "Invalid GitHub url pattern $url for package $(pkg). Should satisfy $gh_path_reg_git"
        user=m2.captures[1]
        repo=m2.captures[2]

        for (ver, avail) in versions
            #Check that all sha1 files have the correct version hashes
            sha1_file = joinpath("METADATA", pkg, "versions", string(ver), "sha1")
            @assert isfile(sha1_file) "Not a file: $sha1_file"
            sha1fromfile = open(readchomp, sha1_file)
            @assert sha1fromfile == avail.sha1
        end

        #Issue #2057 - naming convention check
        @assert !endswith(pkg, ".jl") "Package name $pkg should not end in .jl"
        @assert endswith(repo, ".jl") "Repository name $repo does not end in .jl"

        sha1_file = joinpath("METADATA", pkg, "versions", string(maxv), "sha1")
        @assert isfile(sha1_file) "File not found: $sha1_file"

        #Issue #3582 - check that newest version of a package is at least minpkgver
        #and furthermore has a requires file listing a minimum Julia version
        #that is at least minjuliaver
        if print_list_3582 || !((pkg, maxv) in ( #List of grandfathered packages
            ("ASCIIPlots", v"0.0.3"), #1
            ("ActiveAppearanceModels", v"0.1.2"), #2
            ("AnsiColor", v"0.0.2"), #3
            ("AppleAccelerate", v"0.1.0"), #4
            ("Arduino", v"0.1.2"), #5
            ("Arrowhead", v"0.0.1"), #6
            ("AudioIO", v"0.1.1"), #7
            ("Autoreload", v"0.2.0"), #8
            ("BDF", v"0.0.5"), #9
            ("BEncode", v"0.1.1"), #10
            ("BSplines", v"0.0.3"), #11
            ("BackpropNeuralNet", v"0.0.3"), #12
            ("BayesNets", v"0.1.0"), #13
            ("Bebop", v"0.0.1"), #14
            ("Benchmark", v"0.1.0"), #15
            ("BenchmarkLite", v"0.1.2"), #16
            ("BioSeq", v"0.3.0"), #17
            ("BiomolecularStructures", v"0.0.1"), #18
            ("Biryani", v"0.2.0"), #19
            ("BlackBoxOptim", v"0.0.1"), #20
            ("BlossomV", v"0.0.1"), #21
            ("BoundingBoxes", v"0.1.0"), #22
            ("Brownian", v"0.0.1"), #23
            ("CLBLAS", v"0.1.0"), #24
            ("CLFFT", v"0.1.0"), #25
            ("CPUTime", v"0.0.4"), #26
            ("CRC32", v"0.0.2"), #27
            ("CRF", v"0.1.1"), #28
            ("CUDA", v"0.1.0"), #29
            ("CUFFT", v"0.0.3"), #30
            ("Calendar", v"0.4.3"), #31
            ("Catalan", v"0.0.3"), #32
            ("CauseMap", v"0.0.3"), #33
            ("CellularAutomata", v"0.1.2"), #34
            ("ChainedVectors", v"0.0.0"), #35
            ("ChaosCommunications", v"0.0.1"), #36
            ("ChemicalKinetics", v"0.1.0"), #37
            ("Church", v"0.0.1"), #38
            ("CirruParser", v"0.0.2"), #39
            ("Clang", v"0.0.5"), #40
            ("Cliffords", v"0.2.3"), #41
            ("Clustering", v"0.4.0"), #42
            ("Codecs", v"0.1.4"), #43
            ("CommonCrawl", v"0.0.1"), #44
            ("CompilerOptions", v"0.1.0"), #45
            ("CompressedSensing", v"0.0.2"), #46
            ("ConfidenceWeighted", v"0.0.2"), #47
            ("ContinuedFractions", v"0.0.0"), #48
            ("Contour", v"0.0.8"), #49
            ("CoreNLP", v"0.1.0"), #50
            ("Cosmology", v"0.1.3"), #51
            ("Cpp", v"0.1.0"), #52
            ("CrossDecomposition", v"0.0.1"), #53
            ("Curl", v"0.0.3"), #54
            ("CurveFit", v"0.0.1"), #55
            ("DASSL", v"0.0.4"), #56
            ("DCEMRI", v"0.1.1"), #57
            ("DICOM", v"0.0.1"), #58
            ("DReal", v"0.0.2"), #59
            ("DWARF", v"0.0.0"), #60
            ("DataFramesMeta", v"0.0.1"), #61
            ("Datetime", v"0.1.7"), #62
            ("DevIL", v"0.2.2"), #63
            ("DictUtils", v"0.0.2"), #64
            ("DimensionalityReduction", v"0.1.2"), #65
            ("DirichletProcessMixtures", v"0.0.1"), #66
            ("DiscreteFactor", v"0.0.0"), #67
            ("Distance", v"0.5.1"), #68
            ("Distances", v"0.2.0"), #69
            ("Docker", v"0.0.0"), #70
            ("DoubleDouble", v"0.1.0"), #71
            ("Dynare", v"0.0.1"), #72
            ("ELF", v"0.0.0"), #73
            ("ERFA", v"0.1.0"), #74
            ("ElasticFDA", v"0.0.4"), #75
            ("Equations", v"0.1.1"), #76
            ("Etcd", v"0.0.1"), #77
            ("ExpressionUtils", v"0.0.0"), #78
            ("FLANN", v"0.0.2"), #79
            ("FaceDatasets", v"0.1.4"), #80
            ("FastArrayOps", v"0.1.0"), #81
            ("FileFind", v"0.0.0"), #82
            ("FinancialMarkets", v"0.1.1"), #83
            ("FiniteStateMachine", v"0.0.2"), #84
            ("FixedPoint", v"0.0.1"), #85
            ("Fixtures", v"0.0.2"), #86
            ("FreeType", v"1.0.1"), #87
            ("FunctionalCollections", v"0.1.2"), #88
            ("FunctionalUtils", v"0.0.0"), #89
            ("GARCH", v"0.1.2"), #90
            ("GLMNet", v"0.0.4"), #91
            ("GLPlot", v"0.0.5"), #92
            ("GLText", v"0.0.4"), #93
            ("GLUT", v"0.4.0"), #94
            ("Gaston", v"0.0.0"), #95
            ("GaussianProcesses", v"0.1.2"), #96
            ("GeneticAlgorithms", v"0.0.3"), #97
            ("GeometricalPredicates", v"0.0.4"), #98
            ("GetC", v"1.1.1"), #99
            ("Gettext", v"0.1.0"), #100
            ("GibbsSeaWater", v"0.0.4"), #101
            ("Glob", v"1.0.1"), #102
            ("GradientBoost", v"0.0.1"), #103
            ("GraphLayout", v"0.2.0"), #104
            ("GreatCircle", v"0.0.1"), #105
            ("HTTP", v"0.0.2"), #106
            ("Hadamard", v"0.1.2"), #107
            ("Helpme", v"0.0.13"), #108
            ("Hexagons", v"0.0.4"), #109
            ("Hiccup", v"0.0.1"), #110
            ("HopfieldNets", v"0.0.0"), #111
            ("HyperDualNumbers", v"0.1.7"), #112
            ("HyperLogLog", v"0.0.0"), #113
            ("HypothesisTests", v"0.2.9"), #114
            ("ICU", v"0.4.4"), #115
            ("IDXParser", v"0.1.0"), #116
            ("IPPCore", v"0.2.1"), #117
            ("IPPDSP", v"0.0.1"), #118
            ("IProfile", v"0.3.1"), #119
            ("IndexedArrays", v"0.1.0"), #120
            ("IniFile", v"0.2.4"), #121
            ("InplaceOps", v"0.0.4"), #122
            ("Instruments", v"0.0.1"), #123
            ("IntervalTrees", v"0.0.4"), #124
            ("Isotonic", v"0.0.1"), #125
            ("IterationManagers", v"0.0.1"), #126
            ("Ito", v"0.0.2"), #127
            ("JFVM", v"0.0.1"), #128
            ("JLDArchives", v"0.0.6"), #129
            ("JPLEphemeris", v"0.2.1"), #130
            ("JellyFish", v"0.0.1"), #131
            ("JointMoments", v"0.2.5"), #132
            ("JudyDicts", v"0.0.0"), #133
            ("JuliaWebRepl", v"0.0.0"), #134
            ("JulieTest", v"0.0.2"), #135
            ("KLDivergence", v"0.0.0"), #136
            ("KernSmooth", v"0.0.3"), #137
            ("KernelDensity", v"0.1.1"), #138
            ("LARS", v"0.0.3"), #139
            ("LIBSVM", v"0.0.1"), #140
            ("LNR", v"0.0.1"), #141
            ("LambertW", v"0.0.4"), #142
            ("LazySequences", v"0.1.0"), #143
            ("LibGit2", v"0.3.8"), #144
            ("LibTrading", v"0.0.1"), #145
            ("LineEdit", v"0.0.1"), #146
            ("LinearMaps", v"0.1.1"), #147
            ("LinguisticData", v"0.0.2"), #148
            ("Lint", v"0.1.68"), #149
            ("Loss", v"0.0.1"), #150
            ("LowDimNearestNeighbors", v"0.0.1"), #151
            ("LowRankModels", v"0.1.0"), #152
            ("Lumira", v"0.0.2"), #153
            ("MAT", v"0.2.12"), #154
            ("MCMC", v"0.3.0"), #155
            ("MDCT", v"0.0.2"), #156
            ("MDPs", v"0.1.1"), #157
            ("MPFI", v"0.0.1"), #158
            ("MUMPS", v"0.0.1"), #159
            ("MachineLearning", v"0.0.3"), #160
            ("ManifoldLearning", v"0.1.0"), #161
            ("MapLight", v"0.0.2"), #162
            ("Markdown", v"0.3.0"), #163
            ("Mathematica", v"0.2.0"), #164
            ("Media", v"0.1.1"), #165
            ("Memoize", v"0.0.0"), #166
            ("Meshing", v"0.0.0"), #167
            ("MessageUtils", v"0.0.2"), #168
            ("MetaTools", v"0.0.1"), #169
            ("MinimalPerfectHashes", v"0.1.2"), #170
            ("MixtureModels", v"0.2.0"), #171
            ("MolecularDynamics", v"0.1.3"), #172
            ("Monads", v"0.0.0"), #173
            ("Mongo", v"0.1.4"), #174
            ("Mongrel2", v"0.0.0"), #175
            ("MsgPackRpcClient", v"0.0.0"), #176
            ("MultiNest", v"0.2.0"), #177
            ("MultiPoly", v"0.0.1"), #178
            ("Multirate", v"0.0.2"), #179
            ("Murmur3", v"0.1.0"), #180
            ("MutableStrings", v"0.0.0"), #181
            ("NFFT", v"0.0.2"), #182
            ("NHST", v"0.0.2"), #183
            ("NIDAQ", v"0.0.2"), #184
            ("NIfTI", v"0.0.4"), #185
            ("NLreg", v"0.1.1"), #186
            ("NMF", v"0.2.4"), #187
            ("NPZ", v"0.0.1"), #188
            ("NaiveBayes", v"0.1.0"), #189
            ("Named", v"0.0.0"), #190
            ("NamedTuples", v"0.0.2"), #191
            ("Neovim", v"0.0.2"), #192
            ("NetCDF", v"0.2.1"), #193
            ("NeuralynxNCS", v"0.0.1"), #194
            ("NumericExtensions", v"0.6.2"), #195
            ("OCCA", v"0.0.1"), #196
            ("ODBC", v"0.3.10"), #197
            ("OSC", v"0.0.1"), #198
            ("OSXNotifier", v"0.0.1"), #199
            ("OpenGL", v"2.0.3"), #200
            ("OpenSSL", v"0.0.0"), #201
            ("OpenSecrets", v"0.0.1"), #202
            ("OpenSlide", v"0.0.1"), #203
            ("OptimPack", v"0.1.2"), #204
            ("Options", v"0.2.5"), #205
            ("Orchestra", v"0.0.5"), #206
            ("PAINTER", v"0.1.2"), #207
            ("PEGParser", v"0.1.2"), #208
            ("PGFPlots", v"1.2.2"), #209
            ("PGM", v"0.0.1"), #210
            ("PLX", v"0.0.5"), #211
            ("PTools", v"0.0.0"), #212
            ("PValueAdjust", v"2.0.0"), #213
            ("Pandas", v"0.2.0"), #214
            ("Pardiso", v"0.0.2"), #215
            ("PatternDispatch", v"0.0.2"), #216
            ("Pedigrees", v"0.0.1"), #217
            ("Permutations", v"0.0.1"), #218
            ("Phylogenetics", v"0.0.2"), #219
            ("PicoSAT", v"0.1.0"), #220
            ("PiecewiseIncreasingRanges", v"0.0.3"), #221
            ("Plotly", v"0.0.3"), #222
            ("PolarFact", v"0.0.5"), #223
            ("Polynomial", v"0.1.1"), #224
            ("PowerSeries", v"0.1.13"), #225
            ("ProgressMeter", v"0.2.1"), #226
            ("ProjectTemplate", v"0.0.1"), #227
            ("Push", v"0.0.1"), #228
            ("PyLexYacc", v"0.0.2"), #229
            ("PySide", v"0.0.2"), #230
            ("Quaternions", v"0.0.4"), #231
            ("QuickCheck", v"0.0.0"), #232
            ("RCall", v"0.2.1"), #233
            ("RDF", v"0.0.1"), #234
            ("RDatasets", v"0.1.2"), #235
            ("REPL", v"0.0.2"), #236
            ("REPLCompletions", v"0.0.3"), #237
            ("RdRand", v"0.0.0"), #238
            ("React", v"0.1.6"), #239
            ("Redis", v"0.0.1"), #240
            ("Reel", v"0.1.0"), #241
            ("Reexport", v"0.0.3"), #242
            ("Resampling", v"0.0.0"), #243
            ("ReverseDiffOverload", v"0.0.1"), #244
            ("Rif", v"0.0.12"), #245
            ("Rmath", v"0.0.0"), #246
            ("RobustShortestPath", v"0.0.1"), #247
            ("RobustStats", v"0.0.1"), #248
            ("RomanNumerals", v"0.1.0"), #249
            ("RudeOil", v"0.1.0"), #250
            ("RunTests", v"0.0.3"), #251
            ("SDE", v"0.3.1"), #252
            ("SDL", v"0.1.5"), #253
            ("SMTPClient", v"0.0.0"), #254
            ("SVM", v"0.0.1"), #255
            ("Sampling", v"0.0.8"), #256
            ("SaveREPL", v"0.0.1"), #257
            ("SemidefiniteProgramming", v"0.1.0"), #258
            ("ShapeModels", v"0.0.3"), #259
            ("ShowSet", v"0.0.1"), #260
            ("SigmoidalProgramming", v"0.0.1"), #261
            ("Silo", v"0.1.0"), #262
            ("Sims", v"0.1.0"), #263
            ("SkyCoords", v"0.1.0"), #264
            ("SliceSampler", v"0.0.0"), #265
            ("Slugify", v"0.1.1"), #266
            ("Smile", v"0.1.3"), #267
            ("SmoothingKernels", v"0.0.0"), #268
            ("Snappy", v"0.0.1"), #269
            ("Sobol", v"0.1.1"), #270
            ("Sodium", v"0.0.0"), #271
            ("Soundex", v"0.0.0"), #272
            ("Sparklines", v"0.1.0"), #273
            ("SpecialMatrices", v"0.1.3"), #274
            ("StackedNets", v"0.0.1"), #275
            ("Stats", v"0.1.0"), #276
            ("StrPack", v"0.0.1"), #277
            ("StreamStats", v"0.0.2"), #278
            ("SuffixArrays", v"0.0.1"), #279
            ("Sundials", v"0.1.3"), #280
            ("SunlightAPIs", v"0.0.3"), #281
            ("Switch", v"0.0.1"), #282
            ("Synchrony", v"0.0.1"), #283
            ("Taro", v"0.2.0"), #284
            ("Tau", v"0.0.3"), #285
            ("TensorOperations", v"0.3.1"), #286
            ("TermWin", v"0.0.31"), #287
            ("TerminalExtensions", v"0.0.2"), #288
            ("Terminals", v"0.0.1"), #289
            ("TestImages", v"0.0.8"), #290
            ("TexExtensions", v"0.0.2"), #291
            ("TextPlots", v"0.3.0"), #292
            ("ThermodynamicsTable", v"0.0.3"), #293
            ("ThingSpeak", v"0.0.2"), #294
            ("TikzGraphs", v"0.0.1"), #295
            ("TimeModels", v"0.0.2"), #296
            ("TopicModels", v"0.0.1"), #297
            ("TrafficAssignment", v"0.0.4"), #298
            ("Trie", v"0.0.0"), #299
            ("TypeCheck", v"0.0.3"), #300
            ("Typeclass", v"0.0.1"), #301
            ("UAParser", v"0.3.0"), #302
            ("URITemplate", v"0.0.1"), #303
            ("URLParse", v"0.0.0"), #304
            ("UTF16", v"0.3.0"), #305
            ("Units", v"0.2.6"), #306
            ("VML", v"0.0.1"), #307
            ("VStatistic", v"1.0.0"), #308
            ("ValueDispatch", v"0.0.0"), #309
            ("VennEuler", v"0.0.1"), #310
            ("VoronoiDelaunay", v"0.0.1"), #311
            ("Voting", v"0.0.1"), #312
            ("Wallace", v"0.0.1"), #313
            ("Winston", v"0.11.13"), #314
            ("WorldBankData", v"0.0.4"), #315
            ("XClipboard", v"0.0.3"), #316
            ("XGBoost", v"0.1.0"), #317
            ("XSV", v"0.0.2"), #318
            ("YT", v"0.2.0"), #319
            ("Yelp", v"0.3.0"), #320
            ("ZChop", v"0.0.2"), #321
            ("ZVSimulator", v"0.0.0"), #322
            ("ZipFile", v"0.2.4"), #323
            ("kNN", v"0.0.0"), #324
            ))
            try
                @assert maxv >= minpkgver "$pkg: version $maxv no longer allowed (>= $minpkgver needed)"

                requires_file = joinpath("METADATA", pkg, "versions", string(maxv), "requires")
                @assert isfile(requires_file) "File not found: $requires_file"
                open(requires_file) do f
                    hasjuliaver = false
                    for line in eachline(f)
                        if startswith(line, "julia")
                            tokens = split(line)
                            @assert length(tokens)>1 "$requires_file: oldest allowed julia version not specified (>= $minjuliaver needed)"
                            juliaver = convert(VersionNumber, tokens[2])
                            @assert juliaver ≥ minjuliaver "$requires_file: oldest allowed julia version $juliaver too old (>= $minjuliaver needed)"
                            hasjuliaver = true
                        end
                    end
                    @assert hasjuliaver "$requires_file: no julia entry (>= $minjuliaver needed)"
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
        println("""            ("$pkg", v"$maxv"), #$npkg""")
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
Pkg.Entry.check_metadata()
