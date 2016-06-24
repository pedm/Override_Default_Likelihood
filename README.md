# Override_Default_Likelihood
Demonstrate how to override default likelihood used in Bayesian estimation in Dynare

In dynare_estimation_1.m, the objective function used in the Metropolis algorithm is determined here:

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

