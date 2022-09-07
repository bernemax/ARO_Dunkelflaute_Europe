SET b ’Bus’ /b1*b3/;
SET l ’Line’ /l1*l3/;
SET t ’Time period’ /t1*t3/;
 SET u ’Unit’ /u1*u5/;
 SET o ’scenarios’ /o1*o2/;
 SET g ’scenarios’ /g1*g2/;
 SET incDES(l,b) ’destination bus’ /l1.b2,l2.b3,l3.b3/;
 SET incORI(l,b) ’origin bus’ /l1.b1,l2.b1,l3.b2/;
 SET incD(u) ’demand’ /u1*u2/;
 SET incG(u) ’conventional power plant’ /u3/;
 SET incR(u) ’stochastic production facility’ /u4/;
 SET incS(u) ’storage unit’ /u5/;
 SET incMB(b) ’buses connected to the main grid’ /b1/;
 SET incREF(b) ’reference bus’ /b1/;
 SET incDB(u,b) ’demand at bus’ /u1.b2,u2.b3/;
 SET incGB(u,b) ’conventional power plant at bus’ /u3.b2/;
 SET incRB(u,b) ’stochastic production facility at bus’ /u4.b3/;
 SET incSB(u,b) ’storage unit at bus’ /u5.b3/;
 SCALAR TT ’Number of trading hours in a day’ /3/;
 SCALAR delta ’Power-energy conversion factor’ /1/;
 SCALAR mup ’Output conversion efficiency of the storage unit’ /0.9/;
 SCALAR mun ’Input conversion efficiency of the storage unit’ /0.9/;
 SCALAR Sbase ’Base apparent power’ /100/;
 SCALAR Vbase ’Base voltage’ /10/;
 SCALAR PV_max ’Maximum power that can be produced by the VPP’/40/;
 SCALAR PV_min ’Maximum power that can be consumed by the VPP’ /-60/;
 SCALAR beta ’Weight of CVaR’ /1/;
 SCALAR alpha ’Confidence level used for calculating CVaR’ /0.8/;
 SCALAR GammaR ’Parameter used to control the protection level of constraints’ /1/;
***** Demands data
TABLE PD_max(u,t) ’Maximum load level for unit u in time period t’
   t1 t2 t3
u1 20 20 10
u2 30 30 15;
TABLE PD_min(u,t) ’Minimum load level for unit u in time period t’
   t1 t2 t3
u1 0  0  0
u2 5  5  5;
TABLE Utility(u,t) ’Utility of unit u for energy consumption in time period t’
   t1 t2 t3
u1 40 50 40
u2 50 60 50;
PARAMETER ED_min(u) ’Minimum daily energy consumption requested by unit i’
/u1 30
 u2 50/;
 
PARAMETER RD_up(u) ’Load drop ramping limits for unit u’
/u1 15
u2 25/;
PARAMETER RD_do(u) ’Pick-up ramping limit for unit u’
/u1 15
u2 25/;
 PARAMETER PD0(u) ’Initial load level for each unit’
 /u1 10
 u2 20/;
***** Conventional power plants data
PARAMETER PG_max(u) ’Maximum power production limit for unit u in time period t’
/u3 20/;
PARAMETER PG_min(u) ’Minimum power production limit for unit u in time period t’
/u3 0/;
PARAMETER RG_up(u) ’Ramping up limits for unit u’
/u3 20/;
PARAMETER RG_do(u) ’Ramping down limit for unit u’
/u3 20/;
PARAMETER CF(u) ’Fixed cost for unit u’
 /u3 10/;
PARAMETER CG(u) ’Variable cost for unit u’
/u3 45/;
PARAMETER PG0(u) ’Initial power production of unit u’
/u3 0/;
 PARAMETER V0(u) ’Initial status of unit u’
/u3 0/;
***** Storage units data
PARAMETER ES_max(u) ’Energy capacity of the storage unit u’
/u5 10/;
PARAMETER ES_min(u) ’Minimum energy capacity of the storage unit u’
/u5 5/;
PARAMETER PS_p(u) ’Maximum power that can be produced by unit u’
/u5 10/;
PARAMETER PS_n(u) ’Maximum power that can be transferred to unit u’
/u5 10/;
PARAMETER ES0(u) ’Initial energy stored in the storage unit’
/u5 5/;
***** Network data
PARAMETER PL_max(l) ’Capacity of line l’
/l1 50
l2 50
l3 50/;
PARAMETER BL(l) ’Susceptance of line l’
/l1 200
l2 200
l3 200/;
BL(l)=BL(l)/(Sbase/(Vbase**2));
PARAMETER PM_max(b) ’Maximum power that can be bought from the main grid’
/b1 100/;

***** Scenarios of uncertain parameters
TABLE PR_max_n ’Nominal value of available stochastic production in time period t’
   t1 t2 t3
u4 6  7  5;
TABLE PR_max_d ’Deviation value of available stochastic production in time period t’
   t1 t2 t3
u4 2  3  4;
TABLE lambda_DA ’Scenarios of prices in the day-ahead energy market in time period t’
   t1 t2 t3
o1 20 40 30
o2 30 50 40;
TABLE lambda_RT ’Scenarios of prices in the real-time energy market in time period t’
      t1 t2 t3
o1.g1 25 50 25
o1.g2 10 45 28
o2.g1 35 60 35
o2.g2 20 55 38;
PARAMETER prob(o,g) ’Probability of scenarios’
/o1.g1 0.16
o1.g2 0.24
o2.g1 0.24
o2.g2 0.36/;
***** Actual data of the day-ahead market prices
PARAMETER lambda_DA_act(t) ’Actual day-ahead market price in time period t’
/t1 25
t2 50
t3 35/;
VARIABLES
pl(l,t,o,g) ’Power flow through line l in time period t’
pda(t) ’Power traded by the VPP in the day-ahead energy market in time period t’
prt(t,o,g) ’Power traded by the VPP in the real-time energy market in time period t’
pm(b,t,o,g) ’Power injection at bus b connected to the main grid in time period t’
teta(b,t,o,g) ’Voltage angle at bus b in time period t’
z ’Objective’
zsc(o,g) ’Objective in each scenario’
p(u,t,o,g) ’Power dispatch of unit u in time period t’
rho ’Value at risk’
cvar ’Conditional value at risk metric’
ep ’Expected profit’;
POSITIVE VARIABLES
es(u,t,o,g) ’Energy stored at the end of time period t’
psp(u,t,o,g) ’Power produced by the storage unit in time period t’
psn(u,t,o,g) ’Power transferred to the storage unit in time period t’
mu(o,g) ’Auxiliary variable to calculate the conditional value at risk’
KappaR(u,t,o,g) ’Dual variable used in the robust optimization model’
PsiR(u,t,o,g) ’Dual variable used in the robust optimization model’
yR(u,t,o,g) ’Auxiliary variable used in the robust optimization model’;

BINARY VARIABLES
v(u,t) ’Binary variable to state the commitment status of unit u in time period t’;

*****************************************************
*** Equations definition *****
EQUATIONS
obj ’Objective function’
objscen ’Objective in each scenario’
expected_profit ’Expected profit’
cvar_calculation1 ’Calculating the conditional value at risk’
cvar_calculation2 ’Calculating the conditional value at risk’
nodal_balance_mg ’Power balance at the main grid buses’
nodal_balance ’Power balance at the remaining buses’
trade ’Power traded in the day-ahead and real-time markets’
line_power ’Power flow through lines’
line_max ’Upper bound of lines flows’
line_min ’Lower bound of lines flows’
voltage_angle_ref ’Voltage angle at reference bus’
voltage_angle_max ’Upper bound of voltage angles’
voltage_angle_min ’Lower bound of voltage angles’
tradeda_min ’Lower bound of power traded in the day-ahead market’
tradeda_max ’Upper bound of power traded in the day-ahead market’
tradedart_min ’Lower bound of power traded in the energy markets’
tradedart_max ’Upper bound of power traded in the energy markets’
trade_min ’Lower bound of power injection at each bus’
trade_max ’Upper bound of power injection at each bus’
dailyenergy_min ’Daily minimum energy consumption for each demand’
demand_max ’Upper bound of load level’
demand_min ’Lower bound of load level’
demand_ramp_down_initial ’Load ramp down limitation’
demand_ramp_pick_initial ’Load ramp up limitation’
demand_ramp_down ’Load ramp down limitation’
demand_ramp_pick ’Load ramp up limitation’
CPP_max ’Maximum power production limitation’
CPP_min ’Minimum power production limitation’
CPP_ramp_down_initial ’Ramp down production limitation’
CPP_ramp_up_initial ’Ramp up production limitation’
CCP_ramp_down ’Ramp down production limitation’
CCP_ramp_up ’Ramp up production limitation’
storage_balance_initial ’Power balance equation in the storage unit’
storage_balance ’Power balance equation in the storage unit’
storage_capacity ’Upper bound of energy stored in the storage unit’
storage_min ’Lower bound of energy stored in the storage unit’
storage_psp_max ’Maxmimum power that can be produced by storage unit’
storage_psn_max ’Maxmimum power that can be transferred to storage unit’

stochastic_max1 ’Maximum power production limitation in robust form’
stochastic_max2 ’Maximum power production limitation in robust form’
stochastic_max3 ’Maximum power production limitation in robust form’;
*

obj.. z=E=ep+beta*CVAR
;
objscen(o,g).. zsc(o,g) =E= SUM(t,lambda_DA(o,t)*pda(t)*delta+ lambda_RT(o,g,t)*prt(t,o,g)*delta
                          + SUM(u$incD(u),Utility(u,t)*p(u,t,o,g)*delta)
                          - SUM(u$incG(u),CF(u)*v(u,t)+CG(u)*p(u,t,o,g) *delta))
;
expected_profit..    ep =E= SUM((o,g),prob(o,g)*zsc(o,g))
;
cvar_calculation1.. CVAR =e= rho-(1/(1-alpha))*SUM((o,g),prob(o,g)*mu(o,g))
;
cvar_calculation2(o,g)..  -zsc(o,g)+rho-mu(o,g)=L=0
;
nodal_balance_mg(b,t,o,g)$(incMB(b)).. SUM(u$incGB(u,b),p(u,t,o,g))
                                     + SUM(u$incRB(u,b),p(u,t,o,g))
                                     + SUM(u$incSB(u,b),psp(u,t,o,g)-psn(u,t,o,g))
                                     - SUM(l$incORI(l,b),pl(l,t,o,g))
                                     + SUM(l$incDES(l,b),pl(l,t,o,g))
                                     =E= pm(b,t,o,g)+SUM(u$incDB(u,b),p(u,t,o,g))
;
nodal_balance(b,t,o,g)$(NOT incMB(b))..  SUM(u$incGB(u,b),p(u,t,o,g))
                                       + SUM(u$incRB(u,b),p(u,t,o,g))
                                       + SUM(u$incSB(u,b),psp(u,t,o,g)-psn(u,t,o,g))
                                       - SUM(l$incORI(l,b),pl(l,t,o,g))
                                       + SUM(l$incDES(l,b),pl(l,t,o,g))
                                       =E= SUM(u$incDB(u,b),p(u,t,o,g))
;
trade(t,o,g)..    pda(t)+prt(t,o,g)=E=SUM(b$incMB(b),pm(b,t,o,g))
;
line_power(l,t,o,g)..  pl(l,t,o,g)=E=Sbase*BL(l)*(SUM(b$incORI(l,b),teta(b,t,o,g))-SUM(b$incDES(l,b),teta(b,t,o,g)))
;
line_max(l,t,o,g)..   pl(l,t,o,g)=L=PL_max(l)
;
line_min(l,t,o,g).. -PL_max(l)=L=pl(l,t,o,g)
;
voltage_angle_ref(b,t,o,g)$(incREF(b)).. teta(b,t,o,g)=E=0
;
voltage_angle_max(b,t,o,g).. teta(b,t,o,g)=L=Pi
;
voltage_angle_min(b,t,o,g).. -Pi=L=teta(b,t,o,g)
;
tradeda_min(t).. PV_min=L=pda(t)
;
tradeda_max(t).. pda(t)=L=PV_max
;
tradedart_min(t,o,g).. PV_min=L=pda(t)+prt(t,o,g)
;
tradedart_max(t,o,g).. pda(t)+prt(t,o,g)=L=PV_max
;
trade_min(b,t,o,g)$(incMB(b)).. -PM_max(b)=L=pm(b,t,o,g)
;
trade_max(b,t,o,g)$(incMB(b)).. pm(b,t,o,g)=L=PM_max(b)
;
dailyenergy_min(u,o,g)$(incD(u)).. SUM(t,p(u,t,o,g)*delta) =G= ED_min(u)
;
demand_max(u,t,o,g)$(incD(u))..  p(u,t,o,g) =L= PD_max(u,t)
;
demand_min(u,t,o,g)$(incD(u)).. PD_min(u,t) =L= p(u,t,o,g)
;
demand_ramp_down_initial(u,t,o,g)$((incD(u)) AND (ORD(t) EQ 1))..  -RD_do(u) =L= p(u,t,o,g) - PD0(u)
;
demand_ramp_pick_initial(u,t,o,g)$((incD(u)) AND (ORD(t) EQ 1)).. p(u,t,o,g)-PD0(u) =L= RD_up(u)
;
demand_ramp_down(u,t,o,g)$((incD(u)) AND (ORD(t) GE 2)).. - RD_do(u) =L= p(u,t,o,g)-p(u,t-1,o,g)
;
demand_ramp_pick(u,t,o,g)$((incD(u)) AND (ORD(t) GE 2))..  p(u,t,o,g)-p(u,t-1,o,g)=L=RD_up(u)
;
CPP_max(u,t,o,g)$(incG(u)).. p(u,t,o,g) =L= PG_max(u)*v(u,t)
;
CPP_min(u,t,o,g)$(incG(u)).. v(u,t)*PG_min(u) =L= p(u,t,o,g)
;
CPP_ramp_down_initial(u,t,o,g)$((incG(u)) AND (ORD(t) EQ 1))..  -RG_do(u) =L= p(u,t,o,g)-PG0(u)
;
CPP_ramp_up_initial(u,t,o,g)$((incG(u)) AND (ORD(t) EQ 1))..  p(u,t,o,g)-PG0(u) =L= RG_up(u)
;
CCP_ramp_down(u,t,o,g)$((incG(u)) AND (ORD(t) GE 2))..  - RG_do(u) =L= p(u,t,o,g)-p(u,t-1,o,g)
;
CCP_ramp_up(u,t,o,g)$((incG(u)) AND (ORD(t) GE 2)).. p(u,t,o,g)- p(u,t-1,o,g)=L=RG_up(u)
;
storage_balance_initial(u,t,o,g)$((incS(u)) AND (ORD(t) EQ 1)).. es(u,t,o,g)=E=ES0(u)+mun*psn(u,t,o,g)*delta-psp(u,t,o,g) * delta/mup
;
storage_balance(u,t,o,g)$((incS(u)) AND (ORD(t) GE 2))..   es(u,t,o,g)=E=es(u,t-1,o,g) + mun*psn(u,t,o,g)*delta-psp(u,t,o,g)* delta/mup
;
storage_capacity(u,t,o,g)$(incS(u)).. es(u,t,o,g)=L=ES_max(u)
;
storage_min(u,t,o,g)$(incS(u)).. es(u,t,o,g)=G=ES_min(u)
;
storage_psp_max(u,t,o,g)$(incS(u)).. psp(u,t,o,g)=L=PS_p(u)
;
storage_psn_max(u,t,o,g)$(incS(u)).. psn(u,t,o,g)=L=PS_n(u)
;
*************************************************
stochastic_max1(u,t,o,g)$(incR(u))..   p(u,t,o,g) + GammaR * KappaR(u,t,o,g) + PsiR(u,t,o,g)  =L= PR_max_n(u,t)
;
stochastic_max2(u,t,o,g)$(incR(u))..   KappaR(u,t,o,g) + PsiR(u,t,o,g) =G= PR_max_d(u,t) * yR(u,t,o,g)
;
stochastic_max3(u,t,o,g)$(incR(u))..   yR(u,t,o,g)=G=1
;
************************************************
*************************************************
***Model definition *****************
MODEL SSDA /all/;
OPTION OPTCR=0;
OPTION OPTCA=0;
OPTION iterlim=1e8;
************************************************
*** Parameters used to save the results*******
PARAMETER state ’Convergence status’;
PARAMETER pda_act ’Actual power traded in the day-ahead market’;
PARAMETER revenueda_act ’Revenue in the day-ahead market’;
******************************
*** Solution *********************
SOLVE SSDA USING MIP MAXIMIZING z;
state = SSDA.modelstat;
pda_act(t)=pda.l(t);
revenueda_act=SUM(t,pda_act(t)*lambda_DA_act(t));
*********************************************
display state, pda_act, revenueda_act;

execute_unload "check_Virtual_PP.gdx"
;









































