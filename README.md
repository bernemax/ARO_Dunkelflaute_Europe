# Adaptive Robust Optimization for European Electricity System Planning Considering Regional Dunkelflaute Events 

This repository encompasses a capacity expansion model that identifies the worst-case regional "Dunkelflaute" events — prolonged periods of low wind and solar availability — and incorporates them into the optimization process. Furthermore the deterministic counterpart is provided, which indentifies hte optimal generation capacity mix based on an average weather year.

## Model, Code, Solver and Data
The optimization problem is formulated with GAMS. Gurobi version 11.0 (Barrier algorithm) is used to solve the optimization problem. 
The data for both models are stored in a excle file:
- Deterministic model: Data_Input.xlsx
- ARO model: Data_Input_ARO.xlsx

### Specifications Adaptive Robust Optimization Model:
Gurobi solver parameters:
- Primal Problem: Method=2, BarConvTol =  0, Crossover = 0
- Dual Problem: ScaleFlag = 1, Barhomogeneous = 1, NumericFocus =1, Presolve=2, BarConvTol =  0.0

The uncertainty buget must be adjusted mannualy within the GAMS code - section: line 869 - line 884

## Consideration: 
- A system of 24 EU countries an 50 nodes 
- Renewable electricity generation resources like solar PV, wind-onshore, wind-offshore, run of river and hydro reservoirs
- Storages like lithium battery, hydrogen and hydro pumping storage plants
- High voltage electricity grid - power flow is modelled using linearizied DC OPF
- Future synthetic country demand profiles
- Wind and PV generation capacity profiles from renewables ninja
- Country specific hydro generation potentials 

## Map of the Base System  
![](https://github.com/bernemax/ARO_EU/blob/main/Pictures%20and%20Maps/Benchmark%20System.png)

