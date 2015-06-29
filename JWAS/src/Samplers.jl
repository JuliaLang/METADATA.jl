## Bayes samplers

function sampleVariance(x, n, df, scale)
    return (dot(x,x) + df*scale)/rand(Chisq(n+df))
end

### x' Rinv x beta_hat = x' Rinv ( ycorr + x beta_hat )
function sampleFixedEffects!(yCorr, nFixedEffects, C, Rinv, β, vare)
    for j=1:nFixedEffects
        oldβ   = β[j]
        cRinv  = C[:,j].*Rinv
        lhs    = dot(cRinv,C[:,j])
        rhs    = dot(cRinv,yCorr) + lhs*β[j]
        invLhs = 1.0/lhs
        mean   = rhs*invLhs
        β[j]   = mean + randn()*sqrt(invLhs*vare)
        BLAS.axpy!(oldβ-β[j],C[:,j],yCorr)
    end
end

function samplePi(nEffects, nTotal)
    return rand(Beta(nTotal-nEffects+1, nEffects+1))
end

function sampleScale(var, df, shape, scale)
    invSum = sum(1.0./var[var.!=0])
    shapeTilde = shape + 0.5*df*length(var)
    scaleTilde = 1.0/(1.0/scale + 0.5*df*invSum)
    return rand(Gamma(shapeTilde, scaleTilde))
end
