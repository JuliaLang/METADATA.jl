function sampleEffectsBayesC0!(nMarkers,
                        nObs,
                        xArray::Array{Array{Float32,1},1},
                        xpx::Array{Float32,1},
                        yCorr::Array{Float32,1},
                        α::Array{Float32,1},
                        meanAlpha::Array{Float32,2},
                        vare::Float32,
                        varEffects::Float32,
                        x::Array{Float32,1})
    for j=1:nMarkers
        x = xArray[j]
        rhs::Float32 = dot(x,yCorr) + xpx[j]*α[j]
        lhs::Float32      = xpx[j] + vare/varEffects
        invLhs::Float32   = 1.0/lhs
        mean::Float32     = invLhs*rhs
        oldAlpha::Float32 = α[j]
        α[j] = mean + randn()*sqrt(invLhs*vare)
        BLAS.axpy!(oldAlpha-α[j],x,yCorr)
    end
    nothing
end

function BayesC0!(options,X,y)

    ###INPUT
    chainLength     =   options.chainLength     # number of iterations
    estimateScale   =   options.estimateScale   # "yes" or "no"
    dfEffectVar     =   options.dfEffectVar     # hyper parameter (degrees of freedom) for locus effect variance
    nuRes           =   options.nuRes           # hyper parameter (degrees of freedom) for residual variance
    varGenotypic    =   options.varGenotypic    # used to derive hyper parameter (scale) for locus effect variance
    varResidual     =   options.varResidual     # used to derive hyper parameter (scale) for locus effect variance

    numIter       =   chainLength
    nObs,nMarkers = size(X)
    nFixedEffects = size(C,2)

    ###START
    X = copy(X) #copy original X matrix, not change original data
    markerMeans = center!(X)
    xArray = get_column_ref(X)
    XpRinvX = getXpRinvX(X, Rinv)

    #initial values
    vare       = varResidual
    p          = markerMeans/2.0
    mean2pq    = (2*p*(1-p)')[1,1]
    varEffects = varGenotypic/((1-probFixed)*mean2pq)
    scaleVar   = varEffects*(dfEffectVar-2)/dfEffectVar        # scale factor for locus effects
    scaleRes   = varResidual*(nuRes-2)/nuRes        # scale factor for residual varianc
    yCorr      = copy(y)
    β          = zeros(nFixedEffects)  # sample of fixed effects
    α          = zeros(nMarkers)       # sample of marker effects
    RinvSqrt   = sqrt(Rinv)

    #return values
    meanFxdEff = zeros(nFixedEffects)
    meanAlpha  = zeros(nMarkers)
    mdlFrq     = zeros(nMarkers)
    resVar     = zeros(chainLength)
    genVar     = zeros(chainLength)
    scale      = zeros(chainLength)

    for i=1:numIter
        # sample fixed effects
        sampleFixedEffects!(yCorr, nFixedEffects, C, Rinv, β, vare)
        meanFxdEff = meanFxdEff + (β - meanFxdEff)/i

        # sample effects
        sampleEffectsBayesC0!(nMarkers,nObs,xArray,xpx,yCorr,α,meanAlpha,vare,varEffects,x)
        meanAlpha = meanAlpha + (α - meanAlpha)/i
        genVar[i] = var(X*α)

        # sample residula variance
        vare = sampleVariance(yCorr.*RinvSqrt, nObs, nuRes, scaleRes)
        resVar[i] = vare

        #sample locus effect variance
        varEffects = sampleVariance(α, nMarkers, dfEffectVar, scaleVar)

        #sample scale parameters
        if (estimateScale == "yes")
            scaleVar = sampleScale(varEffects, dfEffectVar, 1, 1)
        end
        scale[i] = scaleVar


        if (i%100)==0
            yhat = meanMu+X*meanAlpha
            resCorr = cor(yhat,yhat) #modify
            println ("Correlation of between true and predicted breeding value: ", resCorr[1])
        end
    end

    ###OUTPUT
    output = Dict()
    output["posterior mean of fixed effects"]         = meanFxdEff
    output["posterior mean of marker effects"]        = meanAlpha
    output["posterior sample of scale"]               = scale
    output["posterior sample of genotypic variance"]  = genVar
    output["posterior sample of residual variance"]   = resVar

    return output

end
