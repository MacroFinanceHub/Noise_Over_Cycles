function [IRFs, ub1, lb1, ub2, lb2] = genIRFs(A_IRF,A_boot,B,B_boot,H, sig1, sig2)
% Generate IRFs and bootstrapped IRF confidence intervals for ALL shocks
% H = IR horizon for the generation of IRFs (to be used in variance decomposition)
% sig1 = CI significance level (enter as 0.9 for example)
% sig2 = a 2nd CI significance level (enter as 0.95 for example)
% Can choose not to do bootstrapping by setting A_boot to 0.

nvar = size(A_IRF,1);
nlag = (size(B,1)-1)/nvar;
nshocks = nvar;
nsimul = size(A_boot,3);
perc_up1 = ceil(nsimul*sig1); % the upper percentile of bootstrapped responses for CI
perc_low1 = floor(nsimul*(1-sig1)); % the lower percentile of bootstrapped responses for CI
perc_up2 = ceil(nsimul*sig2); % same for 2nd CI
perc_low2 = floor(nsimul*(1-sig2)); % same for 2nd CI

% Remove constant
B = B(2:end,:);
B_boot = B_boot(2:end,:,:);


% Preallocate IRs
IRFs = zeros(nvar,H,nshocks);
IRFs_boot = zeros(nvar,H,nshocks,nsimul);
IRFs_boot_sorted = zeros(nvar,H,nshocks,nsimul);
ub1 = zeros(nvar,H,nshocks);
lb1 = zeros(nvar,H,nshocks);
ub2 = zeros(nvar,H,nshocks);
lb2 = zeros(nvar,H,nshocks);

for i_shock=1:nshocks
      shocks = zeros(nvar,1);
      shocks(i_shock,1) = 1;
      
      % Initialize:
      IRFs(:,1,i_shock) = A_IRF*shocks;
      F = [IRFs(:,1,i_shock)' zeros(1,(nlag-1)*nvar)];
      % Generate IRFs
      for k=2:H
            IRFs(:,k,i_shock) = F*B;
            F = [IRFs(:,k,i_shock)' F(1:end-nvar)];
      end
      
      if sum(sum(A_boot)) == 0
            % don't do bootstrapping
      else
            % Redo for bootstrapped samples: Here we need an extra loop over nsimul
            for i_sim=1:nsimul
                  %Initialize:
                  IRFs_boot(:,1,i_shock,i_sim) = A_boot(:,:,i_sim)*shocks;
                  F_boot = [IRFs_boot(:,1,i_shock,i_sim)' zeros(1,(nlag-1)*nvar)];
                  %Generate IRFs
                  for k=2:H
                        IRFs_boot(:,k,i_shock,i_sim) = F_boot*B_boot(:,:,i_sim);
                        F_boot = [IRFs_boot(:,k,i_shock,i_sim)' F_boot(1:end-nvar)];
                  end
                  % If bootstraps go the wrong way, flip them
                  if i_shock == 1 && i_shock == 3 % only do for IT shock since news never flips
                        
                        which_flip_test = 'old';
                        switch which_flip_test
                              case 'old'
                                    % thinks of the flip as being a mirror around the 0-line
                                    if sum(sum(abs(IRFs_boot(:,:,i_shock,i_sim) - IRFs(:,:,i_shock)))) ...
                                                >= sum(sum(abs(IRFs_boot(:,:,i_shock,i_sim) + IRFs(:,:,i_shock))))
                                          IRFs_boot(:,:,i_shock,i_sim) = - IRFs_boot(:,:,i_shock,i_sim);
                                    else
                                          IRFs_boot(:,:,i_shock,i_sim) = IRFs_boot(:,:,i_shock,i_sim);
                                    end
                              case 'alternative'
                                    % alternative test for 'going the wrong way' for IT:
                                    % If the response of TFP to IT is negative at some far
                                    % horizon, the flip all the responses to the IT shock
                                    far_out = 20;
                                    if IRFs_boot(1,far_out, i_sim) < 0
                                          IRFs_boot(:,:,i_shock,i_sim) = - IRFs_boot(:,:,i_shock,i_sim);
                                    end
                                    
                              case 'alt2'
                                    % alternative test for 'going the wrong way' for IT (its position is 3):
                                    % If the response of IT to IT is negative on impact
                                    if IRFs_boot(3,1,i_sim) < 0
                                          IRFs_boot(:,:,i_shock,i_sim) = - IRFs_boot(:,:,i_shock,i_sim);
                                    end
                              case 'none'
                        end
                  end
            end
            
            % Sort bootstrap IRFs and set lower and upper bounds
            for i_shocks = 1:nshocks
                  IRFs_boot_sorted(:,:,i_shocks,:) = sort(IRFs_boot(:,:,i_shocks,:),4);
                  ub1(:,:,i_shocks) = IRFs_boot_sorted(:,:,i_shocks,perc_up1);
                  lb1(:,:,i_shocks) = IRFs_boot_sorted(:,:,i_shocks,perc_low1);
                  ub2(:,:,i_shocks) = IRFs_boot_sorted(:,:,i_shocks,perc_up2);
                  lb2(:,:,i_shocks) = IRFs_boot_sorted(:,:,i_shocks,perc_low2);
            end
      end
end

%Normalization
normalization = 0;
if normalization == 1
      ub1(:,:,i_shock)   = ub1(:,:,1)/IRFs(1,1,1);
      lb1(:,:,i_shock)   = lb1(:,:,1)/IRFs(1,1,1);
      ub2(:,:,i_shock)   = ub2(:,:,1)/IRFs(1,1,1);
      lb2(:,:,i_shock)   = lb2(:,:,1)/IRFs(1,1,1);
      IRFs(:,:,i_shock)  = IRFs(:,:,1)/IRFs(1,1,1); % so that each IRF is in terms of the impact change for that shock of the shocked variable
      warning('You are doing a specific normalization. Check it!')
end

end