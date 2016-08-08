# Override_Default_Likelihood
Here I demonstrate how to override the default likelihood function used by Dynare in Bayesian estimation.

The objective function used in the Metropolis algorithm is determined in these lines of dynare_estimation_1.m. The objective function is contained in either dsge_likelihood.m or non_linear_dsge_likelihood.m. Unfortunately Dynare does not allow us to specifiy an alternative objective function directly. 

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

However, it is possible to override Dynare's default dsge_likelihood() function. This can be done by creating our own dsge_likelihood.m in the working directory of Matlab. This overrides the default dsge_likelihood.m in Dynare.

In this code, I confirm that this works. I think that the next step is to modify dsge_likelihood.m, by adding code that penalizes the likelihood based on the variance-covariance matrix of the shocks. 
