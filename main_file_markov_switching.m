clear
close all

rho = 0.9;
sigm = 1;
T = 2000;
drift = 5;
tt = 0;
[y, yss] = generate_AR1(rho,sigm,T,drift,tt);
x = [ones(T-1,1), y(1:end-1)'];
y = y(2:end)';

prior_rho = [drift - 3; rho - 0.2];
prior_VARrho = eye(size(x,2));
prior_s = 770;
prior_v = 300;
N_simul = 100000;
n = 3;

[rho_post, sig_post, rho_dist, sig_dist] = ...
      bayesian_OLS_Gibbs_Sampling(prior_rho,prior_VARrho,prior_s,prior_v,y,x,N_simul,n);

rhod = squeeze(rho_dist);
sigd = squeeze(sig_dist);

return

%Generate a switching process
x_min = 1;
x_max = 10;
T = 500;
x = linspace(x_min,x_max,T);
noise = randn(1,T+1);
x = x + noise;
y = zeros(1,T);
b1 = 1;
b2 = -1;
p = 0.93;
q = 0.96;
coin(1) = randn(1,1);
for i = 1:T
      if coin(i) >= 0
            if rand(1,1) < p
                  y(i) = b1 + 0.05*randn(1,1); %state 1
                  coin(i+1) = 1;
            else
                  y(i) = b2 + 0.5*randn(1,1); %state 2
                  coin(i+1) = -1;
            end
      else
            if rand(1,1) < 1 - q
                  y(i) = b1 + 0.5*randn(1,1); %state 1
                  coin(i+1) = 1;
            else
                  y(i) = b2 + 0.5*randn(1,1); %state 2
                  coin(i+1) = -1;
            end
      end
end

figure(1)
hold on
grid on
plot(y,'linewidth',1.5)
plot(coin,'linewidth',1.5)
legend('Gross Domestic Product','State of the World')
hold off






