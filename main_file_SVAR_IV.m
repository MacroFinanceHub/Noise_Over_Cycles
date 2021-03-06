%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%  Marco Brianti, Vito Cormun, PhD Candidates, Boston College,
%  Department of Economics, Feb 18, 2019
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc
clear
close all
tic
% Technical Parameters
lags                = 1;             % Number of lags in the first step (deriving Ztilde)
leads               = 0;             % Number of leads in the first step (deriving Ztilde)
H                   = 40;            % IRFs horizon
which_trend         = 'quadratic' ;  % BPfilter, HPfilter, linear, quadratic for Local Projection
which_Z             = '1';           % Which Forecast Revision: RGDP, NGDP, RCONS, INDPROD, RINV
which_shock         = {'Sentiment'}; % Tech, News
diff_LP             = 0;             % LP in levels or differences
nPC                 = 1;             % Number of Principal Components
norm_SHOCK          = 1;             % Divide shock over its own variance
printIRFs           = 0;             % Print IRFs
printVD             = 0;             % Print Variance Decompositions
nsimul              = 500;          % number of simulations for bootstrap

% Define Dependent Variables
varlist          = {'RealInvestment','TFP','PC1'};

% Read main dataset
filename                    = 'main_file';
sheet                       = 'Sheet1';
range                       = 'B1:DM300';
do_truncation               = 0; %Do not truncate data. You will have many NaN
[dataset, var_names]        = read_data2(filename, sheet, range, do_truncation);
dataset                     = [dataset; NaN(leads,size(dataset,2))]; % Adding some NaN at the end for technical purposes

% Assess name to each variable
for i = 1:size(dataset,2)
      eval([var_names{i} ' = dataset(:,i);']);
end

%*************************************************************************%
%                                                                         %
%                     1st stage - Deriving sentiment                      %
%                                                                         %
%*************************************************************************%

%Building Zt - Forecast Revisions from SPF and Michigan Index
create_Z;

% Define Variables
[TFP_trunc, trunc1, trunc2] = truncate_data(TFP);
TFPBP                       = bpass(TFP_trunc,4,32);
TFPBP                       = [TFPBP; NaN(length(TFP) - length(TFPBP),1)];
dTFP                        = [NaN; diff(TFP)];
PC                          = [PC1 PC2 PC3 PC4 PC5 PC6 PC7 PC8 PC9];
PC                          = PC(:,1:nPC);
SHOCKS_NARRATIVE            = [MUNI1Y PDVMILY HAMILTON3YP RESID08 TAXNARRATIVE];

% Defibe dependent variable
eval(['Z = Z', which_Z,';']);
Y                           = Z;

% Define Regressors and Dependent Variable
X_contemporaneous           = [TFP]; %SHOCKS_NARRATIVE];
X_lag                       = [TFPBP PC]; % PC SHOCKS_NARRATIVE];
X_lead                      = TFPBP;

% Control Regression
[~, Zhat, Ztilde, regressor] = lead_lag_matrix_regression(Y,X_lead,...
      leads,X_lag,lags,X_contemporaneous);
Ztilde = [NaN(lags,1); Ztilde; NaN(leads,1)];
Ztilde = Z;
%*************************************************************************%
%                                                                         %
%                 STRUCTURAL VAR INSTRUMENTAL VARIABLE                    %
%                                                                         %
%*************************************************************************%

% Build System and eventually filter it
for i = 1:length(varlist)
      system(:,i) = eval(varlist{i});
end
[XXX, loc_start, loc_end]     = truncate_data([system Ztilde]);
system                        = XXX(:,1:end-1);
Ztilde                        = XXX(:,end);
% Detrend Variables
which_trend = 'quad';
system = detrend_func(system,which_trend);

% Tests for lags
max_lags     = 10;
[AIC,BIC,HQ] = aic_bic_hq(system,max_lags);

% Reduced Form VAR
nlags           = 4;
disp(['Number of lags is ',num2str(nlags)])
fprintf('\n')
[B,res,sigma] = reduform_var(system, nlags);


Ztilde        = Ztilde(1+nlags:end);
Time          = Time(1+nlags+loc_start:loc_end);

% IV VAR Identification
[MM, loc_startIV, loc_endIV]     = truncate_data([res Ztilde]);
res                              = MM(:,1:end-1);
Ztilde                           = MM(:,end);
THET(:,1)                        = (res'*Ztilde)./(res(:,1)'*Ztilde);

% [structural_shocks, IR, s] = get_structural_shocks_general(A,gamma,resid,which_shocks);

% Create dataset from bootstrap
nburn             = 0;
which_correction  = 'none';
blocksize         = 4;
%nlagZ             = 4;
[~, data_boot2,Ztilde_boot2,~,~] ...
      = bootstrap_IVSVAR(B,nburn,res,Ztilde,nsimul,which_correction);

% ReAlign Time and dummyITA with res_boot (you lose nlags again!)
Time                   = Time(1+nlags:end);
Ztilde_boot2           = Ztilde_boot2(1+nlags:end,:);
% Bootstrap Identification
for i_simul=1:nsimul
      % Reduced Form VAR
      [B_boot(:,:,i_simul),res_boot(:,:,i_simul),~] = reduform_var(data_boot2(:,:,i_simul),nlags);
      % IV VAR Identification
      THET_boot(:,1,i_simul) = (res_boot(:,:,i_simul)'*Ztilde_boot2(:,i_simul))...
            ./(res(:,1)'*Ztilde);
      
      %(res_boot(:,loc_CDSITA,i_simul)'*dummyITA_boot2(:,i_simul));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      IMPULSE RESPONSE FUNCTIONS                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

A                             = [THET zeros(size(THET,1),size(THET,1)-1)];
THET_boot(:,2:size(THET,1),:) = zeros(size(THET,1),size(THET,1)-1,nsimul);
A_boot                        = THET_boot;

% Generate IRFs with upper and lower bounds
sig1                       = 0.05;
sig2                       = 0.025;
normIRFs                   = 0;
[IRFs, ub1, lb1, ub2, lb2] = genIRFs(A,A_boot,B,B_boot,H,sig1,sig2);

% Create and Printing figures for IRFs
base_path         = pwd;
which_ID          = 'IRFs_2LAG';
print_figs        = 'no';
use_current_time  = 1; % (don't) save the time
which_shocks      = 1; %[Uposition];
shocknames        = {'Sentiment Shock'};
unique            = 1;
if unique == 1
      plot_IRFs_2CIs(IRFs,ub1,lb1,ub2,lb2,H,which_shocks,shocknames,...
            varlist,which_ID,print_figs,use_current_time,base_path)
else
      plot_IRFs_2CIs_multifigures(IRFs,ub1,lb1,ub2,lb2,H,which_shocks,shocknames,...
            system_names,which_ID,print_figs,use_current_time,base_path)
end
asd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       VARIANCE DECOMPOSITION                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create and Printing figures for Variance decomposition
which_ID          = 'vardec_2LAG';
print_figs        = 'yes';
sig1VD            = 0.05;
sig2VD            = 0.025;
normVD            = 0;
[vardec, ub1_vardec, lb1_vardec, ub2_vardec, lb2_vardec] = ...
      gen_vardec_boot(A,A_boot,A,A_boot,B,B_boot,H,sig1VD,sig2VD,normVD);
% Plotting VD
plot_IRFs_2CIs(vardec,ub1_vardec,lb1_vardec,ub2_vardec,lb2_vardec,H,which_shocks,shocknames,...
      system_names,which_ID,print_figs,use_current_time,base_path)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       STRUCTURAL SHOCKS                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get Structural Shocks
ss  = (inv(A)*res')';
ssU = ss(:,3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     HISTORICAL DECOMPOSITION                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Historical Decomposition
normHD          = 0;
[HD,diffHD]     = historical_decomposition(A,B,ss,normHD);
HD              = HD(3:end,:,:);
system_namesHD  = {'CDSITA2014','CDSBANKS2014'};
systemHD        = system(:,3:end);
meansystemHD    = meansystem(3:end);

% Plotting Figures
which_ID          = 'HD_3LAG';
print_figs        = 'yes';
unique            = 1;
year_to_start     = 0;
which_shocksHD    = loc_dummy;
plot_historical_decomposition(Time,HD,systemHD,meansystemHD,DAYS,nlags,...
      which_shocks,shocknames,system_namesHD,print_figs,...
      use_current_time,base_path,unique,which_ID,year_to_start)


asd


