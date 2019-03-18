function plot_IRFs_2CIs(IRFs,ub1,lb1,ub2, lb2, h,...
      which_shock,names, varnames, which_ID_strat, print_figs, ...
      use_current_time, base_path)
% h = IR horizon for figures
% ub1 and lb1 are the bootstrapped CI for the 1st significance level
% ub2 and lb2 are the bootstrapped CI for the 2nd significance level
% names = cell vector of shock names
% varnames = cell vector of variable names
% which_ID_strat = a string describing which identification strategy we used
% print_figs = 'yes' --> saves the figures; else if 'no' -- > just
% shows the figures.

nvar = size(IRFs,1);
nshocks = size(which_shock,2);
periods = 1:h;

% Draw pretty pictures
for i_shock=1:nshocks
      for i_var=1:nvar
            figure(i_shock)
            subplot(2,ceil(nvar/2),i_var)
            set(gcf,'color','w'); % sets white background color
            set(gcf, 'Position', get(0, 'Screensize')); % sets the figure fullscreen (hopefully)
            varname = varnames{i_var};
            shockname = names{i_shock};
            %name = names{i_shock};
            hold on
            x2 = [periods, fliplr(periods)];
            % The bigger CI
            inBetween = [lb2(i_var,1:h,which_shock(i_shock)), ...
                  fliplr(ub2(i_var,1:h,which_shock(i_shock)))];
            hh1 = fill(x2, inBetween, [0.75 0.75 0.75],'LineStyle','none');
            set(hh1,'facealpha',.5)
            % The smaller CI
            inBetween = [lb1(i_var,1:h,which_shock(i_shock)), ...
                  fliplr(ub1(i_var,1:h,which_shock(i_shock)))];
            hh2 = fill(x2, inBetween, [0.5 0.5 0.5],'LineStyle','none');
            set(hh2,'facealpha',.5)
            plot(zeros(1,h), 'Color','b')
            plot(periods,IRFs(i_var,1:h,which_shock(i_shock)),'linewidth',1,'Color','r')
            xt = get(gca, 'XTick');
            set(gca, 'FontSize', 14)
            title([varname],'fontsize',24)
            %ylim([min_y_lim(i_var) max_y_lim(i_var)]);
            hold off
            grid on
      end
      % Save figures if you want to
      if strcmp(print_figs, 'yes')
            invoke_export_fig([shockname], which_ID_strat,...
                  use_current_time, base_path)
            %close all
            pause(0.5)
      end
end


end