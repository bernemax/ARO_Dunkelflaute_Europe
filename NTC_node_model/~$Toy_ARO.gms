
* only one "*" for a model run is possible for now
************************** representative european weather years
$setglobal  cf_1989  ""       if "*" considered, if "" taken out
$setglobal  cf_1990  "*"       if "*" considered, if "" taken out
$setglobal  cf_2010  ""       if "*" considered, if "" taken out
$setglobal  cf_2012  ""       if "*" considered, if "" taken out

************************** capacity options for 2020 - 2050
$setglobal  cap_exo20 "*"      if "*" considered, if "" taken out
$setglobal  cap_exo30 ""      if "*" considered, if "" taken out
$setglobal  cap_exo40 ""      if "*" considered, if "" taken out
$setglobal  cap_exo50 ""      if "*" considered, if "" taken out

************************** representative load Secnarios for 2020 - 2050
$setglobal  Load_exo20 "*"      if "*" considered, if "" taken out
$setglobal  Load_exo30 ""      if "*" considered, if "" taken out
$setglobal  Load_exo40 ""      if "*" considered, if "" taken out
$setglobal  Load_exo50 ""      if "*" considered, if "" taken out

$set        Data_input         Data_input\


Sets

n /DE,DK,SE,PL,CZ,AT,CH,FR,BE,NE,
   NW,UK,IT,ES,BALT,SI,SEE,FI/
g /g1*g102/
s /s1*s51/
*NTC/ntc1*ntc100/
t/t1*t100/
v /v1*v5/

link/l1*l168/

rr/rr1*rr17/
res/res1*res17/
*wind and solar
hr/hr1*hr17/

DF/DF1*DF365/

;
alias (n,nn),(t,tt), (v,vv)
;

* Subsets
sets
****************************thermal************************************************
gas(g)
lig(g)
coal(g)
nuc(g)
oil(g)
waste(g)
biomass(g)

****************************hydro***************************************************
ror(s)
reservoir(s)
psp(s)
****************************links***************************************************

ex(link)
/l1*l84/
prosp(link)
/l85*l164/

****************************mapping*************************************************

MapG(g,n)
MapS(s,n)
MapRes(res,n)
Map_RR(rr,n)
Map_RR_RES(rr,res)
MapHr(hr,n)
Map_DF(t,DF)
Map_link_NTC(link,n,nn)
;
*execute_unload "check_ARO_Toy.gdx";
*$stop
$include Loading_input_data.gms
;
*execute_unload "check_ARO_Toy.gdx";
*$stop
*######################################variables######################################
Variables
*********************************************Master*************************************************
O_M

*********************************************Subproblem*********************************************
O_Sub                       Objective var of dual Subproblem
lam(n,t)                    dual var lamda assoziated with Equation: MP_marketclear
 
;

positive Variables
*********************************************MASTER*************************************************
ETA
inv_NTC_M(n,nn)               Investment decision variable regarding NTC capacity investment
Gen_g(g,t,v)                  generation conventionals
Gen_r(res,t,v)                generation renewables
Gen_s(s,t,v)                  generation hydro

Power_flow_ex(n,nn,t,v)       NTC power flow of existing NTC
Power_flow_prosp(n,nn,t,v)    NTC power flow of prospective NTC

storagelvl(s,t,v)             storage level
charge(s,t,v)                 charging of storage

Su(g,t,v)                     start up capacity
P_on(g,t,v)                   online capacity
Load_shed(t,n,v)              load shedding

*********************************************Subproblem*********************************************

*phi(n,nn,t)                    dual variable assiciated to NTC power flow
AF_res(t,rr,n)              realization of combined wind and pv

phiPG_conv(g,t)             dual var phi assoziated with Equation: MP_PG_max_gen
phiPG_P_on(g,t)             dual var phi assoziated with Equation: MP_PG_max_cap
phiPG_Su(g,t)               dual var phi assoziated with Equation: MP_PG_startup_constr

phi_res(res,t)              dual variable of combined wind and solar pv generation assoziated with Equation: MP_PG_RR

phi_ror_cap(s,t)          dual Var phi 
phi_ror_inflow(s,t)

phi_psp_start(s,t)
phi_psp_normal(s,t)
phi_psp_end(s,t)
phi_psp_stor_cap(s,t)
phi_psp_power(s,t)
phi_psp_max_gen(s,t)

phiLS(n,t)                  dual load shedding variable

phi_NTC_ex(n,nn)
phi_NTC_inv(n,nn)

aux_phi_res_DF(res,t)       aux continuous var to linearize

;
Binary Variables
*********************************************MASTER*************************************************

*********************************************Subproblem*********************************************

z_PG_res(DF,rr)             decision variable to construct polyhedral UC-set and decides weather combined pv and wind generation potential is Max or not


;
Equations
*********************************************Master**************************************************
MP_Total_costs
MP_Balance

MP_max_gen
MP_max_cap
MP_startup_constr

MP_max_res

MP_max_gencap_ror
MP_max_inflow_ror

MP_reservor_stor_lvl_start
MP_reservor_stor_lvl
MP_reservor_stor_lvl_end
MP_min_reservoir_gen
MP_max_reservoir_gen
MP_max_reservoir_stor_lvl
MP_min_reservoir_stor_lvl

MP_Store_level_start
MP_Store_level
MP_Store_level_end
MP_Store_level_max
MP_Store_prod_max
MP_Store_prod_max_end

MP_ex_NTC_max
*MP_ex_NTC_max_im
MP_prosp_NTC_max
*MP_prosp_NTC_max_im

MP_LS_det
MP_ETA
*********************************************Subproblem*********************************************

SUB_Dual_Objective

SUB_Dual_PG_gen
SUB_Dual_PG_max_on
SUB_Dual_PG_startup

SUB_Dual_PG_res

SUB_Dual_PG_ror

SUB_Dual_PG_PSP_start
SUB_Dual_PG_PSP_normal
SUB_Dual_PG_PSP_end

SUB_Dual_PG_PSP_charge_start
SUB_Dual_PG_PSP_charge_normal

SUB_Dual_PG_PSP_gen_start
SUB_Dual_PG_PSP_gen_normal



SUB_Dual_LS


SUB_Dual_NTC_PF
SUB_Dual_NTC_PF_inv

SUB_US_PG_RR
SUB_UB_Total
SUB_UB_PG_RR

SUB_lin1
SUB_lin2
SUB_lin3
SUB_lin4

;
*#######################################################objective##########################################################

MP_Total_costs(vv)..                O_M =e=   sum((n,nn), inv_NTC_M(n,nn) * toy_inv_costs) + sum((nn,n), inv_NTC_M(nn,n) * toy_inv_costs) + ETA
;

*####################################################energy balance########################################################

MP_Balance(t,n,vv)$(ord(vv) lt (itaux+1))..                (load(t,n) - Load_shed(t,n,vv))  =e= sum(g$MapG(g,n), Gen_g(g,t,vv))

                                                          
                                                           + sum(res$MapRes(res,n), Gen_r(res,t,vv))

                                                           - sum(nn, Power_flow_ex(n,nn,t,vv))
                                                           + sum(nn, Power_flow_ex(nn,n,t,vv))
                                                           
                                                           - sum(nn,   Power_flow_prosp(n,nn,t,vv)
                                                                     + Power_flow_prosp(nn,n,t,vv))
                                                           

                                                           + sum(ror$MapS(ror,n), Gen_s(ror,t,vv))
$ontext
                                                           + sum(s$MapS(s,n), Gen_s(s,t,vv))
                                                           - sum(psp$MapS(psp,n), charge(psp,t,vv))
                                                           
$offtext
;
**Eff_res(biomass)
*######################################################generation##########################################################

MP_max_gen(g,t,vv)$(ord(vv) lt (itaux+1))..                                Gen_g(g,t,vv) =l= P_on(g,t,vv)
;
MP_max_cap(g,t,vv)$(ord(vv) lt (itaux+1))..                                P_on(g,t,vv)  =l= cap_conv(g)
;
MP_startup_constr(g,t,vv)$(ord(vv) lt (itaux+1))..                         P_on(g,t,vv) - P_on(g,t-1,vv) =l= Su(g,t,vv)
;
MP_max_res(res,n,rr,t,vv)$(MapRes(res,n) and ord(vv) lt (itaux+1))..       gen_r(res,t,vv) =l=  AF_M_Res_fixed(t,rr,n,vv) * cap_res(res)

;
********************************************************Hydro RoR**********************************************************

MP_max_gencap_ror(ror,t,vv)$(ord(vv) lt (itaux+1))..                                            gen_s(ror,t,vv) =l=  cap_hydro(ror)
;
MP_max_inflow_ror(ror,n,hr,t,vv)$(MapHR(hr,n) and MapS(ror,n) and ord(vv) lt (itaux+1))..       gen_s(ror,t,vv) =l=  (af_hydro(t,hr,n) * scale_to_MW) *  share_inflow(ror,n)     
;
********************************************************Hydro PsP**********************************************************

MP_Store_level_start(psp,t,vv)$(ord(t) =1 and ord(vv) lt (itaux+1))..               storagelvl(psp,t,vv) =e= cap_hydro(psp) *0.5 + charge(psp,t,vv) * eff_hydro(psp) - gen_s(psp,t,vv)
;
MP_Store_level(psp,t,vv)$(ord(t) gt 1 and ord(vv) lt (itaux+1))..                   storagelvl(psp,t,vv) =e= storagelvl(psp,t-1,vv) + charge(psp,t-1,vv) * eff_hydro(psp) - gen_s(psp,t-1,vv)
;
MP_Store_level_end(psp,t,vv)$(ord(t) = card(t) and ord(vv) lt (itaux+1))..          storagelvl(psp,t,vv) =e= cap_hydro(psp) * 0.5
;
MP_Store_level_max(psp,t,vv)$(ord(vv) lt (itaux+1))..                               storagelvl(psp,t,vv) =l= cap_hydro(psp) * store_cpf
;
MP_Store_prod_max(psp,t,vv)$(ord(vv) lt (itaux+1))..                                gen_s(psp,t,vv) + charge(psp,t,vv) *1.2 =l= cap_hydro(psp) 
;
MP_Store_prod_max_end(psp,t,vv)$(ord(t) = card(t)and ord(vv) lt (itaux+1))..        gen_s(psp,t,vv)      =l= storagelvl(psp,t,vv)
;
*****************************************************Hydro reservoir******************************************************

MP_reservor_stor_lvl_start(reservoir,n,hr,t,vv)$(MapHR(hr,n) and MapS(reservoir,n) and ord(vv) lt (itaux+1) and ord(t) =1)..

                                                                             storagelvl(reservoir,t,vv) =e= reservoir_stor_cap(reservoir,n) *0.7 - gen_s(reservoir,t,vv) + (af_hydro(t,hr,n) * scale_to_MW) * share_inflow(reservoir,n)
;
MP_reservor_stor_lvl(reservoir,n,hr,t,vv)$(MapHR(hr,n) and MapS(reservoir,n) and ord(vv) lt (itaux+1) and ord(t) gt 1)..

                                                                             storagelvl(reservoir,t,vv) =e= storagelvl(reservoir,t-1,vv) - gen_s(reservoir,t-1,vv) + (af_hydro(t-1,hr,n) * scale_to_MW) * share_inflow(reservoir,n)
;
MP_reservor_stor_lvl_end(reservoir,n,hr,t,vv)$(MapHR(hr,n) and MapS(reservoir,n) and ord(vv) lt (itaux+1) and ord(t) = card(t))..

                                                                             storagelvl(reservoir,t,vv) =e= reservoir_stor_cap(reservoir,n) *0.7 - gen_s(reservoir,t-1,vv) + (af_hydro(t-1,hr,n) * scale_to_MW) * share_inflow(reservoir,n)
;
MP_min_reservoir_gen(reservoir,n,hr,t,vv)$(MapHR(hr,n) and MapS(reservoir,n) and ord(vv) lt (itaux+1))..

                                                                             gen_s(reservoir,t,vv) =g= (af_hydro(t,hr,n) *scale_to_MW) * share_inflow(reservoir,n) * 0.1
;
MP_max_reservoir_gen(reservoir,n,hr,t,vv)$(MapHR(hr,n) and MapS(reservoir,n) and ord(vv) lt (itaux+1))..

                                                                             gen_s(reservoir,t,vv) =l= cap_hydro(reservoir) 
;
MP_max_reservoir_stor_lvl(reservoir,n,hr,t,vv)$(MapHR(hr,n) and MapS(reservoir,n) and ord(vv) lt (itaux+1))..

                                                                             storagelvl(reservoir,t,vv) =l= reservoir_stor_cap(reservoir,n)
;
MP_min_reservoir_stor_lvl(reservoir,n,hr,t,vv)$(MapHR(hr,n) and MapS(reservoir,n) and ord(vv) lt (itaux+1) and (ord(t) gt 1) )..

                                                                             storagelvl(reservoir,t,vv) =g= 0.15 * reservoir_stor_cap(reservoir,n)
;

*##########################################################NTC exchange###########################################################

MP_ex_ntc_max(n,nn,t,vv)$(ord(vv) lt (itaux+1))..                     power_flow_ex(n,nn,t,vv) =l= NTC_cap_ex(n,nn)
* +inv_NTC_M(n,nn)
;
*MP_ex_ntc_max_im(nn,n,t,vv)$(ord(vv) lt (itaux+1))..                     power_flow_ex(nn,n,t,vv) =l= NTC_cap_ex(nn,n)
*;
MP_prosp_NTC_max(n,nn,t,vv)$(ord(vv) lt (itaux+1))..                  power_flow_prosp(n,nn,t,vv) =l= inv_NTC_M(n,nn)
;
*MP_prosp_NTC_max_im(nn,n,t,vv)$(ord(vv) lt (itaux+1))..                  power_flow_prosp(nn,n,t,vv) =l= inv_NTC_M(nn,n)
*;

*****************************************************load shedding determination*******************************************

MP_LS_det(t,n,vv)$(ord(vv) lt (itaux+1))..                           Load_shed(t,n,vv)     =l= load(t,n)
;

MP_ETA(vv)$(ord(vv) lt (itaux+1))..                                    ETA =g=   sum((g,t), Var_costs(g,t) * Gen_g(g,t,vv))
                                                                      + sum((g,t), su_costs(g,t) * Su(g,t,vv))
                                                                      + sum((t,n), LS_costs(n) * Load_shed(t,n,vv))
;
*#####################################################################################Subproblem####################################################################################

SUB_Dual_Objective..                                                   O_Sub =e=  sum((n,t), lam(n,t) * load(t,n))
                                                                       
                                                                                + sum((g,t), - phiPG_P_on(g,t) * Cap_conv(g))
                                                                               
                                                                                + sum((rr,res,n,DF,t)$(Map_RR(rr,n) and Map_RR_RES(rr,res)),
                                                                                - phi_Res(res,t) * (Cap_res(res) * (Ratio_N(t,DF,rr,n)$MAP_DF(t,DF) * Budget_N(DF,rr,n)))
                                                                                + aux_phi_Res_DF(res,t)  * (Cap_res(res) * (Ratio_DF(t,DF,rr,n)$MAP_DF(t,DF) * Budget_Delta(DF,rr,n))))
                                                                                 
                                                                                + sum((ror,t), - phi_ror_cap(ror,t) * cap_hydro(ror))
                                                                                + sum((hr,n,ror,t)$(MapHr(hr,n) and MapS(ror,n)), - phi_ror_inflow(ror,t) * ((af_hydro(t,hr,n) * scale_to_MW) *  share_inflow(ror,n)))     
$ontext                                                                                
                                                                                + sum((psp,t)$(ord(t)=1), (cap_hydro(psp) * 0.5) * phi_psp_start(psp,t))
                                                                                + sum((psp,t)$(ord(t)=card(t)), (cap_hydro(psp) * 0.5) * phi_psp_end(psp,t))
                                                                                + sum((psp,t), - phi_psp_stor_cap(psp,t) * (cap_hydro(psp) * store_cpf) )
                                                                                + sum((psp,t), - phi_psp_power(psp,t) * cap_hydro(psp))
$offtext                                                                
                                                                                + sum((n,t), - phiLS(n,t) * load(t,n))

                                                                                + sum((n,nn), - phi_NTC_ex(n,nn) * NTC_cap_sub_ex(n,nn))
                                                                                + sum((n,nn), - phi_NTC_inv(n,nn) * NTC_cap_sub_prosp(n,nn))
*                                                                                + sum((nn,n), - phi_NTC_im(nn,n) * NTC_cap_sub(nn,n))


;

********************************************************dual power generation conventionals unit commitment*************************************************************************

SUB_Dual_PG_gen(g,t)..                                                 sum(n$MapG(g,n), lam(n,t) - phiPG_conv(g,t)) =l= Var_costs(g,t)
;
SUB_Dual_PG_max_on(g,t)..                                              sum(n$MapG(g,n), phiPG_conv(g,t) - phiPG_P_on(g,t) - phiPG_Su(g,t) + phiPG_Su(g,t-1))   =l= su_costs(g,t)
;
SUB_Dual_PG_startup(g,t)..                                             sum(n$MapG(g,n), phiPG_Su(g,t)) =l= su_costs(g,t)
;

********************************************************dual renewable power generation*********************************************************************************************

SUB_Dual_PG_res(res,t)..                                               sum((n)$(MapRes(res,n)), lam(n,t) - phi_Res(res,t))    =l=   0
;


********************************************************dual ROR power generation***************************************************************************************************

SUB_Dual_PG_ror(ror,t)..                                               sum((n)$MapS(ror,n) , lam(n,t) -  phi_ror_cap(ror,t) -  phi_ror_inflow(ror,t))     =l=   0
;

********************************************************dual PSP power generation***************************************************************************************************

SUB_Dual_PG_PSP_start(psp,t)$(ord(t) = 1)..                             sum((n)$MapS(psp,n),  phi_psp_start(psp,t) - phi_psp_stor_cap(psp,t) + phi_psp_max_gen(psp,t)) =e= 0
;
SUB_Dual_PG_PSP_normal(psp,t)$(ord(t) gt 1 and ord(t) lt card(t))..     sum((n)$MapS(psp,n),  phi_psp_normal(psp,t+1) - phi_psp_normal(psp,t) - phi_psp_stor_cap(psp,t)+ phi_psp_max_gen(psp,t)) =e= 0
;
SUB_Dual_PG_PSP_end(psp,t)$(ord(t) = card(t))..                         sum((n)$MapS(psp,n),  phi_psp_end(psp,t) - phi_psp_stor_cap(psp,t) + phi_psp_max_gen(psp,t))    =e= 0
;

SUB_Dual_PG_PSP_charge_start(psp,t)$(ord(t) = 1)..                      sum((n)$MapS(psp,n) , lam(n,t) - (phi_psp_start(psp,t) * eff_hydro(psp)) - phi_psp_power(psp,t) * 1.2 ) =e= 0
;
SUB_Dual_PG_PSP_charge_normal(psp,t)$(ord(t) gt 1)..                    sum((n)$MapS(psp,n) , lam(n,t) - (phi_psp_normal(psp,t) * eff_hydro(psp)) - phi_psp_power(psp,t) * 1.2 ) =e= 0
;
SUB_Dual_PG_PSP_gen_start(psp,t)$(ord(t) = 1)..                         sum((n)$MapS(psp,n) , lam(n,t) + phi_psp_start(psp,t) - phi_psp_power(psp,t) - phi_psp_max_gen(psp,t)) =e= 0 
;
SUB_Dual_PG_PSP_gen_normal(psp,t)$(ord(t) gt 1)..                       sum((n)$MapS(psp,n) , lam(n,t) + phi_psp_normal(psp,t) - phi_psp_power(psp,t) - phi_psp_max_gen(psp,t)) =e= 0 
;

********************************************************dual Reservoir power generation*********************************************************************************************







********************************************************dual load shedding**********************************************************************************************************

SUB_Dual_LS(t)..                                                       sum(n, lam(n,t) -  phiLS(n,t))                         =l=  sum(n, LS_costs(n) ) 
;

********************************************************dual NTC power flow*********************************************************************************************************

SUB_Dual_NTC_PF(t)..                                                   sum((n,nn), lam(n,t) -  phi_NTC_ex(n,nn))              =l= 0
;
SUB_Dual_NTC_PF_inv(t)..                                               sum((n,nn),  phi_NTC_inv(nn,n))                        =l= toy_inv_costs
;

*********************************************************uncertainty set & budget for renewable generation**************************************************************************

SUB_US_PG_RR(t,DF,rr,n)$(MAP_DF(t,DF) and Map_RR(rr,n))..             AF_Res(t,rr,n) =e=  Ratio_N(t,DF,rr,n) * Budget_N(DF,rr,n) - z_PG_res(DF,rr) * (Ratio_DF(t,DF,rr,n) * Budget_Delta(DF,rr,n)) 
;
SUB_UB_Total..                                                         Gamma_res_total - sum((DF,rr),  z_PG_res(DF,rr)) =g= 0
;
SUB_UB_PG_RR(rr)..                                                     sum(DF, z_PG_res(DF,rr))  =l= Gamma_PG_res(rr)
;

********************************************************linearization with big M ***************************************************************************************************

SUB_lin1(t,DF,rr,res)$(MAP_DF(t,DF) and Map_RR_RES(rr,res))..         aux_phi_res_DF(res,t)                              =l= M *  z_PG_res(DF,rr) 
;
SUB_lin2(t,DF,rr,res)$(MAP_DF(t,DF) and Map_RR_RES(rr,res))..         phi_res(res,t) -  aux_phi_res_DF(res,t)            =l= M *  (1 - z_PG_res(DF,rr) )
;
SUB_lin3(t,DF,rr,res)$(MAP_DF(t,DF) and Map_RR_RES(rr,res))..         - M * z_PG_res(DF,rr)                              =l= aux_phi_res_DF(res,t) 
;   
SUB_lin4(t,DF,rr,res)$(MAP_DF(t,DF) and Map_RR_RES(rr,res))..         - M * (1 - z_PG_res(DF,rr) )                       =l= phi_res(res,t) -  aux_phi_res_DF(res,t) 
;






execute_unload "check_ARO_Toy.gdx";
$stop
*#########################################################Model definition##########################################################

Model Master_VO
/
MP_Total_costs
MP_Balance
/
;
Model Master
/
MP_Total_costs
MP_Balance

MP_max_gen
MP_max_cap
MP_startup_constr

MP_max_res

MP_max_gencap_ror
MP_max_inflow_ror

$ontext
MP_reservor_stor_lvl_start
MP_reservor_stor_lvl
MP_reservor_stor_lvl_end
MP_min_reservoir_gen
MP_max_reservoir_gen
MP_max_reservoir_stor_lvl
MP_min_reservoir_stor_lvl

MP_Store_level_start
MP_Store_level
MP_Store_level_end
MP_Store_level_max
MP_Store_prod_max
MP_Store_prod_max_end
$offtext
MP_ex_NTC_max
*MP_ex_NTC_max
MP_prosp_NTC_max
*MP_prosp_NTC_max

MP_LS_det
MP_ETA
/
;
model Subproblem
/
SUB_Dual_Objective

SUB_Dual_PG_gen
SUB_Dual_PG_max_on
SUB_Dual_PG_startup

SUB_Dual_PG_res

SUB_Dual_PG_ror

$ontext
SUB_Dual_PG_PSP_start
SUB_Dual_PG_PSP_normal
SUB_Dual_PG_PSP_end

SUB_Dual_PG_PSP_charge_start
SUB_Dual_PG_PSP_charge_normal

SUB_Dual_PG_PSP_gen_start
SUB_Dual_PG_PSP_gen_normal
$offtext

SUB_Dual_LS


SUB_Dual_NTC_PF
SUB_Dual_NTC_PF_inv

SUB_US_PG_RR
SUB_UB_Total
SUB_UB_PG_RR

SUB_lin1
SUB_lin2
SUB_lin3
SUB_lin4
/

;

option optcr = 0
;
Gamma_Res_total = 10
;
Gamma_PG_res(rr) = 2
;
LB                  = -1e12
;
UB                  =  1e12
;


Loop(v$((UB - LB) gt Toleranz),


AF_M_Res_fixed(t,rr,n,v)  = af_res_up(t,rr,n)
;

itaux = ord(v)
;

if( ord(v) = 1,



*#######################################################Step 2

    solve Master_VO using MIP minimizing O_M
    ;

else

    solve Master using MIP minimizing O_M
    ;
  );
*######################################################Step 3

LB =  O_M.l
*O_M.l
;
*inv_cost_master = sum(l,  inv_NTC_M.l(l) * (I_costs_new(l)/L_cap_prosp(l)));

            report_decomp(v,'itaux','')         = itaux;
            report_decomp(v,nn,n)               = inv_NTC_M.l(n,nn)                                           ;
*            report_decomp(v,'line cost','')     = inv_cost_master                                               + EPS;
            report_decomp(v,'M_obj','')         = O_M.L                                                         + EPS;
            report_decomp(v,'ETA','')           = ETA.l                                                         + EPS;
            report_decomp(v,'LB','')            = LB;
            report_decomp(v,'M_Shed','')        = SUM((t,n), Load_shed.l(t,n,v))                                + EPS;
            report_decomp(v,'M_GC','')          = SUM((g,t), var_costs(g,t) * Gen_g.l(g,t,v))                   + EPS;
            report_decomp(v,'M_LS','')          = SUM((t,n), LS_costs(n) * Load_shed.l(t,n,v))                  + EPS;

           
;
*######################################################Step 4

$include NTC_merge.gms
;
NTC_cap_sub_ex(n,nn) = NTC_cap_ex(n,nn) 
;
NTC_cap_sub_prosp(n,nn) = inv_NTC_M.l(nn,n)
;


*######################################################Step 5

solve Subproblem using MIP maximizing O_Sub
;
*######################################################Step 6

UB = min(UB,  sum((n,nn), inv_NTC_M.l(n,nn) * toy_inv_costs) + sum((nn,n), inv_NTC_M.l(nn,n) * toy_inv_costs) + O_Sub.l)
;
*            report_decomp(v,'network','')       = card(ex_l);
            report_decomp(v,'Sub_obj','')       = O_Sub.L                                                       + EPS;
            report_decomp(v,'UB','')            = UB;
*            report_decomp(v,'Sub_Shed','')      = SUM((n,d,t), phiLS.m(n,d,t))                                      + EPS;
            report_decomp(v,'UB-LB','')         = UB - LB                                                       + EPS;
*            report_decomp(v,'Gen_conv','')      = SUM((g,t), PE_conv.l(g,t))                                    + EPS;
*            compare_av_ren(t,rr,n)              = AF_Res.l(t,rr,n) - AF_Res_up(t,rr,n);
            
*######################################################Step 7

AF_M_Res_fixed(t,rr,n,v) = AF_Res.l(t,rr,n)
;

*execute_unload "check_ARO_toy_complete.gdx"
$include Clean_NTC_inv.gms

execute_unload "check_Loop_Run.gdx";
;
)

execute_unload "check_TEP_ARO.gdx";

*#########################################################Solving##################################################################
$ontext

solve Quant_reliab_res_EU using MIP minimizing O_M
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

$offtext









