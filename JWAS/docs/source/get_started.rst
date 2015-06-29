Get Started
===========

An example to run BayesC is shown below. Let's start by simulating a dataset (a more complicated simulation 
package ``GenSim`` can be found at `QTL.rocks <http://QTL.rocks>`_.) Here a naive simulation is performed using Distributions.jl.

.. code-block:: julia

	using(Distributions)
	d = Binomial(2,0.5)

	nObs     = 10
	nMarkers = 100
	X        = rand(d,(nObs,nMarkers))
	α        = randn(nMarkers)
	a        = X*α
	stdGen   = std(a)
	a        = a/stdGen
	y        = a + randn(nObs)

Though ``JWAS`` can fit any fixed effects and weighted phenotypes, this example below showed how to run BayesC with only 
population mean as fixed effects.

.. code-block:: julia

	using JWAS
	
	myOption=Dict()
	myOption["run"]           = "BayesC"
	myOption["seed"]          = 314	
	myOption["chainLength"]   = 5000
	myOption["probFixed"]     = 0.95 
	myOption["estimatePi"]    = "yes"
	myOption["estimateScale"] = "yes"
	myOption["varGenotypic"]  = 1
	myOption["varResidual"]   = 1
	
	output = runJWAS(myOption,X,y)
	
Posterior samples for all parameters of interest are saved in the dictionary ``output``. A plot of the result is shown below. 


