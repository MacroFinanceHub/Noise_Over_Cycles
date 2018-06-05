clear 
close all

%Add path for data dor both Marco's PC and Vito's Mac
current_dir = pwd;
base_path = pwd;
addpath(base_path)
if exist([base_path '\Data'], 'dir')
      addpath([base_path '\Data']) %for Microsoft
else
      addpath([base_path '/Data']) %for Mac
end

%Data Info
% x_t|t     = first column of variables
% x_t+4|t   = fifth column of variables
% x_t|t-1   = second column of variables previous period
% x_t+4|t-1 = sixth column of variables previous period

%Import data of expected Real GDP level
SPF_RGDP     = xlsread('meanLevel','RGDP','A2:H200');
SPF_INDPROD  = xlsread('meanLevel','INDPROD','A2:H200');
SPF_RRESINV  = xlsread('meanLevel','RRESINV','A2:H200');
SPF_RNRESINV = xlsread('meanLevel','RNRESIN','A2:H200');

time = 1968 + 4/4 : 1/4 : 2018+2/4;
% Generalized Truncation
data = [SPF_RGDP SPF_INDPROD SPF_RRESINV SPF_RNRESINV];
n_var_system = size(data,2);
threshold = -1/eps;
for i_var_system = 1:n_var_system
      loc(i_var_system) = find(data(:,i_var_system) > threshold, 1);
end
truncation_point = max(loc);
SPF_RGDP     = SPF_RGDP(truncation_point:end,:);
SPF_INDPROD  = SPF_INDPROD(truncation_point:end,:);
SPF_RRESINV  = SPF_RRESINV(truncation_point:end,:);
SPF_RNRESINV  = SPF_RNRESINV(truncation_point:end,:);
time = time(truncation_point+1:end);
%Building Zt
%Step 1 - Getting the forecasted growth rates
Delta_RGDP_t = log(SPF_RGDP(:,7)) - log(SPF_RGDP(:,3));
Delta_RDGP_t1 = log(SPF_RGDP(:,8)) - log(SPF_RGDP(:,4));
Delta_INDPROD_t = log(SPF_INDPROD(:,7)) - log(SPF_INDPROD(:,3));
Delta_INDPROD_t1 = log(SPF_INDPROD(:,8)) - log(SPF_INDPROD(:,4));
Delta_RRESINV_t = log(SPF_RRESINV(:,7)) - log(SPF_RRESINV(:,3));
Delta_RRESINV_t1 = log(SPF_RRESINV(:,8)) - log(SPF_RRESINV(:,4));

Delta_RINV_t = log(SPF_RNRESINV(:,7) + SPF_RRESINV(:,7)) ...
      - log(SPF_RNRESINV(:,3) + SPF_RRESINV(:,3));
Delta_RINV_t1 = log(SPF_RNRESINV(:,8) + SPF_RRESINV(:,8)) ...
      - log(SPF_RNRESINV(:,4) + SPF_RRESINV(:,4));
%Step 2 - Revision in forecast growth rates
Z1 = Delta_RGDP_t(2:end) - Delta_RDGP_t1(1:end-1);
Z2 = Delta_INDPROD_t(2:end) - Delta_INDPROD_t1(1:end-1);
%Z3 = Delta_RRESINV_t(2:end) - Delta_RRESINV_t1(1:end-1);
Z3 = Delta_RINV_t(2:end) - Delta_RINV_t1(1:end-1);

figure(1)
hold on
grid on
plot(time',Z1)
plot(time',Z2)
plot(time',Z3)
legend('Real GDP','Industrial production','Investment')
hold off

Z = [Z1 Z2 Z3];

corr(Z)