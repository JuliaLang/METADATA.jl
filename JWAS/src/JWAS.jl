module JWAS

using(Distributions)

type JWASOptions
    seed           # seed for random number generator
    run            # BayeB,BayesC,BayesC0,BayesR
    chainLength    # number of iterations
    probFixed      # parameter "pi" the probability SNP effect is zero
    estimatePi     # "yes" or "no"
    estimateScale  # "yes" or "no"
    varGenotypic   # used to derive hyper parameter (scale) for locus effect variance
    varResidual    # used to derive hyper parameter (scale) for locus effect variance
    dfEffectVar    # hyper parameter (degrees of freedom) for locus effect variance
    nuRes          # hyper parameter (degrees of freedom) for residual variance

    #parameters for BayesN
    fittedSNPperWindow   # for BayesN
    windowWidth          # in mega-basepaire unit
    markerMap            # marker_id, chrom_id, position

    function JWASOptions(opt::Dict{Any,Any})
        global seed               = 314
        global run                = "BayesC0"
        global chainLength        = 50000
        global estimatePi         = "No"
        global estimateScale      = "No"
        global probFixed          = 0.0
        global varGenotypic       = 1.0
        global varResidual        = 1.0
        global dfEffectVar        = 4
        global nuRes              = 4
        global fittedSNPperWindow = 5
        global windowWidth        = 1e6
        global markerMap          = NaN

        #parameter list
        parmlist = ["seed","run","chainLength",
                    "varGenotypic","varResidual",
                    "dfEffectVar","nuRes",
                    "probFixed","estimatePi","estimateScale",
                    "fittedSNPperWindow","windowWidth","markerMap"]

        for par in parmlist
           if (haskey(opt,par)==true)
                ex = Expr(:(=),symbol(par),opt[par]) #metaprogramming
                eval(ex)                             #e.g. run=opt["run"]
            end
        end

        new(seed,run,chainLength,probFixed,estimatePi,estimateScale,
            varGenotypic,varResidual,dfEffectVar,nuRes,
            fittedSNPperWindow,windowWidth,markerMap)
    end
end

include("Tools.jl")
include("Samplers.jl")
include("BayesB.jl")
include("BayesC0.jl")
include("BayesC.jl")
include("BayesCDom.jl")
#include("BayesN.jl")
#include("anteBayesB.jl")
#include("BayesR.jl")



#= #metaprogramming not work
function runGenSel(parmdict::Dict{Any,Any},X::Array{Float64,2},y::Array{Float64,1};
                   C::Array{Float64,2}=ones(length(y),1), Rinv::Array{Float64,1}= ones(length(y)))

          global myOptions=GenSelOptions(parmdict)
          mymethod=string(myOptions.run,"!(myOptions,$X,$y,$C,$Rinv)")  #e.g. BayesC!(myOptions,X,y,C,Rinv)
          eval(parse(mymethod))
end
=#

function runJWAS(parmdict::Dict{Any,Any},X::Array{Float64,2},y::Array{Float64,1};
                   C::Array{Float64,2}=ones(length(y),1), Rinv::Array{Float64,1}= ones(length(y)))

      myOptions=JWASOptions(parmdict)
      srand(myOptions.seed)

      if myOptions.run=="BayesC0"
        BayesC0!(myOptions,X,y)
      elseif myOptions.run=="BayesB"
        BayesB!(myOptions,X,y,C,Rinv)
      elseif myOptions.run=="BayesC"
        BayesC!(myOptions,X,y,C,Rinv)
      elseif myOptions.run=="BayesR"
        #BayesR!(myOptions,X,y)
      elseif myOptions.run=="BayesCDom"
        BayesCDom!(myOptions,X,y,C,Rinv)
      elseif myOptions.run=="BayesN"
        BayesN!(myOptions,X,y,C,Rinv)
      elseif myOptions.run=="anteBayesB" || myOptions.run=="anteBayesBTempleman"
        anteBayesB!(myOptions,X,y,C,Rinv)
      end
end

export runJWAS
export get_dom_cov

end
