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
            ("AppleAccelerate", v"0.1.0"), #4
            ("Arduino", v"0.1.2"), #5
            ("Arrowhead", v"0.0.1"), #6
            ("AudioIO", v"0.1.1"), #7
            ("Autoreload", v"0.2.0"), #8
            ("BEncode", v"0.1.1"), #9
            ("BSplines", v"0.0.3"), #10
            ("BackpropNeuralNet", v"0.0.3"), #11
            ("Bebop", v"0.0.1"), #12
            ("Benchmark", v"0.1.0"), #13
            ("BenchmarkLite", v"0.1.2"), #14
            ("BiomolecularStructures", v"0.0.1"), #15
            ("Biryani", v"0.2.0"), #16
            ("BlackBoxOptim", v"0.0.1"), #17
            ("BlossomV", v"0.0.1"), #18
            ("BoundingBoxes", v"0.1.0"), #19
            ("Brownian", v"0.0.1"), #20
            ("CLBLAS", v"0.1.0"), #21
            ("CLFFT", v"0.1.0"), #22
            ("CPUTime", v"0.0.4"), #23
            ("CRC32", v"0.0.2"), #24
            ("CRF", v"0.1.1"), #25
            ("CUDA", v"0.1.0"), #26
            ("CUFFT", v"0.0.3"), #27
            ("Calendar", v"0.4.3"), #28
            ("Catalan", v"0.0.3"), #29
            ("CauseMap", v"0.0.3"), #30
            ("CellularAutomata", v"0.1.2"), #31
            ("ChainedVectors", v"0.0.0"), #32
            ("ChaosCommunications", v"0.0.1"), #33
            ("ChemicalKinetics", v"0.1.0"), #34
            ("Church", v"0.0.1"), #35
            ("CirruParser", v"0.0.2"), #36
            ("Clang", v"0.0.5"), #37
            ("Cliffords", v"0.2.3"), #38
            ("Clustering", v"0.4.0"), #39
            ("CommonCrawl", v"0.0.1"), #40
            ("CompilerOptions", v"0.1.0"), #41
            ("CompressedSensing", v"0.0.2"), #42
            ("ConfidenceWeighted", v"0.0.2"), #43
            ("ContinuedFractions", v"0.0.0"), #44
            ("Contour", v"0.0.8"), #45
            ("CoreNLP", v"0.1.0"), #46
            ("Cosmology", v"0.1.3"), #47
            ("Cpp", v"0.1.0"), #48
            ("CrossDecomposition", v"0.0.1"), #49
            ("Curl", v"0.0.3"), #50
            ("CurveFit", v"0.0.1"), #51
            ("DASSL", v"0.0.4"), #52
            ("DCEMRI", v"0.1.1"), #53
            ("DICOM", v"0.0.1"), #54
            ("DReal", v"0.0.2"), #55
            ("DWARF", v"0.0.0"), #56
            ("DataFramesMeta", v"0.0.1"), #57
            ("Datetime", v"0.1.7"), #58
            ("DevIL", v"0.2.2"), #59
            ("DictUtils", v"0.0.2"), #60
            ("DimensionalityReduction", v"0.1.2"), #61
            ("DirichletProcessMixtures", v"0.0.1"), #62
            ("DiscreteFactor", v"0.0.0"), #63
            ("Distance", v"0.5.1"), #64
            ("Docker", v"0.0.0"), #65
            ("DoubleDouble", v"0.1.0"), #66
            ("Dynare", v"0.0.1"), #67
            ("ELF", v"0.0.0"), #68
            ("ERFA", v"0.1.0"), #69
            ("Equations", v"0.1.1"), #70
            ("Etcd", v"0.0.1"), #71
            ("ExpressionUtils", v"0.0.0"), #72
            ("FLANN", v"0.0.2"), #73
            ("FaceDatasets", v"0.1.4"), #74
            ("FastArrayOps", v"0.1.0"), #75
            ("FileFind", v"0.0.0"), #76
            ("FinancialMarkets", v"0.1.1"), #77
            ("FiniteStateMachine", v"0.0.2"), #78
            ("FixedPoint", v"0.0.1"), #79
            ("Fixtures", v"0.0.2"), #80
            ("FreeType", v"1.0.1"), #81
            ("FunctionalCollections", v"0.1.2"), #82
            ("FunctionalUtils", v"0.0.0"), #83
            ("GARCH", v"0.1.2"), #84
            ("GLPlot", v"0.0.5"), #85
            ("GLText", v"0.0.4"), #86
            ("GLUT", v"0.4.0"), #87
            ("Gaston", v"0.0.0"), #88
            ("GaussianProcesses", v"0.1.2"), #89
            ("GeneticAlgorithms", v"0.0.3"), #90
            ("GeometricalPredicates", v"0.0.4"), #91
            ("GetC", v"1.1.1"), #92
            ("Gettext", v"0.1.0"), #93
            ("GibbsSeaWater", v"0.0.4"), #94
            ("Glob", v"1.0.1"), #95
            ("GradientBoost", v"0.0.1"), #96
            ("GraphLayout", v"0.2.0"), #97
            ("GreatCircle", v"0.0.1"), #98
            ("HTTP", v"0.0.2"), #99
            ("Hadamard", v"0.1.2"), #100
            ("Helpme", v"0.0.13"), #101
            ("Hexagons", v"0.0.4"), #102
            ("Hiccup", v"0.0.1"), #103
            ("HopfieldNets", v"0.0.0"), #104
            ("HyperDualNumbers", v"0.1.7"), #105
            ("HyperLogLog", v"0.0.0"), #106
            ("ICU", v"0.4.4"), #107
            ("IDXParser", v"0.1.0"), #108
            ("IPPCore", v"0.2.1"), #109
            ("IPPDSP", v"0.0.1"), #110
            ("IProfile", v"0.3.1"), #111
            ("IndexedArrays", v"0.1.0"), #112
            ("IniFile", v"0.2.4"), #113
            ("InplaceOps", v"0.0.4"), #114
            ("Instruments", v"0.0.1"), #115
            ("IntervalTrees", v"0.0.4"), #116
            ("Isotonic", v"0.0.1"), #117
            ("IterationManagers", v"0.0.1"), #118
            ("Ito", v"0.0.2"), #119
            ("JFVM", v"0.0.1"), #120
            ("JLDArchives", v"0.0.6"), #121
            ("JPLEphemeris", v"0.2.1"), #122
            ("JellyFish", v"0.0.1"), #123
            ("JointMoments", v"0.2.5"), #124
            ("JudyDicts", v"0.0.0"), #125
            ("JuliaWebRepl", v"0.0.0"), #126
            ("JulieTest", v"0.0.2"), #127
            ("KLDivergence", v"0.0.0"), #128
            ("KernSmooth", v"0.0.3"), #129
            ("LARS", v"0.0.3"), #130
            ("LIBSVM", v"0.0.1"), #131
            ("LNR", v"0.0.1"), #132
            ("LambertW", v"0.0.4"), #133
            ("LazySequences", v"0.1.0"), #134
            ("LibGit2", v"0.3.8"), #135
            ("LibTrading", v"0.0.1"), #136
            ("LineEdit", v"0.0.1"), #137
            ("LinearMaps", v"0.1.1"), #138
            ("LinguisticData", v"0.0.2"), #139
            ("Lint", v"0.1.68"), #140
            ("Loss", v"0.0.1"), #141
            ("LowDimNearestNeighbors", v"0.0.1"), #142
            ("LowRankModels", v"0.1.0"), #143
            ("Lumira", v"0.0.2"), #144
            ("MCMC", v"0.3.0"), #145
            ("MDCT", v"0.0.2"), #146
            ("MDPs", v"0.1.1"), #147
            ("MPFI", v"0.0.1"), #148
            ("MUMPS", v"0.0.1"), #149
            ("MachineLearning", v"0.0.3"), #150
            ("ManifoldLearning", v"0.1.0"), #151
            ("MapLight", v"0.0.2"), #152
            ("Markdown", v"0.3.0"), #153
            ("Mathematica", v"0.2.0"), #154
            ("Media", v"0.1.1"), #155
            ("Memoize", v"0.0.0"), #156
            ("Meshing", v"0.0.0"), #157
            ("MessageUtils", v"0.0.2"), #158
            ("MetaTools", v"0.0.1"), #159
            ("MinimalPerfectHashes", v"0.1.2"), #160
            ("MixtureModels", v"0.2.0"), #161
            ("MolecularDynamics", v"0.1.3"), #162
            ("Monads", v"0.0.0"), #163
            ("Mongrel2", v"0.0.0"), #164
            ("MsgPackRpcClient", v"0.0.0"), #165
            ("MultiNest", v"0.2.0"), #166
            ("MultiPoly", v"0.0.1"), #167
            ("Multirate", v"0.0.2"), #168
            ("Murmur3", v"0.1.0"), #169
            ("MutableStrings", v"0.0.0"), #170
            ("NFFT", v"0.0.2"), #171
            ("NHST", v"0.0.2"), #172
            ("NIDAQ", v"0.0.2"), #173
            ("NLreg", v"0.1.1"), #174
            ("NMF", v"0.2.4"), #175
            ("NPZ", v"0.0.1"), #176
            ("NaiveBayes", v"0.1.0"), #177
            ("Named", v"0.0.0"), #178
            ("NamedTuples", v"0.0.2"), #179
            ("Neovim", v"0.0.2"), #180
            ("NetCDF", v"0.2.1"), #181
            ("NeuralynxNCS", v"0.0.1"), #182
            ("NumericExtensions", v"0.6.2"), #183
            ("OCCA", v"0.0.1"), #184
            ("ODBC", v"0.3.10"), #185
            ("OSC", v"0.0.1"), #186
            ("OSXNotifier", v"0.0.1"), #187
            ("OpenGL", v"2.0.3"), #188
            ("OpenSSL", v"0.0.0"), #189
            ("OpenSecrets", v"0.0.1"), #190
            ("OpenSlide", v"0.0.1"), #191
            ("OptimPack", v"0.1.2"), #192
            ("Orchestra", v"0.0.5"), #193
            ("PAINTER", v"0.1.2"), #194
            ("PEGParser", v"0.1.2"), #195
            ("PGFPlots", v"1.2.2"), #196
            ("PGM", v"0.0.1"), #197
            ("PLX", v"0.0.5"), #198
            ("PTools", v"0.0.0"), #199
            ("PValueAdjust", v"2.0.0"), #200
            ("Pandas", v"0.2.0"), #201
            ("Pardiso", v"0.0.2"), #202
            ("PatternDispatch", v"0.0.2"), #203
            ("Pedigrees", v"0.0.1"), #204
            ("Permutations", v"0.0.1"), #205
            ("Phylogenetics", v"0.0.2"), #206
            ("PicoSAT", v"0.1.0"), #207
            ("Plotly", v"0.0.3"), #208
            ("PolarFact", v"0.0.5"), #209
            ("Polynomial", v"0.1.1"), #210
            ("ProgressMeter", v"0.2.1"), #211
            ("ProjectTemplate", v"0.0.1"), #212
            ("Push", v"0.0.1"), #213
            ("PyLexYacc", v"0.0.2"), #214
            ("PySide", v"0.0.2"), #215
            ("Quaternions", v"0.0.4"), #216
            ("QuickCheck", v"0.0.0"), #217
            ("RDF", v"0.0.1"), #218
            ("RDatasets", v"0.1.2"), #219
            ("REPL", v"0.0.2"), #220
            ("REPLCompletions", v"0.0.3"), #221
            ("RdRand", v"0.0.0"), #222
            ("React", v"0.1.6"), #223
            ("Redis", v"0.0.1"), #224
            ("Reel", v"0.1.0"), #225
            ("Reexport", v"0.0.3"), #226
            ("Resampling", v"0.0.0"), #227
            ("ReverseDiffOverload", v"0.0.1"), #228
            ("Rif", v"0.0.12"), #229
            ("Rmath", v"0.0.0"), #230
            ("RobustStats", v"0.0.1"), #231
            ("RomanNumerals", v"0.1.0"), #232
            ("RudeOil", v"0.1.0"), #233
            ("RunTests", v"0.0.3"), #234
            ("SDE", v"0.3.1"), #235
            ("SDL", v"0.1.5"), #236
            ("SMTPClient", v"0.0.0"), #237
            ("SVM", v"0.0.1"), #238
            ("Sampling", v"0.0.8"), #239
            ("SaveREPL", v"0.0.1"), #240
            ("SemidefiniteProgramming", v"0.1.0"), #241
            ("ShapeModels", v"0.0.3"), #242
            ("ShowSet", v"0.0.1"), #243
            ("SigmoidalProgramming", v"0.0.1"), #244
            ("Silo", v"0.1.0"), #245
            ("Sims", v"0.1.0"), #246
            ("SkyCoords", v"0.1.0"), #247
            ("SliceSampler", v"0.0.0"), #248
            ("Slugify", v"0.1.1"), #249
            ("Smile", v"0.1.3"), #250
            ("SmoothingKernels", v"0.0.0"), #251
            ("Snappy", v"0.0.1"), #252
            ("Sodium", v"0.0.0"), #253
            ("Soundex", v"0.0.0"), #254
            ("Sparklines", v"0.1.0"), #255
            ("SpecialMatrices", v"0.1.3"), #256
            ("StackedNets", v"0.0.1"), #257
            ("Stats", v"0.1.0"), #258
            ("StrPack", v"0.0.1"), #259
            ("StreamStats", v"0.0.2"), #260
            ("SuffixArrays", v"0.0.1"), #261
            ("Sundials", v"0.1.3"), #262
            ("SunlightAPIs", v"0.0.3"), #263
            ("Switch", v"0.0.1"), #264
            ("Synchrony", v"0.0.1"), #265
            ("Taro", v"0.2.0"), #266
            ("Tau", v"0.0.3"), #267
            ("TensorOperations", v"0.3.1"), #268
            ("TermWin", v"0.0.31"), #269
            ("TerminalExtensions", v"0.0.2"), #270
            ("Terminals", v"0.0.1"), #271
            ("TestImages", v"0.0.8"), #272
            ("TexExtensions", v"0.0.2"), #273
            ("TextPlots", v"0.3.0"), #274
            ("ThermodynamicsTable", v"0.0.3"), #275
            ("ThingSpeak", v"0.0.2"), #276
            ("TopicModels", v"0.0.1"), #277
            ("Trie", v"0.0.0"), #278
            ("TypeCheck", v"0.0.3"), #279
            ("Typeclass", v"0.0.1"), #280
            ("UAParser", v"0.3.0"), #281
            ("URITemplate", v"0.0.1"), #282
            ("URLParse", v"0.0.0"), #283
            ("UTF16", v"0.3.0"), #284
            ("Units", v"0.2.6"), #285
            ("VML", v"0.0.1"), #286
            ("VStatistic", v"1.0.0"), #287
            ("ValueDispatch", v"0.0.0"), #288
            ("VennEuler", v"0.0.1"), #289
            ("VoronoiDelaunay", v"0.0.1"), #290
            ("Voting", v"0.0.1"), #291
            ("Wallace", v"0.0.1"), #292
            ("Winston", v"0.11.13"), #293
            ("WorldBankData", v"0.0.4"), #294
            ("XClipboard", v"0.0.3"), #295
            ("XGBoost", v"0.1.0"), #296
            ("XSV", v"0.0.2"), #297
            ("YT", v"0.2.0"), #298
            ("Yelp", v"0.3.0"), #299
            ("ZChop", v"0.0.2"), #300
            ("ZVSimulator", v"0.0.0"), #301
            ("kNN", v"0.0.0"), #302
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
