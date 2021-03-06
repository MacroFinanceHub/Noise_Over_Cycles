function [B, Yhat, res, XX] = lead_lag_matrix_regression(Y,X_lead,leads,...
      X_lag,lags,X_contemporaneous)

% Rearrange data to run a lead-lag regression
% X_lead is not using contemporaneous data, only leads
% X_lags is not using contemporaneous data, only lags
% X_contemporaneous uses only contemporaneous data
% if no X_contemoraneous just X_contemoraneous = 0 (zero(1,1))
% if no X_lead just X_lag = whatever and leads = 0 (zero(1,1))
% if no X_lag just X_lead = whatever and lags = 0 (zero(1,1))

YY = Y(1+lags:end-leads);

if lags > 0
      XX_lag = X_lag(1+lags-1:end-leads-1,:); % Contemporaneous
      for i = 2:lags
            if size(X_lag,2) > 1
                  XX_lag = [XX_lag X_lag(1-i+lags:end-i-leads,:)];
            else
                  XX_lag = [XX_lag X_lag(1-i+lags:end-i-leads)];
            end
      end
end

if leads > 0
      XX_lead = X_lead(1+lags+1:end-leads+1,:); % It is already a period haed
      for i = 2:leads
            if size(X_lead,2) > 1
                  XX_lead = [XX_lead X_lead(1+i+lags:end-leads+i,:)];
            else
                  XX_lead = [XX_lead X_lead(1+i+lags:end-leads+i)];
            end
      end
end


if size(X_contemporaneous,1) > 1 && lags > 0 && leads > 0
      XX = [ones(size(YY,1),1) XX_lag XX_lead X_contemporaneous(1+lags:end-leads,:)];
elseif sum(sum(abs(X_contemporaneous))) == 0 && lags > 0 && leads > 0
      XX = [ones(size(YY,1),1) XX_lag XX_lead];
elseif size(X_contemporaneous,1) > 1 && lags == 0 && leads > 0
      XX = [ones(size(YY,1),1) XX_lead X_contemporaneous(1+lags:end-leads,:)];
elseif size(X_contemporaneous,1) > 1 && lags > 0 && leads == 0
      XX = [ones(size(YY,1),1) XX_lag X_contemporaneous(1+lags:end-leads,:)];
elseif size(X_contemporaneous,1) > 1 && lags == 0 && leads == 0
      XX = [ones(size(YY,1),1) X_contemporaneous(1+lags:end-leads,:)];
elseif sum(sum(abs(X_contemporaneous))) == 0 && lags > 0 && leads == 0
      XX = [ones(size(YY,1),1) XX_lag];
elseif sum(sum(abs(X_contemporaneous))) == 0 && lags == 0 && leads > 0
      XX = [ones(size(YY,1),1) XX_lead];
elseif sum(sum(abs(X_contemporaneous))) == 0 && lags == 0 && leads == 0
      XX = [ones(size(YY,1),1)];  
      warning('You are only using the constant as regressor')
end


[B,Bint,res]   = regress(YY,XX);
Yhat           = YY - res;
tuple          = [YY XX];


end