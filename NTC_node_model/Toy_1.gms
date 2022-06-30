
* only one "*" for a model run is possible for now
************************** representative european weather years
$setglobal  cf_1989  ""       if "*" considered, if "" taken out
$setglobal  cf_1990  "*"       if "*" considered, if "" taken out
$setglobal  cf_2010  ""       if "*" considered, if "" taken out
$setglobal  cf_2012  ""       if "*" considered, if "" taken out

************************** capacity options for 2020 - 2050
$setglobal  cap_exo20 ""      if "*" considered, if "" taken out
$setglobal  cap_exo30 ""      if "*" considered, if "" taken out
$setglobal  cap_exo40 "*"      if "*" considered, if "" taken out
$setglobal  cap_exo50 ""      if "*" considered, if "" taken out

************************** representative load Secnarios for 2020 - 2050
$setglobal  Load_exo20 ""      if "*" considered, if "" taken out
$setglobal  Load_exo30 ""      if "*" considered, if "" taken out
$setglobal  Load_exo40 "*"      if "*" considered, if "" taken out
$setglobal  Load_exo50 ""      if "*" considered, if "" taken out

$set        Data_input         Data_input\


Sets

n /DE,DK,SE,PL,CZ,AT,CH,FR,BE,NL,
   NO,UK,IT,ES,BALT,SI,SEE,FI/
g /g1*g102/
s /s1*s51/
res/res1*res51/
ren/ren1*ren17/
*NTC/ntc1*ntc100/
t/t1*t8760/
sr/sr1*sr17/
wr/wr1*wr17/
hr/hr1*hr17/

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
lig(g)
coal(g)
nuc(g)
oil(g)
waste(g)
biomass(g)

****************************renewable***********************************************
wind(res)
sun(res)

****************************hydro***************************************************
ror(s)
reservoir(s)
psp(s)

****************************mapping*************************************************

MapG(g,n)
MapS(s,n)
MapRes(res,n)
MapHr(hr,n)
MapSr(sr,n)
MapWr(wr,n)

*for ARO
MapRen(ren,n)
Map_RR(rr,n)
Map_RR_REN(rr,ren)
Map_DF(t,DF)

*Map_link_NTC(link,n,nn)
;

$include Loading_input_deterministic.gms
;

execute_unload "check_ARO_Toy.gdx";
$stop
*######################################variables######################################
Variables
Costs
*Power_flow(n,nn,t)
;

positive Variables
Gen_g (g,t)             generation conventionals
Gen_r(res,t)            generation renewables
Gen_s (s,t)             generation hydro

Power_flow(n,nn,t)

storagelvl(s,t)
charge(s,t)

Su(g,t)
P_on(g,t)

Load_shed(t,n)
Curtailment(res,t)
;

Equations
Total_costs
Balance

max_gen
max_cap
startup_constr

max_res_biomass
max_res_sun
max_res_wind

max_gencap_ror
max_inflow_ror

reservor_stor_lvl_start
reservor_stor_lvl
reservor_stor_lvl_end
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

Total_costs..                costs =e=   sum((g,t), Var_costs(g,t) * Gen_g(g,t))
                                       + sum((g,t), Su(g,t) *su_costs(g,t))
                                       + sum((res,t), Fc_res(res,t) * Gen_r(res,t))
                                       + sum((t,n), LS_costs(n) * Load_shed(t,n))
                                       + sum((res,t), Curtailment(res,t) * cur_costs)

;

*####################################################energy balance########################################################

Balance(t,n)..                (load(t,n) - Load_shed(t,n))  =e= sum(g$MapG(g,n),Gen_g(g,t))

                                                           + sum(biomass$MapRes(biomass,n),Gen_r(biomass,t))
                                                           + sum(sun$MapRes(sun,n),Gen_r(sun,t))
                                                           + sum(wind$MapRes(wind,n),Gen_r(wind,t))

                                                           - sum(nn, Power_flow(n,nn,t))
                                                           + sum(nn, Power_flow(nn,n,t))

                                                           + sum(s$MapS(s,n), Gen_s(s,t))
                                                           - sum(psp$MapS(psp,n), charge(psp,t))
;
**Eff_res(biomass)
*######################################################generation##########################################################

max_gen(g,t)..                                                          Gen_g(g,t) =l= P_on(g,t)
;
max_cap(g,t)..                                                          P_on(g,t)  =l= cap_conv(g)
;
startup_constr(g,t)..                                                   P_on(g,t) - P_on(g,t-1) =l= Su(g,t)
;
max_res_biomass(biomass,t)..                                            gen_r(biomass,t) =l=  cap_res(biomass)
;
max_res_sun(sun,n,sr,t)$(MapSR(sr,n) and MapRes(sun,n))..               gen_r(sun,t) =e=  af_sun(t,sr,n) * cap_res(sun)- Curtailment(sun,t)
;
max_res_wind(wind,n,wr,t)$(MapWR(wr,n) and MapRes(wind,n))..            gen_r(wind,t) =e= af_wind(t,wr,n) * cap_res(wind)- Curtailment(wind,t)
;

********************************************************Hydro RoR**********************************************************

max_gencap_ror(ror,t)..                                                 gen_s(ror,t) =l=  cap_hydro(ror)
;
max_inflow_ror(ror,n,hr,t)$(MapHR(hr,n) and MapS(ror,n))..              gen_s(ror,t) =l=  (af_hydro(t,hr,n) * scale_to_MW) *  share_inflow(ror,n)     
;
********************************************************Hydro PsP**********************************************************

Store_level_start(psp,t)$(ord(t) =1)..                                  storagelvl(psp,t) =e= cap_hydro(psp) *0.5 + charge(psp,t) * eff_hydro(psp) - gen_s(psp,t)
;
Store_level(psp,t)$(ord(t) gt 1)..                                      storagelvl(psp,t) =e= storagelvl(psp,t-1) + charge(psp,t-1) * eff_hydro(psp) - gen_s(psp,t-1)
;
Store_level_end(psp,t)$(ord(t) = card(t))..                             storagelvl(psp,t) =e= cap_hydro(psp) * 0.5
;
Store_level_max(psp,t)..                                                storagelvl(psp,t) =l= cap_hydro(psp) * store_cpf
;
Store_prod_max(psp,t)..                                                 gen_s(psp,t) + charge(psp,t) *1.2 =l= cap_hydro(psp) 
;
Store_prod_max_end(psp,t)$(ord(t) = card(t))..                          gen_s(psp,t)      =l= storagelvl(psp,t)
;
*****************************************************Hydro reservoir******************************************************

reservor_stor_lvl_start(reservoir,n,hr,t)$(MapHR(hr,n) and MapS(reservoir,n) and ord(t) =1)..               storagelvl(reservoir,t) =e= reservoir_stor_cap(reservoir,n) *0.7 - gen_s(reservoir,t) + (af_hydro(t,hr,n) * scale_to_MW) * share_inflow(reservoir,n)
;
reservor_stor_lvl(reservoir,n,hr,t)$(MapHR(hr,n) and MapS(reservoir,n) and ord(t) gt 1)..                   storagelvl(reservoir,t) =e= storagelvl(reservoir,t-1) - gen_s(reservoir,t-1) + (af_hydro(t-1,hr,n) * scale_to_MW) * share_inflow(reservoir,n)
;
reservor_stor_lvl_end(reservoir,n,hr,t)$(MapHR(hr,n) and MapS(reservoir,n) and ord(t) = card(t))..          storagelvl(reservoir,t) =e= reservoir_stor_cap(reservoir,n) *0.7 - gen_s(reservoir,t-1) + (af_hydro(t-1,hr,n) * scale_to_MW) * share_inflow(reservoir,n)
;
min_reservoir_gen(reservoir,n,hr,t)$(MapHR(hr,n) and MapS(reservoir,n))..                                   gen_s(reservoir,t) =g= (af_hydro(t,hr,n) *scale_to_MW) * share_inflow(reservoir,n) * 0.1
;
max_reservoir_gen(reservoir,n,hr,t)$(MapHR(hr,n) and MapS(reservoir,n))..                                   gen_s(reservoir,t) =l= cap_hydro(reservoir) 
;
max_reservoir_stor_lvl(reservoir,n,hr,t)$(MapHR(hr,n) and MapS(reservoir,n))..                              storagelvl(reservoir,t) =l= reservoir_stor_cap(reservoir,n)
;
min_reservoir_stor_lvl(reservoir,n,hr,t)$(MapHR(hr,n) and MapS(reservoir,n) and (ord(t) gt 1) )..           storagelvl(reservoir,t) =g= 0.15 * reservoir_stor_cap(reservoir,n)
;

*##########################################################NTC exchange###########################################################

ntc_max_ex(n,nn,t)..                                                    power_flow(n,nn,t) =l= NTC_cap(n,nn)
;
ntc_max_im(nn,n,t)..                                                    power_flow(nn,n,t) =l= NTC_cap(nn,n)
;
*****************************************************load shedding determination*******************************************

LS_det(t,n)..                                                           Load_shed(t,n)     =l= load(t,n)
;
*execute_unload "check_Toy_1.gdx";
*$stop
*#########################################################Model definition##########################################################

Model Quant_reliab_res_EU
/
Total_costs
Balance

max_gen
max_cap
startup_constr

max_res_biomass
max_res_sun
max_res_wind

max_gencap_ror
max_inflow_ror

reservor_stor_lvl_start
reservor_stor_lvl
reservor_stor_lvl_end
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

solve Quant_reliab_res_EU using MIP minimizing costs
;
*****************************************************parameter calibration*********************************************************

count_time(t) = card(t)
;
price(t,n) = Balance.m(t,n)*(-1)
;
Average_price(n) = sum(t,price(t,n)/count_time(t))
;
Count_LS_hours(t,n)$(Load_shed.l(t,n) gt 0) = 1
;
Count_curtail_hours(res,t)$(Curtailment.l(res,t) gt 0) =1;

******************************************************report parameter definition**************************************************

report(n,'Average Price') = Average_price(n)
;
hourly_price_report(t,n) = price(t,n)
;
report(n,'LOLH') = sum(t, Count_LS_hours(t,n))
;
report(n,'EENS') = sum((t),Load_shed.l(t,n))
;
report(n,'Curtailment')= sum((res,t)$MapRes(res,n), Count_curtail_hours(res,t))
;
****************************************************write to gdx*******************************************************************
execute_unload "check_Toy_1.gdx"
;

****************************************************output*************************************************************************

execute "gdxxrw check_Toy_1.gdx output=Output_toy_1.xlsx  par=report  rng=report!A1"
execute "gdxxrw check_Toy_1.gdx output=Output_toy_1.xlsx  par=hourly_price_report  rng=price_report!A1"
;











