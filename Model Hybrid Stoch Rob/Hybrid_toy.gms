
************************** reprenentative load Secnarios for 2020 - 2050
$setglobal  Load_exo20 ""      if "*" considered, if "" taken out
$setglobal  Load_exo30 ""      if "*" considered, if "" taken out
$setglobal  Load_exo40 "*"      if "*" considered, if "" taken out
$setglobal  Load_exo50 ""      if "*" considered, if "" taken out

$set        Data_input         Data_input\


Sets
   
n/AT,BALT,BE,CH,CZ,DE,DK,ES,FR,HU,IT,NL,NO,PL,SE,SI,UK/

*SEE,FI
   
g /g1*g119/
s /s1*s51/
ren/ren1*ren51/
*ren/ren1*ren17/
*NTC/ntc1*ntc100/
t/t1*t1000/
sr/sr1*sr17/
wr/wr1*wr17/
hr/hr1*hr17/

*for Stochastic
Sc/sc1*sc3/

*for ARO
rr/rr1*rr17/
DF/Df1*DF365/
v/v1*v5/
link/L1*L84/

;
Alias (n,nn)
;
Sets

*H(t,it)

****************************thermal************************************************
gas(g)
*lig(g)
*coal(g)
*nuc(g)
*oil(g)
*waste(g)
*biomass(g)

****************************renewable***********************************************
wind(ren)
sun(ren)

****************************hydro***************************************************
ror(s)
reservoir(s)
psp(s)

****************************mapping*************************************************

MapG(g,n)
MapS(s,n)
Mapren(ren,n)
MapSr(sr,n)
MapWr(wr,n)

*for ARO
Map_RR(rr,n)
Map_RR_REN(rr,ren)
Map_DF(t,DF)

*Map_link_NTC(link,n,nn)
;

$include Loading_input_Hybrid.gms
;

*execute_unload "check_Hybrid_Toy1.gdx";
*$stop

*######################################variables######################################
Variables
Costs
*Power_flow(sc,n,nn,t)
;

positive Variables
*Investment variables
Cap_conv(g,n)             generation conventionals
Cap_ren(ren,n)            generation renewables
Cap_hydro(s,n)             generation hydro

*Scenario operation/feasibility variables

Sc_Gen_g (Sc,g,n,t)             generation conventionals
Sc_Gen_r(Sc,ren,t)            generation renewables
Sc_Gen_s (Sc,s,n,t)             generation hydro
SC_Power_flow(Sc,n,nn,t)

SC_storagelvl(Sc,s,n,t)
SC_charge(Sc,s,n,t)

SC_Su(Sc,g,n,t)
SC_P_on(Sc,g,n,t)

SC_Load_shed(Sc,t,n)
SC_Curtailment(Sc,ren,t)

*************Robust formulation

*var_af_sun(Sc,n,t)
*var_af_wind(Sc,n,t)
unc_load(sc,n,t)

*KappaR(Sc,ren,t) ’Dual variable used in the robust optimization model’
*PsiR(Sc,ren,t) ’Dual variable used in the robust optimization model’
*yR(Sc,ren,n,t) ’Auxiliary variable used in the robust optimization model

KappaD(sc,n,t)
PsiD(sc,n,t)
yD(sc,n,t)
;

Equations
Total_costs
Balance

robust_dem1
robust_dem2
robust_dem3

max_gen
max_cap
startup_constr

max_ren_sun
*stochastic_sun1
*stochastic_sun2
*stochastic_sun3

max_ren_wind
*stochastic_wind1
*stochastic_wind2
*stochastic_wind3

max_gencap_ror
max_inflow_ror

renervor_stor_lvl_start
renervor_stor_lvl
renervor_stor_lvl_end
min_reservoir_gen
max_reservoir_gen
max_reservoir_stor_lvl
min_reservoir_stor_lvl

Store_level_start
Store_level
Store_level_end
Store_level_max
Store_prod_max
Store_prod_max_end

NTC_max_ex
NTC_max_im
LS_det

;
*#######################################################objective##########################################################

Total_costs..                costs =e= sum((g,n)$MapG(g,n), Cap_conv(g,n) * IC_conv(g)) + sum((ren,n)$MapRen(ren,n), Cap_ren(ren,n) * IC_ren(ren)) + sum((s,n)$MapS(s,n),Cap_hydro(s,n) * IC_stor(s))
                                        
                                       + sum(sc, propability(sc)*( 
                                       + sum((g,n,t)$MapG(g,n),  Sc_Gen_g(Sc,g,n,t) * Var_costs(g,t))
                                       + sum((g,n,t)$MapG(g,n),  SC_Su(Sc,g,n,t) * su_costs(g,t))
                                       + sum((t,n),  Sc_Load_shed(Sc,t,n) * LS_costs(n))
                                       + sum((ren,t),Sc_Curtailment(Sc,ren,t) * cur_costs))
                                                                )

;

*####################################################energy balance########################################################

Balance(Sc,t,n)..              (unc_load(sc,n,t)  - SC_Load_shed(Sc,t,n))  =e= sum(g$MapG(g,n), Sc_Gen_g(Sc,g,n,t))

                                                         
                                                           + sum(sun$MapRen(sun,n),Sc_Gen_r(sc,sun,t) - Sc_Curtailment(Sc,sun,t))
                                                           + sum(wind$MapRen(wind,n),Sc_Gen_r(sc,wind,t) - Sc_Curtailment(Sc,wind,t))

                                                           - sum(nn, SC_Power_flow(sc,n,nn,t))
                                                           + sum(nn, SC_Power_flow(sc,nn,n,t))

                                                           + sum(s$MapS(s,n), Sc_Gen_s(sc,s,n,t))
                                                           - sum(psp$MapS(psp,n), SC_charge(sc,psp,n,t))
;
**Eff_ren(biomass)
*****************************************************Robust formulation of demand*****************************************

robust_dem1(Sc,n,t)..                             unc_load(sc,n,t) - Gamma_D * KappaD(sc,n,t)  =g= load(t,n)
;
robust_dem2(Sc,n,t)..                             KappaD(sc,n,t)  =g= delta_load(n,t) * yD(sc,n,t)
;
robust_dem3(Sc,n,t)..                             yD(sc,n,t)  =g=  1
;

*######################################################generation##########################################################

*dispatch
*max_gen(Sc,g,n,t)$MapG(g,n)..                                              Sc_Gen_g(Sc,g,n,t) =l= Cap_conv(g,n)
*;

*unit commitment
max_gen(Sc,g,n,t)$MapG(g,n)..                                              Sc_Gen_g(Sc,g,n,t) =l= SC_P_on(Sc,g,n,t)
;
max_cap(Sc,g,n,t)$MapG(g,n)..                                              SC_P_on(Sc,g,n,t)  =l= Cap_conv(g,n) 
;
startup_constr(Sc,g,n,t)$MapG(g,n)..                                       SC_P_on(Sc,g,n,t) - SC_P_on(Sc,g,n,t-1) =l= SC_Su(Sc,g,n,t)
;


max_ren_sun(Sc,sun,n,t)$MapRen(sun,n)..                                    Sc_Gen_r(sc,sun,t) =e=  af_sun(Sc,t,n) * cap_ren(sun,n) 
;
max_ren_wind(Sc,wind,n,t)$MapRen(wind,n)..                                 Sc_Gen_r(sc,wind,t) =e= af_wind(Sc,t,n) * cap_ren(wind,n) 
;


*max_ren_sun(Sc,sun,n,t)$MapRen(sun,n)..                                    Sc_Gen_r(sc,sun,t) =e=  var_af_sun(Sc,n,t) * cap_ren(sun) 
*;
*max_ren_wind(Sc,wind,n,t)$MapRen(wind,n)..                                 Sc_Gen_r(sc,wind,t) =e= var_af_wind(Sc,n,t) * cap_ren(wind) 
*;


*****************************************************Robust formulation of renewable production************************************
**********Sun
$ontext
stochastic_sun1(Sc,sun,n,t)$MapRen(sun,n)..             var_af_sun(Sc,n,t) + Gamma_S * KappaR(sc,sun,t) + PsiR(sc,sun,t) =L= af_sun(Sc,t,n)
;
stochastic_sun2(Sc,sun,n,t)$MapRen(sun,n)..             KappaR(sc,sun,t) + PsiR(sc,sun,t) =G= (delta_af_sun(Sc,t,n)) * yR(Sc,sun,n,t)
;
stochastic_sun3(Sc,sun,n,t)$MapRen(sun,n)..             yR(Sc,sun,n,t)  =G=  1
;

**********Wind

stochastic_wind1(Sc,wind,n,t)$MapRen(wind,n)..         var_af_wind(Sc,n,t) + Gamma_W * KappaR(sc,wind,t) + PsiR(sc,wind,t) =L= af_wind(Sc,t,n)
;
stochastic_wind2(Sc,wind,n,t)$MapRen(wind,n)..         KappaR(sc,wind,t) + PsiR(sc,wind,t) =G= (delta_af_wind(Sc,t,n)) * yR(Sc,wind,n,t)
;
stochastic_wind3(Sc,wind,n,t)$MapRen(wind,n)..         yR(Sc,wind,n,t)  =G=  1
;
$offtext

********************************************************Hydro RoR**********************************************************

max_gencap_ror(Sc,ror,n,t)$(MapS(ror,n))..                                                  Sc_gen_s(sc,ror,n,t) =l=  cap_hydro(ror,n)
;
max_inflow_ror(Sc,ror,n,t)$(MapS(ror,n))..                                                  Sc_gen_s(sc,ror,n,t) =l=  (af_hydro(t,n) * scale_to_MW) *  share_inflow(ror,n)     
;
********************************************************Hydro PsP**********************************************************

Store_level_start(Sc,psp,n,t)$(MapS(psp,n) and ord(t) =1)..                                 Sc_storagelvl(sc,psp,n,t) =e= cap_hydro(psp,n) *0.5 + SC_charge(sc,psp,n,t) * eff_hydro(psp) - Sc_gen_s(sc,psp,n,t)
;
Store_level(Sc,psp,n,t)$(MapS(psp,n) and ord(t) gt 1)..                                     Sc_storagelvl(sc,psp,n,t) =e= Sc_storagelvl(sc,psp,n,t-1) + Sc_charge(sc,psp,n,t-1) * eff_hydro(psp) - Sc_gen_s(sc,psp,n,t-1)
;
Store_level_end(Sc,psp,n,t)$(MapS(psp,n) and ord(t) = card(t))..                            Sc_storagelvl(sc,psp,n,t) =e= cap_hydro(psp,n) * 0.5
;
Store_level_max(Sc,psp,n,t)$(MapS(psp,n))..                                                 Sc_storagelvl(sc,psp,n,t) =l= cap_hydro(psp,n) * store_cpf
;
Store_prod_max(Sc,psp,n,t)$(MapS(psp,n))..                                                  Sc_gen_s(sc,psp,n,t) + SC_charge(sc,psp,n,t) *1.2 =l= cap_hydro(psp,n) 
;
Store_prod_max_end(Sc,psp,n,t)$(MapS(psp,n) and ord(t) = card(t))..                         Sc_gen_s(sc,psp,n,t)      =l= Sc_storagelvl(sc,psp,n,t)
;
*****************************************************Hydro reservoir******************************************************

renervor_stor_lvl_start(Sc,reservoir,n,t)$(MapS(reservoir,n) and ord(t) =1)..               Sc_storagelvl(sc,reservoir,n,t) =e= reservoir_stor_cap(reservoir,n) *0.7 - Sc_gen_s(sc,reservoir,n,t) + (af_hydro(t,n) * scale_to_MW) * share_inflow(reservoir,n)
;
renervor_stor_lvl(Sc,reservoir,n,t)$(MapS(reservoir,n) and ord(t) gt 1)..                   Sc_storagelvl(sc,reservoir,n,t) =e= Sc_storagelvl(sc,reservoir,n,t-1) - Sc_gen_s(sc,reservoir,n,t-1) + (af_hydro(t-1,n) * scale_to_MW) * share_inflow(reservoir,n)
;
renervor_stor_lvl_end(Sc,reservoir,n,t)$(MapS(reservoir,n) and ord(t) = card(t))..          Sc_storagelvl(sc,reservoir,n,t) =e= reservoir_stor_cap(reservoir,n) *0.7 - Sc_gen_s(sc,reservoir,n,t-1) + (af_hydro(t-1,n) * scale_to_MW) * share_inflow(reservoir,n)
;
min_reservoir_gen(Sc,reservoir,n,t)$(MapS(reservoir,n))..                                   Sc_gen_s(sc,reservoir,n,t) =g= (af_hydro(t,n) *scale_to_MW) * share_inflow(reservoir,n) * 0.1
;
max_reservoir_gen(Sc,reservoir,n,t)$(MapS(reservoir,n))..                                   Sc_gen_s(sc,reservoir,n,t) =l= cap_hydro(reservoir,n) 
;
max_reservoir_stor_lvl(Sc,reservoir,n,t)$(MapS(reservoir,n))..                              Sc_storagelvl(sc,reservoir,n,t) =l= reservoir_stor_cap(reservoir,n)
;
min_reservoir_stor_lvl(Sc,reservoir,n,t)$(MapS(reservoir,n) and (ord(t) gt 1) )..           Sc_storagelvl(sc,reservoir,n,t) =g= 0.15 * reservoir_stor_cap(reservoir,n)
;

*##########################################################NTC exchange############################################################

ntc_max_ex(Sc,n,nn,t)..                                                                     SC_Power_flow(sc,n,nn,t) =l= NTC_cap(n,nn)
;
ntc_max_im(Sc,nn,n,t)..                                                                     SC_Power_flow(sc,nn,n,t) =l= NTC_cap(nn,n)
;
*****************************************************load shedding determination***************************************************

LS_det(Sc,t,n)..                                                                            SC_Load_shed(sc,t,n)     =l= load(t,n)
;
*execute_unload "check_Toy_1.gdx";
*$stop


*#########################################################Model definition##########################################################

Model Hybrid_Stochastic_robust
/
Total_costs
Balance
robust_dem1
robust_dem2
robust_dem3


max_gen
max_cap
startup_constr

max_ren_sun
*stochastic_sun1
*stochastic_sun2
*stochastic_sun3

max_ren_wind
*stochastic_wind1
*stochastic_wind2
*stochastic_wind3

max_gencap_ror
max_inflow_ror

renervor_stor_lvl_start
renervor_stor_lvl
renervor_stor_lvl_end
min_reservoir_gen
max_reservoir_gen
max_reservoir_stor_lvl
min_reservoir_stor_lvl

Store_level_start
Store_level
Store_level_end
Store_level_max
Store_prod_max
Store_prod_max_end

NTC_max_ex
NTC_max_im
LS_det
/
;
*option names = no;

*#########################################################Solving##################################################################
*Hybrid_Stochastic_robust.Scaleopt= 1
*;
solve Hybrid_Stochastic_robust using MIP minimizing costs
;
*****************************************************parameter calibration*********************************************************

count_time(t) = card(t)
;
price(sc,t,n) = Balance.m(Sc,t,n)*(-1)
;
Average_price(sc,n) = sum(t,price(sc,t,n)/count_time(t))
;
Count_LS_hours(sc,t,n)$(Sc_Load_shed.l(sc,t,n) gt 0) = 1
;
Count_curtail_hours(sc,ren,t)$(Sc_Curtailment.l(Sc,ren,t) gt 0) =1
;

******************************************************report parameter definition**************************************************

report(sc,n,'Average Price') = Average_price(sc,n)
;
hourly_price_report(sc,t,n) = price(sc,t,n)
;
report(sc,n,'LOLH') = sum(t, Count_LS_hours(sc,t,n))
;
report(sc,n,'EENS') = sum((t),Sc_Load_shed.l(sc,t,n))
;
report(sc,n,'Curtailment')= sum((ren,t)$MapRen(ren,n), Count_curtail_hours(sc,ren,t))
;
report(sc,n,'Wind_invest')= sum((wind)$MapRen(wind,n), cap_ren.l(wind,n))
;
report(sc,n,'Sun_invest')= sum((sun)$MapRen(sun,n), cap_ren.l(sun,n))
;
report(sc,n,'gas_invest')= sum((gas), Cap_conv.l(gas,n))
;
$ontext
report(sc,n,'lig_invest')= sum((lig), Cap_conv.l(lig,n))
;
report(sc,n,'coal_invest')= sum((coal), Cap_conv.l(coal,n))
;
report(sc,n,'oil_invest')= sum((oil), Cap_conv.l(oil,n))
;
report(sc,n,'waste_invest')= sum((waste), Cap_conv.l(waste,n))
;
report(sc,n,'biomass_invest')= sum((biomass), Cap_conv.l(biomass,n))
;
$offtext
report(sc,n,'ror_invest')= sum((ror), cap_hydro.l(ror,n))
;
report(sc,n,'reservoir_invest')= sum((reservoir), cap_hydro.l(reservoir,n))
;
report(sc,n,'psp_invest')= sum((psp), cap_hydro.l(psp,n))
;


****************************************************write to gdx*******************************************************************
execute_unload "check_Toy_1.gdx"
;

****************************************************output*************************************************************************

execute "gdxxrw check_Toy_1.gdx output=Output_toy_1.xlsx  par=report  rng=report!A1"
;
execute "gdxxrw check_Toy_1.gdx output=Output_toy_1.xlsx  par=hourly_price_report  rng=price_report!A1"
;











