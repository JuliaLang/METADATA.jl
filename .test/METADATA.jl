if VERSION < v"0.4-"
    startswith = beginswith
end

const url_reg = r"^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?"
const gh_path_reg_git=r"^/(.*)?/(.*)?.git$"

const releasejuliaver = v"0.4" #Current release version of Julia
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
        "ErrorFreeTransforms",
        "Evapotranspiration",
        "GtkSourceWidget",
        "HiRedis",
        "KyotoCabinet",
        "LatexPrint",
        "MachO",
        "MathLink",
        "ObjectiveC",
        "OffsetArrays",
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

for (pkg, versions) in Pkg.Read.available()
    url = Pkg.Read.url(pkg)
    if length(versions) <= 0
        error("Package $pkg has no tagged versions.")
    end
    maxv = sort(collect(keys(versions)))[end]
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

        #Issue #3582 - check that newest version of a package is at least minpkgver
        #and furthermore has a requires file listing a minimum Julia version
        #that is at least minjuliaver
        if print_list_3582 || !((pkg, maxv) in ( #List of grandfathered packages
            ("ASCIIPlots", v"0.0.3"), #1
            ("ActiveAppearanceModels", v"0.1.2"), #2
            ("AnsiColor", v"0.0.2"), #3
            ("Arbiter", v"0.0.2"), #4
            ("Arduino", v"0.1.2"), #5
            ("Arrowhead", v"0.0.1"), #6
            ("AudioIO", v"0.1.1"), #7
            ("Autoreload", v"0.2.0"), #8
            ("AxisAlgorithms", v"0.1.4"), #9
            ("BSplines", v"0.0.3"), #10
            ("BaseTestDeprecated", v"0.1.0"), #11
            ("Bebop", v"0.0.1"), #12
            ("Benchmark", v"0.1.0"), #13
            ("BenchmarkLite", v"0.1.2"), #14
            ("Bio", v"0.1.0"), #15
            ("BioSeq", v"0.4.0"), #16
            ("Biryani", v"0.2.0"), #17
            ("Blocks", v"0.1.0"), #18
            ("BlossomV", v"0.0.1"), #19
            ("BoundingBoxes", v"0.1.0"), #20
            ("Brownian", v"0.0.1"), #21
            ("BufferedStreams", v"0.0.2"), #22
            ("CLBLAS", v"0.1.0"), #23
            ("CLFFT", v"0.1.0"), #24
            ("CPUTime", v"0.0.4"), #25
            ("CRC32", v"0.0.2"), #26
            ("CRF", v"0.1.1"), #27
            ("CUBLAS", v"0.0.2"), #28
            ("CUDArt", v"0.2.3"), #29
            ("CUDNN", v"0.3.0"), #30
            ("CURAND", v"0.0.4"), #31
            ("Calendar", v"0.4.3"), #32
            ("Catalan", v"0.0.3"), #33
            ("CauseMap", v"0.0.3"), #34
            ("CellularAutomata", v"0.1.2"), #35
            ("ChainedVectors", v"0.0.0"), #36
            ("ChaosCommunications", v"0.0.1"), #37
            ("ChemicalKinetics", v"0.1.0"), #38
            ("Chipmunk", v"0.0.5"), #39
            ("Church", v"0.0.1"), #40
            ("CirruParser", v"0.0.2"), #41
            ("Clang", v"0.1.0"), #42
            ("Cliffords", v"0.2.3"), #43
            ("ClusterManagers", v"0.0.5"), #44
            ("CommonCrawl", v"0.0.1"), #45
            ("CompilerOptions", v"0.1.0"), #46
            ("CompressedSensing", v"0.0.2"), #47
            ("ConfParser", v"0.0.7"), #48
            ("ConfidenceWeighted", v"0.0.2"), #49
            ("ContinuedFractions", v"0.0.0"), #50
            ("CoreNLP", v"0.1.0"), #51
            ("CoverageBase", v"0.0.3"), #52
            ("Cpp", v"0.1.0"), #53
            ("CrossDecomposition", v"0.0.1"), #54
            ("Curl", v"0.0.3"), #55
            ("DASSL", v"0.0.4"), #56
            ("DICOM", v"0.0.1"), #57
            ("DReal", v"0.0.2"), #58
            ("DSGE", v"0.1.1"), #59
            ("DWARF", v"0.0.0"), #60
            ("Dates", v"0.4.4"), #61
            ("Datetime", v"0.1.7"), #62
            ("DecFP", v"0.1.1"), #63
            ("DeclarativePackages", v"0.1.2"), #64
            ("DevIL", v"0.3.0"), #65
            ("DictFiles", v"0.1.0"), #66
            ("DictUtils", v"0.0.2"), #67
            ("DimensionalityReduction", v"0.1.2"), #68
            ("DirichletProcessMixtures", v"0.0.1"), #69
            ("DiscreteFactor", v"0.0.0"), #70
            ("Distance", v"0.5.1"), #71
            ("Docker", v"0.0.0"), #72
            ("DoubleDouble", v"0.1.0"), #73
            ("Dynare", v"0.0.1"), #74
            ("ELF", v"0.0.0"), #75
            ("Elliptic", v"0.2.0"), #76
            ("Etcd", v"0.0.1"), #77
            ("ExpressionUtils", v"0.0.0"), #78
            ("ExtremelyRandomizedTrees", v"0.1.0"), #79
            ("FMIndexes", v"0.0.1"), #80
            ("FTPClient", v"0.1.1"), #81
            ("Faker", v"0.0.3"), #82
            ("FastAnonymous", v"0.3.2"), #83
            ("FastArrayOps", v"0.1.0"), #84
            ("FileFind", v"0.0.0"), #85
            ("FinancialMarkets", v"0.1.1"), #86
            ("FiniteStateMachine", v"0.0.2"), #87
            ("FixedEffectModels", v"0.2.2"), #88
            ("FixedPoint", v"0.0.1"), #89
            ("Fixtures", v"0.0.2"), #90
            ("FunctionalData", v"0.1.0"), #91
            ("FunctionalDataUtils", v"0.1.0"), #92
            ("FunctionalUtils", v"0.0.0"), #93
            ("GARCH", v"0.1.2"), #94
            ("GLPlot", v"0.0.5"), #95
            ("GLText", v"0.0.4"), #96
            ("GLUT", v"0.4.0"), #97
            ("Gaston", v"0.0.0"), #98
            ("GeneticAlgorithms", v"0.0.3"), #99
            ("GeometricalPredicates", v"0.0.4"), #100
            ("GetC", v"1.1.1"), #101
            ("Gettext", v"0.1.0"), #102
            ("GibbsSeaWater", v"0.0.4"), #103
            ("GradientBoost", v"0.0.1"), #104
            ("Graphics", v"0.1.3"), #105
            ("GreatCircle", v"0.0.1"), #106
            ("Grid", v"0.4.0"), #107
            ("Gtk", v"0.9.3"), #108
            ("HTTP", v"0.0.2"), #109
            ("Hadamard", v"0.1.2"), #110
            ("Helpme", v"0.0.13"), #111
            ("HexEdit", v"0.0.5"), #112
            ("Hexagons", v"0.0.4"), #113
            ("HopfieldNets", v"0.0.0"), #114
            ("HttpCommon", v"0.2.4"), #115
            ("HttpParser", v"0.1.1"), #116
            ("HttpServer", v"0.1.5"), #117
            ("Humanize", v"0.4.0"), #118
            ("Hwloc", v"0.2.0"), #119
            ("HyperDualNumbers", v"0.1.7"), #120
            ("HyperLogLog", v"0.0.0"), #121
            ("ICU", v"0.4.4"), #122
            ("IDRsSolver", v"0.1.3"), #123
            ("IDXParser", v"0.1.0"), #124
            ("IPPCore", v"0.2.1"), #125
            ("IPPDSP", v"0.0.1"), #126
            ("IndexableBitVectors", v"0.1.0"), #127
            ("IndexedArrays", v"0.1.0"), #128
            ("InformedDifferentialEvolution", v"0.1.0"), #129
            ("IntArrays", v"0.0.1"), #130
            ("Interfaces", v"0.0.4"), #131
            ("Isotonic", v"0.0.1"), #132
            ("IterationManagers", v"0.0.1"), #133
            ("Ito", v"0.0.2"), #134
            ("JellyFish", v"0.0.1"), #135
            ("JointMoments", v"0.2.5"), #136
            ("JudyDicts", v"0.0.0"), #137
            ("JuliaWebRepl", v"0.0.0"), #138
            ("JulieTest", v"0.0.2"), #139
            ("Jumos", v"0.2.1"), #140
            ("KLDivergence", v"0.0.0"), #141
            ("KShiftsClustering", v"0.1.0"), #142
            ("KernSmooth", v"0.0.3"), #143
            ("LARS", v"0.0.3"), #144
            ("LIBSVM", v"0.0.1"), #145
            ("LMDB", v"0.0.4"), #146
            ("LRUCache", v"0.0.1"), #147
            ("LaTeX", v"0.1.0"), #148
            ("LambertW", v"0.0.4"), #149
            ("LazySequences", v"0.1.0"), #150
            ("LibGit2", v"0.3.8"), #151
            ("LibTrading", v"0.0.1"), #152
            ("Libz", v"0.0.2"), #153
            ("LineEdit", v"0.0.1"), #154
            ("LinguisticData", v"0.0.2"), #155
            ("Lora", v"0.5.0"), #156
            ("Loss", v"0.0.1"), #157
            ("LowDimNearestNeighbors", v"0.0.1"), #158
            ("Lumira", v"0.0.2"), #159
            ("MATLABCluster", v"0.0.1"), #160
            ("MCMC", v"0.3.0"), #161
            ("MDCT", v"0.0.2"), #162
            ("MDPs", v"0.1.1"), #163
            ("MPFI", v"0.0.1"), #164
            ("MPI", v"0.3.2"), #165
            ("MachineLearning", v"0.0.3"), #166
            ("ManifoldLearning", v"0.1.0"), #167
            ("MapLight", v"0.0.2"), #168
            ("Markdown", v"0.3.0"), #169
            ("MarketTechnicals", v"0.4.1"), #170
            ("Mathematica", v"0.2.0"), #171
            ("MessageUtils", v"0.0.2"), #172
            ("MetaTools", v"0.0.1"), #173
            ("Millboard", v"0.0.6"), #174
            ("MinimalPerfectHashes", v"0.1.2"), #175
            ("MixtureModels", v"0.2.0"), #176
            ("MolecularDynamics", v"0.1.3"), #177
            ("Monads", v"0.0.0"), #178
            ("Mongrel2", v"0.0.0"), #179
            ("MsgPackRpcClient", v"0.0.0"), #180
            ("MultiNest", v"0.2.0"), #181
            ("Multirate", v"0.0.2"), #182
            ("Munkres", v"0.1.0"), #183
            ("MutableStrings", v"0.0.0"), #184
            ("NFFT", v"0.0.2"), #185
            ("NHST", v"0.0.2"), #186
            ("NLreg", v"0.1.1"), #187
            ("NMEA", v"0.0.5"), #188
            ("NMF", v"0.2.4"), #189
            ("NURBS", v"0.0.1"), #190
            ("Named", v"0.0.0"), #191
            ("NamedDimensions", v"0.0.3"), #192
            ("Nemo", v"0.4.1"), #193
            ("Neovim", v"0.0.2"), #194
            ("NeuralynxNCS", v"0.0.1"), #195
            ("NullableArrays", v"0.0.2"), #196
            ("NumericExtensions", v"0.6.2"), #197
            ("OCCA", v"0.0.1"), #198
            ("OSC", v"0.0.1"), #199
            ("OSXNotifier", v"0.0.1"), #200
            ("OpenGL", v"2.0.3"), #201
            ("OpenSSL", v"0.0.0"), #202
            ("OpenSecrets", v"0.0.1"), #203
            ("OpenSlide", v"0.0.1"), #204
            ("OptimPack", v"0.2.0"), #205
            ("Orchestra", v"0.0.5"), #206
            ("PAINTER", v"0.1.2"), #207
            ("PEGParser", v"0.1.2"), #208
            ("PGM", v"0.0.1"), #209
            ("PLX", v"0.0.5"), #210
            ("PTools", v"0.0.0"), #211
            ("PValueAdjust", v"2.0.0"), #212
            ("Pandas", v"0.2.0"), #213
            ("Pardiso", v"0.0.2"), #214
            ("Pcap", v"0.0.2"), #215
            ("Pedigrees", v"0.0.1"), #216
            ("Permutations", v"0.0.1"), #217
            ("Phylogenetics", v"0.0.2"), #218
            ("PicoSAT", v"0.1.0"), #219
            ("Plotly", v"0.0.3"), #220
            ("Polynomial", v"0.1.1"), #221
            ("ProfileView", v"0.1.1"), #222
            ("ProjectTemplate", v"0.0.1"), #223
            ("PropertyGraph", v"0.1.0"), #224
            ("Push", v"0.0.1"), #225
            ("PyLexYacc", v"0.0.2"), #226
            ("PySide", v"0.0.2"), #227
            ("Quandl", v"0.5.4"), #228
            ("QuickCheck", v"0.0.0"), #229
            ("QuickShiftClustering", v"0.1.0"), #230
            ("RDF", v"0.0.1"), #231
            ("RDatasets", v"0.1.2"), #232
            ("REPL", v"0.0.2"), #233
            ("REPLCompletions", v"0.0.3"), #234
            ("RLEVectors", v"0.0.1"), #235
            ("RandomFerns", v"0.1.0"), #236
            ("RdRand", v"0.0.0"), #237
            ("React", v"0.1.6"), #238
            ("Reel", v"0.1.0"), #239
            ("Reexport", v"0.0.3"), #240
            ("Resampling", v"0.0.0"), #241
            ("ReverseDiffOverload", v"0.0.1"), #242
            ("Rif", v"0.0.12"), #243
            ("Rmath", v"0.0.0"), #244
            ("RobustShortestPath", v"0.2.1"), #245
            ("RobustStats", v"0.0.1"), #246
            ("RomanNumerals", v"0.1.0"), #247
            ("RudeOil", v"0.1.0"), #248
            ("RunTests", v"0.0.3"), #249
            ("SDE", v"0.3.1"), #250
            ("SDL", v"0.1.5"), #251
            ("SFML", v"0.1.0"), #252
            ("SVM", v"0.0.1"), #253
            ("Sampling", v"0.0.8"), #254
            ("SaveREPL", v"0.0.1"), #255
            ("ShapeModels", v"0.0.3"), #256
            ("ShowSet", v"0.0.1"), #257
            ("SigmoidalProgramming", v"0.0.1"), #258
            ("Silo", v"0.1.0"), #259
            ("Sims", v"0.1.0"), #260
            ("SkyCoords", v"0.1.0"), #261
            ("SliceSampler", v"0.0.0"), #262
            ("Slugify", v"0.1.1"), #263
            ("SmoothingKernels", v"0.0.0"), #264
            ("Sodium", v"0.0.0"), #265
            ("SoftConfidenceWeighted", v"0.1.2"), #266
            ("Soundex", v"0.0.0"), #267
            ("Sparklines", v"0.1.0"), #268
            ("SparseGrids", v"0.1.0"), #269
            ("SpecialMatrices", v"0.1.3"), #270
            ("StackedNets", v"0.0.1"), #271
            ("Stats", v"0.1.0"), #272
            ("StrPack", v"0.0.1"), #273
            ("StreamStats", v"0.0.2"), #274
            ("StructsOfArrays", v"0.0.3"), #275
            ("SuffixArrays", v"0.0.1"), #276
            ("Sundials", v"0.2.0"), #277
            ("SunlightAPIs", v"0.0.3"), #278
            ("Switch", v"0.0.1"), #279
            ("Synchrony", v"0.0.1"), #280
            ("Tau", v"0.0.3"), #281
            ("TermWin", v"0.0.31"), #282
            ("TerminalExtensions", v"0.0.2"), #283
            ("Terminals", v"0.0.1"), #284
            ("TextPlots", v"0.3.0"), #285
            ("ThingSpeak", v"0.0.2"), #286
            ("TimeSeries", v"0.7.3"), #287
            ("TopicModels", v"0.0.1"), #288
            ("Trie", v"0.0.0"), #289
            ("TypeCheck", v"0.0.3"), #290
            ("Typeclass", v"0.0.1"), #291
            ("URITemplate", v"0.0.1"), #292
            ("URLParse", v"0.0.0"), #293
            ("UTF16", v"0.3.0"), #294
            ("Units", v"0.2.6"), #295
            ("VML", v"0.0.1"), #296
            ("VStatistic", v"1.0.0"), #297
            ("ValueDispatch", v"0.0.0"), #298
            ("VennEuler", v"0.0.1"), #299
            ("VoronoiDelaunay", v"0.0.1"), #300
            ("Voting", v"0.0.1"), #301
            ("Wallace", v"0.0.1"), #302
            ("Watcher", v"0.1.0"), #303
            ("WaveletMatrices", v"0.1.0"), #304
            ("Winston", v"0.11.13"), #305
            ("XClipboard", v"0.0.3"), #306
            ("XGBoost", v"0.1.0"), #307
            ("XSV", v"0.0.2"), #308
            ("Yelp", v"0.3.0"), #309
            ("ZChop", v"0.0.2"), #310
            ("ZVSimulator", v"0.0.0"), #311
            ("kNN", v"0.0.0"), #312
            ))
            try
                if maxv < minpkgver
                    error("$pkg: version $maxv no longer allowed (>= $minpkgver needed)")
                end
                requires_file = joinpath("METADATA", pkg, "versions", string(maxv), "requires")
                if !isfile(requires_file)
                    error("File not found: $requires_file")
                end
                open(requires_file) do f
                    hasjuliaver = false
                    for line in eachline(f)
                        if startswith(line, "julia")
                            tokens = split(line)
                            if length(tokens) <= 1
                                error("$requires_file: oldest allowed julia version not specified (>= $minjuliaver needed)")
                            end
                            juliaver = convert(VersionNumber, tokens[2])
                            if juliaver < minjuliaver
                                error("$requires_file: oldest allowed julia version $juliaver too old (>= $minjuliaver needed)")
                            end
                            if (juliaver < releasejuliaver && juliaver.patch==0 &&
                                (juliaver.prerelease != () || juliaver.build != ()))
                                #No prereleases older than current release allowed
                                error("$requires_file: prerelease $juliaver not allowed (>= $releasejuliaver needed)")
                            end
                            hasjuliaver = true
                        end
                    end
                    if !hasjuliaver
                        error("$requires_file: no julia entry (>= $minjuliaver needed)")
                    end
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

info("Checking that all entries in METADATA are recognized packages...")

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

info("Verifying METADATA...")
Pkg.Entry.check_metadata()
