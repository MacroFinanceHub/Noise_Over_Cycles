function [ys_, params, info] = BC_19March2019_RBC_with_K_N_steadystate2(ys_, exo_, params)
% Steady state generated by Dynare preprocessor
    info = 0;
    ys_(6)=1;
    ys_(5)=(1+params(6))*(1+params(1))+params(2)-1;
    ys_(3)=ys_(5)*(1-params(4))/(ys_(5)/params(4)-params(2)-params(6))/params(4);
    ys_(2)=ys_(3)*(1+params(6))*(ys_(5)/params(4))^(1/(params(4)-1));
    ys_(1)=ys_(2)*(1-params(2))/(1+params(6));
    ys_(4)=ys_(1);
    % Auxiliary equations
    check_=0;
end
