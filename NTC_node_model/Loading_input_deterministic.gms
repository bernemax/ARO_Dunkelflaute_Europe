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

load20                          upload table for country wise load data 2020
load30                          upload table for country wise load data 2030
load40                          upload table for country wise load data 2040
load50                          upload table for country wise load data 2050

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
Count_curtail_hours(res,t)
report(n,*)
hourly_price_report(t,n)

**********************************************************input txt. table******************************************
;

Table
Solar_Ty(t, n)
*$include %Data_input%Syn_data%EU_sol%syn_sol_TDY.txt
$include %Data_input%syn_sol_TDY.txt
;

execute_unload "check_Toy_input.gdx";
$stop

Table
Solar_Ex_low(t,n)
*$include %Data_input%Syn_data%EU_sol%syn_sol_ELCF.txt
$include %Data_input%syn_sol_ELCF.txt
;
Table
Solar_ex_hight(t,n)
*$include %Data_input%Syn_data%EU_sol%syn_sol_EHCF.txt
$include %Data_input%syn_sol_EHCF.txt
;

;
Table
Wind_Ty(t,n)
*$include %Data_input%Syn_data%EU_won%syn_wind_TDY.txt
$include %Data_input%syn_wind_TDY.txt
;
Table
Wind_Ex_low(t,n)
*$include %Data_input%Syn_data%EU_won%syn_wind_ELCF.txt
$include %Data_input%syn_wind_ELCF.txt
;
Table
Wind_Ex_high(t,n)
*$include %Data_input%Syn_data%EU_won%syn_wind_EHCF.txt
$include %Data_input%syn_wind_EHCF.txt
;

execute_unload "check_Toy_input.gdx";
$stop
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

par=Gen_conv                    rng=Gen_conv!B1:N103                    rDim=1 cdim=1
par=Gen_Hydro                   rng=Gen_Hydro!A1:M52                    rDim=1 cdim=1
par=Gen_res                     rng=Gen_res!B1:I52                      rDim=1 cdim=1

par=priceup                     rng=prices!A1:I8761                     rDim=1 cdim=1
par=availup_hydro               rng=Availability!A2:R8762               rDim=1 cdim=1
par=NTC_cap                     rng=NTC!A1:CE83                         rDim=1 cdim=1

$offecho

$onUNDF
$call   gdxxrw I=%Data_input%Data.xlsx O=%Data_input%Data.gdx @Genup.txt
$GDXin  %Data_input%Data.gdx
$load   MapG, MapS, MapRes, MapSr, MapWr, MapHr
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
*************************************Generation Capacity**********************
**************************2020
%cap_exo20%$ontext

Cap_conv(g)         =          Gen_conv(g,'Gen_cap')
;
Cap_hydro(s)        =          Gen_Hydro(s,'Gen_cap')
;
Cap_res(res)        =          Gen_res(res,'Gen_cap')
;
$ontext
$offtext

**************************2030
%cap_exo30%$ontext

Cap_conv(g)         =          Gen_conv(g,'cap_exo30')
;
Cap_hydro(s)        =          Gen_Hydro(s,'cap_exo30')
;
Cap_res(res)        =          Gen_res(res,'cap_exo30')
;
$ontext
$offtext

**************************2040
%cap_exo40%$ontext
Cap_conv(g)         =          Gen_conv(g,'cap_exo40')
;
Cap_hydro(s)        =          Gen_Hydro(s,'cap_exo40')
;
Cap_res(res)        =          Gen_res(res,'cap_exo40')
;

$ontext
$offtext
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

*************************************calculating************************************

var_costs(g,t)   =          ((FC_conv(g,t)+ co2_costs(t) * co2_content(g)) / Eff_conv(g) )
;
su_costs(g,t)     =          depri_costs(g) + su_fact(g) * fuel_start(g) * FC_conv(g,t) + co2_content(g) * co2_costs(t)
;

*execute_unload "check_Toy_1.gdx";
*$stop
*************************************upload table clearing**************************

*option kill = Node_Demand ;