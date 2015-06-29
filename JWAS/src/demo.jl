#load GenSel
include("GenSel.jl")
using GenSel

#simulate data
using(Distributions)
d = Binomial(2,0.5)

nObs     = 100
nMarkers = 1000
X = float32(rand(d,(nObs,nMarkers)))
α  = float32(randn(nMarkers))
a  = X*α
stdGen = std(a)
a = a/stdGen
y = float32(a + randn(nObs))
saveAlpha = float32(α);

C = ones(nObs,1)    # incidence matrix for fixed effects
Rinv = ones(nObs)   # weights for residual

dominantGeneAction = false
if (dominantGeneAction)
    W = zeros(nObs,nMarkers)
    for j=1:nMarkers
        W[:,j] = get_dom_cov(X[:,j], nObs)
    end
    δ = float32(randn(nMarkers))
    δ = δ/std(W*δ)
    y = y + W*δ
end


#Options
myOption=Dict()
myOption["run"]          = "BayesB"
myOption["seed"]         = 10
myOption["chainLength"]  = 2000
myOption["probFixed"]    = 0.5        # [value for a, value for d] for running BayesCPiDom
myOption["estimatePi"]   = "no"
myOption["dfEffectVar"]  = 4
myOption["nuRes"]        = 4
myOption["varGenotypic"] = 1          # [value for a, value for d] for running BayesCPiDom
myOption["varResidual"]  = 1

parm1=GenSelOptions(myOption["run"],
                    myOption["seed"],
                    myOption["chainLength"],
                    myOption["probFixed"],
                    myOption["estimatePi"],
                    myOption["dfEffectVar"],
                    myOption["nuRes"],
                    myOption["varGenotypic"],
                    myOption["varResidual"])

#Run BayesC0
output = runGenSel(parm1,X,y,C,Rinv)
keys(output)
