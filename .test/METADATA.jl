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
            ("Dates", v"0.4.4"), #60
            ("Datetime", v"0.1.7"), #61
            ("DecFP", v"0.1.1"), #62
            ("DeclarativePackages", v"0.1.2"), #63
            ("DevIL", v"0.3.0"), #64
            ("DictFiles", v"0.1.0"), #65
            ("DictUtils", v"0.0.2"), #66
            ("DimensionalityReduction", v"0.1.2"), #67
            ("DirichletProcessMixtures", v"0.0.1"), #68
            ("DiscreteFactor", v"0.0.0"), #69
            ("Distance", v"0.5.1"), #70
            ("Docker", v"0.0.0"), #71
            ("DoubleDouble", v"0.1.0"), #72
            ("Dynare", v"0.0.1"), #73
            ("Elliptic", v"0.2.0"), #74
            ("Etcd", v"0.0.1"), #75
            ("ExtremelyRandomizedTrees", v"0.1.0"), #76
            ("FMIndexes", v"0.0.1"), #77
            ("FTPClient", v"0.1.1"), #78
            ("Faker", v"0.0.3"), #79
            ("FastAnonymous", v"0.3.2"), #80
            ("FastArrayOps", v"0.1.0"), #81
            ("FileFind", v"0.0.0"), #82
            ("FinancialMarkets", v"0.1.1"), #83
            ("FiniteStateMachine", v"0.0.2"), #84
            ("FixedEffectModels", v"0.2.2"), #85
            ("FixedPoint", v"0.0.1"), #86
            ("Fixtures", v"0.0.2"), #87
            ("FunctionalData", v"0.1.0"), #88
            ("FunctionalDataUtils", v"0.1.0"), #89
            ("FunctionalUtils", v"0.0.0"), #90
            ("GARCH", v"0.1.2"), #91
            ("GLPlot", v"0.0.5"), #92
            ("GLText", v"0.0.4"), #93
            ("GLUT", v"0.4.0"), #94
            ("Gaston", v"0.0.0"), #95
            ("GeneticAlgorithms", v"0.0.3"), #96
            ("GeometricalPredicates", v"0.0.4"), #97
            ("GetC", v"1.1.1"), #98
            ("Gettext", v"0.1.0"), #99
            ("GibbsSeaWater", v"0.0.4"), #100
            ("GradientBoost", v"0.0.1"), #101
            ("Graphics", v"0.1.3"), #102
            ("GreatCircle", v"0.0.1"), #103
            ("Grid", v"0.4.0"), #104
            ("Gtk", v"0.9.3"), #105
            ("HTTP", v"0.0.2"), #106
            ("Hadamard", v"0.1.2"), #107
            ("Helpme", v"0.0.13"), #108
            ("HexEdit", v"0.0.5"), #109
            ("Hexagons", v"0.0.4"), #110
            ("HopfieldNets", v"0.0.0"), #111
            ("HttpCommon", v"0.2.4"), #112
            ("HttpParser", v"0.1.1"), #113
            ("HttpServer", v"0.1.5"), #114
            ("Humanize", v"0.4.0"), #115
            ("Hwloc", v"0.2.0"), #116
            ("HyperDualNumbers", v"0.1.7"), #117
            ("HyperLogLog", v"0.0.0"), #118
            ("ICU", v"0.4.4"), #119
            ("IDRsSolver", v"0.1.3"), #120
            ("IDXParser", v"0.1.0"), #121
            ("IPPCore", v"0.2.1"), #122
            ("IPPDSP", v"0.0.1"), #123
            ("IndexableBitVectors", v"0.1.0"), #124
            ("IndexedArrays", v"0.1.0"), #125
            ("InformedDifferentialEvolution", v"0.1.0"), #126
            ("IntArrays", v"0.0.1"), #127
            ("Interfaces", v"0.0.4"), #128
            ("Isotonic", v"0.0.1"), #129
            ("IterationManagers", v"0.0.1"), #130
            ("Ito", v"0.0.2"), #131
            ("JellyFish", v"0.0.1"), #132
            ("JointMoments", v"0.2.5"), #133
            ("JudyDicts", v"0.0.0"), #134
            ("JuliaWebRepl", v"0.0.0"), #135
            ("JulieTest", v"0.0.2"), #136
            ("Jumos", v"0.2.1"), #137
            ("KLDivergence", v"0.0.0"), #138
            ("KShiftsClustering", v"0.1.0"), #139
            ("KernSmooth", v"0.0.3"), #140
            ("LARS", v"0.0.3"), #141
            ("LIBSVM", v"0.0.1"), #142
            ("LMDB", v"0.0.4"), #143
            ("LRUCache", v"0.0.1"), #144
            ("LaTeX", v"0.1.0"), #145
            ("LambertW", v"0.0.4"), #146
            ("LazySequences", v"0.1.0"), #147
            ("LibGit2", v"0.3.8"), #148
            ("LibTrading", v"0.0.1"), #149
            ("Libz", v"0.0.2"), #150
            ("LineEdit", v"0.0.1"), #151
            ("LinguisticData", v"0.0.2"), #152
            ("Loss", v"0.0.1"), #153
            ("LowDimNearestNeighbors", v"0.0.1"), #154
            ("Lumira", v"0.0.2"), #155
            ("MATLABCluster", v"0.0.1"), #156
            ("MCMC", v"0.3.0"), #157
            ("MDCT", v"0.0.2"), #158
            ("MDPs", v"0.1.1"), #159
            ("MPFI", v"0.0.1"), #160
            ("MachineLearning", v"0.0.3"), #161
            ("ManifoldLearning", v"0.1.0"), #162
            ("MapLight", v"0.0.2"), #163
            ("Markdown", v"0.3.0"), #164
            ("MarketTechnicals", v"0.4.1"), #165
            ("Mathematica", v"0.2.0"), #166
            ("MessageUtils", v"0.0.2"), #167
            ("MetaTools", v"0.0.1"), #168
            ("Millboard", v"0.0.6"), #169
            ("MinimalPerfectHashes", v"0.1.2"), #170
            ("MixtureModels", v"0.2.0"), #171
            ("MolecularDynamics", v"0.1.3"), #172
            ("Monads", v"0.0.0"), #173
            ("Mongrel2", v"0.0.0"), #174
            ("MsgPackRpcClient", v"0.0.0"), #175
            ("MultiNest", v"0.2.0"), #176
            ("Multirate", v"0.0.2"), #177
            ("Munkres", v"0.1.0"), #178
            ("MutableStrings", v"0.0.0"), #179
            ("NHST", v"0.0.2"), #180
            ("NLreg", v"0.1.1"), #181
            ("NMEA", v"0.0.5"), #182
            ("NMF", v"0.2.4"), #183
            ("NURBS", v"0.0.1"), #184
            ("Named", v"0.0.0"), #185
            ("NamedDimensions", v"0.0.3"), #186
            ("Nemo", v"0.4.1"), #187
            ("Neovim", v"0.0.2"), #188
            ("NeuralynxNCS", v"0.0.1"), #189
            ("NullableArrays", v"0.0.2"), #190
            ("NumericExtensions", v"0.6.2"), #191
            ("OCCA", v"0.0.1"), #192
            ("OSC", v"0.0.1"), #193
            ("OSXNotifier", v"0.0.1"), #194
            ("OpenGL", v"2.0.3"), #195
            ("OpenSSL", v"0.0.0"), #196
            ("OpenSecrets", v"0.0.1"), #197
            ("OpenSlide", v"0.0.1"), #198
            ("OptimPack", v"0.2.0"), #199
            ("Orchestra", v"0.0.5"), #200
            ("PEGParser", v"0.1.2"), #201
            ("PGM", v"0.0.1"), #202
            ("PLX", v"0.0.5"), #203
            ("PTools", v"0.0.0"), #204
            ("PValueAdjust", v"2.0.0"), #205
            ("Pandas", v"0.2.0"), #206
            ("Pardiso", v"0.0.2"), #207
            ("Pcap", v"0.0.2"), #208
            ("Pedigrees", v"0.0.1"), #209
            ("Permutations", v"0.0.1"), #210
            ("Phylogenetics", v"0.0.2"), #211
            ("PicoSAT", v"0.1.0"), #212
            ("Plotly", v"0.0.3"), #213
            ("Polynomial", v"0.1.1"), #214
            ("ProfileView", v"0.1.1"), #215
            ("ProjectTemplate", v"0.0.1"), #216
            ("PropertyGraph", v"0.1.0"), #217
            ("Push", v"0.0.1"), #218
            ("PyLexYacc", v"0.0.2"), #219
            ("PySide", v"0.0.2"), #220
            ("Quandl", v"0.5.4"), #221
            ("QuickCheck", v"0.0.0"), #222
            ("QuickShiftClustering", v"0.1.0"), #223
            ("RDF", v"0.0.1"), #224
            ("RDatasets", v"0.1.2"), #225
            ("REPL", v"0.0.2"), #226
            ("REPLCompletions", v"0.0.3"), #227
            ("RandomFerns", v"0.1.0"), #228
            ("RdRand", v"0.0.0"), #229
            ("React", v"0.1.6"), #230
            ("Reel", v"0.1.0"), #231
            ("Reexport", v"0.0.3"), #232
            ("Resampling", v"0.0.0"), #233
            ("ReverseDiffOverload", v"0.0.1"), #234
            ("Rif", v"0.0.12"), #235
            ("Rmath", v"0.0.0"), #236
            ("RobustStats", v"0.0.1"), #237
            ("RomanNumerals", v"0.1.0"), #238
            ("RudeOil", v"0.1.0"), #239
            ("RunTests", v"0.0.3"), #240
            ("SDE", v"0.3.1"), #241
            ("SDL", v"0.1.5"), #242
            ("SFML", v"0.1.0"), #243
            ("SVM", v"0.0.1"), #244
            ("Sampling", v"0.0.8"), #245
            ("SaveREPL", v"0.0.1"), #246
            ("ShapeModels", v"0.0.3"), #247
            ("ShowSet", v"0.0.1"), #248
            ("SigmoidalProgramming", v"0.0.1"), #249
            ("Silo", v"0.1.0"), #250
            ("Sims", v"0.1.0"), #251
            ("SkyCoords", v"0.1.0"), #252
            ("SliceSampler", v"0.0.0"), #253
            ("Slugify", v"0.1.1"), #254
            ("SmoothingKernels", v"0.0.0"), #255
            ("Sodium", v"0.0.0"), #256
            ("Soundex", v"0.0.0"), #257
            ("Sparklines", v"0.1.0"), #258
            ("SparseGrids", v"0.1.0"), #259
            ("SpecialMatrices", v"0.1.3"), #260
            ("StackedNets", v"0.0.1"), #261
            ("Stats", v"0.1.0"), #262
            ("StrPack", v"0.0.1"), #263
            ("StreamStats", v"0.0.2"), #264
            ("StructsOfArrays", v"0.0.3"), #265
            ("SuffixArrays", v"0.0.1"), #266
            ("Sundials", v"0.2.0"), #267
            ("SunlightAPIs", v"0.0.3"), #268
            ("Switch", v"0.0.1"), #269
            ("Synchrony", v"0.0.1"), #270
            ("Tau", v"0.0.3"), #271
            ("TermWin", v"0.0.31"), #272
            ("TerminalExtensions", v"0.0.2"), #273
            ("Terminals", v"0.0.1"), #274
            ("TextPlots", v"0.3.0"), #275
            ("ThingSpeak", v"0.0.2"), #276
            ("TimeSeries", v"0.7.3"), #277
            ("TopicModels", v"0.0.1"), #278
            ("Trie", v"0.0.0"), #279
            ("TypeCheck", v"0.0.3"), #280
            ("Typeclass", v"0.0.1"), #281
            ("URITemplate", v"0.0.1"), #282
            ("URLParse", v"0.0.0"), #283
            ("UTF16", v"0.3.0"), #284
            ("Units", v"0.2.6"), #285
            ("VML", v"0.0.1"), #286
            ("VStatistic", v"1.0.0"), #287
            ("VennEuler", v"0.0.1"), #288
            ("VoronoiDelaunay", v"0.0.1"), #289
            ("Voting", v"0.0.1"), #290
            ("Wallace", v"0.0.1"), #291
            ("Watcher", v"0.1.0"), #292
            ("WaveletMatrices", v"0.1.0"), #293
            ("Winston", v"0.11.13"), #294
            ("XClipboard", v"0.0.3"), #295
            ("XGBoost", v"0.1.0"), #296
            ("XSV", v"0.0.2"), #297
            ("Yelp", v"0.3.0"), #298
            ("ZChop", v"0.0.2"), #299
            ("ZVSimulator", v"0.0.0"), #300
            ("kNN", v"0.0.0"), #301
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
