%
% Status : main Dynare file
%
% Warning : this file is generated automatically by Dynare
%           from model file (.mod)

if isoctave || matlab_ver_less_than('8.6')
    clear all
else
    clearvars -global
    clear_persistent_variables(fileparts(which('dynare')), false)
end
tic0 = tic;
% Save empty dates and dseries objects in memory.
dates('initialize');
dseries('initialize');
% Define global variables.
global M_ options_ oo_ estim_params_ bayestopt_ dataset_ dataset_info estimation_info ys0_ ex0_
options_ = [];
M_.fname = 'Beaudry_Portier_2004';
M_.dynare_version = '4.5.4';
oo_.dynare_version = '4.5.4';
options_.dynare_version = '4.5.4';
%
% Some global variables initialization
%
global_initialization;
diary off;
diary('Beaudry_Portier_2004.log');
M_.exo_names = 'eps_X';
M_.exo_names_tex = 'eps\_X';
M_.exo_names_long = 'eps_X';
M_.exo_names = char(M_.exo_names, 'eps_K');
M_.exo_names_tex = char(M_.exo_names_tex, 'eps\_K');
M_.exo_names_long = char(M_.exo_names_long, 'eps_K');
M_.exo_names = char(M_.exo_names, 'eps_S');
M_.exo_names_tex = char(M_.exo_names_tex, 'eps\_S');
M_.exo_names_long = char(M_.exo_names_long, 'eps_S');
M_.endo_names = 'C';
M_.endo_names_tex = 'C';
M_.endo_names_long = 'C';
M_.endo_names = char(M_.endo_names, 'K');
M_.endo_names_tex = char(M_.endo_names_tex, 'K');
M_.endo_names_long = char(M_.endo_names_long, 'K');
M_.endo_names = char(M_.endo_names, 'LK');
M_.endo_names_tex = char(M_.endo_names_tex, 'LK');
M_.endo_names_long = char(M_.endo_names_long, 'LK');
M_.endo_names = char(M_.endo_names, 'LX');
M_.endo_names_tex = char(M_.endo_names_tex, 'LX');
M_.endo_names_long = char(M_.endo_names_long, 'LX');
M_.endo_names = char(M_.endo_names, 'X');
M_.endo_names_tex = char(M_.endo_names_tex, 'X');
M_.endo_names_long = char(M_.endo_names_long, 'X');
M_.endo_names = char(M_.endo_names, 'L');
M_.endo_names_tex = char(M_.endo_names_tex, 'L');
M_.endo_names_long = char(M_.endo_names_long, 'L');
M_.endo_names = char(M_.endo_names, 'I');
M_.endo_names_tex = char(M_.endo_names_tex, 'I');
M_.endo_names_long = char(M_.endo_names_long, 'I');
M_.endo_names = char(M_.endo_names, 'LOGTHETX');
M_.endo_names_tex = char(M_.endo_names_tex, 'LOGTHETX');
M_.endo_names_long = char(M_.endo_names_long, 'LOGTHETX');
M_.endo_names = char(M_.endo_names, 'LOGTHETK');
M_.endo_names_tex = char(M_.endo_names_tex, 'LOGTHETK');
M_.endo_names_long = char(M_.endo_names_long, 'LOGTHETK');
M_.endo_names = char(M_.endo_names, 'LOGSENT');
M_.endo_names_tex = char(M_.endo_names_tex, 'LOGSENT');
M_.endo_names_long = char(M_.endo_names_long, 'LOGSENT');
M_.endo_partitions = struct();
M_.param_names = 'del';
M_.param_names_tex = 'del';
M_.param_names_long = 'del';
M_.param_names = char(M_.param_names, 'bet');
M_.param_names_tex = char(M_.param_names_tex, 'bet');
M_.param_names_long = char(M_.param_names_long, 'bet');
M_.param_names = char(M_.param_names, 'thetk');
M_.param_names_tex = char(M_.param_names_tex, 'thetk');
M_.param_names_long = char(M_.param_names_long, 'thetk');
M_.param_names = char(M_.param_names, 'thetx');
M_.param_names_tex = char(M_.param_names_tex, 'thetx');
M_.param_names_long = char(M_.param_names_long, 'thetx');
M_.param_names = char(M_.param_names, 'a');
M_.param_names_tex = char(M_.param_names_tex, 'a');
M_.param_names_long = char(M_.param_names_long, 'a');
M_.param_names = char(M_.param_names, 'v');
M_.param_names_tex = char(M_.param_names_tex, 'v');
M_.param_names_long = char(M_.param_names_long, 'v');
M_.param_names = char(M_.param_names, 'alp');
M_.param_names_tex = char(M_.param_names_tex, 'alp');
M_.param_names_long = char(M_.param_names_long, 'alp');
M_.param_names = char(M_.param_names, 'gam');
M_.param_names_tex = char(M_.param_names_tex, 'gam');
M_.param_names_long = char(M_.param_names_long, 'gam');
M_.param_names = char(M_.param_names, 'v0');
M_.param_names_tex = char(M_.param_names_tex, 'v0');
M_.param_names_long = char(M_.param_names_long, 'v0');
M_.param_names = char(M_.param_names, 'rhox');
M_.param_names_tex = char(M_.param_names_tex, 'rhox');
M_.param_names_long = char(M_.param_names_long, 'rhox');
M_.param_names = char(M_.param_names, 'rhok');
M_.param_names_tex = char(M_.param_names_tex, 'rhok');
M_.param_names_long = char(M_.param_names_long, 'rhok');
M_.param_names = char(M_.param_names, 'rhos');
M_.param_names_tex = char(M_.param_names_tex, 'rhos');
M_.param_names_long = char(M_.param_names_long, 'rhos');
M_.param_partitions = struct();
M_.exo_det_nbr = 0;
M_.exo_nbr = 3;
M_.endo_nbr = 10;
M_.param_nbr = 12;
M_.orig_endo_nbr = 10;
M_.aux_vars = [];
M_.Sigma_e = zeros(3, 3);
M_.Correlation_matrix = eye(3, 3);
M_.H = 0;
M_.Correlation_matrix_ME = 1;
M_.sigma_e_is_diagonal = 1;
M_.det_shocks = [];
options_.block=0;
options_.bytecode=0;
options_.use_dll=0;
M_.hessian_eq_zero = 1;
erase_compiled_function('Beaudry_Portier_2004_static');
erase_compiled_function('Beaudry_Portier_2004_dynamic');
M_.orig_eq_nbr = 10;
M_.eq_nbr = 10;
M_.ramsey_eq_nbr = 0;
M_.set_auxiliary_variables = exist(['./' M_.fname '_set_auxiliary_variables.m'], 'file') == 2;
M_.lead_lag_incidence = [
 0 5 0;
 1 6 0;
 0 7 15;
 0 8 16;
 0 9 0;
 0 10 0;
 0 11 0;
 2 12 17;
 3 13 18;
 4 14 0;]';
M_.nstatic = 4;
M_.nfwrd   = 2;
M_.npred   = 2;
M_.nboth   = 2;
M_.nsfwrd   = 4;
M_.nspred   = 4;
M_.ndynamic   = 6;
M_.equations_tags = {
};
M_.static_and_dynamic_models_differ = 0;
M_.exo_names_orig_ord = [1:3];
M_.maximum_lag = 1;
M_.maximum_lead = 1;
M_.maximum_endo_lag = 1;
M_.maximum_endo_lead = 1;
oo_.steady_state = zeros(10, 1);
M_.maximum_exo_lag = 0;
M_.maximum_exo_lead = 0;
oo_.exo_steady_state = zeros(3, 1);
M_.params = NaN(12, 1);
M_.NNZDerivatives = [35; -1; -1];
M_.params( 1 ) = 0.05;
del = M_.params( 1 );
M_.params( 2 ) = 0.98;
bet = M_.params( 2 );
M_.params( 3 ) = 1;
thetk = M_.params( 3 );
M_.params( 4 ) = 1;
thetx = M_.params( 4 );
M_.params( 5 ) = 0.5;
a = M_.params( 5 );
M_.params( 6 ) = (-1.5);
v = M_.params( 6 );
M_.params( 7 ) = 0.6;
alp = M_.params( 7 );
M_.params( 8 ) = 0.97;
gam = M_.params( 8 );
M_.params( 9 ) = 1;
v0 = M_.params( 9 );
M_.params( 10 ) = 0.95;
rhox = M_.params( 10 );
M_.params( 11 ) = 0;
rhok = M_.params( 11 );
M_.params( 12 ) = 0;
rhos = M_.params( 12 );
LOGTHETXss = 0;
LOGTHETKss = 0;
LOGSENTss  = 0;
LXss       = 0.51199;
LKss       = 0.10104;
Xss        = thetx * LXss^alp;
Kss        = 1/del * thetk * LKss^gam;
Css        = ( a*( Xss )^v + (1-a)*( Kss )^v )^(1/v);
Lss        = LKss + LXss;
Iss        = thetk * LKss^gam; 
%
% INITVAL instructions
%
options_.initval_file = 0;
oo_.steady_state( 8 ) = LOGTHETXss;
oo_.steady_state( 9 ) = LOGTHETKss;
oo_.steady_state( 10 ) = LOGSENTss;
oo_.steady_state( 4 ) = LXss;
oo_.steady_state( 3 ) = LKss;
oo_.steady_state( 5 ) = Xss;
oo_.steady_state( 2 ) = Kss;
oo_.steady_state( 1 ) = Css;
oo_.steady_state( 6 ) = Lss;
oo_.steady_state( 7 ) = Iss;
if M_.exo_nbr > 0
	oo_.exo_simul = ones(M_.maximum_lag,1)*oo_.exo_steady_state';
end
if M_.exo_det_nbr > 0
	oo_.exo_det_simul = ones(M_.maximum_lag,1)*oo_.exo_det_steady_state';
end
%
% SHOCKS instructions
%
M_.exo_det_length = 0;
M_.Sigma_e(1, 1) = 1;
M_.Sigma_e(3, 3) = 1;
steady;
oo_.dr.eigval = check(M_,options_,oo_);
options_.irf = 20;
options_.order = 1;
var_list_ = char('LOGTHETX','C','I','L','X','LK','LX','K');
info = stoch_simul(var_list_);
save('Beaudry_Portier_2004_results.mat', 'oo_', 'M_', 'options_');
if exist('estim_params_', 'var') == 1
  save('Beaudry_Portier_2004_results.mat', 'estim_params_', '-append');
end
if exist('bayestopt_', 'var') == 1
  save('Beaudry_Portier_2004_results.mat', 'bayestopt_', '-append');
end
if exist('dataset_', 'var') == 1
  save('Beaudry_Portier_2004_results.mat', 'dataset_', '-append');
end
if exist('estimation_info', 'var') == 1
  save('Beaudry_Portier_2004_results.mat', 'estimation_info', '-append');
end
if exist('dataset_info', 'var') == 1
  save('Beaudry_Portier_2004_results.mat', 'dataset_info', '-append');
end
if exist('oo_recursive_', 'var') == 1
  save('Beaudry_Portier_2004_results.mat', 'oo_recursive_', '-append');
end


disp(['Total computing time : ' dynsec2hms(toc(tic0)) ]);
if ~isempty(lastwarn)
  disp('Note: warning(s) encountered in MATLAB/Octave code')
end
diary off
