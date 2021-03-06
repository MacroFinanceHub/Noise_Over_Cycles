%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 1 - Forecasted growth rates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Real GDP
Delta_RGDP_t        = RGDP5_SPF./RGDP1_SPF - ones(length(RGDP1_SPF),1); %Y(t+3|t)/Y(t-1|t) %correct
Delta_RDGP_t1       = RGDP6_SPF./RGDP2_SPF - ones(length(RGDP1_SPF),1); %Y(t+4|t)/Y(t|t)   %correct
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 2 - Revision in forecast growth rates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Z1                  = [NaN; Delta_RGDP_t(2:end) - Delta_RDGP_t1(1:end-1)]; %Y(t+3|t)/Y(t-1|t) - Y(t+3|t-1)/Y(t-1|t-1) --> correct, notice that with this notation this is the forecast revision at time t!!!
Z2                  = [NaN; Delta_NGDP_t(2:end) - Delta_NDGP_t1(1:end-1)];
Z3                  = [NaN; Delta_RCONS_t(2:end) - Delta_RCONS_t1(1:end-1)];
Z4                  = [NaN; Delta_INDPROD_t(2:end) - Delta_INDPROD_t1(1:end-1)];
Z5                  = [NaN; Delta_RINV_t(2:end) - Delta_RINV_t1(1:end-1)];
Z6                  = [NaN; Delta_CPI_t(2:end)];% - Delta_CPI_t1(1:end-1)];
Z7                  = [NaN; diff(MichIndexConfidence)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 3 - Forecast errors and Forecasts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Real GDP
YR                    = exp(RealGDP); % back to GDP levels (We are taking the log when we read data) %%% OTHER STUFF: %YR      = [RGDP1_SPF(2:end); NaN]; %it's very different from RealGDP, has %jumps and the growth is too much right skewed
YRG                   = [NaN(4,1); YR(1+4:end)./YR(1:end-4) - ones(length(YR)-4,1)];  %Y(t)/Y(t-4) --> correct, this is GDP growth rate at time t %%% OTHER STUFF: %FE_RGDP = [YRG(4:end) - Delta_RGDP_t(1:end-3); NaN(3,1)]; %Y(t+3)/Y(t-1) - Y(t+3|t)/Y(t-1|t)
ForecastErrorRGDPG    = [NaN(3,1); YRG(1+3:end) - Delta_RGDP_t(1:end-3)]; %Y(t)/Y(t-4) - Y(t|t-3)/Y(t-4|t-3) %%% OTHER STUFF: %[B,Bint] = regress( FE_RGDP , [Z1, ones(length(Z1),1)] ) %replicates Gennaioli OTHER STRUFF: %[B,Bint] = regress( FE_RGDP(2:end) , [Z1(2:end),FE_RGDP(1:end-1),ones(length(Z1)-1,1)] )%not robust, forecast errors are highly autocorrelated 
ForecastRGDPG         = [NaN(3,1); Delta_RGDP_t(1:end-3)]; %Y(t|t-3)/Y(t-4|t-3)
% Nominal GDP - find series for now we use GDPdefl*GDPreal
YN                    = exp(GDPDefl).*exp(RealGDP)/100; %Use GDPDeflator/100 to recover nominal GDP from real GDP. %YN = [NGDP1_SPF(2:end); NaN];
YNG                   = [NaN(4,1); YN(5:end)./YN(1:end-4) - ones(length(YN)-4,1)];  %Y(t)/Y(t-4)   OTHER STUFF: %FE_NGDP = [YNG(4:end) - Delta_NGDP_t(1:end-3); NaN(3,1)]; %Y(t+3)/Y(t-1) - Y(t+3|t)/Y(t-1|t)
ForecastErrorNGDP     = [NaN(3,1) ; YNG(4:end) - Delta_NGDP_t(1:end-3)]; %Y(t)/Y(t-4) - Y(t|t-3)/Y(t-4|t-3) OTHER STUFF: %[B,Bint] = regress( FE_NGDP , [Z2, ones(length(Z2),1)] ) %replicates Gennaioli OTHER STUFF: %[B,Bint] = regress( FE_NGDP(2:end) , [Z2(2:end),FE_NGDP(1:end-1),ones(length(Z2)-1,1)] )%not robust, forecast errors are highly autocorrelated 
ForecastNGDPG         = [NaN(3,1); Delta_NGDP_t(1:end-3)]; %Y(t|t-3)/Y(t-4|t-3)
% Real Consumption - find series for now we use Gennaioli series
RC                    = exp(RealCons); % back to consumption levels (We are taking the log when we read data) %OTHER STUFF: RC      = [RCONS1_SPF(2:end); NaN];
RCG                   = [NaN(4,1); RC(5:end)./RC(1:end-4) - ones(length(RC)-4,1)];  %Y(t)/Y(t-4) OTHER STUFF: %FE_RC   = [RCG(4:end) - Delta_RCONS_t(1:end-3); NaN(3,1)]; %Y(t+3)/Y(t-1) - Y(t+3|t)/Y(t-1|t)
ForecastErrorRCG      = [NaN(3,1); RCG(4:end) - Delta_RCONS_t(1:end-3) ]; %Y(t)/Y(t-4) - Y(t|t-3)/Y(t-4|t-3) OTHER STUFF: %[B,Bint] = regress( FE_RC , [Z3, ones(length(Z3),1)] ) %replicates Gennaioli OTHER STUFF: %[B,Bint] = regress( FE_RC(2:end) , [Z3(2:end),FE_RC(1:end-1),ones(length(Z3)-1,1)] )%not robust, forecast errors are highly autocorrelated 
ForecastRCG           = [NaN(3,1); Delta_RCONS_t(1:end-3)]; %Y(t|t-3)/Y(t-4|t-3)




