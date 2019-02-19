function [AIC,BIC,HQ] = aic_bic_hq(dataset,max_lags,normalize)

%These criteria minimize the following objective functions:
%AIC(p) = T ln detOmega_hat + 2(n^2*p)
%BIC(p) = T ln detOmega_hat + (n^2*p)lnT
%HQ(p)  = T ln detOmega_hat + 2(n^2*p)lnlnT
%where n is the number of variables, T is the length of the dataset, and p
%is the number of lags

T = size(dataset,1);
nvar = size(dataset,2);
for nlags = 1:max_lags
      [~,~,~,sigma] = sr_var(dataset,nlags);
      
      AIC(nlags)      = T*log(det(sigma)) + 2*(nvar^2*nlags);
      BIC(nlags)      = T*log(det(sigma)) + (nvar^2*nlags)*log(T);
      HQ(nlags)       = T*log(det(sigma)) + 2*(nvar^2*nlags)*log(log(T));
end

[AIC_minvalue, AIC]    = min(AIC);
[BIC_minvalue, BIC]    = min(BIC);
[HQ_minvalue, HQ]      = min(HQ);

end