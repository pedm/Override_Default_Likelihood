# Override_Default_Likelihood
Here I demonstrate how to override the default likelihood function used by Dynare. In Dynare, Bayesian estimation is performed using dynare_estimation_1.m, which implements the Metropolis–Hastings algorithm. This algorithm uses the objective_function defined as follows: 

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

The objective function is either dsge_likelihood.m or non_linear_dsge_likelihood.m. Unfortunately Dynare does not allow us to specifiy an alternative objective function directly. However, it is possible to override Dynare's default dsge_likelihood.m function. 

This can be done by creating a copy of dsge_likelihood.m in the working directory of Matlab. This overrides the default dsge_likelihood.m in Dynare. It is then possible to modify the likelihood function locally. In the attached code, I confirm that this override method works. 

I think that the next step is to modify dsge_likelihood.m, by adding code that penalizes the likelihood based on the variance-covariance matrix of the shocks. 
