# Adaptive Robust Optimization for European Electricity System Planning Considering Regional Dunkelflaute Events 

This repository entails the capacity expansion model for a fully decarbonized European electricity system using an Adaptive Robust Optimization (ARO) framework. The model endogenously identifies the worst regional Dunkelflaute events, prolonged periods of low wind and solar availability, and incorporates multiple extreme weather realizations within a single optimization run. Furthermore the deterministic counterpart is provided, which calculates capacity expansion based on an average weather year.
The repository contains both, the deterministic expansion model based on an average weather year and the ARO model. 

## Model, Code, Solver and Data
The optimization problem is formulated using GAMS. We use Gurobi 11.0 to solve the optimization problem using the Barrier algorithm. 
The data for both models are stored in a excle file:
- Deterministic model: Data_Input.xlsx
- ARO model: Data_Input_ARO.xlsx

### Specifications Adaptive Robust Optimization Model:
Gurobi solver parameters:
- Primal Problem: Method=2, BarConvTol =  0, Crossover = 0
- Dual Problem: ScaleFlag = 1, Barhomogeneous = 1, NumericFocus =1, Presolve=2, BarConvTol =  0.0

The uncertianty buget must be adjusted mannualy within the GAMS code in section line 869 - line 884

## Consideration: 
- A system of 24 EU countries is examined
- Renewable elecricity resources like PV, wind-onshore, wind-offshore, hydro 
- Storages like battery, psp, reservoire, hydrogen
- High voltage electricity grid, DC OPF
- Future synthetic country based demand profiles
- Wind and PV generation capacity profiles (historically 40 Years)
- Hydro generation potentials country wise

## Map of the Base System  
![](https://github.com/bernemax/ARO_EU/blob/main/Pictures%20and%20Maps/Benchmark%20System.png)

