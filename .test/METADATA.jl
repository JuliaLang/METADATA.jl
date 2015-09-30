if VERSION < v"0.4"
    startswith = beginswith
end

const url_reg = r"^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?"
const gh_path_reg_git=r"^/(.*)?/(.*)?.git$"

const minjuliaver = v"0.3.0" #Oldest Julia version allowed to be registered
const minpkgver = v"0.0.1"   #Oldest package version allowed to be registered
#3582## Uncomment the #3582# code blocks to generate the list of grandfathered
#3582##packages permitted under Issue #3582
#3582#npkg = 1

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
        if !((pkg, maxv) in ( #List of grandfathered packages
            ("AnsiColor", v"0.0.2"), #1
            ("JLDArchives", v"0.0.6"), #2
            ("Mongo", v"0.1.4"), #3
            ("ICU", v"0.4.4"), #4
            ("ElasticFDA", v"0.0.4"), #5
            ("kNN", v"0.0.0"), #6
            ("Plotly", v"0.0.3"), #7
            ("IPPDSP", v"0.0.1"), #8
            ("IndexedArrays", v"0.1.0"), #9
            ("NetCDF", v"0.2.1"), #10
            ("Typeclass", v"0.0.1"), #11
            ("AudioIO", v"0.1.1"), #12
            ("Hexagons", v"0.0.4"), #13
            ("VStatistic", v"1.0.0"), #14
            ("VML", v"0.0.1"), #15
            ("Languages", v"0.0.2"), #16
            ("OptimPack", v"0.1.2"), #17
            ("Trie", v"0.0.0"), #18
            ("YT", v"0.2.0"), #19
            ("FLANN", v"0.0.2"), #20
            ("Polynomial", v"0.1.1"), #21
            ("NHST", v"0.0.2"), #22
            ("VoronoiDelaunay", v"0.0.1"), #23
            ("ELF", v"0.0.0"), #24
            ("Media", v"0.1.1"), #25
            ("Isotonic", v"0.0.1"), #26
            ("HyperLogLog", v"0.0.0"), #27
            ("ZChop", v"0.0.2"), #28
            ("CUFFT", v"0.0.3"), #29
            ("Contour", v"0.0.8"), #30
            ("Sundials", v"0.1.3"), #31
            ("GLAbstraction", v"0.0.5"), #32
            ("MutableStrings", v"0.0.0"), #33
            ("PatternDispatch", v"0.0.2"), #34
            ("Redis", v"0.0.1"), #35
            ("CUDA", v"0.1.0"), #36
            ("LibTrading", v"0.0.1"), #37
            ("Bebop", v"0.0.1"), #38
            ("OSC", v"0.0.1"), #39
            ("JuliaWebRepl", v"0.0.0"), #40
            ("DCEMRI", v"0.1.1"), #41
            ("Curl", v"0.0.3"), #42
            ("BioSeq", v"0.3.0"), #43
            ("Dynare", v"0.0.1"), #44
            ("XSV", v"0.0.2"), #45
            ("IProfile", v"0.3.1"), #46
            ("ProgressMeter", v"0.2.1"), #47
            ("DimensionalityReduction", v"0.1.2"), #48
            ("CompressedSensing", v"0.0.2"), #49
            ("Gaston", v"0.0.0"), #50
            ("PValueAdjust", v"2.0.0"), #51
            ("DReal", v"0.0.2"), #52
            ("Soundex", v"0.0.0"), #53
            ("Etcd", v"0.0.1"), #54
            ("Helpme", v"0.0.13"), #55
            ("BSplines", v"0.0.3"), #56
            ("DoubleDouble", v"0.1.0"), #57
            ("IterationManagers", v"0.0.1"), #58
            ("HopfieldNets", v"0.0.0"), #59
            ("Distance", v"0.5.1"), #60
            ("Silo", v"0.1.0"), #61
            ("StackedNets", v"0.0.1"), #62
            ("JulieTest", v"0.0.2"), #63
            ("InplaceOps", v"0.0.4"), #64
            ("StreamStats", v"0.0.2"), #65
            ("CRC32", v"0.0.2"), #66
            ("MultiPoly", v"0.0.1"), #67
            ("Synchrony", v"0.0.1"), #68
            ("PyLexYacc", v"0.0.2"), #69
            ("RunTests", v"0.0.3"), #70
            ("Wallace", v"0.0.1"), #71
            ("Neovim", v"0.0.2"), #72
            ("BlackBoxOptim", v"0.0.1"), #73
            ("OpenSecrets", v"0.0.1"), #74
            ("PiecewiseIncreasingRanges", v"0.0.3"), #75
            ("OSXNotifier", v"0.0.1"), #76
            ("JellyFish", v"0.0.1"), #77
            ("MessageUtils", v"0.0.2"), #78
            ("Memoize", v"0.0.0"), #79
            ("IDXParser", v"0.1.0"), #80
            ("Meshing", v"0.0.0"), #81
            ("JPLEphemeris", v"0.2.1"), #82
            ("Clustering", v"0.4.0"), #83
            ("Pardiso", v"0.0.2"), #84
            ("PTools", v"0.0.0"), #85
            ("TypeCheck", v"0.0.3"), #86
            ("SDE", v"0.3.1"), #87
            ("ChainedVectors", v"0.0.0"), #88
            ("KernSmooth", v"0.0.3"), #89
            ("Rif", v"0.0.12"), #90
            ("CUBLAS", v"0.0.1"), #91
            ("ChemicalKinetics", v"0.1.0"), #92
            ("CirruParser", v"0.0.2"), #93
            ("MapLight", v"0.0.2"), #94
            ("GibbsSeaWater", v"0.0.4"), #95
            ("URITemplate", v"0.0.1"), #96
            ("Gettext", v"0.1.0"), #97
            ("ActiveAppearanceModels", v"0.1.2"), #98
            ("MetaTools", v"0.0.1"), #99
            ("LARS", v"0.0.3"), #100
            ("NamedTuples", v"0.0.2"), #101
            ("Clang", v"0.0.5"), #102
            ("Sobol", v"0.1.1"), #103
            ("Cosmology", v"0.1.3"), #104
            ("RomanNumerals", v"0.1.0"), #105
            ("RobustShortestPath", v"0.0.1"), #106
            ("CrossDecomposition", v"0.0.1"), #107
            ("OCCA", v"0.0.1"), #108
            ("Murmur3", v"0.1.0"), #109
            ("MCMC", v"0.3.0"), #110
            ("NumericExtensions", v"0.6.2"), #111
            ("BoundingBoxes", v"0.1.0"), #112
            ("PLX", v"0.0.5"), #113
            ("PEGParser", v"0.1.2"), #114
            ("CLBLAS", v"0.1.0"), #115
            ("AppleAccelerate", v"0.1.0"), #116
            ("NIDAQ", v"0.0.2"), #117
            ("Mongrel2", v"0.0.0"), #118
            ("LinguisticData", v"0.0.2"), #119
            ("FastArrayOps", v"0.1.0"), #120
            ("JudyDicts", v"0.0.0"), #121
            ("Debug", v"0.1.4"), #122
            ("CommonCrawl", v"0.0.1"), #123
            ("NPZ", v"0.0.1"), #124
            ("SuffixArrays", v"0.0.1"), #125
            ("ERFA", v"0.1.0"), #126
            ("Arduino", v"0.1.2"), #127
            ("Phylogenetics", v"0.0.2"), #128
            ("GLWindow", v"0.0.5"), #129
            ("NIfTI", v"0.0.4"), #130
            ("Quaternions", v"0.0.4"), #131
            ("Stats", v"0.1.0"), #132
            ("BenchmarkLite", v"0.1.2"), #133
            ("SDL", v"0.1.5"), #134
            ("GreatCircle", v"0.0.1"), #135
            ("DirichletProcessMixtures", v"0.0.1"), #136
            ("Rmath", v"0.0.0"), #137
            ("TerminalExtensions", v"0.0.2"), #138
            ("Ito", v"0.0.2"), #139
            ("XGBoost", v"0.1.0"), #140
            ("DevIL", v"0.2.2"), #141
            ("Cliffords", v"0.2.3"), #142
            ("HTTP", v"0.0.2"), #143
            ("BayesNets", v"0.1.0"), #144
            ("ShowSet", v"0.0.1"), #145
            ("PGFPlots", v"1.2.2"), #146
            ("FileFind", v"0.0.0"), #147
            ("CompilerOptions", v"0.1.0"), #148
            ("Pedigrees", v"0.0.1"), #149
            ("RDF", v"0.0.1"), #150
            ("TestImages", v"0.0.8"), #151
            ("PicoSAT", v"0.1.0"), #152
            ("Pandas", v"0.2.0"), #153
            ("Loss", v"0.0.1"), #154
            ("IniFile", v"0.2.4"), #155
            ("Fixtures", v"0.0.2"), #156
            ("ConfidenceWeighted", v"0.0.2"), #157
            ("Sodium", v"0.0.0"), #158
            ("DWARF", v"0.0.0"), #159
            ("ThermodynamicsTable", v"0.0.3"), #160
            ("LazySequences", v"0.1.0"), #161
            ("ModernGL", v"0.0.5"), #162
            ("LineEdit", v"0.0.1"), #163
            ("Sampling", v"0.0.8"), #164
            ("Lint", v"0.1.68"), #165
            ("ReverseDiffOverload", v"0.0.1"), #166
            ("LibGit2", v"0.3.8"), #167
            ("RudeOil", v"0.1.0"), #168
            ("React", v"0.1.6"), #169
            ("CurveFit", v"0.0.1"), #170
            ("FinancialMarkets", v"0.1.1"), #171
            ("IntervalTrees", v"0.0.4"), #172
            ("SmoothingKernels", v"0.0.0"), #173
            ("TermWin", v"0.0.31"), #174
            ("TimeModels", v"0.0.2"), #175
            ("Orchestra", v"0.0.5"), #176
            ("Monads", v"0.0.0"), #177
            ("Docker", v"0.0.0"), #178
            ("DiscreteFactor", v"0.0.0"), #179
            ("CUDNN", v"0.1.0"), #180
            ("NaiveBayes", v"0.1.0"), #181
            ("Resampling", v"0.0.0"), #182
            ("Lumira", v"0.0.2"), #183
            ("ZipFile", v"0.2.4"), #184
            ("LowDimNearestNeighbors", v"0.0.1"), #185
            ("UAParser", v"0.3.0"), #186
            ("TensorOperations", v"0.3.1"), #187
            ("QuickCheck", v"0.0.0"), #188
            ("LowRankModels", v"0.1.0"), #189
            ("PAINTER", v"0.1.2"), #190
            ("LambertW", v"0.0.4"), #191
            ("MDPs", v"0.1.1"), #192
            ("OpenSSL", v"0.0.0"), #193
            ("REPLCompletions", v"0.0.3"), #194
            ("MachineLearning", v"0.0.3"), #195
            ("NMF", v"0.2.4"), #196
            ("BiomolecularStructures", v"0.0.1"), #197
            ("JointMoments", v"0.2.5"), #198
            ("ASCIIPlots", v"0.0.3"), #199
            ("GetC", v"1.1.1"), #200
            ("GLText", v"0.0.4"), #201
            ("FunctionalUtils", v"0.0.0"), #202
            ("Glob", v"1.0.1"), #203
            ("SpecialMatrices", v"0.1.3"), #204
            ("MixtureModels", v"0.2.0"), #205
            ("Voting", v"0.0.1"), #206
            ("Yelp", v"0.3.0"), #207
            ("ProjectTemplate", v"0.0.1"), #208
            ("Slugify", v"0.1.1"), #209
            ("OpenGL", v"2.0.3"), #210
            ("Named", v"0.0.0"), #211
            ("PySide", v"0.0.2"), #212
            ("BackpropNeuralNet", v"0.0.3"), #213
            ("Calendar", v"0.4.3"), #214
            ("Arrowhead", v"0.0.1"), #215
            ("REPL", v"0.0.2"), #216
            ("Autoreload", v"0.2.0"), #217
            ("CoreNLP", v"0.1.0"), #218
            ("GeometricalPredicates", v"0.0.4"), #219
            ("CauseMap", v"0.0.3"), #220
            ("Mathematica", v"0.2.0"), #221
            ("SkyCoords", v"0.1.0"), #222
            ("HypothesisTests", v"0.2.9"), #223
            ("GaussianProcesses", v"0.1.2"), #224
            ("SaveREPL", v"0.0.1"), #225
            ("MDCT", v"0.0.2"), #226
            ("Codecs", v"0.1.4"), #227
            ("GeneticAlgorithms", v"0.0.3"), #228
            ("Datetime", v"0.1.7"), #229
            ("ManifoldLearning", v"0.1.0"), #230
            ("Thrift", v"0.0.1"), #231
            ("PGM", v"0.0.1"), #232
            ("Reel", v"0.1.0"), #233
            ("ODBC", v"0.3.10"), #234
            ("Permutations", v"0.0.1"), #235
            ("Instruments", v"0.0.1"), #236
            ("SMTPClient", v"0.0.0"), #237
            ("StrPack", v"0.0.1"), #238
            ("TexExtensions", v"0.0.2"), #239
            ("KernelDensity", v"0.1.1"), #240
            ("Cpp", v"0.1.0"), #241
            ("Equations", v"0.1.1"), #242
            ("DataFramesMeta", v"0.0.1"), #243
            ("Distances", v"0.2.0"), #244
            ("Reexport", v"0.0.3"), #245
            ("OpenSlide", v"0.0.1"), #246
            ("ZVSimulator", v"0.0.0"), #247
            ("GLUT", v"0.4.0"), #248
            ("Push", v"0.0.1"), #249
            ("FixedPoint", v"0.0.1"), #250
            ("Benchmark", v"0.1.0"), #251
            ("PolarFact", v"0.0.5"), #252
            ("ShapeModels", v"0.0.3"), #253
            ("PowerSeries", v"0.1.13"), #254
            ("BlossomV", v"0.0.1"), #255
            ("MPFI", v"0.0.1"), #256
            ("DictUtils", v"0.0.2"), #257
            ("SigmoidalProgramming", v"0.0.1"), #258
            ("FreeType", v"1.0.1"), #259
            ("Switch", v"0.0.1"), #260
            ("Biryani", v"0.2.0"), #261
            ("Tau", v"0.0.3"), #262
            ("TextPlots", v"0.3.0"), #263
            ("URLParse", v"0.0.0"), #264
            ("LIBSVM", v"0.0.1"), #265
            ("ThingSpeak", v"0.0.2"), #266
            ("TopicModels", v"0.0.1"), #267
            ("Options", v"0.2.5"), #268
            ("Multirate", v"0.0.2"), #269
            ("ChaosCommunications", v"0.0.1"), #270
            ("Jacobi", v"0.1.0"), #271
            ("Markdown", v"0.3.0"), #272
            ("KLDivergence", v"0.0.0"), #273
            ("DICOM", v"0.0.1"), #274
            ("NeuralynxNCS", v"0.0.1"), #275
            ("MAT", v"0.2.12"), #276
            ("GLMNet", v"0.0.4"), #277
            ("BDF", v"0.0.5"), #278
            ("Terminals", v"0.0.1"), #279
            ("CLFFT", v"0.1.0"), #280
            ("Hadamard", v"0.1.2"), #281
            ("Brownian", v"0.0.1"), #282
            ("Church", v"0.0.1"), #283
            ("SunlightAPIs", v"0.0.3"), #284
            ("FiniteStateMachine", v"0.0.2"), #285
            ("Smile", v"0.1.3"), #286
            ("LinearMaps", v"0.1.1"), #287
            ("CRF", v"0.1.1"), #288
            ("SVM", v"0.0.1"), #289
            ("Snappy", v"0.0.1"), #290
            ("BEncode", v"0.1.1"), #291
            ("NLreg", v"0.1.1"), #292
            ("GraphLayout", v"0.2.0"), #293
            ("LNR", v"0.0.1"), #294
            ("JFVM", v"0.0.1"), #295
            ("NFFT", v"0.0.2"), #296
            ("NumericFuns", v"0.2.3"), #297
            ("Taro", v"0.2.0"), #298
            ("FunctionalCollections", v"0.1.2"), #299
            ("MinimalPerfectHashes", v"0.1.2"), #300
            ("XClipboard", v"0.0.3"), #301
            ("RdRand", v"0.0.0"), #302
            ("ExpressionUtils", v"0.0.0"), #303
            ("ContinuedFractions", v"0.0.0"), #304
            ("RCall", v"0.2.1"), #305
            ("MolecularDynamics", v"0.1.3"), #306
            ("SliceSampler", v"0.0.0"), #307
            ("MsgPackRpcClient", v"0.0.0"), #308
            ("WorldBankData", v"0.0.4"), #309
            ("Winston", v"0.11.13"), #310
            ("TrafficAssignment", v"0.0.4"), #311
            ("UTF16", v"0.3.0"), #312
            ("Catalan", v"0.0.3"), #313
            ("RobustStats", v"0.0.1"), #314
            ("SemidefiniteProgramming", v"0.1.0"), #315
            ("Sims", v"0.1.0"), #316
            ("Units", v"0.2.6"), #317
            ("MultiNest", v"0.2.0"), #318
            ("MUMPS", v"0.0.1"), #319
            ("CellularAutomata", v"0.1.2"), #320
            ("GradientBoost", v"0.0.1"), #321
            ("Sparklines", v"0.1.0"), #322
            ("DASSL", v"0.0.4"), #323
            ("FaceDatasets", v"0.1.4"), #324
            ("Hiccup", v"0.0.1"), #325
            ("GARCH", v"0.1.2"), #326
            ("CPUTime", v"0.0.4"), #327
            ("IPPCore", v"0.2.1"), #328
            ("GLPlot", v"0.0.5"), #329
            ("ValueDispatch", v"0.0.0"), #330
            ("HyperDualNumbers", v"0.1.7"), #331
            ("RDatasets", v"0.1.2"), #332
            ("TikzGraphs", v"0.0.1"), #333
            ("VennEuler", v"0.0.1"), #334
            ))
            #3582#try
            @assert maxv >= minpkgver "$pkg: version $maxv no longer allowed (>= $minpkgver needed)"

            requires_file = joinpath("METADATA", pkg, "versions", string(maxv), "requires")
            @assert isfile(requires_file) "File not found: $requires_file"
            open(requires_file) do f
                hasjuliaver = false
                for line in eachline(f)
                   if startswith(line, "julia")
                       tokens = split(line)
                       @assert length(tokens)>1 "$requires_file: oldest allowed julia version not specified (>= $minjuliver needed)"
                       juliaver = VersionNumber(tokens[2])
                       @assert juliaver ≥ minjuliaver "$requires_file: oldest allowed julia version $juliaver too old (>= $minjuliaver needed)"
                       hasjuliaver = true
                   end
                end
                @assert hasjuliaver "$requires_file: no julia entry (>= $minjuliaver needed)"
            end
            #3582#catch
            #3582#    println("""            ("$pkg", $maxv), #npkg""")
            #3582#    npkg += 1
            #3582#end
        end
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
