function sampleEffectsBayesC!(nMarkers,
                              xArray,
                              XpRinvX,
                              yCorr,
                              α,
                              δ,
                              vare,
                              varEffects,
                              π,
                              Rinv)

    logPi         = log(π)
    logPiComp     = log(1.0-π)
    logVarEffects = log(varEffects)
    logDelta0     = logPi
    invVarRes     = 1.0/vare
    invVarEffects = 1.0/varEffects
    nLoci = 0

    for j=1:nMarkers
        x = xArray[j]
        rhs = (dot(x.*Rinv,yCorr) + XpRinvX[j]*α[j])*invVarRes
        lhs = XpRinvX[j]*invVarRes + invVarEffects
        invLhs = 1.0/lhs
        gHat   = rhs*invLhs
        logDelta1  = -0.5*(log(lhs) + logVarEffects - gHat*rhs) + logPiComp
        probDelta1 = 1.0/(1.0 + exp(logDelta0 - logDelta1))
        oldAlpha = α[j]

        if(rand()<probDelta1)
            δ[j] = 1
            α[j] = gHat + randn()*sqrt(invLhs)
            BLAS.axpy!(oldAlpha-α[j],x,yCorr)
            nLoci = nLoci + 1
        else
            if (oldAlpha!=0)
                BLAS.axpy!(oldAlpha,x,yCorr)
            end
            δ[j] = 0
            α[j] = 0
        end
    end
    return nLoci
end


function BayesC!(options,X,y,C,Rinv)

    ###INPUT
    chainLength     =   options.chainLength     # number of iterations
    probFixed       =   options.probFixed       # parameter "pi" the probability SNP effect is zero
    estimatePi      =   options.estimatePi      # "yes" or "no"
    estimateScale   =   options.estimateScale   # "yes" or "no"
    dfEffectVar     =   options.dfEffectVar     # hyper parameter (degrees of freedom) for locus effect variance
    nuRes           =   options.nuRes           # hyper parameter (degrees of freedom) for residual variance
    varGenotypic    =   options.varGenotypic    # used to derive hyper parameter (scale) for locus effect variance
    varResidual     =   options.varResidual     # used to derive hyper parameter (scale) for locus effect variance

    numIter         =   chainLength
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
    δ          = zeros(nMarkers)       # inclusion indicator for marker effects
    π          = probFixed
    RinvSqrt   = sqrt(Rinv)

    #return values
    meanFxdEff = zeros(nFixedEffects)
    meanAlpha  = zeros(nMarkers)
    mdlFrq     = zeros(nMarkers)
    resVar     = zeros(chainLength)
    genVar     = zeros(chainLength)
    pi         = zeros(chainLength)
    scale      = zeros(chainLength)

    # MCMC sampling
    for i=1:numIter
        # sample fixed effects
        sampleFixedEffects!(yCorr, nFixedEffects, C, Rinv, β, vare)
        meanFxdEff = meanFxdEff + (β - meanFxdEff)/i

        # sample effects
        nLoci = sampleEffectsBayesC!(nMarkers, xArray, XpRinvX, yCorr, α, δ, vare, varEffects, π, Rinv)
        meanAlpha = meanAlpha + (α - meanAlpha)/i
        mdlFrq    = mdlFrq    + (δ - mdlFrq   )/i
        genVar[i] = var(X*α)

        # sample residula variance
        vare = sampleVariance(yCorr.*RinvSqrt, nObs, nuRes, scaleRes)
        resVar[i] = vare

        # sample locus effect variance
        varEffects = sampleVariance(α, nLoci, dfEffectVar, scaleVar)

        if (estimatePi == "yes")
            π = samplePi(nLoci, nMarkers)
        end
        pi[i] = π

        if (estimateScale == "yes")
            scaleVar = sampleScale(varEffects, dfEffectVar, 1, 1)
        end
        scale[i] = scaleVar

        if (i%100)==0
            yCorr = y - C*β - X*α  # remove rounding errors
            println ("This is iteration ", i, ", number of loci ", nLoci, ", vara ", genVar[i], ", vare ", vare)
        end
    end

    ###OUTPUT
    output = Dict()
    output["posterior mean of fixed effects"]         = meanFxdEff
    output["posterior mean of marker effects"]        = meanAlpha
    output["model frequency"]                         = mdlFrq
    output["posterior sample of pi"]                  = pi
    output["posterior sample of scale"]               = scale
    output["posterior sample of genotypic variance"]  = genVar
    output["posterior sample of residual variance"]   = resVar

    return output

end
