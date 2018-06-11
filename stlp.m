function [IRF_E, IRF_R ] = stlp(y,x,u,fz,lags,H)
% H is the length of the irf
% y and x are Tx1;
% the regression is  y(t+h) = A0 + PI^E(1-F(z(t-1)))u(t) + PI^RF(z(t-1))u(t) + B1u(t-1) + C1y(t-1) + D1x(t-1) + C2y(t-2) + ...
for h = 1:H
    Y = y(h+lags:end,:);
    X = u(lags+1:end-h+1,:).*(ones(length(Y),1)-fz(lags+1:end-h+1,1)); %make sure fz is lagged in the argument of the function
    X = [X, u(lags+1:end-h+1,:).*fz(lags+1:end-h+1,1)];
    if lags > 0 %which allows for controls
        for jj = 1:lags;
            if x(1)^2 > 0; 
            X  = [X, u(lags-jj+1:end-jj-h+1,:), y(lags-jj+1:end-jj-h+1,:),...
               x(lags-jj+1:end-jj-h+1,:)];
            else 
                X  = [X, u(lags-jj+1:end-jj-h+1,:), y(lags-jj+1:end-jj-h+1,:)];
            end
            end
    end
    X = [X , ones(length(Y),1),[1:1:length(Y)]'];
    B = X'*X\(X'*Y);
    IRF_E(h) = B(1)*1 + B(2)*0; %here we are fixing the probability over the IRFs - need to relax
    IRF_R(h) = B(1)*0 + B(2)*1;
end




