function plot_IRF(varlist,IRF_low,IRF_low2,IRF_up,IRF_up2,IRF,H,...
      export_fig,fig_name)

% Technical parameters, you may want to change depending on the number of Nvar
n_row      = 3; % number of rows in the figure
unique     = 1; % if unique = 1 plot IRFs together, if = 1 plot each IRF separately

% IRFs are now percentage deviations
IRF_low    = IRF_low*100;
IRF_low2   = IRF_low2*100;
IRF_up     = IRF_up*100;
IRF_up2    = IRF_up2*100;
IRF        = IRF*100;

%Impulse Response Functions using Local Projection - Figure
if unique == 1
      nvar     = length(varlist);
      n_col    = ceil(nvar/n_row); %plus one for Vix
      figure('Position',[1 41 1920 963])
      set(gcf,'color','w');
end
for j = 1:length(varlist)
      if unique == 1
            s = subplot(n_row,n_col,j);
      else
            figure(j)
            nvar     = length(varlist);
            n_col    = ceil(nvar/n_row); %plus one for Vix
            figure('Position',[1 41 1920 963])
            set(gcf,'color','w');
      end
      hold on
      plot([0:H-1]',IRF_low(j,:), '--k','linewidth', 1);
      plot([0:H-1]',IRF_up(j,:), '--k','linewidth', 1);
      plot([0:H-1]',IRF_low2(j,:), '--k','linewidth', 2);
      plot([0:H-1]',IRF_up2(j,:), '--k','linewidth', 2);
      plot([0:H-1]',IRF(j,:), '-k', 'linewidth', 3);
      plot([0:H-1]',0*[1:H]',':k');
      set(gca,'TickLabelInterpreter','latex')
      title(varlist{j},'interpreter', 'latex', 'fontsize', 26);
      if unique == 1 && j == 1
            xlabel('Quarter','interpreter','latex','fontsize',20);
            ylabel('\% deviation from s.s.','interpreter','latex','fontsize',18);
      elseif unique == 0
            xlabel('Quarter','interpreter','latex','fontsize',20);
            ylabel('\% deviation from s.s.','interpreter','latex','fontsize',18);
      end
      axis tight
      
      
      if export_fig == 1
      
      % Create the correct path
      base_path = pwd;
      warning off
      if exist([base_path '\Figures'], 'dir')
            cd([base_path '\Figures']) %for Microsoft
      else
            cd([base_path '/Figures']) %for Mac
      end
      if exist([base_path '\Export_Fig'], 'dir')
            addpath([base_path '\Export_Fig']) %for Microsoft
      else
            addpath([base_path '/Export_Fig']) %for Mac
      end
      warning on
      export_fig(fig_name)
      cd(base_path) %back to the original path

end
end
