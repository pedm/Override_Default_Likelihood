# Override_Default_Likelihood
Here I demonstrate how to override the default likelihood function used by Dynare in Bayesian estimation.

The objective function used in the Metropolis algorithm is determined in these lines of dynare_estimation_1.m:

```matlab
if ~options_.dsge_var
    if options_.particle.status
        objective_function = str2func('non_linear_dsge_likelihood');
    else
        objective_function = str2func('dsge_likelihood');
    end
else
    objective_function = str2func('dsge_var_likelihood');
end
```

Unfortunately Dynare does not allow us to specify an alternative objective function via the options object. 

However, it is possible to define our own override the default dsge_likelihood function. This can be done by creating our own own dsge_likelihood.m in the current working directory of Matlab. This overrides the default dsge_likelihood.m in Dynare.

Here I demonstrate that this works. I think that the next step is to modify dsge_likelihood.m, by adding code at the bottom that penalizes the likelihood based on the variance-covariance matrix of the shocks. 
