function sampleEffectsBayesB!(nMarkers,
                              xArray,
                              XpRinvX,
                              yCorr,
                              u,
                              α,
                              δ,
                              vare,
                              locusEffectVar,
                              π,
                              Rinv)

    logPi         = log(π)
    logPiComp     = log(1.0-π)
    logDelta0     = logPi
    invVarRes     = 1.0/vare
    invlocusEffectVar = 1.0./locusEffectVar
    loglocusEffectVar = log(locusEffectVar)
    nLoci = 0

    for j=1:nMarkers
        x = xArray[j]
        rhs = (dot(x.*Rinv,yCorr) + XpRinvX[j]*u[j])*invVarRes
        lhs = XpRinvX[j]*invVarRes + invlocusEffectVar[j]
        invLhs = 1.0/lhs
        gHat   = rhs*invLhs
        logDelta1  = -0.5*(log(lhs) + loglocusEffectVar[j] - gHat*rhs) + logPiComp
        probDelta1 = 1.0/(1.0 + exp(logDelta0 - logDelta1))
        oldu = u[j]

        if(rand()<probDelta1)
            δ[j] = 1
            α[j] = gHat + randn()*sqrt(invLhs)
            u[j] = α[j]
            BLAS.axpy!(oldu-u[j],x,yCorr)
            nLoci = nLoci + 1
        else
            if (oldu!=0)
                BLAS.axpy!(oldu,x,yCorr)
            end
            δ[j] = 0
            α[j] = randn()*sqrt(locusEffectVar[j])
            u[j] = 0
        end
    end
    return nLoci
end


function BayesB!(options,X,y,C,Rinv)
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
    X = copy(X)              #copy original X matrix
    markerMeans = center!(X) #centering
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
    α          = zeros(nMarkers)       # sample of partial marker effects unconditional on δ
    u          = zeros(nMarkers)       # sample of marker effects
    δ          = zeros(nMarkers)       # inclusion indicator for marker effects
    π          = probFixed
    RinvSqrt   = sqrt(Rinv)
    locusEffectVar = fill(varEffects,nMarkers)

    #return values
    meanFxdEff = zeros(nFixedEffects)
    meanMrkEff  = zeros(nMarkers,1)
    mdlFrq     = zeros(nMarkers)
    resVar     = zeros(chainLength)
    genVar     = zeros(chainLength)
    pi         = zeros(chainLength)
    scale      = zeros(chainLength)

    #MCMC sampling
    for i=1:numIter
        # sample fixed effects
        sampleFixedEffects!(yCorr, nFixedEffects, C, Rinv, β, vare)
        meanFxdEff = meanFxdEff + (β - meanFxdEff)/i

        # sample effects
        nLoci = sampleEffectsBayesB!(nMarkers, xArray, XpRinvX, yCorr, u, α, δ, vare, locusEffectVar, π, Rinv)
        meanMrkEff = meanMrkEff + (u - meanMrkEff)/i
        mdlFrq     = mdlFrq     + (δ - mdlFrq    )/i
        genVar[i]  = var(X*u)

        # sample residula variance
        vare = sampleVariance(yCorr.*RinvSqrt, nObs, nuRes, scaleRes)
        resVar[i] = vare

        # sample locus effect variance
        for j=1:nMarkers
            locusEffectVar[j] = sampleVariance(α[j],1,dfEffectVar, scaleVar)
        end

        if (estimatePi == "yes")
            π = samplePi(nLoci, nMarkers)
        end
        pi[i] = π

        if (estimateScale == "yes")
            scaleVar = sampleScale(varEffects, dfEffectVar, 1, 1)
        end
        scale[i] = scaleVar

        if (i%100)==0
            yCorr = y - C*β - X*u  # remove rounding errors
            println ("This is iteration ", i, ", number of loci ", nLoci, ", vara ", genVar[i], ", vare ", vare)
        end
    end

    ###OUTPUT
    output = Dict()
    output["posterior mean of fixed effects"]         = meanFxdEff
    output["posterior mean of marker effects"]        = meanMrkEff
    output["model frequency"]                         = mdlFrq
    output["posterior sample of pi"]                  = pi
    output["posterior sample of scale"]               = scale
    output["posterior sample of genotypic variance"]  = genVar
    output["posterior sample of residual variance"]   = resVar

    return output

end
