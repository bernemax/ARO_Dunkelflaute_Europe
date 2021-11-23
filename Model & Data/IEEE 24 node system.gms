option profile = 1;
option profiletol = 0.01;

$setglobal NO_Invest "*"        if "*" no investment options are taken into account, and dispatch with unit commitment and DC powerflow is optimized

set
*time set
t /t1*t24/
*conventional generator set
g /g1*g13/
*wind generator set
w /w1*w6/
*line set
l /l1*l60/
*node set
n /n1*n32/
*expansion Korridor
*k /k1*k4/
*years in model
year/1*3/

*referenze node
ref(n) /n1/
exist_nodes(n) /n1*n24/
prosp_nodes(n) /n25*n32/
exist_lines(l) /l1*l34/
prosp_lines(l) /l35*l60/
Map_send(l,n)                       mapping of sending-line to node
Map_res(l,n)                        mapping of resiving-line to node
Map_gen(g,n)                        mapping of conventional generation to node
Map_wind(w,n)                       mapping of wind generation to node
Map_prosp_send_Line_node(l,n)       mapping of prospective sending-line to node
Map_prosp_res_Line_node(l,n)        mapping of prospective resiving-line to node
Map_prosp_nodeconnection(l,n)
;

alias
(t,tt), (year,period)
;
scalars
Sbase /100/
M    /1000/
ILmax /100000/
dis   /0.06/
intr  /0.1/
;
Parameter
genup                       upload table for generation data\parameter like costs\startups and co.
lineup                      upload table for line data
availup                     upload table for wind availability factors


System_demand(t) 
nodal_Load_share(n)
nodal_demand(n,t,year)

P_max(g)
P_min(g)
P_init(g)
ramp_up(g)
ramp_down(g)
wind_cap(w)
wind_af(t,year)

ramp_up_reserve(g)             Maximum up reserve capacity of generating unit
ramp_down_reserve(g)           Maximum down reserve capacity of generating unit

gen_costs(g)
su_costs(g)

line_cap(l)                    line capacity
b(l)                           line susceptance = 1\line reactance

Inv_costs(l,year)
price(n,t,year)

line_investment(l)
total_investment(l,year)
ANF(year)
Discount(year)

EENS(year)
Count(t)
LOLH(year)

;
*########################################################set & parameter loading####################################################
$onecho > IEEE.txt
set=Map_gen                     rng=Mapping!A2:B19                rdim=2 cDim=0
set=Map_wind                    rng=Mapping!J2:K7                 rdim=2 cDim=0
set=Map_send                    rng=Mapping!D2:E35                rdim=2 cDim=0    
set=Map_res                     rng=Mapping!G2:H35                rdim=2 cDim=0
set=Map_prosp_send_Line_node    rng=Mapping!M2:N27                rdim=2 cDim=0
set=Map_prosp_res_Line_node     rng=Mapping!P2:Q27                rdim=2 cDim=0
            
par=genup                       rng=Generation!A1:R19             rdim=1 cDim=1
par=lineup                      rng=lines!A2:D70                  rdim=1 cDim=1
par=availup                     rng=Availability!A1:B25           rdim=1 cDim=1

par=System_demand               rng=Demand!A1:B25                 rdim=1 cDim=0
par=nodal_Load_share            rng=Demand!D2:E18                 rdim=1 cDim=0
$offecho

$onUNDF
$call   gdxxrw Data_24_toys.xlsx @IEEE.txt
$GDXin  Data_24_toys.gdx
$load   Map_gen, Map_wind, Map_send, Map_res, Map_prosp_send_Line_node, Map_prosp_res_Line_node
$load   genup, lineup, availup,
$load   System_demand, nodal_Load_share
$offUNDF
;
*execute_unload "check.gdx";
*$stop

Map_prosp_nodeconnection(l,n)$Map_prosp_send_Line_node(l,n)= yes;
Map_prosp_nodeconnection(l,n)$Map_prosp_res_Line_node(l,n) = yes;
;
**********************************************************parameter assignment*******************************************************
P_max(g)                =   genup(g,'Pi_max')
;
P_min(g)                =   genup(g,'Pi_min')
;
P_init(g)               =   genup(g,'Pi_init')
;   
ramp_up(g)              =   genup(g,'Ri_up')
;
ramp_down(g)            =   genup(g,'Ri_down')
;
ramp_up_reserve(g)      =   genup(g,'Ri+')
;             
ramp_down_reserve(g)    =   genup(g,'Ri-')
;
gen_costs(g)            =   genup(g,'Ci')
;
su_costs(g)             =   genup(g,'Ci_su')
;
nodal_demand(n,t,year)  =   system_demand(t)*nodal_load_share(n) 
;
line_cap(l)             =   lineup(l,'cap') 
;   
b(l)                    =   lineup(l,'b') 
;
Inv_costs(l,year)       =   lineup(l,'Inv_costs')
;
wind_cap(w)             =   genup(w,'Pi_max')
;
wind_af(t,year)         =   availup(t,'Wind_low')
;
*ANF(year)           =   (((1 + dis)**(ord(year) - 1)) * dis)/ (((1+dis)**ord(year)) - 1)
*;
*Discount(year)      =    1 / (1+intr)**(ord(year) -1 )
*;
*execute_unload "check.gdx";
*$stop
*############################################################variables########################################################
Variables
Costs
Power_flow(l,t,year)
Theta(n,t,year)
Su(g,t,year)

;

Positive variables
gen_conv(g,t,year)
gen_wind(w,t,year)
P_on(g,t,year)


LS(n,t,year)
;
Binary Variable
x(l,t,year)
z(n,t,year)

;
*#############################################################Equations#######################################################
Equations
Total_costs

LineNode
Conect_constr


Balance

max_gen
max_cap
min_cap
startup_constr
Ramp_up_constr
Ramp_down_constr
P_on_start

EQ_wind_cap


Ex_line_angle
Ex_Line_neg_flow
Ex_line_pos_flow
Prosp_line_neg_flow
Prosp_line_pos_flow
Linearization_prosp_line_neg
Linearization_prosp_line_pos

prosp_substat_neg
Prosp_substat_pos

binary_restr
Theta_LB
Theta_UB
Theta_ref
;
*#################################################################Objective function#############################################

Total_costs..                costs                  =e=   (sum((g,t,year), gen_conv(g,t,year) * gen_costs(g))
                                                        + sum((g,t,year), Su(g,t,year) * su_costs(g))
                                                        + sum((n,t,year), LS(n,t,year) * 3000)) 
*                                                       
                                
%NO_Invest%                                             + sum((l,t,year),Inv_costs(l,year)* ANF(year) * (x(l,t,year))) 
                                
;
*##################################################################Energy balance################################################

Balance(n,t,year)..          nodal_demand(n,t,year) - LS (n,t,year) =e=  sum(g$Map_gen(g,n), gen_conv(g,t,year)*0.7)
                                                                                   + sum(w$Map_wind(w,n),gen_wind(w,t,year))

                                                        + sum(l$Map_res(l,n),power_flow(l,t,year))
                                                        - sum(l$Map_send(l,n),power_flow(l,t,year))
                                                 
%NO_Invest%                                             + sum(l$Map_prosp_res_Line_node(l,n), power_flow(l,t,year))
%NO_Invest%                                             - sum(l$Map_prosp_send_Line_node(l,n), power_flow(l,t,year))
                                                      

;
*##################################################################Investment budget#############################################

*Line_investment..                                      sum((t,k,l)$prosp_lines(l),Inv_costs(l)*x(l,t)) =l= ILmax
*;
LineNode(n,l,t,year)..                                  x(l,t,year)$Map_prosp_nodeconnection(l,n)     =l=  z(n,t,year)$Map_prosp_nodeconnection(l,n)     
;
Conect_constr(n,t,year)..                               sum(l,x(l,t,year)$prosp_lines(l)) =g= 2 * z(n,t,year)$prosp_nodes(n)
;
*##################################################################Generation funcioning##########################################

max_gen(g,t,year)..                                     Gen_conv(g,t,year)  =l= P_on(g,t,year)
;
max_cap(g,t,year)..                                     P_on(g,t,year) =l= P_max(g) 
;
min_cap(g,t,year)$(ord(t) gt 1)..                       P_on(g,t,year)  =g=  P_min(g)
;
startup_constr(g,t,year)..                              P_on(g,t,year) - P_on(g,t-1,year) =l= Su(g,t,year)
;
Ramp_up_constr(g,t,year)$(ord(t) gt 1)..                Su(g,t,year) =l= ramp_up(g)
;
Ramp_down_constr(g,t,year)$(ord(t) gt 1)..              Su(g,t,year) =g= -ramp_down(g)
;
P_on_start(g,t,year)$(ord(t) = 1)..                     P_on(g,t,year) =e= P_init(g)
;
EQ_wind_cap(w,t,year)..                                 gen_wind(w,t,year) =e= wind_cap(w) * wind_af(t,year)
;
*###############################################################Grid technical functioning#########################################

Ex_line_angle(l,t,year)$exist_lines(l)..                     power_flow(l,t,year) =e=  (B(l)*(sum(n$Map_send(l,n), Theta(n,t,year))-sum(n$Map_res(l,n), Theta(n,t,year)))) *sbase
;
Ex_line_neg_flow(l,t,year)$exist_lines(l)..                  power_flow(l,t,year) =g= -Line_cap(l)
;
Ex_line_pos_flow(l,t,year)$exist_lines(l)..                  power_flow(l,t,year) =l=  Line_cap(l)
;

Prosp_line_neg_flow(l,t,year)$prosp_lines(l)..               power_flow(l,t,year) =g= -sum((tt,period)$((ord(tt) le ord(t))and (ord(period) le ord(year))),x(l,tt,period) * Line_cap(l))  
;
Prosp_line_pos_flow(l,t,year)$prosp_lines(l)..               power_flow(l,t,year) =l=  sum((tt,period)$((ord(tt) le ord(t))and (ord(period) le ord(year))),x(l,tt,period) * Line_cap(l))  
;
Linearization_prosp_line_neg(l,t,year)$prosp_lines(l)..      -sum((tt,period)$((ord(tt) le ord(t))and (ord(period) le ord(year))),(1-x(l,tt,period)))*M   =l= power_flow(l,t,year) - B(l) * (sum(n$Map_send(l,n),Theta(n,t,year))-sum(n$Map_res(l,n),Theta(n,t,year)))*sbase 
;
Linearization_prosp_line_pos(l,t,year)$prosp_lines(l)..      sum((tt,period)$((ord(tt) le ord(t))and (ord(period) le ord(year))),(1-x(l,tt,period)))*M    =g= power_flow(l,t,year) - B(l) * (sum(n$Map_send(l,n),Theta(n,t,year))-sum(n$Map_res(l,n),Theta(n,t,year)))*sbase 
;

Theta_LB(n,t,year)$exist_nodes(n)..                           -3.1415         =l= Theta(n,t,year)
;
Theta_UB(n,t,year)$exist_nodes(n)..                           3.1415          =g= Theta(n,t,year)
;
Theta_ref(n,t,year)$exist_nodes(n)..                          Theta(n,t,year)$ref(n) =l= 0
;

prosp_substat_neg(n,t,year)$prosp_nodes(n)..                  -z(n,t,year) * 3.1415 =l= Theta(n,t,year)
;
Prosp_substat_pos(n,t,year)$prosp_nodes(n)..                  z(n,t,year)  * 3.1415 =g= Theta(n,t,year)
;
binary_restr(l)$prosp_lines(l)..                              sum((t,year), x(l,t,year)) =l= 1 +EPS
;
*#############################################################solving##############################################################




Model TEP_IEEE_24
/
Total_costs

%NO_Invest% LineNode
%NO_Invest% Conect_constr


Balance

max_gen
max_cap
min_cap
startup_constr
Ramp_up_constr
Ramp_down_constr
P_on_start

EQ_wind_cap

Ex_line_angle
Ex_Line_neg_flow
Ex_line_pos_flow

%NO_Invest% Prosp_line_neg_flow
%NO_Invest% Prosp_line_pos_flow
%NO_Invest% Linearization_prosp_line_neg
%NO_Invest% Linearization_prosp_line_pos


%NO_Invest% prosp_substat_neg
%NO_Invest% Prosp_substat_pos

%NO_Invest% binary_restr
Theta_LB
Theta_UB
Theta_ref
/;
*option limrow = 1e9;
TEP_IEEE_24.scaleopt = 1
;

solve TEP_IEEE_24 using MIP minimizing costs;

%NO_Invest% x.fx(l,t,year) = x.l(l,t,year)
;
%NO_Invest% z.fx(n,t,year) = z.l(n,t,year)
;
EENS(year) = sum((n,t),LS.l(n,t,year));

Count(t)$(sum((n,year),LS.l(n,t,year))gt 0) =1;

LOLH(year) = sum(t, count(t));
price(n,t,year) = Balance.m(n,t,year)*(-1);

%NO_Invest% line_investment(l) = sum((t,year), Inv_costs(l,year) * x.l(l,t,year));
%NO_Invest% total_investment(l,year) = sum((tt,period),Inv_costs(l,year)* ANF(year) * (x.l(l,tt,period)));

execute_unload "check.gdx" 
;

