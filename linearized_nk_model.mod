%===================================================================%
% This file simulates the Small Scale NK model in An and Schorfheide (2007)
% Priors are set as in An and Schorfheide (2007)
% 
% This version: Jan 19, 2016
%===================================================================%

% SWITCHES
% simulate_data = 1; Simulate data using the calibrated parameter values
% simulate_data = 0; Perform estimation using the simulated data
% Note: estimation must be performed prior to running post_estimation.m

simulate_data = 0;

%===================================================================%
%                    DECLARATION OF VARIABLES                       %
%===================================================================%

var   

% ENDOGENOUS VARIABLES

R          % (1)  Federal Fund Rate (FFR)
g          % (2)  Public Spending 
z          % (3)  TFP
y          % (4)  GDP 
infl       % (5)  Inflation
ylag       % (6)  Inflation Lagged
c          % (7)  Consumption 
YGR_obs
INF_obs
FFR_obs;

% EXOGENOUS SHOCKS
varexo e_z e_g e_r;  

%=========================================================================%
%%%%                    DECLARATION OF PARAMETERS                      %%%%
%=========================================================================%
 
parameters 

% FREE PARAMETERS 
tau         % (1)  Inverse of IES
kappa       % (2)  Slope of Phillips Curve
psi_1       % (3)  Sensitivity of FFR to Inflation
psi_2       % (4)  Sensitivity of FFR to GDP growth
rho_r       % (5)  Interest Rate Smoothing parameter
rho_g       % (6)  Persistence, Government Spending
rho_z       % (7)  Persistence, TFP growth
R_star_an   % (8)  Interest Rate Target
pi_star_an  % (9)  Inflation Target
gamma_qu    % (10) Growth Rate of Output (quarterly)
sigma_r     % (11) Volatility, Monetary Policy Shock
sigma_g     % (12) Volatility, Government Spending
sigma_z;    % (13) Volatility, TFP growth

%=========================================================================%
%%%%                     PARAMETERS' VALUES                            %%%%
%=========================================================================%

% tau     = 2.00;
% kappa   = 0.15;
% psi_1   = 1.50;
% psi_2   = 1.00;
% rho_r   = 0.60;
% rho_g   = 0.95;
% rho_z   = 0.65;
% R_star_an  = 0.40;
% pi_star_an = 4.00;
% gamma_qu   = 0.50;
% sigma_r = 0.0020;
% sigma_g = 0.0080;
% sigma_z = 0.0045;

M_.params = [
   1.961224774694275
   0.128184670390480
   1.480568087206181
   0.435439934795290
   0.521582740328915
   0.948299458175033
   0.607842662721952
   0.001935834058180
   4.053036275724159
   0.628886315096831
   0.002097054413599
   0.007984699777348
   0.004721327804085];

%=========================================================================%
%%%%                     EQUILIBRIUM CONDITIONS                        %%%%
%=========================================================================%
model(linear);

%=========================IMPLICITELY DEFINED PARAMETERS==================%

#pi_star = 1+(pi_star_an/400);
#gamma   = 1+(gamma_qu/100);
#bet     = 400/(400+R_star_an);

%=========================ENDOGENOUS VARIABLES============================%

y  = y(+1) + g  - g(+1) - (1/tau)*(R - infl(+1) - z(+1));

infl = bet*infl(+1) + kappa*(y - g);

c = y - g;

R = rho_r*R(-1) + (1-rho_r)*psi_1*infl + (1-rho_r)*psi_2*(y - g)+ sigma_r*e_r;
 
g = rho_g*g(-1)+ sigma_g*e_g;

z = rho_z*z(-1) + sigma_z*e_z;

%===============================DEFINITIONS===============================%

ylag = y(-1);

%=========================OBSERVATIONAL EQUATIONS=========================%

YGR_obs     = gamma_qu + 100*( y - y(-1) + z );

INF_obs    = pi_star_an +400*infl;

FFR_obs     = pi_star_an + R_star_an + 4*gamma_qu +400*R;

end; 

%===================================================================%
%%%%             INITIAL CONDITIONS FOR STEADY STATE             %%%%
%===================================================================%

steady_state_model;

c        = 0;
y        = 0;
infl     = 0;
R        = 0;
g        = 0;
z        = 0;
ylag     = 0;
YGR_obs  = gamma_qu;
INF_obs  = pi_star_an;
FFR_obs  = pi_star_an + R_star_an + 4*gamma_qu;

end;

%===================================================================%
%%%%           DEFINE STDEV OF STRUCTURAL INNOVATIONS            %%%%
%===================================================================%
shocks;
var e_z;
stderr 1;
var e_g;
stderr 1;
var e_r;
stderr 1;
end;

steady;

check;

% Set seed for simulation
set_dynare_seed(092677);

% Save observable variables (last one hundred observations only)
if simulate_data
    stoch_simul(order=1,periods=600, irf=20);
    % save_obs
    save sim_post_simulation.mat oo_ M_ options_;
else

    % % After simulating observables
    estimated_params;
        % % Parameter, InitValue, Density,        Para(1),    Para(2);
        % % -----------------------------------------------------------
        tau,        2.00,       GAMMA_PDF,      2.00,       0.50;
        kappa,      0.15,       GAMMA_PDF,      .2,         .1;
        psi_1,      1.50,       GAMMA_PDF,      1.5,        .25;    
        psi_2,      1.00,       GAMMA_PDF,      .5,         .25;
        rho_r,      0.60,       BETA_PDF,       .5,         .20;
        rho_g,      0.95,       BETA_PDF,       .8,         .1;
        rho_z,      0.65,       BETA_PDF,       .66,        .15;
        R_star_an,  0.40,       GAMMA_PDF,      .5,         .5;
        pi_star_an, 4.00,       GAMMA_PDF,      7,          2;
        gamma_qu,   0.50,       NORMAL_PDF,     .4,         .2;

        % For documentation on these moments, see inv_gamma_moments.m
        sigma_r,    0.0020,     INV_GAMMA_PDF,   0.005013,    0.0026;
        sigma_g,    0.0080,     INV_GAMMA_PDF,   0.012500,    0.0066;
        sigma_z,    0.0045,     INV_GAMMA_PDF,   0.006267,    0.0033;
    end;

    varobs YGR_obs INF_obs FFR_obs;

    estimation(
        datafile = SimulatedData100Obs,
        mode_compute = 3,
        order=1,
        mh_replic=1000,
        mh_nblocks=1,
        mh_jscale=0.3,
        nograph
        %, prior_trunc=0
    );

    save sim_post_estimation.mat oo_ M_ options_;
end