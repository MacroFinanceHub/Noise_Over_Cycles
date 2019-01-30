% Brianti, Cormun January 2019 - Buaudry, Galizia, Portier (2019, AER)

%%%%%%% Defining Variables %%%%%%%

var 

rp                     % (1) Risk Premium
e                      % (2) Employment Rate 
x                      % (3) Durable Goods Stock 
logthet                % (4) Log Technology
logzeta;               % (5) Log Preferences

%%%%% Aggregate Productivity Shock %%%%%

varexo eps_thet eps_zeta;  

% Parameterization
parameters
OMEG GAM PSI PHIE PHI PHIBIG S ALP DEL THET BET RHO_THET SIGMA_THET RHO_ZETA SIGMA_ZETA; 

OMEG       = 0.2408; % CRRA Parameter
GAM        = 0.5876; % Habit
PSI        = 0.2994; % One minus initial debt
PHIE       = 0.0467; % Taylor Rule Parameter
PHI        = 0.8827; % Debt Baking
PHIBIG     = 0.0458; % Recovery Cost
S          = 1;      % Other Tech Parameter
ALP        = 2/3;    % Convexity of Production Function
DEL        = 0.05;   % Durable Goods Depreciation Rate 
THET       = 1;      % WRONG! It should be set to have a ss unemployment rate of 0.0583
BET        = 0.99;   % It could be WRONG! Discount Factor
RHO_THET   = 0.9;    % Persistence of tech shock
SIGMA_THET = 1;      % SD of tech shock
RHO_ZETA   = 0.9;    % Persistence of Preference Shocks
SIGMA_ZETA = 1;      % SD of preference shock  

% Defining functionals forms and derivatives

model; 

rp = (1 + (1 - e)*PHI*PHIBIG)/(e + (1 - e)*PHI);  %(1)

x(+1) = (1 - DEL)*x + exp(logthet)*e^ALP;          %(2)

logthet       = RHO_THET*logthet(-1) + SIGMA_THET*eps_thet;               %(3) 

logzeta       = RHO_ZETA*logzeta(-1) + SIGMA_ZETA*eps_zeta;               %(4) 

((   S*(x + exp(logthet)*e^ALP) - GAM*S*(x(-1) + exp(logthet(-1))*e(-1)^ALP)   )^(1-OMEG) - 1)/(1 - OMEG) = BET*THET*exp(logzeta)/exp(logzeta(-1))*(e + (1-e)*PHI)*rp*((   S*(x(+1) + exp(logthet(+1))*e(+1)^ALP) - GAM*S*(x + exp(logthet)*e^ALP)   )^(1-OMEG) - 1)/(1 - OMEG); %(5)

end;

shocks;
  var eps_thet     = 1;
  % var eps_zeta    = 1;
  % var eps, eps_mu = 0;
end;

steady(solve_algo = 2, maxit=1000);

stoch_simul(irf=50, order=1) logthet e x rp;

%stoch_simul(periods=100000, hp_filter = 1600, order=2,ar = 0, nofunctions,nograph,nodecomposition,nocorr) jobphim logz logR logU logV logFPHIC;


