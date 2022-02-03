
* only one "*" for a model run is possible for now
$setglobal  cf_1989  "*"       if "*" considered, if "" taken out
$setglobal  cf_1990  ""       if "*" considered, if "" taken out
$setglobal  cf_2010  ""       if "*" considered, if "" taken out
$setglobal  cf_2012  ""       if "*" considered, if "" taken out

$set        Data_input         Data_input\


Sets

n /DE,DK,SE,PL,CZ,AT,CH,FR,BE,NE,
   NO,UK,IT,ES,BALT,SI,SEE,FI/
g /g1*g102/
s /s1*s51/
res/res1*res51/
*NTC/ntc1*ntc100/
t/t1*t8760/
sr/sr1*sr17/
wr/wr1*wr17/
hr/hr1*hr17/

*H(t,it)

****************************thermal************************************************
gas(g)
lig(g)
coal(g)
nuc(g)
oil(g)
waste(g)

****************************renewable***********************************************
wind(res)
sun(res)
biomass(res)

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
;

alias (n,nn)
;
Scalars
cur_costs /150/
store_cpf /7/
scale_to_MW /1000/
;
Parameters
**********************************************************Input parameter********************************************
Gen_conv                        upload table
Gen_res                         upload table
Gen_hydro                       upload table

priceup                         upload table
availup_vola_89                 upload table for PV and Wind cap factors 1989
availup_vola_90                 upload table for PV and Wind cap factors 1990
availup_vola_10                 upload table for PV and Wind cap factors 2010
availup_vola_12                 upload table for PV and Wind cap factors 2012

availup_hydro                   upload table for hydro availability

NTC_cap(n,nn)                   upload parameter

Fc_conv(g,t)                    fuel costs conventional powerplants
Fc_res(res,t)                   fuel costs renewable powerplants
CO2_content(g)                  Co2 content
CO2_costs(t)                    CO2 costs
SU_costs(g,t)                   start-up costs conventionals

su_fact(g)                      start-up factor conventionals
fuel_start(g)                   fuel consumption factor if start-up decision
depri_costs(g)                  deprication costs conventionals

load(t,n)                       electrical demand in each node in hour t
LS_costs(n)                     loadshedding costs per node
var_costs(g,t)                  variable costs conventional power plants

cap_conv(g)                     max. generation capacity of each conventional generator
cap_hydro(s)                    max. generation capacity of each psp
cap_res(res)                    max. generation capacity of each RES

Eff_conv(g)                     efficiency of conventional powerplants
Eff_hydro(s)                    efficiency of hydro powerplants
Eff_res(res)                    efficiency of renewable powerplants

share_inflow(s,n)
reservoir_stor_cap(s,n)         maximum reservoir storage capacity resp. filling level
af_hydro(t,hr,n)                availability of hydro potential inflow
af_sun(t,sr,n)                  capacity factor of solar energy
af_wind(t,wr,n)                 capacity factor of wind energy
**********************************************************report parameter*******************************************

price(t,n)
Average_price(n)
count_time(t)
Count_LS_hours(t,n)
report(n,*)

**********************************************************input Excel table******************************************
;

************************************technical & mapping******************************
$onecho > Genup.txt
set=MapG                        rng=Mapping!A2:B104                     rdim=2 cDim=0
set=MapS                        rng=Mapping!D2:E100                     rdim=2 cDim=0
set=MapRes                      rng=Mapping!G2:H100                     rdim=2 cDim=0
set=MapSr                       rng=Mapping!J2:K30                      rdim=2 cDim=0
set=MapWr                       rng=Mapping!M2:N30                      rdim=2 cDim=0
set=MapHr                       rng=Mapping!P2:Q30                      rdim=2 cDim=0

par=load                        rng=Load!A1:R8761                       rDim=1 cdim=1
par=Gen_conv                    rng=Gen_conv!B1:J103                    rDim=1 cdim=1
par=Gen_res                     rng=Gen_res!B1:F52                      rDim=1 cdim=1
par=Gen_Hydro                   rng=Gen_Hydro!A1:I52                    rDim=1 cdim=1
par=priceup                     rng=prices!A1:I8761                     rDim=1 cdim=1
par=availup_hydro               rng=Availability!A2:R8762               rDim=1 cdim=1
par=NTC_cap                     rng=NTC!A1:CE83                         rDim=1 cdim=1

$offecho

$onUNDF
$call   gdxxrw I=%Data_input%Data.xlsx O=%Data_input%Data.gdx @Genup.txt
$GDXin  %Data_input%Data.gdx
$load   MapG, MapS, MapRes, MapSr, MapWr, MapHr
$load   load
$load   Gen_conv, Gen_res, Gen_Hydro
$load   priceup,availup_hydro, NTC_cap
$GDXin
$offUNDF

**************************************weather cap factors ***************************
$onecho > availup.txt
par=availup_vola_89              rng=cf_1989!A2:AL8763                  rDim=1 cdim=1
par=availup_vola_90              rng=cf_1990!A2:AL8763                  rDim=1 cdim=1
par=availup_vola_10              rng=cf_2010!A2:AL8763                  rDim=1 cdim=1
par=availup_vola_12              rng=cf_2012!A2:AL8763                  rDim=1 cdim=1
$offecho

$onUNDF
$call   gdxxrw I=%Data_input%Weather_cap_factors.xlsx O=%Data_input%Weather_cap_factors.gdx @availup.txt
$GDXin  %Data_input%Weather_cap_factors.gdx
$load   availup_vola_89, availup_vola_90, availup_vola_10, availup_vola_12
$GDXin
$offUNDF

*####################################subset definitions#############################

        gas(g)          =    Gen_conv(g,'tech')  = 1
;
        oil(g)          =    Gen_conv(g,'tech')  = 2
;
        coal(g)         =    Gen_conv(g,'tech')  = 3
;
        lig(g)          =    Gen_conv(g,'tech')  = 4
;
        nuc(g)          =    Gen_conv(g,'tech')  = 5
;
        waste(g)        =    Gen_conv(g,'tech')  = 6
;

***************************************hydro****************************************

        psp(s)          =    Gen_Hydro(s,'tech') = 7
;
        reservoir(s)    =    Gen_Hydro(s,'tech') = 8
;
        ror(s)          =    Gen_Hydro(s,'tech') = 9
;
        share_inflow(s,n)$(MapS(s,n))  =    Gen_Hydro(s,'share_Reservoir_ROR') 
;
        reservoir_stor_cap(s,n)$(MapS(s,n)) =  Gen_Hydro(s,'Stor_cap')
;
****************************************res*****************************************

        wind(res)       =    Gen_res(res,'tech') = 10
;
        sun(res)        =    Gen_res(res,'tech') = 11
;
        biomass(res)    =    Gen_res(res,'tech') = 12
;


*###################################loading parameter###############################

*****************************************demand*************************************

LS_costs(n)         =          3000
;

*****************************************prices*************************************

Fc_conv(gas,t)      =          priceup(t,'gas')
;
Fc_conv(oil,t)      =          priceup(t,'oil')
;
Fc_conv(coal,t)     =          priceup(t,'coal')
;
Fc_conv(lig,t)      =          priceup(t,'lignite')
;
Fc_conv(nuc,t)      =          priceup(t,'nuclear')
;
Fc_conv(waste,t)    =          priceup(t,'waste')
;
Fc_res(biomass,t)   =          priceup(t,'biomass')
;
CO2_costs(t)        =          priceup(t,'CO2')
;

*************************************generators*************************************

Cap_conv(g)         =          Gen_conv(g,'Gen_cap')
;
Cap_hydro(s)        =          Gen_Hydro(s,'Gen_cap')
;
Cap_res(res)        =          Gen_res(res,'Gen_cap')
;
Eff_conv(g)         =          Gen_conv(g,'eff')
;
Eff_hydro(s)        =          Gen_hydro(s,'eff')
;
Eff_res(res)        =          Gen_res(res,'eff')
;
Co2_content(g)      =          Gen_conv(g,'CO2')
;
su_fact(g)          =          Gen_conv(g,'su_fact')
;
depri_costs(g)      =          Gen_conv(g,'depri_costs')
;
fuel_start(g)       =          Gen_conv(g,'fuel_start')
;

************************************availability************************************

**************************1989
%cf_1989%$ontext

af_sun(t,sr,n)$MapSR(sr,n)  =          availup_vola_89(t,sr)
;
af_wind(t,wr,n)$MapWR(wr,n) =          availup_vola_89(t,wr)
;
af_hydro(t,hr,n)$MapHR(hr,n)=          availup_hydro(t,hr)
;
$ontext
$offtext

**************************1990
%cf_1990%$ontext

af_hydro(t,hr,n)$MapHR(hr,n)=          availup_hydro(t,hr)
;
af_sun(t,sr,n)$MapSR(sr,n)  =          availup_vola_90(t,sr)
;
af_wind(t,wr,n)$MapWR(wr,n) =          availup_vola_90(t,wr)
;
$ontext
$offtext

**************************2010
%cf_2010%$ontext

af_hydro(t,hr,n)$MapHR(hr,n)=          availup_hydro(t,hr)
;
af_sun(t,sr,n)$MapSR(sr,n)  =          availup_vola_10(t,sr)
;
af_wind(t,wr,n)$MapWR(wr,n) =          availup_vola_10(t,wr)
;
$ontext
$offtext

**************************2012
%cf_2012%$ontext

af_hydro(t,hr,n)$MapHR(hr,n)=          availup_hydro(t,hr)
;
af_sun(t,sr,n)$MapSR(sr,n)  =          availup_vola_12(t,sr)
;
af_wind(t,wr,n)$MapWR(wr,n) =          availup_vola_12(t,wr)
;
$ontext
$offtext

*************************************calculating************************************

var_costs(g,t)   =          ((FC_conv(g,t)+ co2_costs(t) * co2_content(g)) / Eff_conv(g) )
;
su_costs(g,t)     =          depri_costs(g) + su_fact(g) * fuel_start(g) * FC_conv(g,t) + co2_content(g) * co2_costs(t)
;

*execute_unload "check_Toy_1.gdx";
*$stop
*************************************upload table clearing**************************

*option kill = Node_Demand ;


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

reservor_stor_lvl_start(reservoir,n,hr,t)$(MapHR(hr,n) and (ord(t) =1))..              storagelvl(reservoir,t) =e= reservoir_stor_cap(reservoir,n) *0.7 - gen_s(reservoir,t) + (af_hydro(t,hr,n) * scale_to_MW) * share_inflow(reservoir,n)
;
reservor_stor_lvl(reservoir,n,hr,t)$(MapHR(hr,n)  and (ord(t) gt 1))..                 storagelvl(reservoir,t) =e= reservoir_stor_cap(reservoir,n) - gen_s(reservoir,t) + (af_hydro(t,hr,n) * scale_to_MW) * share_inflow(reservoir,n)
;
reservor_stor_lvl_end(reservoir,n,hr,t)$(MapHR(hr,n)  and (ord(t) = card(t)))..        storagelvl(reservoir,t) =e= reservoir_stor_cap(reservoir,n) *0.7 - gen_s(reservoir,t) + (af_hydro(t,hr,n) * scale_to_MW) * share_inflow(reservoir,n)
;
min_reservoir_gen(reservoir,n,hr,t)$(MapHR(hr,n) )..                                   gen_s(reservoir,t) =g= (af_hydro(t,hr,n) *scale_to_MW) * share_inflow(reservoir,n) * 0.15
;
max_reservoir_gen(reservoir,n,hr,t)$(MapHR(hr,n) )..                                   gen_s(reservoir,t) =l= cap_hydro(reservoir) 
;
max_reservoir_stor_lvl(reservoir,n,hr,t)$(MapHR(hr,n) )..                              storagelvl(reservoir,t) =l= reservoir_stor_cap(reservoir,n)
;
min_reservoir_stor_lvl(reservoir,n,hr,t)$(MapHR(hr,n)and (ord(t) gt 1) )..             storagelvl(reservoir,t) =g= 0.15 * reservoir_stor_cap(reservoir,n)
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

******************************************************report parameter definition**************************************************

report(n,'Average Price') = Average_price(n)
;
report(n,'LOLH') = sum(t, Count_LS_hours(t,n))
;
report(n,'EENS') = sum((t),Load_shed.l(t,n))
;
****************************************************write to gdx*******************************************************************
execute_unload "check_Toy_1.gdx"
;

****************************************************output*************************************************************************

execute "gdxxrw check_Toy_1.gdx output=Output_toy_1.xlsx  par=report  rng=report!A1"
;











