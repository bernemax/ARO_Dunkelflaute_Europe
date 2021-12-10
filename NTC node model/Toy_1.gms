Sets

n /DE,DK,SE,PL,CZ,AT,CH,FR,BE,NL,
   NO,UK,IT,ES,PT,BALT,SI/
g /g1*g102/
s /s1*s51/
res/res1*res51/
*NTC/ntc1*ntc100/
t/t1*t8760/
sr/sr1*sr17/
wr/wr1*wr17/

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

MapG(n,g)
MapS(n,s)
MapRes(n,res)
MapNTC(n,n)
MapSr(n,sr)
MapWr(n,wr)
;

alias (n,nn)
;

Parameters
**********************************************************Input parameter********************************************
Country_load                    upload table

Gen_conv                        upload table
Gen_res                         upload table
Gen_hydro                       upload table

priceup                         upload table
availup                         upload table

NTC_cap(n,nn)                   upload parameter

Fc_conv(g,t)                    fuel costs conventional powerplants
Fc_res(res,t)                   fuel costs renewable powerplants
CO2_content(g)                  Co2 content
CO2_costs(t)                    CO2 costs
SU_costs(g,t)                   start-up costs conventionals

su_fact(g)                      start-up factor conventionals
fuel_start(g)                   fuel consumption factor if start-up decision
depri_costs(g)                  deprication costs conventionals

load(n,t)                       electrical demand in each node in hour t
LS_costs(n)                     loadshedding costs per node
var_costs(g,t)                  variable costs conventional power plants

cap_conv(g)                     max. generation capacity of each conventional generator
cap_hydro(s)                    max. generation capacity of each psp
cap_res(res)                    max. generation capacity of each RES

Eff_conv(g)                     efficiency of conventional powerplants
Eff_hydro(s)                    efficiency of hydro powerplants
Eff_res(res)                    efficiency of renewable powerplants

af_hydro(s,t)                   availability of hydro potential
af_sun(n,sr,t)                  capacity factor of solar energy
af_wind(n,wr,t)                 capacity factor of wind energy

**********************************************************report parameter*******************************************

price(n,t)



**********************************************************input Excel table******************************************
;

$onecho > TEP.txt
set=MapG                        rng=Mapping!A2:B104                     rdim=2 cDim=0
set=MapS                        rng=Mapping!D2:E100                     rdim=2 cDim=0
set=MapRes                      rng=Mapping!G2:H100                     rdim=2 cDim=0
set=MapSr                       rng=Mapping!J2:K30                      rdim=2 cDim=0
set=MapWr                       rng=Mapping!M2:N30                      rdim=2 cDim=0
set=MapNTC                      

par=Country_load                rng=Load!A1:C506                        rDim=1 cdim=1
par=Gen_conv                    rng=Gen_conv!B1:J561                    rDim=1 cdim=1
par=Gen_res                     rng=Gen_res!B1:E1120                    rDim=1 cdim=1
par=Gen_Hydro                   rng=Gen_Hydro!B1:F177                   rDim=1 cdim=1
par=priceup                     rng=prices!A1:I8761                     rDim=1 cdim=1
par=availup                     rng=Availability!A1:X8762               rDim=1 cdim=1
par=NTC_cap                     rng=NTC!A1:BE57                         rDim=1 cdim=1

$offecho

$onUNDF
$call   gdxxrw Data_input.xlsx @TEP.txt
$GDXin  Data_input.gdx
$load   MapG, MapS, MapRes, MapSr, MapWr, MapNTC
$load   Country_load
$load   Gen_conv, Gen_res, Gen_Hydro
$load   priceup, availup, NTC_cap
$GDXin
$offUNDF

*####################################subset definitions#############################

        gas(g)      =    Gen_conv(g,'tech')  = 1
;
        oil(g)      =    Gen_conv(g,'tech')  = 2
;
        coal(g)     =    Gen_conv(g,'tech')  = 3
;
        lig(g)      =    Gen_conv(g,'tech')  = 4
;
        nuc(g)      =    Gen_conv(g,'tech')  = 5
;
        waste(g)    =    Gen_conv(g,'tech')  = 6
;

***************************************hydro****************************************

        psp(s)      =    Gen_Hydro(s,'tech') = 7
;
        reservoir(s)=    Gen_Hydro(s,'tech') = 8
;
        ror(s)      =    Gen_Hydro(s,'tech') = 9
;

****************************************res*****************************************

        wind(res)   =    Gen_res(res,'tech') = 10
;
        sun(res)    =    Gen_res(res,'tech') = 11
;
        biomass(res)=    Gen_res(res,'tech') = 12
;


*###################################loading parameter###############################

*****************************************demand*************************************

load(n,t)           =          Country_load(n,t)
;
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

af_hydro(ror,t)             =          availup(t,'ror')
;
af_hydro(psp,t)             =          availup(t,'psp')
;
af_hydro(reservoir,t)       =          availup(t,'reservoir')
;
af_sun(n,sr,t)$MapSR(n,sr)  =          availup(t,sr)
;
af_wind(n,wr,t)$MapWR(n,wr) =          availup(t,wr)
;

*************************************calculating************************************

var_costs(g,t)              =          ((FC_conv(g,t)+ co2_costs(t) * co2_content(g)) / Eff_conv(g))
;
su_costs(g,t)               =          depri_costs(g) + su_fact(g) * fuel_start(g) * FC_conv(g,t) + co2_content(g) * co2_costs(t)
;

execute_unload "check.gdx";
$stop
*************************************upload table clearing**************************

*option kill = Node_Demand ;   


*######################################variables######################################
Variables
Costs
Power_flow(n,nn,t)
;

positive Variables
Gen_g (g,t)             generation conventionals
Gen_r(res,t)            generation renewables
Gen_s (s,t)             generation hydro

storagelvl(s,t)
charge(s,t)

Su(g,t)
P_on(g,t)

Load_shed (n,t)
Curtailment (res,t)
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

max_ror
min_reservoir
max_reservoir

Store_level_start
Store_level
Store_level_end
Store_level_max
Store_prod_max
Store_prod_max_end

NTC_max
LS_det

;
*#######################################################objective##########################################################

Total_costs..                costs =e=   sum((g,t), Var_costs(g,t) * Gen_g(g,t))
                                       + sum((g,t), Su(g,t) *su_costs(g,t))
                                       + sum((res,t), Fc_res(res,t) * Gen_r(res,t))
                                       + sum((n,t), LS_costs(n) * Load_shed(n,t))
                                       + sum((res,t), Curtailment(res,t) * cur_costs)
                                       
;


*####################################################energy balance########################################################

Balance(n,t)$(Relevant_Nodes(n))..                (load(n,t) - Load_shed(n,t))  =e= sum(g$MapG(g,n),Gen_g(g,t))

                                                           + sum(biomass$MapRes(biomass,n),Gen_r(biomass,t))
                                                           + sum(sun$MapRes(sun,n),Gen_r(sun,t))
                                                           + sum(wind$MapRes(wind,n),Gen_r(wind,t))

                                                           - Power_flow(n,nn,t)
                                                           + Power_flow(nn,n,t)

                                                           + sum(s$MapS(s,n), Gen_s(s,t))
                                                           - sum(psp$MapS(psp,n), charge(psp,t))
                                                           

;
**Eff_res(biomass)
*######################################################generation##########################################################

max_gen(g,t)..                                                  Gen_g(g,t) =l= P_on(g,t)
;
max_cap(g,t)..                                                  P_on(g,t)  =l= cap_conv(g)
;
startup_constr(g,t)..                                           P_on(g,t) - P_on(g,t-1) =l= Su(g,t)
;
max_res_biomass(biomass,t)..                                    gen_r(biomass,t) =l=  cap_res(biomass)
;
max_res_sun(sun,sr,n,t)$(MapSR(n,sr) and MapRes(sun,n))..       gen_r(sun,t) =e=  af_sun(t,sr,n) * cap_res(sun)- Curtailment(sun,t)
;
max_res_wind(wind,wr,n,t)$(MapWR(n,wr) and MapRes(wind,n))..    gen_r(wind,t) =e= af_wind(t,wr,n) * cap_res(wind)- Curtailment(wind,t)
;

********************************************************Hydro RoR**********************************************************

max_ror(ror,t)..                                            gen_s(ror,t) =l= af_hydro(ror,t) * cap_hydro(ror)
;

********************************************************Hydro PsP**********************************************************
Store_level_start(psp,t)$(ord(t) =1)..                      storagelvl(psp,t) =e= cap_hydro(psp) *0.5 + charge(psp,t) * eff_hydro(psp) - gen_s(psp,t)
;
Store_level(psp,t)$(ord(t) gt 1)..                          storagelvl(psp,t) =e= storagelvl(psp,t-1) + charge(psp,t-1) * eff_hydro(psp) - gen_s(psp,t-1)
;
Store_level_end(psp,t)$(ord(t) = card(t))..                 storagelvl(psp,t) =e= cap_hydro(psp) * 0.5 
;
Store_level_max(psp,t)..                                    storagelvl(psp,t) =l= cap_hydro(psp) * store_cpf
;
Store_prod_max(psp,t)..                                     gen_s(psp,t) + charge(psp,t) *1.2 =l= cap_hydro(psp) * af_hydro(psp,t)
;
Store_prod_max_end(psp,t)$(ord(t) = card(t))..              gen_s(psp,t)      =l= storagelvl(psp,t)
;
*****************************************************Hydro reservoir******************************************************

min_reservoir(reservoir,t)..                                gen_s(reservoir,t) =G= cap_hydro(reservoir) * af_hydro(reservoir,t) * 0.15
;
max_reservoir(reservoir,t)..                                gen_s(reservoir,t) =l= cap_hydro(reservoir) * af_hydro(reservoir,t)
;

*##########################################################NTC exchange###########################################################

ntc_max(n,nn,t)..                                           power_flow(n,nn,t) =l= NTC_cap(n,nn)
;
*****************************************************load shedding determination*******************************************

LS_det(n,t)..                                               Load_shed(n,t)     =l= load(n,t)
;
*execute_unload "check.gdx";
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

max_ror
min_reservoir
max_reservoir

Store_level_start
Store_level
Store_level_end
Store_level_max
Store_prod_max
Store_prod_max_end

ntc_max
LS_det
/
;

*#########################################################Solving##################################################################

solve Quant_reliab_res_EU using MIP minimizing costs
;
*****************************************************parameter report********************************************************

price(n,t) = Balance.m(n,t)*(-1)
;