alias (n,nn)
;
Scalars
store_cpf /7/
scale_to_MW /1000/
Df_factor /0.2/

M         /15000/

Gamma_Res_total

LB
UB
Toleranz  /1/
itaux     /1/

toy_inv_costs /100000/
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
NTC_cap_ex(n,nn)                existing NTC
NTC_cap_prosp(n,nn)             prospective NTC
NTC_cap_sub_ex(n,nn)            Sum NTC of existing and invested prospective NTC for subproblem
NTC_cap_sub_prosp(n,nn) 

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


**************************************combined solar and wind availability****************************************

*af_sun(t,sr,n)                  capacity factor of solar energy
*af_wind(t,wr,n)                 capacity factor of wind energy

af_res_up(t,rr,n)               upper capacity factor of wind and solar pv energy
delta_af_res(t,rr,n)

Ratio_N(t,DF,rr,n)
Ratio_DF(t,DF,rr,n)
Budget_N(DF,rr,n)             budget of renewable availability during a specific time horizion previous to Dunkelflaute even
Budget_Delta(DF,rr,n)
Budget_DF(DF,rr,n)            budget of renewable availability during a specific time horizion previous to Dunkelflaute event

***************************************Uncerttainty budget

Gamma_PG_res(rr)

**************************************renewable generation connection of Subproblem to Master

AF_M_Res_fixed(t,rr,n,v)         fixed combined wind and solar pv availability 


**********************************************************report parameter*******************************************
report_main(*,*)
report_decomp(v,*,*)
inv_cost_master

Report_dunkel_time_Z(rr)
Report_dunkel_hours_Z(DF,rr)
Report_total_cost
Report_line_constr_cost

price(t,n)
Average_price(n)
count_time(t)
Count_LS_hours(t,n)
Count_curtail_hours(res,t)
report(n,*)
hourly_price_report(t,n)

**********************************************************input Excel table******************************************
;

************************************technical & mapping******************************
$onecho > Genup.txt
set=MapG                        rng=Mapping!A2:B104                     rdim=2 cDim=0
set=MapS                        rng=Mapping!D2:E100                     rdim=2 cDim=0
set=Map_DF                      rng=Mapping!S2:T8762                    rdim=2 cDim=0
set=Map_RR                      rng=Mapping!J2:K19                      rdim=2 cDim=0
set=Map_RR_res                  rng=Mapping!J23:K40                     rdim=2 cDim=0
set=MapRes                      rng=Mapping!M2:N19                      rdim=2 cDim=0
set=MapHr                       rng=Mapping!P2:Q30                      rdim=2 cDim=0
set=Map_link_NTC                rng=Mapping!V2:X86                      rdim=3 cDim=0

par=Gen_conv                    rng=Gen_conv!B1:N120                    rDim=1 cdim=1
par=Gen_Hydro                   rng=Gen_Hydro!A1:M52                    rDim=1 cdim=1
par=Gen_res                     rng=Gen_res!R1:W18                      rDim=1 cdim=1

par=priceup                     rng=prices!A1:I8761                     rDim=1 cdim=1
par=availup_hydro               rng=Availability!A2:R8762               rDim=1 cdim=1
par=NTC_cap_ex                  rng=NTC!A1:CE83                         rDim=1 cdim=1

$offecho

$onUNDF
$call   gdxxrw I=%Data_input%Data_ARO.xlsx O=%Data_input%Data_ARO.gdx @Genup.txt
$GDXin  %Data_input%Data_ARO.gdx
$load   MapG, MapS, Map_DF, Map_RR, Map_RR_res, MapRes, MapHr, Map_link_NTC
$load   Gen_conv, Gen_res, Gen_Hydro
$load   priceup, availup_hydro, NTC_cap_ex
$GDXin
$offUNDF

**************************************weather cap factors ***************************
$onecho > availup.txt
par=availup_vola_89              rng=cf_1989!A2:AZ8763                  rDim=1 cdim=1
par=availup_vola_90              rng=cf_1990!A2:AZ8763                  rDim=1 cdim=1
par=availup_vola_10              rng=cf_2010!A2:AZ8763                  rDim=1 cdim=1
par=availup_vola_12              rng=cf_2012!A2:AZ8763                  rDim=1 cdim=1
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
        biomass(g)      =    Gen_conv(g,'tech')  = 7
;
        

***************************************hydro****************************************

        psp(s)          =    Gen_Hydro(s,'tech') = 8
;
        reservoir(s)    =    Gen_Hydro(s,'tech') = 9
;
        ror(s)          =    Gen_Hydro(s,'tech') = 10
;
        share_inflow(s,n)$(MapS(s,n))  =    Gen_Hydro(s,'share_Reservoir_ROR') 
;
        reservoir_stor_cap(s,n)$(MapS(s,n)) =  Gen_Hydro(s,'Stor_cap')
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
Fc_conv(biomass,t)   =         priceup(t,'biomass')
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
af_hydro(t,hr,n)$MapHR(hr,n)=          availup_hydro(t,hr)
;
*af_sun(t,sr,n)$MapSR(sr,n)  =          availup_vola_89(t,sr)
*;
*af_wind(t,wr,n)$MapWR(wr,n) =          availup_vola_89(t,wr)
*;
af_res_up(t,rr,n)$Map_RR(rr,n)          =      availup_vola_89(t,rr)
;
delta_af_res(t,rr,n)$Map_RR(rr,n)       =     (af_res_up(t,rr,n) - Df_factor)$(af_res_up(t,rr,n) gt Df_factor)
;

$ontext
$offtext

**************************1990
%cf_1990%$ontext

af_hydro(t,hr,n)$MapHR(hr,n)=          availup_hydro(t,hr)
;
*af_sun(t,sr,n)$MapSR(sr,n)  =          availup_vola_90(t,sr)
*;
*af_wind(t,wr,n)$MapWR(wr,n) =          availup_vola_90(t,wr)
*;
af_res_up(t,rr,n)$Map_RR(rr,n)          =     availup_vola_90(t,rr)
;
delta_af_res(t,rr,n)$Map_RR(rr,n)       =     (af_res_up(t,rr,n) - Df_factor)$(af_res_up(t,rr,n) gt Df_factor)
;
$ontext
$offtext

**************************2010
%cf_2010%$ontext

af_hydro(t,hr,n)$MapHR(hr,n)=          availup_hydro(t,hr)
;
*af_sun(t,sr,n)$MapSR(sr,n)  =          availup_vola_10(t,sr)
*;
*af_wind(t,wr,n)$MapWR(wr,n) =          availup_vola_10(t,wr)
*;
af_res_up(t,rr,n)$Map_RR(rr,n)          =     availup_vola_10(t,rr)
;
delta_af_res(t,rr,n)$Map_RR(rr,n)       =     (af_res_up(t,rr,n) - Df_factor)$(af_res_up(t,rr,n) gt Df_factor)
;
$ontext
$offtext

**************************2012
%cf_2012%$ontext

af_hydro(t,hr,n)$MapHR(hr,n)=          availup_hydro(t,hr)
;
*af_sun(t,sr,n)$MapSR(sr,n)  =          availup_vola_12(t,sr)
*;
*af_wind(t,wr,n)$MapWR(wr,n) =          availup_vola_12(t,wr)
*;
af_res_up(t,rr,n)$Map_RR(rr,n)          =     availup_vola_12(t,rr)
;
delta_af_res(t,rr,n)$Map_RR(rr,n)       =     (af_res_up(t,rr,n) - Df_factor)$(af_res_up(t,rr,n) gt Df_factor)
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








*************************************Renewable Uncertainty budgets - approach

Budget_N(DF,rr,n)                        = sum((t)$Map_DF(t,DF), af_res_up(t,rr,n))
;              
Budget_Delta(DF,rr,n)                    = sum((t)$Map_DF(t,DF), delta_af_res(t,rr,n))
;
Budget_DF(DF,rr,n)                       = Budget_N(DF,rr,n) - Budget_Delta(DF,rr,n)
;
Ratio_N(t,DF,rr,n)$(MAP_DF(t,DF) and Map_RR(rr,n) and (Budget_N(DF,rr,n) gt 0))     = af_res_up(t,rr,n)/(Budget_N(DF,rr,n))
;

Ratio_DF(t,DF,rr,n)$(MAP_DF(t,DF) and Map_RR(rr,n) and (af_res_up(t,rr,n) = 0 ))    = 0
;
Ratio_DF(t,DF,rr,n)$(MAP_DF(t,DF) and Map_RR(rr,n) and (Budget_N(DF,rr,n) gt 0) and (Budget_Delta(DF,rr,n) gt 0 ))    = delta_af_res(t,rr,n) / Budget_Delta(DF,rr,n)
;














