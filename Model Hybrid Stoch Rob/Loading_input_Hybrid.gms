Scalars
cur_costs /150/
store_cpf /7/
scale_to_MW /1000/
Gamma_W /1/
Gamma_S /1/
Gamma_D /1/
;
Parameters
**********************************************************Input parameter********************************************
Gen_conv
Gen_Hydro
Gen_ren

Inv_conv                        upload table
Inv_ren                         upload table
Inv_hydro                       upload table

IC_conv(g)
IC_ren(ren)
IC_stor(s)

priceup                         upload table
availup_vola_89                 upload table for PV and Wind cap factors 1989
availup_vola_90                 upload table for PV and Wind cap factors 1990
availup_vola_10                 upload table for PV and Wind cap factors 2010
availup_vola_12                 upload table for PV and Wind cap factors 2012

load20                          upload table for country wise load data 2020
load30                          upload table for country wise load data 2030
load40                          upload table for country wise load data 2040
load50                          upload table for country wise load data 2050

availup_hydro                   upload table for hydro availability
NTC_cap(n,nn)                   upload parameter

Fc_conv(g,t)                    fuel costs conventional powerplants
Fc_ren(ren,t)                   fuel costs renewable powerplants
CO2_content(g)                  Co2 content
CO2_costs(t)                    CO2 costs
SU_costs(g,t)                   start-up costs conventionals

su_fact(g)                      start-up factor conventionals
fuel_start(g)                   fuel consumption factor if start-up decision
depri_costs(g)                  deprication costs conventionals

load(t,n)                       electrical demand in each node in hour t
LS_costs(n)                     loadshedding costs per node
var_costs(g,t)                  variable costs conventional power plants


Eff_conv(g)                     efficiency of conventional powerplants
Eff_hydro(s)                    efficiency of hydro powerplants
Eff_ren(ren)                    efficiency of renewable powerplants

share_inflow(s,n)
reservoir_stor_cap(s,n)         maximum reservoir storage capacity renp. filling level
af_hydro(t,n)                   availability of hydro potential inflow

propability(sc)
af_sun(Sc,t,n)                  capacity factor of solar energy
af_wind(Sc,t,n)                 capacity factor of wind energy
delta_af_sun(Sc,t,n)            capacity derivation factor solar energy
delta_af_Wind(Sc,t,n)           capacity derivation factor wind energy



delta_load(n,t)
*Gamma_D(n)
**********************************************************report parameter*******************************************

price(sc,t,n)
Average_price(sc,n)
count_time(t)
Count_LS_hours(sc,t,n)
Count_curtail_hours(sc,ren,t)
report(sc,n,*)
hourly_price_report(sc,t,n)
;
**********************************************************input txt. table******************************************

*Table Solar_scenarios(Sc,t,n)
*$include %Data_input%Solar_CF_Scenarios.txt
*;
*Table Wind_on_scenarios(Sc,t,n)
*$include %Data_input%Wind_on_CF_Scenarios.txt
;

**********************************************************input Excel table******************************************
;

************************************technical & mapping******************************
$onecho > Genup.txt
set=MapG                        rng=Mapping!A2:B121                     rdim=2 cDim=0
set=MapS                        rng=Mapping!D2:E53                      rdim=2 cDim=0
set=MapRen                      rng=Mapping!G2:H53                      rdim=2 cDim=0

par=Gen_conv                    rng=Sheet_conv!B1:N120                  rDim=1 cdim=1
par=Gen_Hydro                   rng=Sheet_hydro!B1:M52                  rDim=1 cdim=1
par=Gen_ren                     rng=Sheet_ren!B1:I35                    rDim=1 cdim=1

par=Inv_conv                    rng=Investments!A1:B8                   rDim=1 cdim=1
par=Inv_ren                     rng=Investments!D1:E3                   rDim=1 cdim=1
par=Inv_hydro                   rng=Investments!G1:H4                   rDim=1 cdim=1

par=priceup                     rng=prices!A1:I8761                     rDim=1 cdim=1
par=availup_hydro               rng=Availability!C2:T8763               rDim=1 cdim=1
par=NTC_cap                     rng=NTC!A1:CE83                         rDim=1 cdim=1
$offecho

$onUNDF
$call   gdxxrw I=%Data_input%Data_Hybrid.xlsx O=%Data_input%Data_Hybrid.gdx @Genup.txt
$GDXin  %Data_input%Data_Hybrid.gdx
$load   MapG, MapS, Mapren
$load   Gen_conv, Gen_Hydro, Gen_ren
$load   Inv_conv, Inv_ren, Inv_hydro
$load   priceup, availup_hydro, NTC_cap
$GDXin
$offUNDF

***********************************load for each country****************************

$onecho > load.txt
par=load20                        rng=Load_2020!A1:R8761                       rDim=1 cdim=1
par=load30                        rng=Load_2030!A1:R8761                       rDim=1 cdim=1
par=load40                        rng=Load_2040!A1:R8761                       rDim=1 cdim=1
par=load50                        rng=Load_2050!A1:R8761                       rDim=1 cdim=1
$offecho

$onUNDF
$call   gdxxrw I=%Data_input%Load_combined.xlsx O=%Data_input%Load_combined.gdx @load.txt
$GDXin  %Data_input%Load_combined.gdx
$load   load20, load30, load40, load50
$GDXin
$offUNDF


***********************************load CF Scenarios********************************

$onecho > load.txt
par=af_sun                       rng=CF_table!U2:AM25922                         rDim=2 cdim=1
par=af_wind                      rng=CF_table!A2:S25922                          rDim=2 cdim=1
$offecho
$onUNDF
$call   gdxxrw I=%Data_input%CF_scenarios.xlsx O=%Data_input%CF_scenarios.gdx @load.txt
$GDXin  %Data_input%CF_scenarios.gdx
$load   af_sun, af_wind
$offUNDF


*####################################subset definitions#############################

        gas(g)          =    Gen_conv(g,'tech')  = 1
;
$ontext
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
        biomass(g)      =    Gen_conv(g,'tech')  = 7
;
$offtext  
        psp(s)          =    Gen_Hydro(s,'tech') = 8
;
        reservoir(s)    =    Gen_Hydro(s,'tech') = 9
;
        ror(s)          =    Gen_Hydro(s,'tech') = 10
;
        Wind(ren)       =    Gen_ren(ren,'tech') = 11
;
        Sun(ren)        =    Gen_ren(ren,'tech') = 12
;   

***************************************hydro****************************************

        share_inflow(s,n)$(MapS(s,n))  =    Gen_Hydro(s,'share_reservoir_ROR') 
;
        reservoir_stor_cap(s,n)$(MapS(s,n)) =  Gen_Hydro(s,'Stor_cap')
;
        af_hydro(t,n)               =       availup_hydro(t,n)
;
*###################################loading parameter###############################

*****************************************demand*************************************

LS_costs(n)         =          3000
;
*****************************************Investment costs***************************

IC_conv(gas)        =           77423
;
$ontext
IC_conv(oil)        =           1000000
;
IC_conv(coal)       =           102446
;
IC_conv(lig)        =           130386
;
IC_conv(nuc)        =           560200
;
IC_conv(waste)      =           1000000
;
IC_conv(biomass)    =           456850
;
$offtext

IC_ren(wind)        =           93900
;
IC_ren(sun)         =           54555
;


IC_stor(ror)        =           255836
;
IC_stor(reservoir)  =           252948
;
IC_stor(psp)        =           85278
;


*****************************************opertation prices***************************

Fc_conv(gas,t)      =          priceup(t,'gas')
;
$ontext
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
Fc_conv(biomass,t)  =          priceup(t,'biomass')
;
$offtext
CO2_costs(t)        =          priceup(t,'CO2')
;
*************************************generators*************************************

Eff_conv(g)         =          Gen_conv(g,'eff')
;
Eff_hydro(s)        =          Gen_hydro(s,'eff')
;
Eff_ren(ren)        =          Gen_ren(ren,'eff')
;
Co2_content(g)      =          Gen_conv(g,'CO2')
;
su_fact(g)          =          Gen_conv(g,'su_fact')
;
depri_costs(g)      =          Gen_conv(g,'depri_costs')
;
fuel_start(g)       =          Gen_conv(g,'fuel_start')
;

*************************************Scenarios*************************************

propability('sc1')  =          0.2
;
propability('sc2')  =          0.6
;
propability('sc3')  =          0.2
;


delta_af_sun(Sc,t,n)      =      (af_sun(Sc,t,n) - 0.2)$(af_sun(Sc,t,n) gt 0.2)
;
delta_af_Wind(Sc,t,n)     =      (af_wind(Sc,t,n) - 0.2)$(af_wind(Sc,t,n) gt 0.2)
;

*************************************load data**********************************
**************************2020
%Load_exo20%$ontext

load(t,n)           =           load20(t,n)
;                 
$ontext
$offtext

**************************2030
%Load_exo30%$ontext

load(t,n)           =           load30(t,n)
;                 
$ontext
$offText

**************************2040
%Load_exo40%$ontext

load(t,n)           =           load40(t,n)
;                 
$ontext
$offText

**************************2050
%Load_exo50%$ontext

load(t,n)           =           load50(t,n)
;                 
$ontext
$offtext


delta_load(n,t)           =      load(t,n) * 0.2
;
*Gamma_D(n)                =      0.5
*;
*************************************calculating************************************

var_costs(g,t)   =          ((FC_conv(g,t)+ co2_costs(t) * co2_content(g)) / Eff_conv(g) )
;
su_costs(g,t)     =          depri_costs(g) + su_fact(g) * fuel_start(g) * FC_conv(g,t) + co2_content(g) * co2_costs(t)
;
*************************************upload table clearing**************************

*option kill = Node_Demand ;