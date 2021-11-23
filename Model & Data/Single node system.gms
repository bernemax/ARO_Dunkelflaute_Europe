option profile = 1;
option profiletol = 0.01;

set
*time set
t /t1*t24/
*generator set
g /g1*g13/
*winf generator set
w /w1*w6/
*years in model
year/1*3/
*referenze node
;

alias
(t,tt), (year,period)
;
scalars
Sbase /100/
dis   /0.06/
intr  /0.1/
;
Parameter
genup                       upload table for generation data\parameter like costs\startups and co.
availup

demand(t,year)

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

price(t,year)
ANF(year)
Discount(year)

EENS(year)
Count(t)
LOLH(year)
;

table System_demand (t,year,*)  Total system demand for each t
*first column: set t . year 1 to year 10
             load
t1.1*3       1775.835
t2.1*3       1669.815
t3.1*3       1590.3
t4.1*3       1563.795
t5.1*3       1563.795
t6.1*3       1590.3
t7.1*3       1961.37
t8.1*3       2279.43
t9.1*3       2517.975
t10.1*3      2544.48
t11.1*3      2544.48
t12.1*3      2517.975
t13.1*3      2517.975
t14.1*3      2517.975
t15.1*3      2464.965
t16.1*3      2464.965
t17.1*3      2623.995
t18.1*3      2650.5
t19.1*3      2650.5
t20.1*3      2544.48
t21.1*3      2411.955
t22.1*3      2199.915
t23.1*3      1934.865
t24.1*3      1669.815
*$offtext
;
*########################################################set & parameter loading####################################################
$onecho > IEEE.txt          
par=genup                       rng=Generation!A1:R14             rdim=1 cDim=1
par=availup                     rng=Availability!A1:B25           rdim=1 cDim=1
$offecho

$onUNDF
$call   gdxxrw Data_24_toys.xlsx @IEEE.txt
$GDXin  Data_24_toys.gdx
$load   genup, availup
$offUNDF

;
**********************************************************parameter assignment*******************************************************
P_max(g)            =   genup(g,'Pi_max')
;
P_min(g)            =   genup(g,'Pi_min')
;
P_init(g)           =   genup(g,'Pi_init')
;
ramp_up(g)          =   genup(g,'Ri_up')
;
ramp_down(g)        =   genup(g,'Ri_down')
;
ramp_up_reserve(g)  =   genup(g,'Ri+')
;             
ramp_down_reserve(g)=   genup(g,'Ri-')
;
gen_costs(g)        =   genup(g,'Ci')
;
su_costs(g)         =   genup(g,'Ci_su')
;
demand(t,year)      =   system_demand(t,year,'load')
;
wind_cap(w)             =   genup(w,'Pi_max')
;
wind_af(t,year)         =   availup(t,'Wind_low')
;
ANF(year)           =   (((1 + dis)**(ord(year) - 1)) * dis)/ (((1+dis)**ord(year)) - 1)
;
Discount(year)      =    1 / (1+intr)**(ord(year) -1 )
;

*execute_unload "check.gdx";
*$stop
*############################################################variables########################################################
Variables
Costs
Su(g,t,year)

;

Positive variables
gen(g,t,year)
gen_wind(w,t,year)
P_on(g,t,year)

LS(t,year)
;
Binary Variable
x(t,year)
;
*#############################################################Equations#######################################################
Equations
Total_costs

Balance

max_gen
max_cap
min_cap
startup_constr
Ramp_up_constr
Ramp_down_constr
P_on_start

EQ_wind_cap

;
*#################################################################Objective function#############################################

Total_costs..                costs                  =e=   sum((g,t,year), gen(g,t,year) * gen_costs(g))
                                                        + sum((g,t,year), Su(g,t,year) * su_costs(g))
                                                        + sum((t,year), LS(t,year) * 3000)                                             
                                

                             
;
*##################################################################Energy balance################################################

Balance(t,year)..          demand(t,year) - LS (t,year)  =e=  sum(g, gen(g,t,year))
                                                            + sum(w,gen_wind(w,t,year))
;
*##################################################################Generation funcioning##########################################

max_gen(g,t,year)..                                     Gen(g,t,year)  =l= P_on(g,t,year)
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
*#############################################################solving##############################################################

Model TEP_IEEE_24_to_single_node /all/;
*option limrow = 1e9;
TEP_IEEE_24_to_single_node.scaleopt = 1
;

solve TEP_IEEE_24_to_single_node using LP minimizing costs;

price(t,year) = Balance.m(t,year)*(-1);

Count(t)$(sum((year),LS.l(t,year))gt 0) =1;
LOLH(year) = sum(t, count(t));
EENS(year) = sum((t),LS.l(t,year));

display price, LOLH, EENS

execute_unload "check_single.gdx" 
;
