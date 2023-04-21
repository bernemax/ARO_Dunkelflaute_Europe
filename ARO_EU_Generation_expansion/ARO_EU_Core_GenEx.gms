* shows the computational time needed by each prcess until 1 sec.
option profile = 1;
option profiletol = 0.01;

$setGlobal bat ""      if "*" no battery in the model, if "" otherwise
$setGlobal hydrogen ""      if "*" no hydrogen in the model, if "" otherwise
;

Sets

t/t1*t1000/

*$ontext
n /DE0,DE1,DE2,DE3,DE4,DE5,DE6,AT0,BE0,CH0,CZ0
,DK0,DK1,EE0,ES0,ES1,ES2,ES3,FI0,FR0,FR1,
FR2,FR3,FR4,FR5,FR6,GB0,GB1,GB2,GB3,GB4,GB5,
HU0,IE0,IT0,IT1,IT2,IT3,IT4,LT0,LU0,LV0,NL0,
NO0,PL0,PT0,SE0,SE1,SI0,SK0
/
*$offtext
l /l1*l97,l1001*l1097/
g  /g7,g10,g15,g21,g33,g39,g64,g69,g81,
g86,g89,g92,g96,g100,g102,g104,g108,g112,
g116,g120,g124,g130,g155,g164,g168,g172/
*/g1*g172/
b /b19,b27,b28,b29,b30,b31,b44,b45,b48/
h /h1*h50/
s /s1*s97/
Ren/ren1,ren10,ren100,ren104,ren108,ren109,ren11,ren111,
ren112,ren113,ren114,ren115,ren116,ren117,ren119,ren121,
ren122,ren123,ren124,ren125,ren126,ren13, ren15,ren18,
ren2,ren20,ren23,ren25,ren26,ren29,ren31,ren32,ren34,
ren36,ren37,ren39,ren43,ren45,ren46,ren47,ren48,ren49,
ren5,ren51,ren55,ren59,ren61,ren62,ren63,ren64,ren66,
ren67,ren69,ren7,ren70,ren73,ren76,ren82,ren84,ren85,
ren86,ren87,ren88,ren89,ren9,ren90,ren91,ren93,ren94,
ren95,ren96,ren98,ren99/
rr/rr1*rr11/
v /v1*v8/
WM/WM1*WM12/

****************************nodes***************************************************
ref(n)
/DE0/

****************************lines***************************************************
ex_l(l)/l1*l97/
pros_l(l)/l1001*l1097/

****************************thermal************************************************
OCGT(g)
CCGT(g)
nuc(g)
lig(g)
coal(g)
oil(g)
waste(g)
biomass(g)


****************************volatil renewables**************************************
wind(ren)
wind_on(ren)
wind_off(ren)
solar_pv(ren)

****************************hydro***************************************************
ror(s)
reservoir(s)
psp(s)
****************************storage**************************************

ex_b(b) /b19,b27,b28,b29,b30,b31,b44,b45,b48/
ex_h(h) /h1*h50/
$ontext
/h1,h2,h4,h5,h10,h11,h13,h15,h18,h19,
h20,h27,h28,h29,h30,h31,h32,h34,h35,h36,
h37,h38,h39,h43,h44,h45,h46,h48,h49/
$offtext
*****************************mapping************************************************
Map_send_L(l,n)
Map_res_L(l,n)
Map_grid(l,n)

MapG(g,n)
Map_OCGT(g,n)
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

MAP_RR_Ren_node(rr,ren,n)
Map_RR_ren(rr,ren)
;
alias (n,nn),(t,tt),(l,ll), (v,vv)
;

$include Loading_ARO_GenEx.gms
*execute_unload "check_input_new.gdx";
*$stop

*######################################variables######################################

Variables
*********************************************Master*************************************************
O_M                         Objective var of Master Problem (total costs)
PF_M(l,t,v)                 power flows derived from DC load flow equation
Theta(t,n,v)                Angle of each node associated with DC power flow equations

*********************************************Subproblem*********************************************

O_Sub                       Objective var of dual Subproblem
lam(t,n)                    dual var lamda assoziated with Equation: MP_marketclear
phi(l,t)                    dual var phi assoziated with Equation: MP_PF_Ex
phi_SL_psp(s,t)             dual var phi assoziated with Equation: MP_Stor_lvl
phi_SL_battery(b,t)         dual var phi assoziated with Equation: MP_battery_lvl
phi_SL_hydrogen(h,t)         dual var phi assoziated with Equation: MP_hydrogen_lvl
teta_ref(t,n)               dual var beta assoziated with Equation: Theta_ref
;
positive Variables
*********************************************MASTER*************************************************

ETA                         aux var to reconstruct obj. function of the ARO problem
PG_M_conv(g,t,v)            power generation level of conventional generators
PG_M_Ren(ren,t,v)           cummulative power generation level of renewable solar pv and wind generators

PG_M_PV(ren,t,v)            cummulative power generation level of renewable solar pv generators
PG_M_Wind(ren,t,v)          cummulative power generation level of renewable wind generators

PLS_M(t,n,v)                load shedding

PG_M_Hydro(s,t,v)           power generation from hydro reservoir and psp and ror
M_Stor_lvl(s,t,v)
M_charge(s,t,v)

PG_M_battery(b,t,v)
M_battery_lvl(b,t,v)
M_battery_charge(b,t,v)

PG_M_hydrogen(h,t,v)
M_hydrogen_lvl(h,t,v)
M_hydrogen_charge(h,t,v)

*new_line_M(l)                decision variable regarding investment in a new prospective line
Cap_conv_M(g)
Cap_ren_M(ren)
Cap_battery_M(b)


Cap_hydrogen_M(h)
Cap_hydro_stor_M(h)
Cap_electrolysis_M(h)
Cap_OCGT_M(h)


*********************************************Subproblem*********************************************

Pdem(t,n)                   Uncertain load in node n in time step t

PE_conv(g,t)                realization of conventional supply (Ro)

AF_Ren(t,rr,n)              realization of combined wind and pv
AF_PV_sub(ren,rr,t)
AF_Wind_sub(ren,rr,t)

mu_PG_conv(g,t)             dual var phi assoziated with Equation: MP_PG_conv
mu_PG_ror(s,t)              dual Var phi assoziated with Equation: MP_PG_Ror
mu_PG_reservoir(s,t)        dual Var phi assoziated with Equation: MP_PG_Reservoir

mu_cap_psp(s,t)            dual Var phi assoziated with Equation: MP_Cap_Stor upper bound
mu_cap_psp_l(s,t)          dual Var phi assoziated with Equation: MP_Cap_Stor lower bound
mu_PG_psp(s,t)             dual var phi assoziated with Equation: MP_PG_Stor
mu_C_psp(s,t)              dual var phi assoziated with Equation: MP_C_Stor

mu_cap_battery(b,t)        dual Var phi assoziated with Equation: MP_Cap_Stor upper bound
mu_cap_battery_l(b,t)      dual Var phi assoziated with Equation: MP_Cap_Stor lower bound
mu_PG_battery(b,t)         dual var phi assoziated with Equation: MP_PG_Stor
mu_C_battery(b,t)          dual var phi assoziated with Equation: MP_C_Stor

mu_cap_hydrogen(h,t)        dual Var phi assoziated with Equation: MP_Cap_Stor upper bound
mu_cap_hydrogen_l(h,t)      dual Var phi assoziated with Equation: MP_Cap_Stor lower bound
mu_PG_hydrogen(h,t)         dual var phi assoziated with Equation: MP_PG_Stor
mu_C_hydrogen(h,t)          dual var phi assoziated with Equation: MP_C_Stor

mu_PG_PV(ren,t)
aux_phi_PV(ren,t)
mu_PG_wind(ren,t)
aux_phi_wind(ren,t)

phiPG_Ren(ren,t)            dual variable of combined wind and solar pv generation assoziated with Equation: MP_PG_RR
aux_phi_Ren_WM(ren,t)       aux continuous var to linearize

mu_LS(t,n)                  dual load shedding variable

omega_UB(l,t)               dual var phi assoziated with Equation: MP_PF_EX_Cap_UB
omega_LB(l,t)               dual var phi assoziated with Equation: MP_PF_EX_Cap_LB

teta_UB(t,n)                dual var beta assoziated with Equation: Theta_UB
teta_LB(t,n)                dual var beta assoziated with Equation: Theta_LB
 
;

Binary Variables
*********************************************Master*************************************************

*new_line_M(l)                decision variable regarding investment in a new prospective line
*inv_upg_M(l)                decision variable regarding an possible upgrade of the capacity of an existing line

*********************************************Subproblem*********************************************

z_dem(t,n)                  decision variable to construct polyhedral UC-set and decides weather Demand is at a lower or upper bound
z_PG_Ren(rr,WM)             decision variable to construct polyhedral UC-set and decides weather combined pv and wind generation potential is Max or not
z_PG_PV(rr,WM)              decision variable to construct polyhedral UC-set and decides weather PV Generation potential is Max or not
z_PG_Wind(rr,WM)            decision variable to construct polyhedral UC-set and decides weather wind Generation potential is Max or not
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
MP_PF_EX_Cap_UB
MP_PF_EX_Cap_LB


MP_LS
Theta_UB
Theta_LB
Theta_ref
MP_ETA

*********************************************Subproblem*********************************************

SUB_Dual_Objective

SUB_Dual_PG_Ren
SUB_Dual_PG_PV
SUB_Dual_PG_Wind

SUB_Dual_PG_conv
SUB_Dual_PG_ror
SUB_Dual_PG_reservoir

SUB_Dual_PG_psp
SUB_Dual_C_psp
SUB_Dual_lvl_psp
SUB_Dual_lvl_psp_start

SUB_Dual_PG_battery
SUB_Dual_C_battery
SUB_Dual_lvl_battery
SUB_Dual_lvl_battery_start

SUB_Dual_PG_hydrogen
SUB_Dual_C_hydrogen
SUB_Dual_lvl_hydrogen
SUB_Dual_lvl_hydrogen_start

SUB_Dual_LS

SUB_Dual_PF
SUB_Lin_Dual
SUB_Lin_Dual_n_ref

SUB_US_LOAD
SUB_US_PG_RR
SUB_UB_Total
SUB_UB_PG_RR

SUB_US_PG_PV
SUB_UB_PV_Total
SUB_UB_PG_PV_RR

SUB_US_PG_Wind
SUB_UB_Wind_Total
SUB_UB_PG_Wind_RR

SUB_lin33
SUB_lin34
SUB_lin35
SUB_lin36

SUB_lin37
SUB_lin38
SUB_lin39
SUB_lin40

SUB_lin41
SUB_lin42
SUB_lin43
SUB_lin44

;
*#####################################################################################Master####################################################################################

MP_Objective(vv)..                                                                              O_M  =e= sum((ren), Cap_ren_M(ren) * IC_ren(ren) * df)
                                                                                                        + sum((g), Cap_conv_M(g) * IC_conv(g) * df)
                                                                                                        + sum((b), ((Cap_battery_M(b) * 6)  * IC_bs(b)  * df)
                                                                                                        +           (Cap_battery_M(b) * IC_bi(b) * df))
                                                                                                                    
                                                                                                        + sum((h), ((Cap_hydrogen_M(h) * 168) * IC_hs(h) * df)
                                                                                                        +           (Cap_hydrogen_M(h) * IC_hel(h) * df)
                                                                                                        +           (Cap_OCGT_M(h) * IC_hfc(h) * df))
                                                                                                        + ETA
;


*********************************************************************************Balancing constraint************************************************************************************

MP_marketclear(t,n,vv)$(ord(vv) lt (itaux+1))..
                                                                                                Demand_data_fixed(t,n,vv) - PLS_M(t,n,vv)
                                                                                              
                                                                                                =e= sum((g)$MapG(g,n), PG_M_conv(g,t,vv))
*                                                                                                +  sum((ren)$Map_Ren_node(ren,n), PG_M_Ren(ren,t,vv))
                                                                                                + sum((ren)$Map_PV(ren,n), PG_M_PV(ren,t,vv))
                                                                                                + sum((ren)$Map_Wind(ren,n), PG_M_Wind(ren,t,vv))

                                                                                                + sum((ror)$MapS(ror,n),  PG_M_Hydro(ror,t,vv))
                                                                                                + sum((reservoir)$MapS(reservoir,n),  PG_M_Hydro(reservoir,t,vv))
                                                                                                + sum((psp)$MapS(psp,n), PG_M_Hydro(psp,t,vv)
                                                                                                -                        M_charge(psp,t,vv))
                                                                                                
%bat%                                                                                           + sum((b)$Map_battery(b,n), PG_M_battery(b,t,vv)
%bat%                                                                                           -                       M_battery_charge(b,t,vv))

%hydrogen%                                                                                      + sum((h)$Map_hydrogen(h,n), PG_M_hydrogen(h,t,vv)
%hydrogen%                                                                                      -                       M_hydrogen_charge(h,t,vv))
                                                                                                
                                                                                                +  sum(l$(Map_Res_l(l,n) and ex_l(l)), PF_M(l,t,vv))
                                                                                                -  sum(l$(Map_Send_l(l,n) and ex_l(l)), PF_M(l,t,vv))

;
*********************************************************************************Volatil Generation**************************************************************************************

MP_PG_RR(ren,t,rr,n,vv)$(MAP_RR_Ren_node(rr,ren,n)  and (ord(vv) lt (itaux+1)))..               PG_M_Ren(ren,t,vv)       =l= Cap_ren_M(ren) * AF_M_Ren_fixed(t,rr,n,vv)
;
MP_PG_PV(ren,rr,t,vv)$(MAP_RR_Ren(rr,ren) and solar_pv(ren) and (ord(vv) lt (itaux+1)))..       PG_M_PV(ren,t,vv)        =l= (Cap_ren_ex(ren) + Cap_ren_M(ren)) * AF_M_PV_fixed(ren,rr,t,vv)
;
MP_PG_Wind(ren,rr,t,vv)$(MAP_RR_Ren(rr,ren) and wind(ren) and (ord(vv) lt (itaux+1)))..         PG_M_Wind(ren,t,vv)      =l= (Cap_ren_ex(ren) +  Cap_ren_M(ren)) * AF_M_Wind_fixed(ren,rr,t,vv)
;

*Map_wind(ren,n)
*********************************************************************************Dispatchable Generation*********************************************************************************

MP_PG_conv(g,t,vv)$(ord(vv) lt (itaux+1))..                                                     PG_M_conv(g,t,vv)        =l= Cap_conv_ex(g) + Cap_conv_M(g)
;
MP_PG_ROR(ror,t,vv)$(ord(vv) lt (itaux+1))..                                                    PG_M_Hydro(ror,t,vv)     =l= Cap_hydro(ror)
;
MP_PG_Reservoir(reservoir,t,vv)$(ord(vv) lt (itaux+1))..                                        PG_M_Hydro(reservoir,t,vv) =l= Cap_hydro(reservoir) / scale
;

*********************************************************************************Hydro Storage Generation********************************************************************************

MP_PG_Stor(psp,t,vv)$(ord(vv) lt (itaux+1))..                                                   PG_M_Hydro(psp,t,vv)        =l= Cap_hydro(psp) * 0.75
;
MP_C_Stor(psp,t,vv)$(ord(vv) lt (itaux+1))..                                                    M_charge(psp,t,vv)          =l= Cap_hydro(psp) 
;
MP_Cap_Stor(psp,t,vv)$(ord(vv) lt (itaux+1))..                                                  M_Stor_lvl(psp,t,vv)        =l= (Cap_hydro(psp) * psp_cpf) / scale
;

MP_Stor_lvl_start(psp,t,vv)$(ord(vv) lt (itaux+1)and ord(t) = 1)..                              M_Stor_lvl(psp,t,vv)        =e= ((Cap_hydro(psp) * psp_cpf)/ scale)/2 + M_charge(psp,t,vv)  -  PG_M_Hydro(psp,t,vv) 
;
MP_Stor_lvl(psp,t,vv)$(ord(vv) lt (itaux+1) and ord(t) gt 1)..                                  M_Stor_lvl(psp,t,vv)        =e= M_Stor_lvl(psp,t-1,vv) + M_charge(psp,t,vv)  -  PG_M_Hydro(psp,t,vv) 
;

*********************************************************************************Battery********************************************************************************

MP_PG_Battery(b,t,vv)$(ord(vv) lt (itaux+1))..                                                   PG_M_Battery(b,t,vv)        =l= Cap_battery_M(b) * 0.96
;
MP_C_Battery(b,t,vv)$(ord(vv) lt (itaux+1))..                                                    M_Battery_charge(b,t,vv)    =l= Cap_battery_M(b) * 0.96
;
MP_Cap_Battery(b,t,vv)$(ord(vv) lt (itaux+1))..                                                  M_Battery_lvl(b,t,vv)        =l= (Cap_battery_M(b) *6) / scale
*Cap_battery_M(b)  
;

MP_Battery_lvl_start(b,vv)$(ord(vv) lt (itaux+1))..                                              M_Battery_lvl(b,'t1',vv)       =e= 0 + M_Battery_charge(b,'t1',vv) - PG_M_Battery(b,'t1',vv) 
*(Cap_battery_M(b) * 6)/20 +  M_Battery_charge(b,t,vv) - PG_M_Battery(b,t,vv) 
;
MP_Battery_lvl(b,t,vv)$(ord(vv) lt (itaux+1) and ord(t) gt 1)..                                  M_Battery_lvl(b,t,vv)        =e= M_Battery_lvl(b,t-1,vv) + M_Battery_charge(b,t,vv)  -  PG_M_Battery(b,t,vv) 
;

*********************************************************************************hydrogen********************************************************************************

MP_PG_hydrogen(h,t,vv)$(ord(vv) lt (itaux+1))..                                                   PG_M_hydrogen(h,t,vv)        =l= Cap_OCGT_M(h) 
;
MP_C_hydrogen(h,t,vv)$(ord(vv) lt (itaux+1))..                                                    M_hydrogen_charge(h,t,vv)    =l= Cap_hydrogen_M(h) * 0.75
;
MP_Cap_hydrogen(h,t,vv)$(ord(vv) lt (itaux+1))..                                                  M_hydrogen_lvl(h,t,vv)        =l= (Cap_hydrogen_M(h) * 168)/ scale
;

MP_hydrogen_lvl_start(h,vv)$(ord(vv) lt (itaux+1))..                                              M_hydrogen_lvl(h,'t1',vv)        =e= 0 +   M_hydrogen_charge(h,'t1',vv)  - PG_M_hydrogen(h,'t1',vv)
*(Cap_hydrogen_M(h) * 168)/20 +   M_hydrogen_charge(h,t,vv) - PG_M_hydrogen(h,t,vv) 
;
MP_hydrogen_lvl(h,t,vv)$(ord(vv) lt (itaux+1) and ord(t) gt 1)..                                  M_hydrogen_lvl(h,t,vv)        =e= M_hydrogen_lvl(h,t-1,vv) +  M_hydrogen_charge(h,t,vv)   -  PG_M_hydrogen(h,t,vv)*2 
;

*********************************************************************************DC Power flow lines***********************************************************************************

MP_PF_EX(l,t,vv)$(ex_l(l)  and (ord(vv) lt (itaux+1)))..                                        PF_M(l,t,vv) =e= B_sus(l) * (sum(n$Map_Send_l(l,n),  Theta(t,n,vv)) - sum(n$Map_Res_l(l,n),  Theta(t,n,vv))) * MVAbase
;
MP_PF_EX_Cap_UB(l,t,vv)$(ex_l(l) and (ord(vv) lt (itaux+1)))..                                  PF_M(l,t,vv) =l= L_cap(l)
;
MP_PF_EX_Cap_LB(l,t,vv)$(ex_l(l)  and (ord(vv) lt (itaux+1)))..                                 PF_M(l,t,vv) =g= - L_cap(l)
;



Theta_UB(t,n,vv)$(ord(vv) lt (itaux+1))..                                                       3.1415          =g= Theta(t,n,vv)
;
Theta_LB(t,n,vv)$(ord(vv) lt (itaux+1))..                                                       - 3.1415         =l= Theta(t,n,vv)
;
Theta_ref(t,n,vv)$(ord(vv) lt (itaux+1))..                                                      Theta(t,n,vv)$ref(n)      =e= 0
;


*********************************************************************************Load shedding*******************************************************************************************

MP_LS(t,n,vv)$(ord(vv) lt (itaux+1))..                                                          PLS_M(t,n,vv) =l= Demand_data_fixed(t,n,vv)
;

*********************************************************************************Iterative Objective function****************************************************************************


MP_ETA(vv)$(ord(vv) lt (itaux+1))..                                                             ETA =g=   sum((g,t), var_costs * PG_M_conv(g,t,vv)) 
                                                                                                + sum((reservoir,t), OM_costs_s * PG_M_Hydro(reservoir,t,vv)) 
                                                                                                
                                                                                                + sum((t,n), LS_costs * PLS_M(t,n,vv)) 

;
*#####################################################################################Subproblem####################################################################################

SUB_Dual_Objective..                                                O_Sub =e= sum((t,n), lam(t,n) * load(t,n)) 

                                                                    + sum((g,t), - mu_PG_conv(g,t) * Cap_conv_S(g))
                                                                    
                                                                    + sum((ren,t)$(solar_pv(ren)),
                                                                    - mu_PG_PV(ren,t) * (Cap_ren_S(ren) * af_PV(ren,t))
                                                                    + aux_phi_PV(ren,t)  * (Cap_ren_S(ren) * delta_af_PV(ren,t)))
                                                                    
                                                                    + sum((ren,t)$(wind(ren)),
                                                                    - mu_PG_wind(ren,t) * (Cap_ren_S(ren) * af_Wind(ren,t))
                                                                    + aux_phi_wind(ren,t)  * (Cap_ren_S(ren) * delta_af_wind(ren,t)))

                                                                    + sum((ror,t), - mu_PG_ror(ror,t) * Cap_Hydro(ror))
                                                                    + sum((reservoir,t), - mu_PG_reservoir(reservoir,t) * (Cap_Hydro(reservoir)/ scale))
                                                                    
                                                                    
                                                                    - sum((psp,t), mu_PG_psp(psp,t) * (Cap_hydro(psp) *0.75)
                                                                    + mu_C_psp(psp,t) * Cap_hydro(psp)
                                                                    + mu_cap_psp(psp,t) * ((Cap_hydro(psp) * psp_cpf)/ scale))
                                                                    + sum((psp,t)$(ord(t) =1),  phi_SL_psp(psp,t) * (((Cap_hydro(psp) * psp_cpf)/scale)/2))
                                                                    
%bat%                                                               + sum((b,t)$ex_b(b), - mu_PG_battery(b,t) * (Cap_inverter_S(b) *0.96)
%bat%                                                               - mu_C_battery(b,t) * (Cap_inverter_S(b) *0.96)
*%bat%                                                               + mu_cap_battery_l(b,t) * 0
%bat%                                                               - mu_cap_battery(b,t) * Cap_battery_S(b))
*%bat%                                                               - sum((b)$(ex_b(b)), phi_SL_battery(b,'t1') * (0))

%hydrogen%                                                          + sum((h,t)$ex_h(h), - mu_PG_hydrogen(h,t) * (Cap_Gen_S(h))
%hydrogen%                                                          - mu_C_hydrogen(h,t) * (Cap_electrolysis_S(h)*0.75)
%hydrogen%                                                          - mu_cap_hydrogen(h,t) * Cap_hydrogen_S(h))
*%hydrogen%                                                          + sum((h),  phi_SL_hydrogen(h,'t1')*0)
                                                                    

*                                                                    + sum((rr,ren,n,WM,t)$(MAP_RR_Ren(rr,ren,n)),
*                                                                    - phiPG_Ren(ren,t) * (Cap_ren(ren) * (Ratio_N(n,rr,t,WM)$MAP_WM(t,WM) * Budget_N(n,rr,WM)))
*                                                                    + aux_phi_Ren_WM(ren,t)  * (Cap_ren(ren) * (Ratio_WM(n,rr,t,WM)$MAP_WM(t,WM) * Budget_Delta(n,rr,WM))))
                                                                    
                                                                
                                                                    + sum((t,n), - mu_LS(t,n) * load(t,n))
                                                                    
                                                                    + sum((l,t)$ex_l(l), - omega_UB(l,t) *  L_cap(l))
                                                                    + sum((l,t)$ex_l(l), - omega_LB(l,t) *  L_cap(l))

;
*delta_af_PV(ren,t)
*****************************************************************Dual Power generation equation*****************************************************************

SUB_Dual_PG_Ren(ren,t,n)$Map_Ren_node(ren,n)..                        lam(t,n) - phiPG_Ren(ren,t)                         =l=   0
;
SUB_Dual_PG_PV(ren,t,n)$Map_PV(ren,n)..                               lam(t,n) - mu_PG_PV(ren,t)                          =l=   0
; 
SUB_Dual_PG_wind(ren,t,n)$Map_Wind(ren,n)..                           lam(t,n) - mu_PG_wind(ren,t)                        =l=   0
;

SUB_Dual_PG_conv(g,t,n)$MapG(g,n)..                                   lam(t,n) -  mu_PG_conv(g,t)                         =l=  var_costs
;
SUB_Dual_PG_ror(ror,t,n)$MapS(ror,n)..                                lam(t,n) -  mu_PG_ror(ror,t)                        =l=   0
; 
SUB_Dual_PG_reservoir(reservoir,t,n)$MapS(reservoir,n)..              lam(t,n) -  mu_PG_reservoir(reservoir,t)            =l=   OM_costs_s  
;

**************************************************************************Dual Hydro PSP*****************************************************************

SUB_Dual_PG_psp(psp,t,n)$MapS(psp,n)..                                lam(t,n)  - phi_SL_psp(psp,t) - mu_PG_psp(psp,t)            =l=   0
;
SUB_Dual_C_psp(psp,t,n)$MapS(psp,n)..                                 - lam(t,n) +  phi_SL_psp(psp,t) - mu_C_psp(psp,t)          =l=   0
;

SUB_Dual_lvl_psp(psp,t)$(ord(t) gt 1)..                               phi_SL_psp(psp,t) -  phi_SL_psp(psp,t-1) - mu_cap_psp(psp,t) + mu_cap_psp_l(psp,t)    =e=   0
;

SUB_Dual_lvl_psp_start(psp,t)$(ord(t) = 1)..                          phi_SL_psp(psp,t)  - mu_cap_psp(psp,t) + mu_cap_psp_l(psp,t)                          =e=   0
*
;

*********************************************************************Dual Battery equation*****************************************************************

SUB_Dual_PG_battery(b,t,n)$(Map_battery(b,n) and ex_b(b))..            lam(t,n) - phi_SL_battery(b,t) - mu_PG_battery(b,t)            =l=   0
;
SUB_Dual_C_battery(b,t,n)$(Map_battery(b,n) and ex_b(b))..             - lam(t,n) +  phi_SL_battery(b,t) - mu_C_battery(b,t)          =l=   0
;

SUB_Dual_lvl_battery(b,t)$(ord(t) le 1000 and ex_b(b))..                - phi_SL_battery(b,t) +  phi_SL_battery(b,t+1)  + mu_cap_battery_l(b,t) - mu_cap_battery(b,t)    =e=   0
;

SUB_Dual_lvl_battery_start(b,t)$(ord(t) = 1000 and ex_b(b))..            - phi_SL_battery(b,t)  + mu_cap_battery_l(b,t)  - mu_cap_battery(b,t)                         =e=   0
*
;

*********************************************************************Dual Hydrogen equation*****************************************************************

SUB_Dual_PG_hydrogen(h,t,n)$(Map_hydrogen(h,n)and ex_h(h))..                         lam(t,n)  - phi_SL_hydrogen(h,t)*2 - mu_PG_hydrogen(h,t)            =l=   0
;
SUB_Dual_C_hydrogen(h,t,n)$(Map_hydrogen(h,n) and ex_h(h))..                          - lam(t,n) +  phi_SL_hydrogen(h,t) - mu_C_hydrogen(h,t)          =l=   0
;

SUB_Dual_lvl_hydrogen(h,t)$(ord(t) le 1000 and ex_h(h))..                             - phi_SL_hydrogen(h,t) +  phi_SL_hydrogen(h,t+1) + mu_cap_hydrogen_l(h,t) - mu_cap_hydrogen(h,t)     =e=   0
;

SUB_Dual_lvl_hydrogen_start(h,t)$(ord(t) = 1000 and ex_h(h))..                         - phi_SL_hydrogen(h,t)  + mu_cap_hydrogen_l(h,t) -  mu_cap_hydrogen(h,t)                         =e=   0
;


*****************************************************************Dual Load shedding equation*********************************************************************

SUB_Dual_LS(t,n)..                                                     lam(t,n) -  mu_LS(t,n)  =l=   LS_costs
;

*****************************************************************Dual Power flow equations***********************************************************************

SUB_Dual_PF(l,t)$ex_l(l)..                                          - sum(n$(Map_Send_l(l,n)), lam(t,n)) + sum(n$(Map_Res_l(l,n)), lam(t,n))
                                                                    - omega_UB(l,t)  + omega_LB(l,t) + (phi(l,t)/MVAbase)
                                                                                                                      =e= 0
;
SUB_LIN_Dual(t,n)..                                                 - sum(l$(Map_Send_l(l,n) and ex_l(l) and not ref(n) ),  B_sus(l) * phi(l,t))
                                                                    + sum(l$(Map_Res_l(l,n) and ex_l(l) and not ref(n) ),   B_sus(l) * phi(l,t))
                                                                                                      =e= 0
;
SUB_Lin_Dual_n_ref(t,n)..                                           - sum(l$(Map_Send_l(l,n) and ex_l(l) and ref(n)), B_sus(l)  * phi(l,t))
                                                                    + sum(l$(Map_Res_l(l,n) and ex_l(l) and ref(n)),  B_sus(l)  * phi(l,t))

                                                                    +  teta_ref(t,n)                                  =e= 0

;

*****************************************************************Uncertainty Sets/ and polyhedral uncertainty budgets (level 2 problem)***************************

SUB_US_LOAD(t,n)..                                                  Pdem(t,n)  =e= load(t,n) 
;


SUB_US_PG_RR(t,rr,n,WM)$(MAP_WM(t,WM) and Map_RR(rr,n))..           AF_Ren(t,rr,n) =e=  Ratio_N(n,rr,t,WM) * Budget_N(n,rr,WM) - z_PG_Ren(rr,WM) * (Ratio_WM(n,rr,t,WM) * Budget_Delta(n,rr,WM)) 
;
SUB_UB_Total..                                                      Gamma_Ren_total - sum((WM,rr),  z_PG_Ren(rr,WM)) =g= 0
;
SUB_UB_PG_RR(rr)..                                                  sum(WM, z_PG_Ren(rr,WM))  =l= Gamma_PG_ren(rr)
;

SUB_US_PG_PV(ren,rr,t,WM)$(MAP_WM(t,WM) and solar_pv(ren) and Map_RR_ren(rr,ren))..   AF_PV_sub(ren,rr,t)  =e= af_PV(ren,t)  - z_PG_PV(rr,WM) * delta_af_PV(ren,t)
;
SUB_UB_PV_Total..                                                   Gamma_PV_total - sum((WM,rr),  z_PG_PV(rr,WM)) =g= 0
;
SUB_UB_PG_PV_RR(rr)..                                               sum(WM, z_PG_PV(rr,WM))  =l= Gamma_PG_PV(rr)         
;

SUB_US_PG_Wind(ren,rr,t,WM)$(MAP_WM(t,WM) and wind(ren) and Map_RR_ren(rr,ren))..         AF_Wind_sub(ren,rr,t)  =e= af_Wind(ren,t)  - z_PG_wind(rr,WM) * delta_af_wind(ren,t)
;
SUB_UB_wind_Total..                                                 Gamma_wind_total - sum((WM,rr),  z_PG_wind(rr,WM)) =g= 0
;
SUB_UB_PG_wind_RR(rr)..                                             sum(WM, z_PG_wind(rr,WM))  =l= Gamma_PG_wind(rr)         
;


*****************************************************************linearization*********************************************************************************

*******for combined PV and wind

SUB_lin33(ren,rr,t,WM)$(MAP_WM(t,WM) and Map_RR_ren(rr,ren))..         aux_phi_Ren_WM(ren,t)                              =l= M *  z_PG_Ren(rr,WM) 
;
SUB_lin34(ren,rr,t,WM)$(MAP_WM(t,WM) and Map_RR_ren(rr,ren))..         phiPG_Ren(ren,t) -  aux_phi_Ren_WM(ren,t)          =l= M *  (1 - z_PG_Ren(rr,WM) )
;
SUB_lin35(ren,rr,t,WM)$(MAP_WM(t,WM) and Map_RR_ren(rr,ren))..         - M * z_PG_Ren(rr,WM)                              =l= aux_phi_Ren_WM(ren,t) 
;   
SUB_lin36(ren,rr,t,WM)$(MAP_WM(t,WM) and Map_RR_ren(rr,ren))..         - M * (1 - z_PG_Ren(rr,WM) )                       =l= phiPG_Ren(ren,t) -  aux_phi_Ren_WM(ren,t) 
;

*******for PV

SUB_lin37(ren,rr,t,WM)$(MAP_WM(t,WM) and solar_pv(ren) and Map_RR_ren(rr,ren))..         aux_phi_PV(ren,t)                                  =l= M *  z_PG_PV(rr,WM) 
;
SUB_lin38(ren,rr,t,WM)$(MAP_WM(t,WM) and solar_pv(ren) and Map_RR_ren(rr,ren))..         mu_PG_PV(ren,t) -  aux_phi_PV(ren,t)               =l= M *  (1 - z_PG_PV(rr,WM) )
;
SUB_lin39(ren,rr,t,WM)$(MAP_WM(t,WM) and solar_pv(ren) and Map_RR_ren(rr,ren))..         - M * z_PG_PV(rr,WM)                               =l= aux_phi_PV(ren,t) 
;   
SUB_lin40(ren,rr,t,WM)$(MAP_WM(t,WM) and solar_pv(ren) and Map_RR_ren(rr,ren))..         - M * (1 - z_PG_PV(rr,WM) )                        =l= mu_PG_PV(ren,t) -  aux_phi_PV(ren,t) 
;

**********for Wind

SUB_lin41(ren,rr,t,WM)$(MAP_WM(t,WM) and wind(ren) and Map_RR_ren(rr,ren))..         aux_phi_wind(ren,t)                                =l= M *  z_PG_wind(rr,WM)
;
SUB_lin42(ren,rr,t,WM)$(MAP_WM(t,WM) and wind(ren) and Map_RR_ren(rr,ren))..         mu_PG_wind(ren,t) -  aux_phi_wind(ren,t)           =l= M *  (1 - z_PG_wind(rr,WM))
;
SUB_lin43(ren,rr,t,WM)$(MAP_WM(t,WM) and wind(ren) and Map_RR_ren(rr,ren))..         - M * z_PG_wind(rr,WM)                             =l= aux_phi_wind(ren,t)
;   
SUB_lin44(ren,rr,t,WM)$(MAP_WM(t,WM) and wind(ren) and Map_RR_ren(rr,ren))..         - M * (1 - z_PG_wind(rr,WM) )                      =l= mu_PG_wind(ren,t) -  aux_phi_wind(ren,t)
;


*execute_unload "check_EQ.gdx";
*$stop
********************************************Model definition**********************************************
model Master_VO
/
MP_Objective
/
;
Master_VO.scaleopt = 1
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


MP_LS
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

model Subproblem
/
SUB_Dual_Objective

*SUB_Dual_PG_Ren
SUB_Dual_PG_PV
SUB_Dual_PG_Wind

SUB_Dual_PG_conv
SUB_Dual_PG_ror
SUB_Dual_PG_reservoir

SUB_Dual_PG_psp
SUB_Dual_C_psp
SUB_Dual_lvl_psp
SUB_Dual_lvl_psp_start

%bat%SUB_Dual_PG_battery
%bat%SUB_Dual_C_battery
%bat%SUB_Dual_lvl_battery
%bat%SUB_Dual_lvl_battery_start

%hydrogen%SUB_Dual_PG_hydrogen
%hydrogen%SUB_Dual_C_hydrogen
%hydrogen%SUB_Dual_lvl_hydrogen
%hydrogen%SUB_Dual_lvl_hydrogen_start

SUB_Dual_PF
SUB_Lin_Dual
SUB_Lin_Dual_n_ref

SUB_Dual_LS
SUB_US_LOAD

*SUB_US_PG_RR
*SUB_UB_Total
*SUB_UB_PG_RR

SUB_US_PG_PV
SUB_UB_PV_Total
SUB_UB_PG_PV_RR

SUB_US_PG_Wind
SUB_UB_Wind_Total
SUB_UB_PG_Wind_RR

*SUB_lin33
*SUB_lin34
*SUB_lin35
*SUB_lin36

SUB_lin37
SUB_lin38
*SUB_lin39
SUB_lin40

SUB_lin41
SUB_lin42
*SUB_lin43
SUB_lin44

/
;
Subproblem.scaleopt = 1
;
option threads =  -1
;
option optcr = 0
;


Gamma_Load = 0
;
Gamma_PG_PV(rr) = 0
;
Gamma_PV_total = 0
;

Gamma_PG_Wind(rr) = 0
;
Gamma_Wind_total = 0
;

Gamma_Ren_total = 0
;
Gamma_PG_ren(rr) = 0
;
*inv_iter_hist(l,v)  = 0;
LB                  = -1e12
;
UB                  =  1e12
;

*Fixing nuclear capacity

Cap_conv_M.fx(g)$nuc(g) = 0
;
*Cap_ren_M.up(ren) = 10
*;
*Cap_battery_M.fx(b)=0
*;

Loop(v$((UB - LB) gt Toleranz),

Demand_data_fixed(t,n,v) = load(t,n)
;
*AF_M_Ren_fixed(t,n,v)  = af_ren_up(n,rr,t)
*;
AF_M_PV_fixed(ren,rr,t,v)  = af_PV(ren,t)
;
AF_M_Wind_fixed(ren,rr,t,v)  = af_Wind(ren,t)
;

itaux = ord(v)
;
if( ord(v) = 1,

*option MIP = Gamschk
*;

*#######################################################Step 2


    solve Master_VO using MIP minimizing O_M
    ;

else

Master.OptFile =1
;
$onecho > cplex.opt
scaind=1
quality=yes
$offEcho
*lpmethod=3
*names=no
*option Savepoint=1
*;

*OPTION SOLPRINT = ON ;
*execute_loadpoint 'Master_p';

    solve Master using MIP minimizing O_M
    ;
  );
*######################################################Step 3

LB =  O_M.l
*O_M.l
;
inv_cost_master(v) = sum(ren, Cap_ren_M.l(ren) * IC_ren(ren)* df)
                    + sum((g), Cap_conv_M.l(g) * IC_conv(g)* df)
                    + sum((b), ((Cap_battery_M.l(b) * 6))  * (IC_bs(b))* df)
                    + sum((b), Cap_battery_M.l(b) * IC_bi(b) * df)
                    + sum((h),  ((Cap_hydrogen_M.l(h)* 168))* (IC_hs(h)) * df)
                    + sum((h), Cap_hydrogen_M.l(h) * IC_hel(h) * df)
*                    + sum((h), Cap_hydrogen_M.l(h) * IC_hfc(h) * df)
                    + sum((h), Cap_OCGT_M.l(h) * IC_hfc(h) * df)
;


            report_decomp(v,'itaux','')         = itaux;
            report_decomp(v,'Gamma_Load','')    = Gamma_Load                                                    + EPS;
            report_decomp(v,'GAMMA_PG_conv','') = GAMMA_PG_conv                                                 + EPS;
            report_decomp(v,'GAMMA_PG_PV','')   = Gamma_PV_total                                                + EPS;
            report_decomp(v,'GAMMA_PG_wind','') = Gamma_Wind_total                                              + EPS;
*            report_decomp(v,'Line built',l)     = new_line_M.l(l)                                                     ;
            report_decomp(v,'investment cost','')     = inv_cost_master(v)                                      + EPS;
            report_decomp(v,'M_obj','')         = O_M.L                                                         + EPS;
            report_decomp(v,'ETA','')           = ETA.l                                                         + EPS;
            report_decomp(v,'LB','')            = LB;
            report_decomp(v,'M_Shed','')        = SUM((t,n), PLS_M.l(t,n,v))                                    + EPS;
            report_decomp(v,'M_GC','')          = SUM((g,t), var_costs * PG_M_conv.l(g,t,v))               + EPS;
            report_decomp(v,'M_LS','')          = SUM((t,n), LS_costs * PLS_M.l(t,n,v))                      + EPS;
            report_decomp(v,'M_Hydro_costs','')       = SUM((t,s),PG_M_Hydro.l(s,t,v)* OM_costs_s)          + EPS;

*            report_cap_conv(n,g,v,'OCGT')            = Cap_conv_M.l(g)$Map_OCGT(g,n);
*            report_cap_conv(n,g,v,'CCGT')            = Cap_conv_M.l(g)$Map_CCGT(g,n);
            report_cap_conv(n,g,v,'Nuclear')         = Cap_conv_M.l(g)$Map_Nuclear(g,n);
            report_cap_ren(n,ren,v,'On_Wind')        = Cap_ren_M.l(ren)$Map_Onwind(ren,n);
            report_cap_ren(n,ren,v,'Off_Wind')       = Cap_ren_M.l(ren)$Map_Offwind(ren,n);
            report_cap_ren(n,ren,v,'PV')             = Cap_ren_M.l(ren)$Map_PV(ren,n);
            report_cap_battery(n,b,v,'Battery')      =(Cap_battery_M.l(b) * (6))$Map_Battery(b,n);
            report_cap_battery(n,b,v,'Inverter')     = Cap_battery_M.l(b)$Map_Battery(b,n);
            report_Cap_hydrogen(n,h,v,'Hydrogen storage')   = (Cap_hydrogen_M.l(h) * (168))$Map_hydrogen(h,n);
            report_Cap_hydrogen(n,h,v,'Electrosysis')       = Cap_hydrogen_M.l(h)$Map_hydrogen(h,n);
            report_Cap_hydrogen(n,h,v,'OCGT')          = Cap_OCGT_M.l(h)$Map_hydrogen(h,n);
            
           


;
*######################################################Step 4

*$include network_expansion_merge_conti.gms
*;
$include ex_storage.gms
$include ex_hydrogen.gms

Cap_conv_S(g) = Cap_conv_ex(g) + Cap_conv_M.l(g) 
;
Cap_ren_S(ren)= Cap_ren_ex(ren) + Cap_ren_M.l(ren)  
;
Cap_battery_S(b)$ex_b(b) = (Cap_battery_M.l(b) *6) / scale 
;
Cap_inverter_S(b)$ex_b(b) = Cap_battery_M.l(b) 
;
Cap_Hydrogen_S(h) = (Cap_hydrogen_M.l(h) *168) / scale
;
Cap_Gen_S(h) = Cap_OCGT_M.l(h)
* Cap_hydrogen_M.l(h)
*Cap_OCGT_M.l(h)
;
Cap_electrolysis_S(h) = Cap_hydrogen_M.l(h)
;
*######################################################Step 5
*option MIP = Gamschk
*;

Subproblem.OptFile =1
;
$onecho > cplex.opt
scaind=1
quality=yes
$offEcho
*lpmethod=3
*names=no
*bendersstrategy = 3
solve Subproblem using MIP maximizing O_Sub
;
*######################################################Step 6

UB = min(UB, (sum(ren, Cap_ren_M.l(ren) * IC_ren(ren)* df)
            + sum((g), Cap_conv_M.l(g) * IC_conv(g)* df)
            + sum((b), ((Cap_battery_M.l(b) * 6))  * (IC_bs(b))* df)
            + sum((b), Cap_battery_M.l(b) * IC_bi(b) * df)
            + sum((h), ((Cap_hydrogen_M.l(h)* 168))* (IC_hs(h)) * df)
            + sum((h), Cap_hydrogen_M.l(h) * IC_hel(h) * df)
*            + sum((h), Cap_hydrogen_M.l(h) * IC_hfc(h) * df)
            + sum((h), Cap_OCGT_M.l(h)* IC_hfc(h) * df)
            + O_Sub.l))
;
            report_decomp(v,'network','')       = card(ex_l);
            report_decomp(v,'Sub_obj','')       = O_Sub.L                                                       + EPS;
            report_decomp(v,'UB','')            = UB;
            report_decomp(v,'UB-LB','')         = UB - LB                                                       + EPS;
            report_decomp(v,'Sub_Shed','')      = SUM((t,n), - mu_LS.m(t,n))                                      + EPS;
            report_decomp(v,'Sub_Gen','')       = SUM((g,t), - mu_PG_conv.m(g,t))                                 + EPS;
            report_decomp(v,'Sub_Hydro','')     = SUM((reservoir,t), - (mu_PG_reservoir.m(reservoir,t))) + EPS; 
*            compare_av_ren(n,rr,t)              = AF_Ren.l(n,rr,t) - af_ren_up(n,rr,t);


*######################################################Step 7
Demand_data_fixed(t,n,v) = load(t,n)
;
*AF_M_Ren_fixed(n,rr,t,v) = AF_Ren.l(n,rr,t)
*;
AF_M_PV_fixed(ren,rr,t,v) = AF_PV_sub.l(ren,rr,t)
;
AF_M_Wind_fixed(ren,rr,t,v) = AF_Wind_sub.l(ren,rr,t) 
;

*execute_unload "check_ARO_toy_complete.gdx"
*$include network_expansion_clean.gms

execute_unload "check_EU_new.gdx";
;
)

*execute_unload "check_TEP_ARO_2.gdx";
***************************************************output**************************************************
Parameter
Report_dunkel_time_Z(rr)
Report_dunkel_PV_Z(rr,WM)
Report_dunkel_Wind_Z(rr,WM)
Report_lines_built(l) 
Report_total_cost
Report_pp_constr_cost(V)
Report_LS_node(t,n,vv)
Report_LS_per_hour(t,vv)
Report_LS_total(vv)
Report_PG(*,*,t,vv)
Report_lineflow(l,t,vv)

Inv_conv(n,g,*)
Inv_ren(n,ren,*)

Inv_total_conv(g,*)
Inv_total_ren(ren,*)

report_cap_final(n,*,*)
;
*$ontext
Report_dunkel_time_Z(rr) = sum(WM, z_PG_wind.l(rr,WM) + z_PG_PV.l(rr,WM))
;
Report_dunkel_PV_Z(rr,WM) =  z_PG_PV.l(rr,WM)
;
Report_dunkel_Wind_Z(rr,WM) = z_PG_wind.l(rr,WM)
;
Report_total_cost = O_M.l
;
Report_PP_constr_cost(v) = inv_cost_master(v)
;

Report_LS_node(t,n,vv) = PLS_M.l(t,n,vv)
;
Report_LS_per_hour(t,vv) = sum(n,Report_LS_node(t,n,vv))
;
Report_LS_total(vv) = sum(t,Report_LS_per_hour(t,vv))
;

$ontext
Inv_total_conv(g,'OCGT') = sum(n,Inv_conv(n,g,'OCGT'))
;
Inv_total_conv(g,'CCGT') = sum(n,Inv_conv(n,g,'CCGT'))
;
Inv_total_ren(ren,'On_Wind') = sum(n,Inv_ren(n,ren,'On_Wind'))
;
Inv_total_ren(ren,'Off_Wind') = sum(n,Inv_ren(n,ren,'Off_Wind'))
;
Inv_total_ren(ren,'PV') = sum(n,Inv_ren(n,ren,'PV'))
;
$offtext
report_cap_final(n,g,'Nuclear') = Cap_conv_ex(g)$Map_Nuclear(g,n)
;
report_cap_final(n,ren,'On_Wind') =Cap_ren_M.l(ren)$Map_Onwind(ren,n)
;
report_cap_final(n,ren,'Off_Wind') = Cap_ren_M.l(ren)$Map_Offwind(ren,n)
;
report_cap_final(n,ren,'PV') = Cap_ren_M.l(ren)$Map_PV(ren,n)
;
report_cap_final(n,b,'battery storage') = (Cap_battery_M.l(b) * 6)$Map_Battery(b,n)
;
report_cap_final(n,b,'battery inverter') = (Cap_battery_M.l(b))$Map_Battery(b,n)
;
report_cap_final(n,h,'OCGT') = (Cap_OCGT_M.l(h))$Map_hydrogen(h,n)
*(Cap_hydrogen_M.l(h))$Map_hydrogen(h,n)
*(Cap_OCGT_M.l(h))$Map_hydrogen(h,n)
;
report_cap_final(n,h,'hydrogen storage') = (Cap_hydrogen_M.l(h) * 168)$Map_hydrogen(h,n)
;
report_cap_final(n,h,'Electrolysis') = (Cap_hydrogen_M.l(h))$Map_hydrogen(h,n)
;



execute_unload "Results_ARO_new.gdx"
Report_dunkel_time_Z, Report_dunkel_PV_Z, Report_dunkel_Wind_Z, Report_PP_constr_cost, Report_total_cost,
Report_pp_constr_cost, Report_LS_node, Report_LS_per_hour, Report_LS_total, Inv_conv,Inv_ren,Inv_total_conv,Inv_total_ren,report_cap_final
;


execute '=gams Master lo=2 gdx=Results_Clustered_ARO'
;
execute '=gdx2xls Results_Clustered_ARO.gdx'
;
*execute '=shellExecute Results_1.xlsx'
*;


$stop
*$offtext