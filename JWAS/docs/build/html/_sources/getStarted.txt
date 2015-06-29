Get Started
===========

An example to run BayesB:

	using GenSel
	
	myOption=Dict()
	myOption["run"]          = "BayesB"
	myOption["seed"]         = 10	
	myOption["chainLength"]  = 2000
	myOption["probFixed"]    = 0.5 
	myOption["estimatePi"]   = "no"
	myOption["dfEffectVar"]  = 4
	myOption["nuRes"]        = 4
	myOption["varGenotypic"] = 1  
	myOption["varResidual"]  = 1
	
	parm=GenSelOptions(myOption["run"], 
                        	myOption["seed"],
                        	myOption["chainLength"],
                        	myOption["probFixed"],
                        	myOption["estimatePi"], 
                        	myOption["dfEffectVar"],
                        	myOption["nuRes"],
                        	myOption["varGenotypic"],
                        	myOption["varResidual"])
                            
    output = runGenSel(parm,X,y,C,Rinv)




To read in X, y,


