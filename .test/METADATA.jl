if VERSION < v"0.4"
    startswith = beginswith
end

const url_reg = r"^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?"
const gh_path_reg_git=r"^/(.*)?/(.*)?.git$"

const minjuliaver = v"0.3.0" #Oldest Julia version allowed to be registered
const minpkgver = v"0.0.1"   #Oldest package version allowed to be registered
print_list_3582 = false # set this to true to generate the list of grandfathered
                        # packages permitted under Issue #3582
list_3582 = Any[]

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
            ("CUBLAS", v"0.0.1"), #29
            ("CUDA", v"0.1.0"), #30
            ("CUDNN", v"0.1.0"), #31
            ("CUFFT", v"0.0.3"), #32
            ("Calendar", v"0.4.3"), #33
            ("Catalan", v"0.0.3"), #34
            ("CauseMap", v"0.0.3"), #35
            ("CellularAutomata", v"0.1.2"), #36
            ("ChainedVectors", v"0.0.0"), #37
            ("ChaosCommunications", v"0.0.1"), #38
            ("ChemicalKinetics", v"0.1.0"), #39
            ("Church", v"0.0.1"), #40
            ("CirruParser", v"0.0.2"), #41
            ("Clang", v"0.0.5"), #42
            ("Cliffords", v"0.2.3"), #43
            ("Clustering", v"0.4.0"), #44
            ("Codecs", v"0.1.4"), #45
            ("CommonCrawl", v"0.0.1"), #46
            ("CompilerOptions", v"0.1.0"), #47
            ("CompressedSensing", v"0.0.2"), #48
            ("ConfidenceWeighted", v"0.0.2"), #49
            ("ContinuedFractions", v"0.0.0"), #50
            ("Contour", v"0.0.8"), #51
            ("CoreNLP", v"0.1.0"), #52
            ("Cosmology", v"0.1.3"), #53
            ("Cpp", v"0.1.0"), #54
            ("CrossDecomposition", v"0.0.1"), #55
            ("Curl", v"0.0.3"), #56
            ("CurveFit", v"0.0.1"), #57
            ("DASSL", v"0.0.4"), #58
            ("DCEMRI", v"0.1.1"), #59
            ("DICOM", v"0.0.1"), #60
            ("DReal", v"0.0.2"), #61
            ("DWARF", v"0.0.0"), #62
            ("DataFramesMeta", v"0.0.1"), #63
            ("Datetime", v"0.1.7"), #64
            ("Debug", v"0.1.4"), #65
            ("DevIL", v"0.2.2"), #66
            ("DictUtils", v"0.0.2"), #67
            ("DimensionalityReduction", v"0.1.2"), #68
            ("DirichletProcessMixtures", v"0.0.1"), #69
            ("DiscreteFactor", v"0.0.0"), #70
            ("Distance", v"0.5.1"), #71
            ("Distances", v"0.2.0"), #72
            ("Docker", v"0.0.0"), #73
            ("DoubleDouble", v"0.1.0"), #74
            ("Dynare", v"0.0.1"), #75
            ("ELF", v"0.0.0"), #76
            ("ERFA", v"0.1.0"), #77
            ("ElasticFDA", v"0.0.4"), #78
            ("Equations", v"0.1.1"), #79
            ("Etcd", v"0.0.1"), #80
            ("ExpressionUtils", v"0.0.0"), #81
            ("FLANN", v"0.0.2"), #82
            ("FaceDatasets", v"0.1.4"), #83
            ("FastArrayOps", v"0.1.0"), #84
            ("FileFind", v"0.0.0"), #85
            ("FinancialMarkets", v"0.1.1"), #86
            ("FiniteStateMachine", v"0.0.2"), #87
            ("FixedPoint", v"0.0.1"), #88
            ("Fixtures", v"0.0.2"), #89
            ("FreeType", v"1.0.1"), #90
            ("FunctionalCollections", v"0.1.2"), #91
            ("FunctionalUtils", v"0.0.0"), #92
            ("GARCH", v"0.1.2"), #93
            ("GLAbstraction", v"0.0.5"), #94
            ("GLMNet", v"0.0.4"), #95
            ("GLPlot", v"0.0.5"), #96
            ("GLText", v"0.0.4"), #97
            ("GLUT", v"0.4.0"), #98
            ("GLWindow", v"0.0.5"), #99
            ("Gaston", v"0.0.0"), #100
            ("GaussianProcesses", v"0.1.2"), #101
            ("GeneticAlgorithms", v"0.0.3"), #102
            ("GeometricalPredicates", v"0.0.4"), #103
            ("GetC", v"1.1.1"), #104
            ("Gettext", v"0.1.0"), #105
            ("GibbsSeaWater", v"0.0.4"), #106
            ("Glob", v"1.0.1"), #107
            ("GradientBoost", v"0.0.1"), #108
            ("GraphLayout", v"0.2.0"), #109
            ("GreatCircle", v"0.0.1"), #110
            ("HTTP", v"0.0.2"), #111
            ("Hadamard", v"0.1.2"), #112
            ("Helpme", v"0.0.13"), #113
            ("Hexagons", v"0.0.4"), #114
            ("Hiccup", v"0.0.1"), #115
            ("HopfieldNets", v"0.0.0"), #116
            ("HyperDualNumbers", v"0.1.7"), #117
            ("HyperLogLog", v"0.0.0"), #118
            ("HypothesisTests", v"0.2.9"), #119
            ("ICU", v"0.4.4"), #120
            ("IDXParser", v"0.1.0"), #121
            ("IPPCore", v"0.2.1"), #122
            ("IPPDSP", v"0.0.1"), #123
            ("IProfile", v"0.3.1"), #124
            ("IndexedArrays", v"0.1.0"), #125
            ("IniFile", v"0.2.4"), #126
            ("InplaceOps", v"0.0.4"), #127
            ("Instruments", v"0.0.1"), #128
            ("IntervalTrees", v"0.0.4"), #129
            ("Isotonic", v"0.0.1"), #130
            ("IterationManagers", v"0.0.1"), #131
            ("Ito", v"0.0.2"), #132
            ("JFVM", v"0.0.1"), #133
            ("JLDArchives", v"0.0.6"), #134
            ("JPLEphemeris", v"0.2.1"), #135
            ("Jacobi", v"0.1.0"), #136
            ("JellyFish", v"0.0.1"), #137
            ("JointMoments", v"0.2.5"), #138
            ("JudyDicts", v"0.0.0"), #139
            ("JuliaWebRepl", v"0.0.0"), #140
            ("JulieTest", v"0.0.2"), #141
            ("KLDivergence", v"0.0.0"), #142
            ("KernSmooth", v"0.0.3"), #143
            ("KernelDensity", v"0.1.1"), #144
            ("LARS", v"0.0.3"), #145
            ("LIBSVM", v"0.0.1"), #146
            ("LNR", v"0.0.1"), #147
            ("LambertW", v"0.0.4"), #148
            ("Languages", v"0.0.2"), #149
            ("LazySequences", v"0.1.0"), #150
            ("LibGit2", v"0.3.8"), #151
            ("LibTrading", v"0.0.1"), #152
            ("LineEdit", v"0.0.1"), #153
            ("LinearMaps", v"0.1.1"), #154
            ("LinguisticData", v"0.0.2"), #155
            ("Lint", v"0.1.68"), #156
            ("Loss", v"0.0.1"), #157
            ("LowDimNearestNeighbors", v"0.0.1"), #158
            ("LowRankModels", v"0.1.0"), #159
            ("Lumira", v"0.0.2"), #160
            ("MAT", v"0.2.12"), #161
            ("MCMC", v"0.3.0"), #162
            ("MDCT", v"0.0.2"), #163
            ("MDPs", v"0.1.1"), #164
            ("MPFI", v"0.0.1"), #165
            ("MUMPS", v"0.0.1"), #166
            ("MachineLearning", v"0.0.3"), #167
            ("ManifoldLearning", v"0.1.0"), #168
            ("MapLight", v"0.0.2"), #169
            ("Markdown", v"0.3.0"), #170
            ("Mathematica", v"0.2.0"), #171
            ("Media", v"0.1.1"), #172
            ("Memoize", v"0.0.0"), #173
            ("Meshing", v"0.0.0"), #174
            ("MessageUtils", v"0.0.2"), #175
            ("MetaTools", v"0.0.1"), #176
            ("MinimalPerfectHashes", v"0.1.2"), #177
            ("MixtureModels", v"0.2.0"), #178
            ("ModernGL", v"0.0.5"), #179
            ("MolecularDynamics", v"0.1.3"), #180
            ("Monads", v"0.0.0"), #181
            ("Mongo", v"0.1.4"), #182
            ("Mongrel2", v"0.0.0"), #183
            ("MsgPackRpcClient", v"0.0.0"), #184
            ("MultiNest", v"0.2.0"), #185
            ("MultiPoly", v"0.0.1"), #186
            ("Multirate", v"0.0.2"), #187
            ("Murmur3", v"0.1.0"), #188
            ("MutableStrings", v"0.0.0"), #189
            ("NFFT", v"0.0.2"), #190
            ("NHST", v"0.0.2"), #191
            ("NIDAQ", v"0.0.2"), #192
            ("NIfTI", v"0.0.4"), #193
            ("NLreg", v"0.1.1"), #194
            ("NMF", v"0.2.4"), #195
            ("NPZ", v"0.0.1"), #196
            ("NaiveBayes", v"0.1.0"), #197
            ("Named", v"0.0.0"), #198
            ("NamedTuples", v"0.0.2"), #199
            ("Neovim", v"0.0.2"), #200
            ("NetCDF", v"0.2.1"), #201
            ("NeuralynxNCS", v"0.0.1"), #202
            ("NumericExtensions", v"0.6.2"), #203
            ("NumericFuns", v"0.2.3"), #204
            ("OCCA", v"0.0.1"), #205
            ("ODBC", v"0.3.10"), #206
            ("OSC", v"0.0.1"), #207
            ("OSXNotifier", v"0.0.1"), #208
            ("OpenGL", v"2.0.3"), #209
            ("OpenSSL", v"0.0.0"), #210
            ("OpenSecrets", v"0.0.1"), #211
            ("OpenSlide", v"0.0.1"), #212
            ("OptimPack", v"0.1.2"), #213
            ("Options", v"0.2.5"), #214
            ("Orchestra", v"0.0.5"), #215
            ("PAINTER", v"0.1.2"), #216
            ("PEGParser", v"0.1.2"), #217
            ("PGFPlots", v"1.2.2"), #218
            ("PGM", v"0.0.1"), #219
            ("PLX", v"0.0.5"), #220
            ("PTools", v"0.0.0"), #221
            ("PValueAdjust", v"2.0.0"), #222
            ("Pandas", v"0.2.0"), #223
            ("Pardiso", v"0.0.2"), #224
            ("PatternDispatch", v"0.0.2"), #225
            ("Pedigrees", v"0.0.1"), #226
            ("Permutations", v"0.0.1"), #227
            ("Phylogenetics", v"0.0.2"), #228
            ("PicoSAT", v"0.1.0"), #229
            ("PiecewiseIncreasingRanges", v"0.0.3"), #230
            ("Plotly", v"0.0.3"), #231
            ("PolarFact", v"0.0.5"), #232
            ("Polynomial", v"0.1.1"), #233
            ("PowerSeries", v"0.1.13"), #234
            ("ProgressMeter", v"0.2.1"), #235
            ("ProjectTemplate", v"0.0.1"), #236
            ("Push", v"0.0.1"), #237
            ("PyLexYacc", v"0.0.2"), #238
            ("PySide", v"0.0.2"), #239
            ("Quaternions", v"0.0.4"), #240
            ("QuickCheck", v"0.0.0"), #241
            ("RCall", v"0.2.1"), #242
            ("RDF", v"0.0.1"), #243
            ("RDatasets", v"0.1.2"), #244
            ("REPL", v"0.0.2"), #245
            ("REPLCompletions", v"0.0.3"), #246
            ("RdRand", v"0.0.0"), #247
            ("React", v"0.1.6"), #248
            ("Redis", v"0.0.1"), #249
            ("Reel", v"0.1.0"), #250
            ("Reexport", v"0.0.3"), #251
            ("Resampling", v"0.0.0"), #252
            ("ReverseDiffOverload", v"0.0.1"), #253
            ("Rif", v"0.0.12"), #254
            ("Rmath", v"0.0.0"), #255
            ("RobustShortestPath", v"0.0.1"), #256
            ("RobustStats", v"0.0.1"), #257
            ("RomanNumerals", v"0.1.0"), #258
            ("RudeOil", v"0.1.0"), #259
            ("RunTests", v"0.0.3"), #260
            ("SDE", v"0.3.1"), #261
            ("SDL", v"0.1.5"), #262
            ("SMTPClient", v"0.0.0"), #263
            ("SVM", v"0.0.1"), #264
            ("Sampling", v"0.0.8"), #265
            ("SaveREPL", v"0.0.1"), #266
            ("SemidefiniteProgramming", v"0.1.0"), #267
            ("ShapeModels", v"0.0.3"), #268
            ("ShowSet", v"0.0.1"), #269
            ("SigmoidalProgramming", v"0.0.1"), #270
            ("Silo", v"0.1.0"), #271
            ("Sims", v"0.1.0"), #272
            ("SkyCoords", v"0.1.0"), #273
            ("SliceSampler", v"0.0.0"), #274
            ("Slugify", v"0.1.1"), #275
            ("Smile", v"0.1.3"), #276
            ("SmoothingKernels", v"0.0.0"), #277
            ("Snappy", v"0.0.1"), #278
            ("Sobol", v"0.1.1"), #279
            ("Sodium", v"0.0.0"), #280
            ("Soundex", v"0.0.0"), #281
            ("Sparklines", v"0.1.0"), #282
            ("SpecialMatrices", v"0.1.3"), #283
            ("StackedNets", v"0.0.1"), #284
            ("Stats", v"0.1.0"), #285
            ("StrPack", v"0.0.1"), #286
            ("StreamStats", v"0.0.2"), #287
            ("SuffixArrays", v"0.0.1"), #288
            ("Sundials", v"0.1.3"), #289
            ("SunlightAPIs", v"0.0.3"), #290
            ("Switch", v"0.0.1"), #291
            ("Synchrony", v"0.0.1"), #292
            ("Taro", v"0.2.0"), #293
            ("Tau", v"0.0.3"), #294
            ("TensorOperations", v"0.3.1"), #295
            ("TermWin", v"0.0.31"), #296
            ("TerminalExtensions", v"0.0.2"), #297
            ("Terminals", v"0.0.1"), #298
            ("TestImages", v"0.0.8"), #299
            ("TexExtensions", v"0.0.2"), #300
            ("TextPlots", v"0.3.0"), #301
            ("ThermodynamicsTable", v"0.0.3"), #302
            ("ThingSpeak", v"0.0.2"), #303
            ("Thrift", v"0.0.1"), #304
            ("TikzGraphs", v"0.0.1"), #305
            ("TimeModels", v"0.0.2"), #306
            ("TopicModels", v"0.0.1"), #307
            ("TrafficAssignment", v"0.0.4"), #308
            ("Trie", v"0.0.0"), #309
            ("TypeCheck", v"0.0.3"), #310
            ("Typeclass", v"0.0.1"), #311
            ("UAParser", v"0.3.0"), #312
            ("URITemplate", v"0.0.1"), #313
            ("URLParse", v"0.0.0"), #314
            ("UTF16", v"0.3.0"), #315
            ("Units", v"0.2.6"), #316
            ("VML", v"0.0.1"), #317
            ("VStatistic", v"1.0.0"), #318
            ("ValueDispatch", v"0.0.0"), #319
            ("VennEuler", v"0.0.1"), #320
            ("VoronoiDelaunay", v"0.0.1"), #321
            ("Voting", v"0.0.1"), #322
            ("Wallace", v"0.0.1"), #323
            ("Winston", v"0.11.13"), #324
            ("WorldBankData", v"0.0.4"), #325
            ("XClipboard", v"0.0.3"), #326
            ("XGBoost", v"0.1.0"), #327
            ("XSV", v"0.0.2"), #328
            ("YT", v"0.2.0"), #329
            ("Yelp", v"0.3.0"), #330
            ("ZChop", v"0.0.2"), #331
            ("ZVSimulator", v"0.0.0"), #332
            ("ZipFile", v"0.2.4"), #333
            ("kNN", v"0.0.0"), #334
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
