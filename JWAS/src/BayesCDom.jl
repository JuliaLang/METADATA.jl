function sampleEffectsBayesCDom!(yCorr, nObs, nMarkers, xArray, XpRinvX, markerMeans, Rinv,
                              a, d, α, δ, π, varEffects, vare, u, g)
    logVarEffects = log(varEffects)
    logPi         = log(π)
    logPiComp     = log(1.0-π)
    logDelta0     = logPi
    invVare::Float64 = 1.0/vare
    invVarEffects    = 1.0./varEffects
    nAddEff = 0
    nDomEff = 0

    for j=1:nMarkers
        if (XpRinvX[j]==0) # skip fixed SNPs
            continue
        end
        gj = zeros(nObs)   # genotypic values for marker j

        # additive effect is first fitted
        olda = a[j]
        x = xArray[j]
        rhs::Float64 = (dot(x.*Rinv,yCorr) + XpRinvX[j]*a[j])*invVare
        lhs::Float64 = XpRinvX[j]*invVare + invVarEffects[1]
        invLhs::Float64 = 1.0/lhs
        gHat::Float64   = rhs*invLhs
        logDelta1::Float64  = -0.5*(log(lhs) + logVarEffects[1] - gHat*rhs) + logPiComp[1]
        probDelta1::Float64 = 1.0/(1.0 + exp(logDelta0[1] - logDelta1))
        if (rand() < probDelta1)
            a[j] = gHat + randn()*sqrt(invLhs)
            BLAS.axpy!(olda-a[j],x,yCorr)
            BLAS.axpy!(a[j],x,gj)
            nAddEff = nAddEff + 1
            δ[j,1] = 1
        else
            if (δ[j,1]!=0)
                BLAS.axpy!(olda,x,yCorr)
            end
            a[j] = 0
            δ[j,1] = 0
        end

        # dominance effect is then fitted
        oldd = d[j]
        w = get_dom_cov(x + markerMeans[j], nObs)
        w = w - mean(w)
        wRinv = w.*Rinv
        wpRinvw = dot(wRinv,w)
        rhs = (dot(wRinv,yCorr) + wpRinvw*d[j])*invVare
        lhs = wpRinvw*invVare + invVarEffects[2]
        invLhs = 1.0/lhs
        gHat   = rhs*invLhs
        logDelta1  = -0.5*(log(lhs) + logVarEffects[2] - gHat*rhs) + logPiComp[2]
        probDelta1 = 1.0/(1.0 + exp(logDelta0[2] - logDelta1))
        if (rand() < probDelta1)
            d[j] = gHat + randn()*sqrt(invLhs)
            BLAS.axpy!(oldd-d[j],w,yCorr)
            BLAS.axpy!(d[j],w,gj)
            nDomEff = nDomEff + 1
            δ[j,2] = 1
        else
            if (δ[j,2]!=0)
                BLAS.axpy!(oldd,w,yCorr)
            end
            d[j] = 0
            δ[j,2] = 0
        end

        # estimate substitution effect by OLS
        if (a[j]!=0 && d[j]==0)
            α[j] = a[j]
            BLAS.axpy!(1,gj,g)
            BLAS.axpy!(1,gj,u)
        elseif (a[j]==0 && d[j]!=0)
            α[j] = 0
            BLAS.axpy!(1,gj,g)
        elseif (a[j]!=0 && d[j]!=0)
            α[j] = dot(x,gj-mean(gj))/dot(x,x)
            BLAS.axpy!(1,gj,g)
            BLAS.axpy!(α[j],x,u)
        else
            α[j] = 0
        end
    end

    return [nAddEff nDomEff]
end


function BayesCDom!(options,X,y,C,Rinv)
    # input options
    chainLength     =   options.chainLength     # number of iterations
    probFixed       =   options.probFixed       # parameter "pi" the probability SNP effect is zero
    estimatePi      =   options.estimatePi      # "yes" or "no"
    estimateScale   =   options.estimateScale   # "yes" or "no"
    dfEffectVar     =   options.dfEffectVar     # hyper parameter (degrees of freedom) for locus effect variance
    nuRes           =   options.nuRes           # hyper parameter (degrees of freedom) for residual variance
    varGenotypic    =   options.varGenotypic    # used to derive hyper parameter (scale) for locus effect variance
    varResidual     =   options.varResidual     # used to derive hyper parameter (scale) for locus effect variance

    # prepare
    numIter         =   chainLength
    nObs,nMarkers   =   size(X)
    nFixedEffects   =   size(C,2)

    X=copy(X)
    markerMeans = center!(X)
    xArray = get_column_ref(X)
    XpRinvX = getXpRinvX(X, Rinv)

    β          =  zeros(nFixedEffects)  # sample of fixed effects
    a          =  zeros(nMarkers)       # sample of additive effects
    d          =  zeros(nMarkers)       # sample of dominance effects
    α          =  zeros(nMarkers)       # sample of substitution effects
    δ          =  zeros(nMarkers,2)     # inclusion indicator for additive and dominance effects
    p          =  markerMeans/2.0
    mean2pq    =  (2*p*(1-p)')[1,1]
    mean2pq2   =  (4*(p.^2)*((1-p).^2)')[1,1]
    meanqmp2   =  ((1-2*p)*(1-2*p)')[1,1]/nMarkers
    varEffects =  zeros(2)
    varEffects[2] = varGenotypic[2]/((1-probFixed[2])*mean2pq2)
    varEffects[1] = varGenotypic[1]/((1-probFixed[1])*mean2pq) - meanqmp2*varEffects[2]
    if (varEffects[1]<0)
        println("Additive variance is too small or dominance variance is too large! Please consider reset these values!")
    end
    scaleVar   =  varEffects*(dfEffectVar-2)/dfEffectVar
    scaleRes   =  varResidual*(nuRes-2)/nuRes        # scale factor for residual varianc
    vare       =  varResidual
    π          =  probFixed
    yCorr      =  copy(y)
    RinvSqrt   =  sqrt(Rinv)

    # output variables
    meanFxdEff   = zeros(nFixedEffects)
    meanAddEff   = zeros(nMarkers)
    meanDomEff   = zeros(nMarkers)
    meanSbtEff   = zeros(nMarkers)
    mdlFrqAddEff = zeros(nMarkers)
    mdlFrqDomEff = zeros(nMarkers)
    piAddEff     = zeros(chainLength)
    piDomEff     = zeros(chainLength)
    scaleAddVar  = zeros(chainLength)
    scaleDomVar  = zeros(chainLength)
    genVar       = zeros(chainLength)
    addVar       = zeros(chainLength)
    resVar       = zeros(chainLength)
    meanGenVal   = zeros(nObs)

    # MCMC sampling
    for i=1:numIter
        u = zeros(nObs)   # sample of animal breeding values
        g = zeros(nObs)   # sample of animal genotypic values

        # sample fixed effects
        sampleFixedEffects!(yCorr, nFixedEffects, C, Rinv, β, vare)
        meanFxdEff = meanFxdEff + (β - meanFxdEff)/i

        # sample marker effects
        nEffects = sampleEffectsBayesCDom!(yCorr, nObs, nMarkers, xArray, XpRinvX, markerMeans, Rinv,
                                             a, d, α, δ, π, varEffects, vare, u, g)
        meanAddEff   = meanAddEff   + (a - meanAddEff)/i
        meanDomEff   = meanDomEff   + (d - meanDomEff)/i
        meanSbtEff   = meanSbtEff   + (α - meanSbtEff)/i
        mdlFrqAddEff = mdlFrqAddEff + (δ[:,1] - mdlFrqAddEff)/i
        mdlFrqDomEff = mdlFrqDomEff + (δ[:,2] - mdlFrqDomEff)/i
        meanGenVal   = meanGenVal   + (g - meanGenVal)/i
        addVar[i]    = var(u)
        genVar[i]    = var(g)

        # sample residula variance
        vare = sampleVariance(yCorr.*RinvSqrt, nObs, nuRes, scaleRes)
        resVar[i] = vare

        # sample locus effect variance
        varEffects[1] = sampleVariance(a, nEffects[1], dfEffectVar, scaleVar[1])
        varEffects[2] = sampleVariance(d, nEffects[2], dfEffectVar, scaleVar[2])

        # sample π
        if (estimatePi == "yes")
            π[1] = samplePi(nEffects[1], nMarkers)
            π[2] = samplePi(nEffects[2], nMarkers)
        end
        piAddEff[i] = π[1]
        piDomEff[i] = π[2]

        if (estimateScale == "yes")
            scaleVar[1] = sampleScale(varEffects[1], dfEffectVar, 1, 1)
            scaleVar[2] = sampleScale(varEffects[2], dfEffectVar, 1, 1)
        end
        scaleAddVar[i] = scaleVar[1]
        scaleDomVar[i] = scaleVar[2]

        # display progress
        if (i%100)==0
            # remove rounding errors
            yCorr = y - C*β - X*a
            for j=1:nMarkers
                w = get_dom_cov(xArray[j] + markerMeans[j], nObs)
                w = w - mean(w)
                yCorr = yCorr - w*d[j]
            end
            println ("Iter ",i,
                     ", number of additive effects ",  nEffects[1],
                     ", number of dominance effects ", nEffects[2])
        end
    end

    # output list
    output = Dict()
    output["posterior mean of fixed effects"]                = meanFxdEff
    output["posterior mean of additive effects"]             = meanAddEff
    output["posterior mean of dominance effects"]            = meanDomEff
    output["posterior mean of substitution effects"]         = meanSbtEff
    output["posterior mean of genotypic values"]             = meanGenVal
    output["model frequency of additive effects"]            = mdlFrqAddEff
    output["model frequency of dominance effects"]           = mdlFrqDomEff
    output["posterior sample of pi for additive effects"]    = piAddEff
    output["posterior sample of pi for dominance effects"]   = piDomEff
    output["posterior sample of scale for additive effects"] = scaleAddVar
    output["posterior sample of scale for dominance effects"]= scaleDomVar
    output["posterior sample of genotypic variance"]         = genVar
    output["posterior sample of additive genetic variance"]  = addVar
    output["posterior sample of residual variance"]          = resVar

    return output
end

