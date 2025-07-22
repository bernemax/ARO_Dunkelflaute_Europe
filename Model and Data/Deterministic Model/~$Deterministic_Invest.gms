* shows the computational time needed by each prcess until 1 sec.
option profile = 1;
option profiletol = 0.01;

$setGlobal bat ""      if "*" no battery in the model, if "" otherwise
$setGlobal hydrogen ""      if "*" no hydrogen in the model, if "" otherwise
;

Sets

t/t1*t2190/

*$ontext
n /DE0,DE1,DE2,DE3,DE4,DE5,DE6,AT0,BE0,CH0,CZ0
,DK0,DK1,EE0,ES0,ES1,ES2,ES3,FI0,FR0,FR1,
FR2,FR3,FR4,FR5,FR6,GB0,GB1,GB2,GB3,GB4,GB5,
HU0,IE0,IT0,IT1,IT2,IT3,IT4,LT0,LU0,LV0,NL0,
NO0,PL0,PT0,SE0,SE1,SI0,SK0
/
*$offtext
l /l1*l97/
g  /
*nuclear
g3,g8,g11,g16,g22,g29,g35,g41,g48,g53,g60,g64,g68,g71,
g76,g81,g85,g90,g95,g98,g101,g105,g109,g111,g113,g117,
g121,g125,g129,g133,g137,g140,g146,g151,g155,g160,g163,
g167,g169,g172,g178,g180,g183,g187,g191

*Biomass
g6,g10,g13,g19,g26,g32,g39,g45,g51,g56,g62,g67,g93,g97,
g100,g103,g107,g110,g112,g116,g120,g124,g127,g132,g135,
g142,g149,g168

/
*g158

*/g1*g172/
b /b1*b50/
h /h1*h50/
OCGT /OCGT1*OCGT50/


s /s1,s2,s3,s5,s7,s8,s9,s11,s12,s14,s16,s17,
s18,s19,s20,s21,s22,s23,s25,s28,s29,s30,s31,
s32,s33,s34,s35,s36,s37,s38,s39,s40,s41,s42,
s43,s44,s45,s46,s47,s48,s49,s50,s51,s52,s55,
s56,s58,s59,s60,s61,s62,s63,s64,s65,s66,s67,
s68,s69,s71,s72,s73,s74,s76,s77,s78,s79,s80,
s81,s82,s83,s84,s85,s86,s87,s88,s89,s91,s92,
s93,s94,s95,s96,s97/

Ren/ren1*ren125/
rr/rr1*rr6/
WM/WM1*WM12/

****************************nodes***************************************************
ref(n)
/DE0/

DE_nodes(n)
/DE0,DE1,DE2,DE3,DE4,DE5,DE6/

****************************lines***************************************************
ex_l(l)/l1*l97/
*pros_l(l)/l1001*l1097/
pros_l_rr1_rr6(l) /l90,l91,l97,l84,l86,l87,l96,l38/
pros_l_rr2_rr3(l) /l80/
pros_l_rr2_rr6(l) /l79/
pros_l_rr3_rr4(l) /l77,l44,l45/
pros_l_rr3_rr5(l) /l15,l16,l58,l1/
pros_l_rr3_rr6(l) /l11,l12,l31,l34,l78/
pros_l_rr5_rr6(l) /l2,l3,l4,l65/
Dc_l(l) /l75,l76,l77,l78,l79,l80,l81,l82,l83,l84,l85,
l86,l87,l88,l89,l90,l91,l92,l93,l94,l95,l97/ 
AC_l(l)

****************************thermal************************************************
*OCGT(g)
CCGT(g)
nuc(g)
lig(g)
coal(g)
oil(g)
waste(g)
biomass(g)

DE_conv(g) /g19,g22,g26,g29,g32,g35,g39,g41,g45,g48,g51,g53,g56,g60/

****************************volatil renewables**************************************
wind(ren)
wind_on(ren)
wind_off(ren)
solar_pv(ren)

DE_ren(ren) /ren10,ren11,ren12,ren13,ren14,ren15,ren16,ren17,ren18,ren19,
         ren20,ren21,ren22,ren23,ren24,ren25/

****************************hydro***************************************************
ror(s)
reservoir(s)
psp(s)

DE_Hydro(s) /s14,s16,s17,s18,s19,s20,s21,s22,s23,s25/


***************************battery**************************************************

DE_batt(b)/b5,b6,b7,b8,b9,b10,b11/

****************************hydrogen************************************************

DE_H2(h) /h5,h6,h7,h8,h9,h10,h11/

*****************************mapping************************************************
Map_send_L(l,n)
Map_res_L(l,n)
Map_rr_send_l(l,rr)
Map_rr_res_l(l,rr)
Map_grid(l,n)

MapG(g,n)
Map_OCGT(OCGT,n)
Map_CCGT(g,n)
Map_Biomass(g,n)
Map_Nuclear(g,n)

MapS(s,n)
Map_Ren_node(ren,n)
Map_PV(ren,n)
Map_wind(ren,n)
Map_Offwind(ren,n)
Map_Onwind(ren,n)

Map_Battery(b,n)
Map_hydrogen(h,n)

MAP_WM(t,WM)

Map_RR(rr,n)
MAP_RR_G(rr,g)
MAP_RR_OCGT(rr,h)
MAP_RR_B(rr,b)    
Map_RR_ren(rr,ren)
MAP_RR_RoR(rr,s)
MAP_RR_reservoir(rr,s)
MAP_RR_PsP(rr,s)

MAP_RR_Ren_node(rr,ren,n)
Map_RR_ren(rr,ren)
;
alias (n,nn),(t,tt),(l,ll), (rr,rrrr)
;

$include Loading_deterministic_paper.gms
*execute_unload "check_input_new.gdx";
*$stop

*######################################variables######################################

Variables
*********************************************Master*************************************************
O_M                         Objective var of Master Problem (total costs)
PF_M(l,t)                 power flows derived from DC load flow equation
Theta(t,n)                Angle of each node associated with DC power flow equations
PSP_operation(s,t)
Battery_operation(b,t)
H2Stor_operation(h,t)

positive Variables
*********************************************MASTER*************************************************

ETA                         aux var to reconstruct obj. function of the ARO problem
PG_M_conv(g,t)            power generation level of conventional generators
PG_M_Ren(ren,t)           cummulative power generation level of renewable solar pv and wind generators
Curtailment(ren,t)

PG_M_PV(ren,t)            cummulative power generation level of renewable solar pv generators
PG_M_Wind(ren,t)          cummulative power generation level of renewable wind generators

PLS_M_1(t,n)                load shedding
PLS_M_2(t,n)
PLS_M_3(t,n)

L_Cap_exp(l)              line capacity expansion

PG_M_Hydro(s,t)           power generation from hydro reservoir and psp and ror
M_Stor_lvl(s,t)
M_charge(s,t)

PG_M_battery(b,t)
M_battery_lvl(b,t)
M_battery_charge(b,t)

PG_M_hydrogen(h,t)
M_hydrogen_lvl(h,t)
M_hydrogen_charge(h,t)

Cap_conv_M(g)
Cap_ren_M(ren)
Cap_battery_M(b)
Cap_hydrogen_M(h)
Cap_OCGT_M(h)
;

Equations
*********************************************Master**************************************************
MP_Objective
MP_marketclear

MP_PG_RR
MP_PG_PV
MP_PG_Wind

MP_PG_conv
MP_PG_ROR
MP_PG_Reservoir

MP_PG_Stor
MP_C_Stor
MP_Cap_Stor
MP_Stor_lvl_start
MP_Stor_lvl

MP_PG_battery
MP_C_battery
MP_Cap_battery
MP_battery_lvl_start
MP_battery_lvl

MP_PG_hydrogen
MP_C_hydrogen
MP_Cap_hydrogen
MP_hydrogen_lvl_start
MP_hydrogen_lvl

MP_PF_EX
Test
MP_PF_EX_Cap_UB
MP_PF_EX_Cap_LB

MP_LS_1
MP_LS_2
MP_LS_3

Theta_UB
Theta_LB
Theta_ref
MP_ETA

;
*#####################################################################################Master####################################################################################

MP_Objective  ..                                                                              O_M  =e= sum((ren), Cap_ren_M(ren) * IC_ren(ren) * df)
                                                                                                        + sum((g),(Cap_conv_ex(g)) * FOM_conv(g) * df)
                                                                                                        + sum((s), Cap_hydro(s) * FOM_hydro(s))
                                                                                                        + sum((b), ((Cap_battery_M(b) * 6)  * IC_bs(b)  * df)
                                                                                                        +           (Cap_battery_M(b) * IC_bi(b) * df))
                                                                                                                    
                                                                                                        + sum((h), ((Cap_hydrogen_M(h) * 168) * IC_hs(h) * df)
                                                                                                        +           (Cap_hydrogen_M(h) * IC_hel(h) * df)
                                                                                                        +           (Cap_OCGT_M(h) * IC_hOCGT(h)* df)
                                                                                                                                                        )
                                                                                                        
                                                                                                        + sum(l, L_Cap_exp(l) * IC_Line(l))
                                                                                                        + ETA
;


*********************************************************************************Balancing constraint************************************************************************************

MP_marketclear(t,n)..
                                                                                                Demand_data_fixed(t,n)
                                                                                                - PLS_M_1(t,n) - PLS_M_2(t,n)  - PLS_M_3(t,n)
                                                                                              
                                                                                                =e= sum((g)$MapG(g,n), PG_M_conv(g,t))
                                                                                                + sum((ren)$Map_PV(ren,n), PG_M_PV(ren,t))
                                                                                                + sum((ren)$Map_Wind(ren,n), PG_M_Wind(ren,t))

                                                                                                + sum((ror)$MapS(ror,n),  PG_M_Hydro(ror,t))
                                                                                                + sum((reservoir)$MapS(reservoir,n),  PG_M_Hydro(reservoir,t))
                                                                                                + sum((psp)$MapS(psp,n), PG_M_Hydro(psp,t)
                                                                                                -                        M_charge(psp,t))
                                                                                                
%bat%                                                                                           + sum((b)$Map_battery(b,n), PG_M_battery(b,t)
%bat%                                                                                           -                       M_battery_charge(b,t))

%hydrogen%                                                                                      + sum((h)$Map_hydrogen(h,n),
%hydrogen%                                                                                                                PG_M_hydrogen(h,t)
%hydrogen%                                                                                      -                       M_hydrogen_charge(h,t))      

                                                                                                +  sum(l, PF_M(l,t)$Map_Res_l(l,n) 
                                                                                                -                 PF_M(l,t)$Map_Send_l(l,n))

;
*********************************************************************************Volatil Generation**************************************************************************************

MP_PG_RR(ren,t,rr,n)$(MAP_RR_Ren_node(rr,ren,n))..                    PG_M_Ren(ren,t)       =e= Cap_ren_M(ren) * AF_M_Ren_fixed(t,rr,n) - Curtailment(ren,t)
;
MP_PG_PV(ren,rr,t)$(MAP_RR_Ren(rr,ren) and solar_pv(ren))..           PG_M_PV(ren,t)        =e=  + Cap_ren_M(ren) * AF_M_PV_fixed(ren,rr,t) - Curtailment(ren,t)
;
MP_PG_Wind(ren,rr,t)$(MAP_RR_Ren(rr,ren) and wind(ren))..             PG_M_Wind(ren,t)      =e= +  Cap_ren_M(ren) * AF_M_Wind_fixed(ren,rr,t) - Curtailment(ren,t)
;

*********************************************************************************Dispatchable Generation*********************************************************************************

MP_PG_conv(g,t)..                                                     PG_M_conv(g,t)        =l= Cap_conv_ex(g) + Cap_conv_M(g)$nuc(g)
;
MP_PG_ROR(ror,t)..                                                    PG_M_Hydro(ror,t)     =l= Cap_hydro(ror)  * af_hydro(t,ror)
;
MP_PG_Reservoir(reservoir,t)..                                        PG_M_Hydro(reservoir,t) =l= Cap_hydro(reservoir) * af_hydro(t,reservoir) 
;

*********************************************************************************Hydro Storage Generation********************************************************************************

MP_PG_Stor(psp,t)..                                                   PG_M_Hydro(psp,t)        =l= Cap_hydro(psp) 
;
MP_C_Stor(psp,t)..                                                    M_charge(psp,t)          =l= Cap_hydro(psp) 
;
MP_Cap_Stor(psp,t)..                                                  M_Stor_lvl(psp,t)        =l= (Cap_hydro(psp) * psp_cpf) / scale
;
MP_Stor_lvl_start(psp,t)$(ord(t) = 1)..                               M_Stor_lvl(psp,t)        =e= ((Cap_hydro(psp) * psp_cpf)/ scale)/2 + M_charge(psp,t) * eff_PSP  -  PG_M_Hydro(psp,t) 
;
MP_Stor_lvl(psp,t)$(ord(t) gt 1)..                                    M_Stor_lvl(psp,t)        =e= M_Stor_lvl(psp,t-1) + M_charge(psp,t) * eff_PSP  -  PG_M_Hydro(psp,t) 
;

*********************************************************************************Battery********************************************************************************


MP_PG_Battery(b,t)..                                                  PG_M_battery(b,t)         =l= Cap_battery_M(b) 
;
MP_C_Battery(b,t)..                                                   M_Battery_charge(b,t)     =l= Cap_battery_M(b) 
;
MP_Cap_Battery(b,t)..                                                 M_Battery_lvl(b,t)        =l= (Cap_battery_M(b) *6) / scale
;

MP_Battery_lvl_start(b)..                                             M_Battery_lvl(b,'t1')       =e= 0 + M_Battery_charge(b,'t1') * eff_Battery  - PG_M_Battery(b,'t1') 
;
MP_Battery_lvl(b,t)$(ord(t) gt 1)..                                   M_Battery_lvl(b,t)        =e= M_Battery_lvl(b,t-1) + M_Battery_charge(b,t) * eff_Battery  -  PG_M_Battery(b,t) 
;


*********************************************************************************hydrogen********************************************************************************

MP_PG_hydrogen(h,t)..                                                 PG_M_hydrogen(h,t)      =l= Cap_OCGT_M(h) 
;
MP_C_hydrogen(h,t)..                                                  M_hydrogen_charge(h,t)    =l= Cap_hydrogen_M(h) 
;
MP_Cap_hydrogen(h,t)..                                                M_hydrogen_lvl(h,t)        =l= (Cap_hydrogen_M(h) * 168)/ scale
;
MP_hydrogen_lvl_start(h)..                                            M_hydrogen_lvl(h,'t1')       =e= 0 +   M_hydrogen_charge(h,'t1') * eff_EL  - PG_M_hydrogen(h,'t1') * 1/eff_OCGT
;
MP_hydrogen_lvl(h,t)$(ord(t) gt 1)..                                  M_hydrogen_lvl(h,t)        =e=  M_hydrogen_lvl(h,t-1) +   M_hydrogen_charge(h,t) * eff_EL   -   PG_M_hydrogen(h,t) * 1/eff_OCGT
;

*********************************************************************************Linearized Power flow lines***********************************************************************************

MP_PF_EX(l,t)$AC_l(l)..                                               PF_M(l,t) =e= B_sus(l)  *  sum(n,  Theta(t,n)$Map_Send_l(l,n) - Theta(t,n)$Map_Res_l(l,n)) * MVAbase
;
MP_PF_EX_Cap_UB(l,t)..                                                PF_M(l,t) =l= L_cap(l) + L_Cap_exp(l)
;
MP_PF_EX_Cap_LB(l,t)..                                                PF_M(l,t) =g= - (L_cap(l) + L_Cap_exp(l))
;



Theta_UB(t,n)..                                                       3.1415          =g= Theta(t,n)
;
Theta_LB(t,n)..                                                       - 3.1415         =l= Theta(t,n)
;
Theta_ref(t,n)..                                                      Theta(t,n)$ref(n)      =e= 0
;


*********************************************************************************Load shedding*******************************************************************************************

MP_LS_1(t,n)..                                                          PLS_M_1(t,n)  =l= Demand_data_fixed(t,n) * 0.05
;
MP_LS_2(t,n)..                                                          PLS_M_2(t,n)  =l= Demand_data_fixed(t,n) * 0.15
;
MP_LS_3(t,n)..                                                          PLS_M_3(t,n)  =l= Demand_data_fixed(t,n) * 0.8
;

*********************************************************************************Iterative Objective function****************************************************************************


MP_ETA..                                                               ETA =g=   sum((g,t), var_costs(g) * PG_M_conv(g,t))                                                                                          
                                                                               + sum((t,n),  PLS_M_1(t,n) * LS_costs_1 + PLS_M_2(t,n) * LS_costs_2 + PLS_M_3(t,n) * LS_costs_3) 

;


model Master
/
MP_Objective
MP_marketclear

*MP_PG_RR
MP_PG_PV
MP_PG_Wind

MP_PG_conv
MP_PG_ROR
MP_PG_Reservoir

MP_PG_Stor
MP_C_Stor
MP_Cap_Stor
MP_Stor_lvl_start
MP_Stor_lvl

%bat%MP_PG_battery
%bat%MP_C_battery
%bat%MP_Cap_battery
%bat%MP_battery_lvl_start
%bat%MP_battery_lvl

%hydrogen%MP_PG_hydrogen
%hydrogen%MP_C_hydrogen
%hydrogen%MP_Cap_hydrogen
%hydrogen%MP_hydrogen_lvl_start
%hydrogen%MP_hydrogen_lvl

MP_PF_EX
MP_PF_EX_Cap_UB
MP_PF_EX_Cap_LB

MP_LS_1
MP_LS_2
MP_LS_3
*Theta_UB
*Theta_LB
Theta_ref
MP_ETA
/
;
Master.scaleopt = 1
;
*solve Master using MIP minimizing O_M;
*execute_unload "check_Master.gdx";
*$stop

option threads =  -1
;
option optcr = 0
;

*Fixing nuclear capacity
Cap_conv_M.fx(g)  = 0
;
Demand_data_fixed(t,n) = load(t,n)
;
AF_M_PV_fixed(ren,rr,t)  = af_PV(ren,t)
;
AF_M_Wind_fixed(ren,rr,t)  = af_Wind(ren,t)
;
L_Cap_exp.up(l)  = L_cap(l) 
;
Cap_ren_M.up(ren) = 300
;
L_Cap_exp.up(l)$Dc_l(l)  = 1
;


option LP = Gurobi
;
solve Master using LP minimizing O_M
;
inv_cost_master = sum(ren, Cap_ren_M.l(ren) * IC_ren(ren)* df)
                    + sum((g), Cap_conv_ex(g) * FOM_conv(g))
                    + sum((b), ((Cap_battery_M.l(b) * 6))  * (IC_bs(b))* df)
                    + sum((b), Cap_battery_M.l(b) * IC_bi(b) * df)
                    + sum((h),  ((Cap_hydrogen_M.l(h)* 168))* (IC_hs(h)) * df)
                    + sum((h), Cap_hydrogen_M.l(h) * IC_hel(h) * df)
                    + sum((h), Cap_hydrogen_M.l(h) * IC_hOCGT(h) * df)
    
;

Parameter
Saldo_PSP(*)
Saldo_PSP_region(t,rr)
Gen_PSP(*)
Gen_PSP_region(t,rr)
Saldo_battery(*)
Saldo_battery_region(t,rr)
Gen_battery(*)
Gen_battery_region(t,rr)
Saldo_Hydrogen(*)
Saldo_Hydrogen_region(t,rr) 
Gen_Hydrogen(*)
Gen_Hydrogen_region(t,rr) 
Report_cap_final(n,*,*)
Report_Invcost_ren(ren,*)
Report_Invcost_battery(b,*)
Report_Invcost_hydrogen(h,*)
Report_Invcost(*)
Report_FOM(*)
Report_total_Gen(*)
Report_total_Gen_cap(*)
Report_total_Gen_country(*)
Report_Gen_share(*)
Report_Gen_share_country(*,*)
Report_LS_costs
Report_line_exp(l)
Report_Balance_Flow_regions(rr)
Report_total_Flow_regions(*,*)
Report_Expansion_regions(*,*)
Report_gen_tech(*,t)
Report_Curtailment_share(*)
Report_average_nodal_price(n)
Report_gen_Region(*,*)


;
Report_average_nodal_price(n) = (sum(t, MP_marketclear.m(t,n))/ 2190) * (-1)
;
Report_cap_final(n,g,'Nuclear') = (Cap_conv_ex(g) + Cap_conv_M.l(g))$Map_Nuclear(g,n)
;
Report_cap_final(n,g,'Biomass') = Cap_conv_ex(g)$Map_Biomass(g,n)
;
Report_cap_final(n,ren,'On_Wind') =Cap_ren_M.l(ren)$Map_Onwind(ren,n)
;
Report_cap_final(n,ren,'Off_Wind') = Cap_ren_M.l(ren)$Map_Offwind(ren,n)
;
Report_cap_final(n,ren,'PV') = Cap_ren_M.l(ren)$Map_PV(ren,n)
;
Report_cap_final(n,b,'battery storage') = (Cap_battery_M.l(b) * 6)$Map_Battery(b,n)
;
Report_cap_final(n,b,'battery inverter') = (Cap_battery_M.l(b))$Map_Battery(b,n)
;
Report_cap_final(n,h,'hydrogen storage') = (Cap_hydrogen_M.l(h) * 168)$Map_hydrogen(h,n)
;
Report_cap_final(n,h,'Electrolysis') = (Cap_hydrogen_M.l(h))$Map_hydrogen(h,n)
;
Report_cap_final(n,h,'OCGT') = (Cap_OCGT_M.l(h))$Map_hydrogen(h,n)
;
Report_line_exp(l) = L_Cap_exp.l(l)
;


Report_total_Gen_cap('Nuclear') =  sum(g$nuc(g),Cap_conv_ex(g))
;
Report_total_Gen_cap('Biomass') = sum(g$biomass(g),Cap_conv_ex(g))
;
Report_total_Gen_cap('On_Wind') =  sum(ren$wind_on(ren), Cap_ren_M.l(ren))
;
Report_total_Gen_cap('Off_Wind') = sum(ren$wind_off(ren), Cap_ren_M.l(ren))
;
Report_total_Gen_cap('PV') =    sum(ren$solar_pv(ren), Cap_ren_M.l(ren))
;
Report_total_Gen_cap('battery storage') = sum(b,Cap_battery_M.l(b) * 6 )
;
Report_total_Gen_cap('battery inverter') = sum(b, Cap_battery_M.l(b))
;
Report_total_Gen_cap('hydrogen storage') = sum(h,Cap_hydrogen_M.l(h) * 168 )
;
Report_total_Gen_cap('Electrolysis') = sum(h,Cap_hydrogen_M.l(h) )
;
Report_total_Gen_cap('OCGT') = sum(h,Cap_OCGT_M.l(h) )
;
Report_total_Gen_cap('ROR') =  sum(ror,Cap_hydro(ror))
;
Report_total_Gen_cap('PSP') = sum(psp, Cap_hydro(psp))
;
Report_total_Gen_cap('Reservoir') =  sum(reservoir, Cap_hydro(reservoir))
;

Report_FOM('Nuclear') = sum(g$nuc(g),Cap_conv_ex(g) * FOM_conv(g))
;
Report_FOM('Biomass') = sum(g$Biomass(g),Cap_conv_ex(g) * FOM_conv(g))
;
Report_FOM('On_Wind') = sum(ren$wind_on(ren), Cap_ren_M.l(ren) * FOM_ren(ren))
;
Report_FOM('Off_Wind') = sum(ren$wind_off(ren), Cap_ren_M.l(ren) * FOM_ren(ren))
;
Report_FOM('PV') = sum(ren$solar_pv(ren), Cap_ren_M.l(ren) * FOM_ren(ren))
;
Report_FOM('battery storage') =  sum(b,Cap_battery_M.l(b) * 6 * FOM_bs(b) )
;
Report_FOM('battery inverter') = sum(b,Cap_battery_M.l(b) * FOM_bi(b) )
;
Report_FOM('hydrogen storage') =sum(h,Cap_hydrogen_M.l(h) * 168 * FOM_Hst(h) )
;
Report_FOM('Electrolysis') = sum(h,Cap_hydrogen_M.l(h) * FOM_Hel(h) )
;
Report_FOM('OCGT') = sum(h,Cap_OCGT_M.l(h) * FOM_OCGT(h))
;
Report_FOM('ROR') = sum(ror,Cap_hydro(ror) * FOM_hydro(ror) )
;
Report_FOM('PSP') = sum(psp, Cap_hydro(psp) * FOM_hydro(psp) )
;
Report_FOM('Reservoir') = sum(reservoir, Cap_hydro(reservoir) * FOM_hydro(reservoir))
;

Report_Invcost_ren(ren,'On_Wind') = sum(n, Report_cap_final(n,ren,'On_Wind')) * IC_ren(ren)$wind_on(ren) * 1000000
;
Report_Invcost_ren(ren,'Off_Wind') = sum(n, Report_cap_final(n,ren,'Off_Wind')) * IC_ren(ren)$wind_off(ren) * 1000000
;
Report_Invcost_ren(ren,'PV') = sum(n, Report_cap_final(n,ren,'PV')) * IC_ren(ren)$solar_pv(ren) * 1000000
;
Report_Invcost_battery(b,'battery storage') = sum(n, Report_cap_final(n,b,'battery storage')) * IC_bs(b) * 1000000
;
Report_Invcost_battery(b,'battery inverter') = sum(n, Report_cap_final(n,b,'battery inverter')) * IC_bi(b) * 1000000
;
Report_Invcost_hydrogen(h,'OCGT') = sum(n,Report_cap_final(n,h,'OCGT')) * IC_hOCGT(h) * 1000000
;
Report_Invcost_hydrogen(h,'hydrogen storage') = sum(n,Report_cap_final(n,h,'hydrogen storage')) * IC_hs(h) * 1000000
;
Report_Invcost_hydrogen(h,'Electrolysis') = sum(n,Report_cap_final(n,h,'Electrolysis')) * IC_hel(h) * 1000000
;

Report_Invcost('Nuclear') = sum(g$nuc(g), Cap_conv_M.l(g) * IC_conv(g) * 1000000)
;
Report_Invcost('On_Wind') = sum(ren, Report_Invcost_ren(ren,'On_Wind'))
;
Report_Invcost('Off_Wind') = sum(ren, Report_Invcost_ren(ren,'Off_Wind'))
;
Report_Invcost('PV') = sum(ren, Report_Invcost_ren(ren,'PV'))
;
Report_Invcost('battery storage') = sum(b, Report_Invcost_battery(b,'battery storage'))
;
Report_Invcost('battery inverter') =  sum(b, Report_Invcost_battery(b,'battery inverter'))
;
Report_Invcost('OCGT') = sum(h, Report_Invcost_hydrogen(h,'OCGT'))
;
Report_Invcost('hydrogen storage') = sum(h, Report_Invcost_hydrogen(h,'hydrogen storage'))
;
Report_Invcost('Electrolysis') = sum(h, Report_Invcost_hydrogen(h,'Electrolysis'))
;
Report_Invcost('line') = sum(l, Report_line_exp(l) * IC_Line(l)) * 1000000
;

Saldo_PSP(t) = sum(psp, PG_M_Hydro.l(psp,t)) - sum(psp, M_charge.l(psp,t))
;
Saldo_PSP_region(t,rr) = sum(psp$MAP_RR_PsP(rr,psp), PG_M_Hydro.l(psp,t)) - sum(psp$MAP_RR_PsP(rr,psp), M_charge.l(psp,t))
;
Gen_PSP(t) = Saldo_PSP(t)$(Saldo_PSP(t) gt 0)
;
Gen_PSP_region(t,rr) = Saldo_PSP_region(t,rr)$(Saldo_PSP_region(t,rr) gt 0)
;


Saldo_battery(t) = sum((b), PG_M_battery.l(b,t)) - sum(b, M_Battery_charge.l(b,t))
;
Saldo_battery_region(t,rr) = sum((b)$MAP_RR_B(rr,b), PG_M_battery.l(b,t)) - sum(b$MAP_RR_B(rr,b), M_Battery_charge.l(b,t))
;
Gen_battery(t) = Saldo_battery(t)$(Saldo_battery(t) gt 0)
;
Gen_battery_region(t,rr) = Saldo_battery_region(t,rr)$(Saldo_battery_region(t,rr) gt 0)
;


Saldo_Hydrogen(t) = sum(h,  PG_M_hydrogen.l(h,t)) - sum(h, M_hydrogen_charge.l(h,t) )
;
Saldo_Hydrogen_region(t,rr) = sum(h$MAP_RR_OCGT(rr,h),  PG_M_hydrogen.l(h,t)) - sum(h$MAP_RR_OCGT(rr,h), M_hydrogen_charge.l(h,t))
;
Gen_Hydrogen(t) = Saldo_Hydrogen(t)$(Saldo_Hydrogen(t) gt 0)
;
Gen_Hydrogen_region(t,rr)= Saldo_Hydrogen_region(t,rr)$(Saldo_Hydrogen_region(t,rr) gt 0)
;


Report_total_Gen('TWh') =  sum((g,t), PG_M_conv.l(g,t))
                  + sum((ren,t), PG_M_PV.l(ren,t))
                  + sum((ren,t), PG_M_Wind.l(ren,t))
                  + sum((ror,t), PG_M_Hydro.l(ror,t))
                  + sum((reservoir,t), PG_M_Hydro.l(reservoir,t))
                  + sum(t, Gen_PSP(t))
                  + sum((t),   Gen_battery(t))
                  + sum((t),   Gen_Hydrogen(t))
                  + sum((n,t), PLS_M_1.l(t,n))
                  + sum((n,t), PLS_M_2.l(t,n))
                  + sum((n,t), PLS_M_3.l(t,n))

;

Report_gen_tech('Nuclear',t) = sum((g)$nuc(g), PG_M_conv.l(g,t))
;
Report_gen_tech('Biomass',t) = sum((g)$biomass(g), PG_M_conv.l(g,t))
;
Report_gen_tech('On_Wind',t) = sum((ren)$wind_on(ren), PG_M_Wind.l(ren,t))
;
Report_gen_tech('Off_Wind',t) =  sum((ren)$wind_off(ren), PG_M_Wind.l(ren,t))
;
Report_gen_tech('PV',t)      = sum((ren)$solar_pv(ren), PG_M_PV.l(ren,t))
;
Report_gen_tech('OCGT',t)    = Gen_Hydrogen(t)
;
Report_gen_tech('Battery',t) = Gen_battery(t)
;
Report_gen_tech('ROR',t)     = sum((ror), PG_M_Hydro.l(ror,t))
;
Report_gen_tech('Reservoir',t) = sum((reservoir), PG_M_Hydro.l(reservoir,t))
;
Report_gen_tech('PSP',t)     = sum((psp), PG_M_Hydro.l(psp,t))
;

Report_Gen_share('Nuclear') = sum((g,t)$nuc(g), PG_M_conv.l(g,t))/ Report_total_Gen('TWh')
;
Report_Gen_share('Biomass') = sum((g,t)$biomass(g), PG_M_conv.l(g,t))/ Report_total_Gen('TWh')
;
Report_Gen_share('On_Wind') = sum((ren,t)$wind_on(ren), PG_M_Wind.l(ren,t))/ Report_total_Gen('TWh')
;
Report_Gen_share('Off_Wind') = sum((ren,t)$wind_off(ren), PG_M_Wind.l(ren,t))/ Report_total_Gen('TWh')
;
Report_Gen_share('PV') = sum((ren,t)$solar_pv(ren), PG_M_PV.l(ren,t))/ Report_total_Gen('TWh')
;
Report_Gen_share('OCGT') = sum((t), Gen_Hydrogen(t))/ Report_total_Gen('TWh')
;
Report_Gen_share('Battery') = sum((t), Gen_battery(t))/ Report_total_Gen('TWh')
;
Report_Gen_share('ROR') = sum((ror,t), PG_M_Hydro.l(ror,t))/ Report_total_Gen('TWh')
;
Report_Gen_share('Reservoir') = sum((reservoir,t), PG_M_Hydro.l(reservoir,t))/ Report_total_Gen('TWh')
;
Report_Gen_share('PSP') = sum(t, Gen_PSP(t))/ Report_total_Gen('TWh')
;
Report_Gen_share('LS1') = sum((n,t), PLS_M_1.l(t,n))/ Report_total_Gen('TWh')
;
Report_Gen_share('LS2') = sum((n,t), PLS_M_2.l(t,n))/ Report_total_Gen('TWh')
;
Report_Gen_share('LS3') = sum((n,t), PLS_M_3.l(t,n))/ Report_total_Gen('TWh')
;


Report_gen_Region('Nuclear',rr) = sum((g,t)$(nuc(g) and MAP_RR_G(rr,g)) , PG_M_conv.l(g,t))
;
Report_Gen_Region('Biomass',rr) = sum((g,t)$(biomass(g)and MAP_RR_G(rr,g)), PG_M_conv.l(g,t))
;
Report_Gen_Region('On_Wind',rr) = sum((ren,t)$(wind_on(ren) and Map_RR_ren(rr,ren)), PG_M_Wind.l(ren,t))
;
Report_Gen_Region('Off_Wind',rr) = sum((ren,t)$(wind_off(ren) and Map_RR_ren(rr,ren)), PG_M_Wind.l(ren,t))
;
Report_Gen_Region('PV',rr) = sum((ren,t)$(solar_pv(ren) and Map_RR_ren(rr,ren)), PG_M_PV.l(ren,t))
;
Report_Gen_Region('OCGT',rr) = sum(t, Gen_Hydrogen_region(t,rr))
;
Report_Gen_Region('Battery',rr) =  sum(t,Gen_battery_region(t,rr))
;
Report_Gen_Region('ROR',rr) = sum((ror,t)$MAP_RR_RoR(rr,ror), PG_M_Hydro.l(ror,t))
;
Report_Gen_Region('Reservoir',rr) = sum((reservoir,t)$MAP_RR_reservoir(rr,reservoir), PG_M_Hydro.l(reservoir,t))
;
Report_Gen_Region('PSP',rr) = sum(t, Gen_PSP_region(t,rr))
;
Report_Gen_Region('LS1',rr) = sum((n,t)$Map_RR(rr,n), PLS_M_1.l(t,n))
;
Report_Gen_Region('LS2',rr) = sum((n,t)$Map_RR(rr,n), PLS_M_2.l(t,n))
;
Report_Gen_Region('LS3',rr) = sum((n,t)$Map_RR(rr,n), PLS_M_3.l(t,n))
;
Report_gen_Region('Total Charge Battery',rr) = sum((b,t)$MAP_RR_B(rr,b), M_Battery_charge.l(b,t))
;
Report_gen_Region('Total Charge OCGT',rr) = sum((h,t)$MAP_RR_OCGT(rr,h), M_hydrogen_charge.l(h,t))
;
Report_gen_Region('Total Charge PSP',rr) = sum((psp,t)$MAP_RR_PsP(rr,psp), M_charge.l(psp,t))
;
Report_gen_Region('Total Gen Battery',rr) =  sum((b,t)$MAP_RR_B(rr,b), PG_M_battery.l(b,t)) 
;
Report_gen_Region('Total Gen OCGT',rr) = sum((h,t)$MAP_RR_OCGT(rr,h),  PG_M_hydrogen.l(h,t))
;
Report_gen_Region('Total Gen PSP',rr) =  sum((psp,t)$MAP_RR_PsP(rr,psp), PG_M_Hydro.l(psp,t))  
;


Report_Balance_Flow_regions(rr) = sum((t,l)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_res_l(l,rr)), PF_M.l(l,t))
                                - sum((t,l)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_send_l(l,rr)), PF_M.l(l,t))
;


Report_total_Flow_regions('Region 1','Region 6') =    sum((t,l,rr)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_res_l(l,rr) and ord(rr)=6), PF_M.l(l,t))
                                                    - sum((t,l,rr)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_send_l(l,rr) and ord(rr)=6), PF_M.l(l,t))                                                    
;
Report_total_Flow_regions('Region 2','Region 3') =    sum((t,l,rr)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_res_l(l,rr) and ord(rr)=2), PF_M.l(l,t))
                                                    - sum((t,l,rr)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_send_l(l,rr) and ord(rr)=3), PF_M.l(l,t))
;
Report_total_Flow_regions('Region 2','Region 6') =    sum((t,l,rr)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_res_l(l,rr) and ord(rr)=2), PF_M.l(l,t))
                                                    - sum((t,l,rr)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_send_l(l,rr) and ord(rr)=6), PF_M.l(l,t))
;
Report_total_Flow_regions('Region 3','Region 2') =    sum((t,l,rr)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_res_l(l,rr) and ord(rr)=3), PF_M.l(l,t))
                                                    - sum((t,l,rr)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_send_l(l,rr) and ord(rr)=2), PF_M.l(l,t))
;
Report_total_Flow_regions('Region 3','Region 4') =    sum((t,l,rr)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_res_l(l,rr) and ord(rr)=3), PF_M.l(l,t))
                                                    - sum((t,l,rr)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_send_l(l,rr) and ord(rr)=4), PF_M.l(l,t))
;
Report_total_Flow_regions('Region 3','Region 5') =    sum((t,l,rr)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_res_l(l,rr) and ord(rr)=3), PF_M.l(l,t))
                                                    - sum((t,l,rr)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_send_l(l,rr) and ord(rr)=5), PF_M.l(l,t))
;
Report_total_Flow_regions('Region 3','Region 6') =    sum((t,l,rr)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_res_l(l,rr) and ord(rr)=3), PF_M.l(l,t))
                                                    - sum((t,l,rr)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_send_l(l,rr) and ord(rr)=6), PF_M.l(l,t))
;
Report_total_Flow_regions('Region 4','Region 3') =    sum((t,l,rr)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_res_l(l,rr) and ord(rr)=4), PF_M.l(l,t))
                                                    - sum((t,l,rr)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_send_l(l,rr) and ord(rr)=3), PF_M.l(l,t))
;
Report_total_Flow_regions('Region 5','Region 3') =    sum((t,l,rr)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_res_l(l,rr) and ord(rr)=5), PF_M.l(l,t))
                                                    - sum((t,l,rr)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_send_l(l,rr) and ord(rr)=3), PF_M.l(l,t))
;
Report_total_Flow_regions('Region 5','Region 6') =    sum((t,l,rr)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_res_l(l,rr) and ord(rr)=5), PF_M.l(l,t))
                                                    - sum((t,l,rr)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_send_l(l,rr) and ord(rr)=6), PF_M.l(l,t))
;
Report_total_Flow_regions('Region 6','Region 1') =    sum((t,l,rr)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_res_l(l,rr) and ord(rr)=1), PF_M.l(l,t))
                                                    - sum((t,l,rr)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_send_l(l,rr) and ord(rr)=1), PF_M.l(l,t))                                                    
;
Report_total_Flow_regions('Region 6','Region 2') =    sum((t,l,rr)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_res_l(l,rr) and ord(rr)=6), PF_M.l(l,t))
                                                    - sum((t,l,rr)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_send_l(l,rr) and ord(rr)=2), PF_M.l(l,t))
;
Report_total_Flow_regions('Region 6','Region 3') =    sum((t,l,rr)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_res_l(l,rr) and ord(rr)=6), PF_M.l(l,t))
                                                    - sum((t,l,rr)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_send_l(l,rr) and ord(rr)=3), PF_M.l(l,t))
;
Report_total_Flow_regions('Region 6','Region 5') =    sum((t,l,rr)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_res_l(l,rr) and ord(rr)=6), PF_M.l(l,t))
                                                    - sum((t,l,rr)$((ord(t) gt 1176 and ord(t) le 1218) and Map_rr_send_l(l,rr) and ord(rr)=5), PF_M.l(l,t))
;

Report_Expansion_regions('Region 1','Region 6') = sum(l$pros_l_rr1_rr6(l) , L_Cap_exp.l(l))
;
Report_Expansion_regions('Region 2','Region 3') = sum(l$pros_l_rr2_rr3(l) , L_Cap_exp.l(l))
;
Report_Expansion_regions('Region 2','Region 6') = sum(l$pros_l_rr2_rr6(l) , L_Cap_exp.l(l))
;
Report_Expansion_regions('Region 3','Region 4') = sum(l$pros_l_rr3_rr4(l)  , L_Cap_exp.l(l))
;
Report_Expansion_regions('Region 3','Region 5') = sum(l$pros_l_rr3_rr5(l)  , L_Cap_exp.l(l))
;
Report_Expansion_regions('Region 3','Region 6') = sum(l$pros_l_rr3_rr6(l)  , L_Cap_exp.l(l))
;
Report_Expansion_regions('Region 5','Region 6') = sum(l$pros_l_rr5_rr6(l)  , L_Cap_exp.l(l))
;

Report_Curtailment_share('Onshore Wind') = sum((ren,t)$wind_on(ren), Curtailment.l(ren,t))/ sum((ren,t)$wind_on(ren), PG_M_Wind.l(ren,t))
;
Report_Curtailment_share('Offshore Wind') = sum((ren,t)$wind_off(ren), Curtailment.l(ren,t))/ sum((ren,t)$wind_off(ren), PG_M_Wind.l(ren,t))
;
Report_Curtailment_share('Solar PV') = sum((ren,t)$solar_pv(ren), Curtailment.l(ren,t))/ sum((ren,t)$solar_pv(ren), PG_M_PV.l(ren,t))
;
Report_Curtailment_share('Total') = sum((ren,t), Curtailment.l(ren,t)) / sum((ren,t), PG_M_Wind.l(ren,t) + PG_M_PV.l(ren,t))
;
execute_unload "Result_Base.gdx";
