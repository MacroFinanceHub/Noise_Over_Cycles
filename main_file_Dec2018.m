%*************************************************************************%
% Main
%
% NOTE describe variables (especially SHOCKS) in dataset
%
% last change 11/30/2018
%
% Code by Brianti, Marco e Cormun, Vito
%*************************************************************************%

clear
close all

%Parameters
lags                = 4; %number of lags of TFP - cannot be zero since 1 include current TFP
fprintf('\n')
disp(['Number of lags used is ',num2str(lags)])
fprintf('\n')
leads               = 16; %number of leads of TFP
disp(['Number of leads used is ',num2str(leads)])
fprintf('\n')
H                   = 20; %irfs horizon

lags_LP             = 2; %Lags in the Local Projection - should use lags selection criterion

which_trend         = 'quadratic' ; %BPfilter, HPfilter, linear, quadratic

% Read main dataset
filename                    = 'main_file';
sheet                       = 'Sheet1';
range                       = 'B1:CX300';
do_truncation               = 0; %Do not truncate data. You will have many NaN
[dataset, var_names]        = read_data2(filename, sheet, range, do_truncation);

%nNaN                        = leads; % adding some NaN at the end to have space for leads
dataset                     = [dataset; NaN(leads,size(dataset,2))];
% Assess name to each variable
for i = 1:size(dataset,2)
      eval([var_names{i} ' = dataset(:,i);']);
end

% *************************************************************************%
%                                                                         %
%          1st stage - Deriving sentiment                              %
%                                                                         %
%*************************************************************************%
fprintf('\n')
fprintf('\n')
disp('First Step: Building Ztilde')
fprintf('\n')
fprintf('\n')

for cc = 2:2
    %Building Zt
    %Step 1 - Getting the forecasted growth rates
    Delta_RGDP_t        = RGDP5_SPF./RGDP1_SPF - ones(length(RGDP1_SPF),1);
    Delta_RDGP_t1       = RGDP6_SPF./RGDP2_SPF - ones(length(RGDP1_SPF),1);
    % Nominal GDP
    Delta_NGDP_t        = NGDP5_SPF./NGDP1_SPF - ones(length(NGDP1_SPF),1);
    Delta_NDGP_t1       = NGDP6_SPF./NGDP2_SPF - ones(length(NGDP1_SPF),1);
    % Real Cons
    Delta_RCONS_t       = RCONS5_SPF./RCONS1_SPF - ones(length(RCONS1_SPF),1);
    Delta_RCONS_t1      = RCONS6_SPF./RCONS2_SPF - ones(length(RCONS1_SPF),1);
    %Industrial Production
    Delta_INDPROD_t     = INDPROD5_SPF./INDPROD1_SPF - ones(length(INDPROD1_SPF),1);
    Delta_INDPROD_t1    = INDPROD6_SPF./INDPROD2_SPF - ones(length(INDPROD1_SPF),1);
    %Investment is the sum between residential and non residential investment
    Delta_RINV_t        = (RRESINV5_SPF + RNRESIN5_SPF)./(RRESINV1_SPF + RNRESIN1_SPF)  - ones(length(RRESINV1_SPF),1);
    Delta_RINV_t1       = (RRESINV6_SPF + RNRESIN6_SPF)./(RRESINV2_SPF + RNRESIN2_SPF)  - ones(length(RRESINV1_SPF),1);
    % CPI
    Delta_CPI_t         = CPI5_SPF;% - CPI1_SPF;
    Delta_CPI_t1        = CPI6_SPF;% - CPI2_SPF;
    %Step 2 - Revision in forecast growth rates
    Z1                  = [NaN; Delta_RGDP_t(2:end) - Delta_RDGP_t1(1:end-1)];
    Z2                  = [NaN; Delta_NGDP_t(2:end) - Delta_NDGP_t1(1:end-1)];
    Z3                  = [NaN; Delta_RCONS_t(2:end) - Delta_RCONS_t1(1:end-1)];
    Z4                  = [NaN; Delta_INDPROD_t(2:end) - Delta_INDPROD_t1(1:end-1)];
    Z5                  = [NaN; Delta_RINV_t(2:end) - Delta_RINV_t1(1:end-1)];
    Z6                  = [NaN; Delta_CPI_t(2:end)];% - Delta_CPI_t1(1:end-1)];
    Z7                  = [NaN; diff(MichIndexConfidence)];
    
    % Choose which SPF variable
    which_Z             = '1';
    eval(['Z = Z', which_Z,';']);
    disp(['Z',which_Z, ' is used as forecast revision variable'])
    fprintf('\n')
    
%     % Building the Forecast Errors
%     FE1                  = [NaN(3,1); (RGDP1_SPF(1+4:end) - RGDP5_SPF(1:end-4))./RGDP1_SPF(2:end-3); NaN];
%     FE2                  = [NaN(3,1); (NGDP1_SPF(1+4:end) - NGDP5_SPF(1:end-4))./NGDP1_SPF(2:end-3); NaN];
%     FE3                  = [NaN(3,1); (RCONS1_SPF(1+4:end) - RCONS5_SPF(1:end-4))./RCONS1_SPF(2:end-3); NaN];
%     FE4                  = [NaN(3,1); (INDPROD1_SPF(1+4:end) - INDPROD5_SPF(1:end-4))./INDPROD1_SPF(2:end-3); NaN];
%     FE5                  = [NaN(3,1); (RRESINV1_SPF(1+4:end) + RNRESIN1_SPF(1+4:end) - RRESINV5_SPF(1:end-4) - RNRESIN5_SPF(1:end-4))./(RRESINV1_SPF(2:end-3) + RNRESIN1_SPF(2:end-3)); NaN];
%     
%     eval(['FE = FE', which_Z,';']);
%     disp(['FE',which_Z, ' is used as forecast error variable'])
%     fprintf('\n')
    
    % Coibon Gorodnichenko Regression
    % [B,BINT,R,RINT,STATS] = regress(Y,X);
    % YFE = FE(1+3:end);
    % XZ  = [ones(length(YFE),1) , Z3(1:end-3)];
    % [B,BINT,~,~,STATS] = regress(YFE,XZ);
    
    %Structural shocks from Ramey narrative approach, Hamilton, Romer and
    %Romer, Military government spending ADD IN ORDER
    [TFP_trunc, trunc1, trunc2] = truncate_data(TFP);
    TFPBP                       = bpass(TFP_trunc,4,32);
    TFPBP                       = [TFPBP; NaN(length(TFP) - length(TFPBP),1)];
    dTFP                        = [NaN; diff(TFP)];
    PC                          = [PC1 PC2 PC3];
    X_contemporaneous           = [TFPBP MUNI1Y PDVMILY HAMILTON3YP RESID08 TAXNARRATIVE];
    X_lag                       = [TFPBP PC MUNI1Y PDVMILY HAMILTON3YP RESID08 TAXNARRATIVE];
    X_lead                      = TFPBP;
    Y                           = Z;
    if sum(sum(abs(X_contemporaneous))) == 0
        disp('No contemporaneous controls for Z')
        fprintf('\n')
    end
    if sum(sum(abs(X_lag))) == 0 || lags == 0
        disp('No past controls for Z')
        fprintf('\n')
    end
    if sum(sum(abs(X_lag))) == 0 || leads == 0
        disp('No future controls for Z')
        fprintf('\n')
    end
    
    % Control Regression
    [~, Zhat, Ztilde, regressor] = lead_lag_matrix_regression(Y,X_lead,...
        leads,X_lag,lags,X_contemporaneous);
    
    %Show the graph of Ztilde - Figure(1)
    plot1 = 0; % if plot = 1, figure will be displayed
    plot_Ztilde(Ztilde,Time(1+lags:end-leads),NBERDates(1+lags:end-leads),plot1)
    
    % Print figure authomatically if "export_figure1 = 1"
    if plot1 == 1
        export_fig1 = 0; % if export_fig1 = 1, figure will be saved
        export_fig_Ztilde(export_fig1)
    end
    
    if cc == 1
    else
        if cc == 2
            % Ztilde = Zhat;
            % Ztilde = RESID08(1+lags:end-leads);
            % Ztilde = MUNI1Y(1+lags:end-leads);
            Ztilde = UnantTFPshock(1+lags:end-leads);
            % Ztilde = BarskySimsNews(1+lags:end-leads);
            % Ztilde = Z1(1+lags:end-leads);
            warning('Ztilde is replaced by another shock')
        end
    end
    % *************************************************************************%
    %                                                                         %
    %          2nd stage - Local Projections                %
    %                                                                         %
    %*************************************************************************%
    fprintf('\n')
    fprintf('\n')
    disp('Second Step: Projecting endogenous variables on Ztilde')
    fprintf('\n')
    fprintf('\n')
    
    % Preparing Data Dependent Variables
    
    % Create Inflation from Price Indexes
    ninfl = 4;
    PCEInflation    = create_inflation(PriceCPE,ninfl);
    CPIInflation    = create_inflation(CPIInflation,ninfl);
    CPIDurables     = create_inflation(CPIDurables,ninfl);
    CPINonDurables  = create_inflation(CPINonDurables,ninfl);
    CPIServices     = create_inflation(CPIServices,ninfl);
    
    FE6      = [NaN(4,1); CPIInflation(1+4:end)*100 - CPI6_SPF(1:end-4)];
    FEM       = [NaN(4,1); CPIInflation(1+4:end)*100 - MedianMichIndexCPI(1:end-4)];
    % Per capita adjustment
    control_pop = 0; % Divide GDP, Cons, Hours, Investment over population
    if control_pop == 1
        RealGDP                 = RealGDP - Population;
        RealCons                = RealCons - Population;
        RealInvestment          = RealInvestment - Population;
        Hours                   = Hours + Employment - Population;
        RealInventories         = RealInventories - Population;
        RealSales               = RealSales - Population;
    end
    
    % Create Var List
    if cc == 1
        SP500            = SP500 - GDPDefl;
    else
    end
    Spread           = MoodySpreadBaa - MoodySpreadAaa;
    varlist          = {'RealGDP','RealCons','RealInvestment','RealInventories',...
          'Credit2GDP','Spread'};%,...
          %'FFR','UnempRate','TFP','CPIInflation',};
    
    %{'RealGDP','RealCons','RealInvestment','Hours'};
    % ,'UnempRate',...
    %       'RealInventories','RealSales','RealI2S','BusinessConfidenceEC',...
    %       'BloomFinDistress','RDurableCons','RNonDurableCons','RServiceCons',... %
    %     'CPIInflation','PCEInflation','Mich1Y'};
    
    % Matrix of dependen variables - All the variables are in log levels
    clear dep_var
    for i = 1:length(varlist)
        if strcmp(varlist{i},'Ztilde') == 1
            dep_var(:,i) = [NaN(lags,1); eval(varlist{i}); NaN(leads,1)];
        else
            dep_var(:,i) = eval(varlist{i});
        end
    end
    
    % Choose the type of transformation
    logdifferences = 0;
    
    if logdifferences == 1
        dep_var = [nan(1,size(dep_var,2)); diff(dep_var)];
        disp('Endogenous variables are differentiated for local projection')
        fprintf('\n')
    end
    
    % Align the timing
    dep_var          = dep_var(1+lags:end-leads,:);
    
    PC               = PC(1+lags:end-leads,:);
    
    
    
    disp(['Filter used is ',which_trend])
    fprintf('\n')
    
    % warning('Be careful Ztilde is now Zhat')
    standardize_Ztilde = 1;
    if standardize_Ztilde == 1
        sdZtilde         = nanstd(Ztilde);
        Ztilde           = Ztilde/sdZtilde;
        sdZhat           = nanstd(Zhat);
        Zhat             = Zhat/sdZhat;
        disp('Variance of Ztilde is now one')
        fprintf('\n')
    else
        warning('Ztilde is not standardize. Variance Decomposition is wrong.')
        fprintf('\n')
    end
    
    %Initializating the loop
    for kk = 1:size(dep_var,2)
        % Define inputs for local_projection
        varnamekk                   = varlist{kk};
        disp(['Projecting ',varnamekk])
        fprintf('\n')
        depvarkk                    = dep_var(:,kk);
        [~, loc_start, loc_end]     = truncate_data([depvarkk Ztilde PC]);
        depvarkk                    = depvarkk(loc_start:loc_end);
        Ztildekk                    = Ztilde(loc_start:loc_end);
        pckk                        = PC(loc_start:loc_end,:);
        % Run local_projection
        if strcmp(varnamekk,'FE') == 1 || strcmp(varnamekk,'Ztilde') == 1 || strcmp(varnamekk,'Zhat') == 1 || strcmp(varnamekk,'Z') == 1
            which_trend_final = 'none';
            disp([varnamekk, ' has not been filtered'])
            fprintf('\n')
        else
            which_trend_final = which_trend;
        end
        [IR{kk},res{kk},tuple{kk},VD{kk}] = ...
            local_projection(depvarkk,pckk,Ztildekk,lags_LP,H,which_trend_final);
        if logdifferences == 0
            IRF(kk,:) = IR{kk};
        else
            IRF(kk,:) = cumsum(IR{kk});
        end
        VDkk(kk,:) = VD{kk};
        % Initiate bootstrap
        nsimul         = 1000;
        tuplekk        = tuple{kk};
        for hh = 1:H
            tuplekkhh = tuplekk{hh}; % Fix a specific horizon
            Y                             = tuplekkhh(:,1);
            X                             = tuplekkhh(:,2:end);
            [Yboot, Xboot]                = bb_bootstrap_LP(Y,X,nsimul,lags_LP);
            for isimul = 1:nsimul
                B                       = Xboot(:,:,isimul)'*Xboot(:,:,isimul)\...
                    (Xboot(:,:,isimul)'*Yboot(:,isimul));
                IRF_boot(kk,hh,isimul)  = B(1);
            end
        end
    end
    
    % Select upper and lower bands
    for kk = 1:size(dep_var,2)
        IRF_bootkk = IRF_boot(kk,:,:);
        if logdifferences == 0
            IRF_boot(kk,:,:)  = IRF_bootkk;
        else
            IRF_boot(kk,:,:)  = cumsum(IRF_bootkk,2);
        end
    end
    %%
    % IRF_boot         = sort(IRF_boot,3);
    sig              = 0.05;
    sig2             = 0.16;
    for j = 1:size(dep_var,2)
        IRF_up(j,:)   = quantile(squeeze(IRF_boot(j,:,:))',1-sig);
        IRF_up2(j,:)  = quantile(squeeze(IRF_boot(j,:,:))',1-sig2);
        IRF_low(j,:)  = quantile(squeeze(IRF_boot(j,:,:))',sig);
        IRF_low2(j,:) = quantile(squeeze(IRF_boot(j,:,:))',sig2);
    end    
    
    %Show the graph of IRF - Figure(2)
    plot2    = 1; % if plot2 = 1, figure will be displayed
    n_row    = 3; % number of rows in the figure
    unique   = 1; % if unique = 1 plot IRFs together, if = 1 plot each IRF separately
    plot_IRF_lp_unconditional(varlist,100.*IRF_low,100.*IRF_low2,100.*IRF_up,100.*IRF_up2,100.*IRF,H,plot2,n_row,unique) %change this function  
    
    %Print figure authomatically if "export_figure1 = 1"
    if plot2 == 1
        export_fig2 = 1; % if export_fig1 = 1, figure will be saved
        export_fig_IRF_lp_unconditional(export_fig2)
    end
    
    %Show the variance Explained - Figure(3)
    plot3    = 1; % if plot2 = 1, figure will be displayed
    n_row    = 3; % number of in the figure
    unique   = 1; % if unique = 1 plot IRFs together, if = 1 plot each IRF separately
    plot_IRF_lp_unconditional(varlist,100*VDkk,100*VDkk,100*VDkk,...
        100*VDkk,100*VDkk,H,plot3,n_row,unique) %change this function
    
    % Print figure authomatically if "export_figure1 = 1"
    if plot3 == 1
        export_fig3 = 0; % if export_fig1 = 1, figure will be saved
        export_fig_IRF_lp_unconditional(export_fig3)
    end
    
end


asd
%% *************************************************************************%
% (Canova) test of cyclical IRF
rho = 0; %rho = 0, Hnull: flat spectral density, otherwise rho should be estimated from data as im BG
T = 1000; %should impose same data length
%generate IRF on AR(1) from LP
Yar(1) = 0;
for t = 2:T
      Yar(t) = rho*Yar(t-1) + randn;
end
%recover shocks
[coef,~,Zar] = regress(Yar(2:end)', Yar(1:end-1)');
%run LP
[IRFar,res,tuplear] = local_projection(Yar(2:end)',zeros(T-1,1),Zar,0,H,'none');
for hh = 1:H
      tuplearhh = tuplear{hh}; % Fix a specific horizon
      Y                             = tuplearhh(:,1);
      X                             = tuplearhh(:,2:end);
      [Yboot, Xboot]                = bb_bootstrap_LP(Y,X,nsimul,0);
      for isimul = 1:nsimul
            B                       = Xboot(:,:,isimul)'*Xboot(:,:,isimul)\...
                  (Xboot(:,:,isimul)'*Yboot(:,isimul));
            IRFar_boot(1,hh,isimul)  = B(1);
      end
end

% plot LP under AR(1)
IRFar_up   = quantile(squeeze(IRFar_boot(1,:,:))',1-sig);
IRFar_low  = quantile(squeeze(IRFar_boot(1,:,:))',sig);
figure(3); %plot spectral density and its CI against the AR(1) counterpart
plot([0:H-1]',IRFar_up,'--k','LineWidth',2); hold on;
plot([0:H-1]',IRFar_low,'--k','LineWidth',2); hold on;
plot([0:H-1]',IRFar,'-k','LineWidth',2);

[sdensityar] = spectrum(IRFar_boot);
[sdensityar_pe, period] = spectrum(IRFar); %point estimate

%plot spectral density of AR(1) from LP
figure(4+cc);
sdensityar_up   = quantile(sdensityar',1-sig);
sdensityar_low  = quantile(sdensityar',sig);
sdensityar_ave  = quantile(sdensityar',.5);
plot(period(10:200)',sdensityar_pe(10:200),'-r','LineWidth',2); hold on; %step dependent
plot(period(10:200)',sdensityar_ave(10:200),'-b','LineWidth',3); hold on;
plot(period(10:200)',sdensityar_up(10:200),'--b','LineWidth',2); hold on;
plot(period(10:200)',sdensityar_low(10:200),'--b','LineWidth',2); hold on; %the point estimate is not included in the CI, is it because we don't correct for the bias in the LP?

% Construct spectrum from data
[sdensity] = spectrum(IRF_boot(1,:,:));
[sdensity_pe(:,cc), period] = spectrum(IRF(1,:)); %point estimate
sdensity_up(cc,:)   = quantile(sdensity',1-sig);
sdensity_low(cc,:)  = quantile(sdensity',sig);
sdensity_ave(cc,:)  = quantile(sdensity',.5);
%Normalize
sdensity_up(cc,:) = sdensity_up(cc,:).* 1/(2*sum(sdensity_up(cc,:)));
sdensity_low(cc,:) = sdensity_low(cc,:).* 1/(2*sum(sdensity_low(cc,:)));
sdensity_ave(cc,:) = sdensity_ave(cc,:).* 1/(2*sum(sdensity_ave(cc,:)));
%Compute average spectral density, D1, around the peak  and average
%spectral density around the trough, D2
lpeak_lower   = 24; %should be adjusted with steps and IRF horizon
lpeak_upper   = 26;
ltrough_lower = 58;
ltrough_upper = 60;
D1 = mean(sdensity(find(period>lpeak_upper,1,'last'):find(period>lpeak_lower,1,'last'),:),1);
D2 = mean(sdensity(find(period>ltrough_upper,1,'last'):find(period>ltrough_lower,1,'last'),:),1);
D  = D1./D2;

D1ar = mean(sdensityar(find(period>lpeak_upper,1,'last'):find(period>lpeak_lower,1,'last'),:));
D2ar = mean(sdensityar(find(perio   d>ltrough_upper,1,'last'):find(period>ltrough_lower,1,'last'),:));
Dar = D1ar./D2ar;

Diff_D = D - Dar;
pval(cc) = 1 - length(find(Diff_D>0))/nsimul %results seems to favor white noise against ar(1)
%end end for cc = 1:2
var_list = {'$S_{GDP}$ to Sentiment','$S_{GDP}$ to Technology'};
for cc = 1:2
      %plot spectral density and its CI against the AR(1) counterpart
      figure(500);
      a = subplot(1,2,cc);
      p = plot(period(10:200)',sdensity_pe(10:200,cc),'-r','LineWidth',2); hold on; %step dependent
      m = plot(period(10:200)',sdensity_ave(cc,10:200),'-b','LineWidth',3); hold on;
      plot(period(10:200)',sdensity_up(cc,10:200),'--b','LineWidth',2); hold on;
      plot(period(10:200)',sdensity_low(cc,10:200),'--b','LineWidth',2); hold on; %the point estimate is not included in the CI, is it because we don't correct for the bias in the LP?
      t = plot(period(10:200)',sdensityar_pe(10:200),'k','LineWidth',3);
      title(var_list{cc},'interpreter', 'latex', 'fontsize', 16);
      if cc == 1
            xlabel('Periodicity','fontsize',12);
      end
      if cc == 2
            l=legend([p m t],{'Point estimate','Median','Null'},'Location', 'NorthEast','interpreter','latex');
            set(l, 'box','off', 'FontSize',14,'Orientation','horizontal','Position',[0.35179282868526 -0.00717088619666764 0.400000000000001 0.0617721521401707]);
      end
end




%% Trash
% %% Multivariate test
% % it should embed the idea that there should be a pick in both spectral
% % densities of the series and their coherence should be high at the
% % frequency considered
%
% %Spectral PCA
% % standardize IRFs
% IRF_boot_z = IRF_boot./sum(IRF_boot.^2,2);
%
% % compute spectrum
% [spect, periodicity] = spectrum(IRF_boot_z);
%
% % compute PCA
% % take 1st pc and construct D
%
% [V,lamb] = eig(sigma); % diag(lamb) are the eigenvalues, V the eigenvectors
% V        = real(V);
% lamb     = real(lamb);
% pc       = data*V./n;
%
% % %Theoretical AR1-IRF
% % IRF_ar1 = 1;
% % for j = 2: H
% %       IRF_ar1(j,:) = rho^j;
% % end
% % [sdensity_ar1] = spectrum(IRF_ar1); %I normalize s.t. the spectral density evaluated btwn 0 and pi is equal to .5 - CHECK
% % plot(sdensity_ar1)
% %
% % figure(5); %plot spectral density and its CI against the AR(1) counterpart
% % sdensity_up   = quantile(sdensity',1-sig);
% % sdensity_low  = quantile(sdensity',sig);
% % sdensity_ave  = quantile(sdensity',.5);
% % plot(period(10:200)',sdensity_pe(10:200),'-r','LineWidth',2); hold on; %step dependent
% % plot(period(10:200)',sdensity_ave(10:200),'-b','LineWidth',3); hold on;
% % plot(period(10:200)',sdensity_up(10:200),'--b','LineWidth',2); hold on;
% % plot(period(10:200)',sdensity_low(10:200),'--b','LineWidth',2); hold on; %the point estimate is not included in the CI, is it because we don't correct for the bias in the LP?
% % plot(period(10:200)',sdensityar_pe(10:200),'k','LineWidth',1.25);
% % xlabel('Frequency','fontsize',20);
% % grid on
% %
% % %Compute average spectral density, D1, around the peak  and average
% % %spectral density around the trough, D2
% % lpeak_lower   = 25; %should be adjusted with steps and IRF horizon
% % lpeak_upper   = 35;
% % ltrough_lower = 40;
% % ltrough_upper = 50;
% % D1 = mean(sdensity(find(period>lpeak_upper,1,'last'):find(period>lpeak_lower,1,'last'),:),1);
% % D2 = mean(sdensity(find(period>ltrough_upper,1,'last'):find(period>ltrough_lower,1,'last'),:),1);
% % D  = D1./D2;
% % D1_ar1 = mean(sdensity_ar1(find(period>lpeak_upper,1,'last'):find(period>lpeak_lower,1,'last'),:));
% % D2_ar1 = mean(sdensity_ar1(find(period>ltrough_upper,1,'last'):find(period>ltrough_lower,1,'last'),:));
% % D_ar1 = D1_ar1./D2_ar1;
% % pval = length(find(D<=D_ar1))/nsimul;
% % disp(['P-value univariate:    ',num2str(pval)])
% %
% % %Need to perform LP on the AR(1)









