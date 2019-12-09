# Functions

```@contents
```


This is a list of all the functions used in the Socio-hydrology package.


## Social Dynamics

The following functions are used to simulate social consistency and conformity dynamics. For more information about consistency-conformity dynamics refer to [this](http://groups.csail.mit.edu/belief-dynamics/MURI/papers07/Pagedblcoord14.pdf) paper.

```@docs
socdyn(nc, ns, a, p, steps, adfreq, seed, model)
```

```@docs
socdyncoupexp(n, ns, belief, soc, p, steps)
```

```@docs
socdyncoupad(n, adflag, belief, popfrac, soc, p, steps)
```

```@docs
treefuncexp(ss, expnum, soc, pconsist, simtime, iurate)
```

```@docs
treefuncad(ss, adflag, soc, pconsist, simtime, iurate, spreadrate)
```

## Coupled Socio-Hydrology 

```@docs
SocioFEHM(; conc_risk = 0, exp_adv = 0, exprate_advper = 0.03 , simulationtime = 20, cthresh = 30, pid = [0, 0, 0],  measure_period = 1, predetect_time = 0, startpumptime = 10, init_urate = 0.99, popul= 10000, agelimit = 70, risk_percentile = .90,  adtargetfrac = 0.5, FEHMprefix = "cm", outputfile = "default_output_file.txt")
```


## Support Functions

```@docs
pidcontrol(crthresh, pK, dK, iK, conchist, Dt, sig, exp_adv, expnum_advper)
```

```@docs
updaterec2(soc, cc, period, agelimit)
```

```@docs
getrisk2(soc, cc, agelimit, irbw, ef, mfi, cpf)
```

## index

```@index
```

