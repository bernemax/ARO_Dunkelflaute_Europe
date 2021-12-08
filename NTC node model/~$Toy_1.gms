Sets

n /DE,DK,SE,PL,CZ,AT,CH,FR,BE,NL,
   NO,GB,IT,SP,PT/
g /g1*g20/
s /s1*s20/
NTC/ntc1*ntc100/
t/t1*t8760/
sr/sr1*sr20/
wr/wr1*wr20/

*H(t,it)

****************************thermal************************************************
gas(g)
lig(g)
coal(g)
nuc(g)
oil(g)
waste(g)

****************************renewable***********************************************
wind(g)
sun(g)
biomass(g)

****************************hydro***************************************************
ror(g)
reservoir(g)
psp(g)

****************************mapping*************************************************

MapG(g,n)
MapNTC(NTC,n,nn)

*MapNTC_send(NTC,n)
*MapNTC_res(NTC,n)

MapRes(res,n)
MapSr(n,sr)
MapWr(n,wr)
;

alias (n,nn)
;

Parameters

Country_load                    upload table

Gen_upload                      upload table

priceup                         upload table
availup_hydro                   upload table
availup_res

NTC_up
NTC_cap(ntc)                    max. net transfer capacity 


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
af_sun(t,sr,n)                  capacity factor of solar energy
af_wind(t,wr,n)                 capacity factor of wind energy


**********************************************input Excel table*******************************************************
;

$onecho > TEP.txt
set=MapG                        rng=Mapping!G3:H561                     rdim=2 cDim=0
set=MapS                        rng=Mapping!J3:K177                     rdim=2 cDim=0
set=MapRes                      rng=Mapping!S3:T1027                    rdim=2 cDim=0
set=MapWr                       rng=Mapping!M3:N482                     rdim=2 cDim=0
set=MapSr                       rng=Mapping!P3:Q482                     rdim=2 cDim=0


par=Country_load                rng=Load!A1:C506                        rDim=1 cdim=1
par=Gen_upload                  rng=Generation!A1:L500                  rDim=1 cdim=1
par=priceup                     rng=prices!A1:I8761                     rDim=1 cdim=1
par=availup_hydro               rng=Availability!A2:D8762               rDim=1 cdim=1
par=availup_res                 rng=Availability!E2:DU8762              rDim=1 cdim=1

$offecho

$onUNDF
$call   gdxxrw Data_input.xlsx @TEP.txt
$GDXin  Data_input.gdx
$load   MapG, MapS, MapRes, MapSr, MapWr
$load   Node_Demand,
$load   Gen_upload, priceup
$load   availup_hydro, availup_res
$GDXin
$offUNDF

*####################################subset definitions#############################

        gas(g)      =    Gen_upload(g,'tech')  = 1
;
        oil(g)      =    Gen_upload(g,'tech')  = 2
;
        coal(g)     =    Gen_upload(g,'tech')  = 3
;
        lig(g)      =    Gen_upload(g,'tech')  = 4
;
        nuc(g)      =    Gen_upload(g,'tech')  = 5
;
        waste(g)    =    Gen_upload(g,'tech')  = 6
;

***************************************hydro****************************************

        psp(s)      =    Gen_upload(g,'tech') = 7
;
        reservoir(s)=    Gen_upload(g,'tech') = 8
;
        ror(s)      =    Gen_upload(g,'tech') = 9
;

****************************************res*****************************************

        wind(res)   =    Gen_upload(g,'tech') = 10
;
        sun(res)    =    Gen_upload(g,'tech') = 11
;
        biomass(res)=    Gen_upload(g,'tech') = 12
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

Cap_conv(g)         =          Gen_upload(g,'Gen_cap')
;
Cap_hydro(s)        =          Gen_upload(s,'Gen_cap')
;
Cap_res(res)        =          Gen_upload(res,'Gen_cap')
;
Eff_conv(g)         =          Gen_upload(g,'eff')
;
Eff_hydro(s)        =          Gen_upload(s,'eff')
;
Eff_res(res)        =          Gen_upload(res,'eff')
;
Co2_content(g)      =          Gen_upload(g,'CO2')
;
su_fact(g)          =          Gen_upload(g,'su_fact')
;
depri_costs(g)      =          Gen_upload(g,'depri_costs')
;
fuel_start(g)       =          Gen_upload(g,'fuel_start')
;

************************************availability************************************

af_hydro(ror,t)             =          availup_hydro(t,'ror')
;
af_hydro(psp,t)             =          availup_hydro(t,'psp')
;
af_hydro(reservoir,t)       =          availup_hydro(t,'reservoir')
;
af_sun(t,sr,n)$MapSR(n,sr)  =          availup_res(t,sr)
;
af_wind(t,wr,n)$MapWR(n,wr) =          availup_res(t,wr)
;
*************************************calculating************************************

var_costs(g,t)              =            ((FC_conv(g,t)+ co2_costs(t) * co2_content(g)) / Eff_conv(g))
;
su_costs(g,t)               =            depri_costs(g) + su_fact(g) * fuel_start(g) * FC_conv(g,t) + co2_content(g) * co2_costs(t)
;

execute_unload "check.gdx";
$stop
*************************************upload table clearing**************************

option kill = Node_Demand ;   
option kill = Ger_Demand ; 
option kill = Grid_tech ;
option kill = Gen_conv ;
option kill = Gen_res ;
option kill = Gen_Hydro ;
option kill = priceup ;
option kill = availup_hydro ;
option kill = availup_res ;
option kill = Grid_invest ;

*######################################variables######################################
Variables
Costs
Power_flow(l,t)
Theta(n,t)
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
X_dem(n,t)             variable to prevent model from infeasibility due to increasing el. demand at high costs
;

Binary variables
x(l)                  investment in 220 kV line
y(l)                  investment in 380 kV line
;



Equations
Total_costs
Line_investment
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

Ex_line_angle
Ex_Line_neg_flow
Ex_line_pos_flow


Prosp_line_neg_flow
Prosp_line_pos_flow

Linearization_prosp_220_line_neg
Linearization_prosp_220_line_pos

Linearization_prosp_380_line_neg
Linearization_prosp_380_line_pos

LS_det
Theta_LB
Theta_UB
Theta_ref
;
*#######################################################objective##########################################################

Total_costs..                costs =e=   sum((g,t), Var_costs(g,t) * Gen_g(g,t))
%Start_up%                             + sum((g,t), Su(g,t) *su_costs(g,t))
                                       + sum((res,t), Fc_res(res,t) * Gen_r(res,t))
                                       + sum((n,t), LS_costs(n) * Load_shed(n,t))
                                       + sum((res,t), Curtailment(res,t) * cur_costs)
                                       
%Prosp_exist%                          + sum((n,t), X_dem(n,t))* 350
%Prosp_exist%                          + sum((l,t)$prosp(l),I_costs_220(l)*x(l)+I_costs_380(l)*y(l))
;

Line_investment..            sum((l)$prosp(l), I_costs_380(l)*y(l)
%only_380%                                   + I_costs_220(l)*x(l)
                                                                    )
                                                                    =l= ILmax
;

*####################################################energy balance########################################################

Balance(n,t)$(Relevant_Nodes(n))..                (load(n,t) - Load_shed(n,t))  =e= sum(g$MapG(g,n),Gen_g(g,t))


                                                           + sum(biomass$MapRes(biomass,n),Gen_r(biomass,t))
                                                           + sum(sun$MapRes(sun,n),Gen_r(sun,t))
                                                           + sum(wind$MapRes(wind,n),Gen_r(wind,t))

                                                           + sum(s$MapS(s,n), Gen_s(s,t))
                                                           - sum(l$(Map_send_L(l,n) and exist(l)),Power_flow(l,t))
                                                           + sum(l$(Map_res_L(l,n) and exist(l)),Power_flow(l,t))
*                                                           + sum(l$map_grid(l,n),Power_flow(l,t)$exist(l))
*                                                           

%Prosp_exist%                                              - sum(l$(Map_send_L(l,n) and prosp(l)),Power_flow(l,t))
%Prosp_exist%                                              + sum(l$(Map_res_L(l,n) and prosp(l)),Power_flow(l,t))

                                                           - sum(psp$MapS(psp,n), charge(psp,t))
                                                           

%endotrans%                                                + phy_flow_to_DE(t,n)
                                                           + phy_flow_states_exo(t,n)
*                                                           - X_dem(n,t)
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
Store_level_end(psp,t)$(ord(t) = card(t))..                 storagelvl(psp,t) =e= cap_hydro(psp) *0.5 
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

*##########################################################Grid###########################################################



Ex_line_angle(l,t)$exist(l)..                               power_flow(l,t) + EPS =e=  (B(l)*(sum(n$Map_send_L(l,n), Theta(n,t))-sum(n$Map_res_L(l,n), Theta(n,t))))* MVABase
;
*Ex_line_angle(l,t)$exist(l)..                               power_flow(l,t) + EPS =e=  (B(l)*(sum(n$Map_Grid(l,n), Theta(n,t) -Theta)nn,t)* MVABase
*;
*Ex_line_angle(l,t)$exist(l)..                               power_flow(l,t) =e=  sum(n$H(l,n), H(l,n)*(Theta(n,t)$Map_send_L(l,n) - Theta(n,t)$Map_res_L(l,n))) *500
*;
Ex_line_neg_flow(l,t)$exist(l)..                            power_flow(l,t) + EPS =g= -L_cap(l)*circuits(l)*reliability
;
Ex_line_pos_flow(l,t)$exist(l)..                            power_flow(l,t) + EPS =l=  L_cap(l)*circuits(l)*reliability
;

Prosp_line_neg_flow(l,t)$prosp(l)..                         power_flow(l,t) + EPS =g= (- y(l) * L_cap_inv_380(l)
%only_380%                                                                             - x(l) * L_cap_inv_220(l)
                                                                                                                ) * reliability
;
Prosp_line_pos_flow(l,t)$prosp(l)..                         power_flow(l,t) + EPS =l= (  y(l) * L_cap_inv_380(l)
%only_380%                                                                             + x(l) * L_cap_inv_220(l) 
                                                                                                                ) * reliability
;
Linearization_prosp_220_line_neg(l,t)$prosp(l)..            -(1-x(l))*M   =l= power_flow(l,t) - B_prosp_220(l) * (sum(n$Map_send_L(l,n),Theta(n,t))-sum(n$Map_res_l(l,n),Theta(n,t))) * MVABase  + EPS
;
Linearization_prosp_220_line_pos(l,t)$prosp(l)..            (1-x(l))*M    =g= power_flow(l,t) - B_prosp_220(l) * (sum(n$Map_send_L(l,n),Theta(n,t))-sum(n$Map_res_l(l,n),Theta(n,t))) * MVABase  + EPS
;
Linearization_prosp_380_line_neg(l,t)$prosp(l)..            -(1-y(l))*M   =l= power_flow(l,t) - B_prosp_380(l) * (sum(n$Map_send_L(l,n),Theta(n,t))-sum(n$Map_res_l(l,n),Theta(n,t))) * MVABase  + EPS
;
Linearization_prosp_380_line_pos(l,t)$prosp(l)..            (1-y(l))*M    =g= power_flow(l,t) - B_prosp_380(l) * (sum(n$Map_send_L(l,n),Theta(n,t))-sum(n$Map_res_l(l,n),Theta(n,t))) * MVABase  + EPS
;

LS_det(n,t)..                                               load_shed(n,t)  =l= load(n,t)
;
Theta_LB(n,t)..                                             -3.1415         =l= Theta(n,t)
;
Theta_UB(n,t)..                                             3.1415          =g= Theta(n,t)
;
Theta_ref(n,t)..                                            Theta(n,t)$ref(n) =l= 0
;
*execute_unload "check.gdx";
*$stop
*#########################################################Solving##########################################################

Model Large_Stat_det_Tep
/
Total_costs
%Prosp_exist%Line_investment
Balance

max_gen
max_cap
%Start_up%startup_constr

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

Ex_line_angle
Ex_Line_neg_flow
Ex_line_pos_flow


%Prosp_exist%Prosp_line_neg_flow
%Prosp_exist%Prosp_line_pos_flow

%only_380%%Prosp_exist%Linearization_prosp_220_line_neg
%only_380%%Prosp_exist%Linearization_prosp_220_line_pos

%Prosp_exist%Linearization_prosp_380_line_neg
%Prosp_exist%Linearization_prosp_380_line_pos


LS_det
Theta_LB
Theta_UB
Theta_ref

/;