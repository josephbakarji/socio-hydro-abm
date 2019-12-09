
<a id='Functions-1'></a>

# Functions

- [Functions](functions.md#Functions-1)
    - [Social Dynamics](functions.md#Social-Dynamics-1)
    - [Coupled Socio-Hydrology](functions.md#Coupled-Socio-Hydrology-1)
    - [Support Functions](functions.md#Support-Functions-1)
    - [index](functions.md#index-1)
- [Examples](examples.md#Examples-1)
    - [Which social model to use](examples.md#Which-social-model-to-use-1)
    - [Concentration vs. Risk](examples.md#Concentration-vs.-Risk-1)
- [Introduction](index.md#Introduction-1)
    - [Problem Statement](index.md#Problem-Statement-1)
    - [Social Modeling](index.md#Social-Modeling-1)
    - [Water Contamination](index.md#Water-Contamination-1)
    - [Control in Coupling Socio-Hydological Dynamics](index.md#Control-in-Coupling-Socio-Hydological-Dynamics-1)


This is a list of all the functions used in the Socio-hydrology package.


<a id='Social-Dynamics-1'></a>

## Social Dynamics


The following functions are used to simulate social consistency and conformity dynamics. For more information about consistency-conformity dynamics refer to [this](http://groups.csail.mit.edu/belief-dynamics/MURI/papers07/Pagedblcoord14.pdf) paper.

<a id='SocialDynamics.socdyn-Tuple{Any,Any,Any,Any,Any,Any,Any,Any}' href='#SocialDynamics.socdyn-Tuple{Any,Any,Any,Any,Any,Any,Any,Any}'>#</a>
**`SocialDynamics.socdyn`** &mdash; *Method*.



```
socdyn(nc, ns, a, p, steps, adfreq, seed, model)
```

Basic consistency-conformity social dynamics simulation function.

Arguments:

  * `nc` : Number of non-expert citizens
  * `ns` : number of experts
  * `a` : number of attributes (belief, usage)
  * `steps` : number of iterations each consisting of 1 interaction/person
  * `adfreq` : advertising frequency
  * `model` : expert influence for `model = "scientist"`, one-time media influence for `model = "ad"`, or regular media ads for `model = "regad"`

Returns:

  * `n-tuse`: number of users

<a id='SocialDynamics.socdyncoupexp-Tuple{Any,Any,Any,Any,Any,Any}' href='#SocialDynamics.socdyncoupexp-Tuple{Any,Any,Any,Any,Any,Any}'>#</a>
**`SocialDynamics.socdyncoupexp`** &mdash; *Method*.



```
socdyncoupexp(n, ns, belief, soc, p, steps)
```

Expert social dynamics.

Arguments:

  * `n`: population size
  * `ns` : number of experts
  * `belief` : binary belief of water contamination
  * `soc` : social record `[belief, usage, cont-accumulation, age]`.
  * `p` : consistency rate; which gives the conformity rate `(1-p)`.
  * `steps`: number of iterations each consisting of 1 interaction/person

Returns:

  * updated `soc`

<a id='SocialDynamics.socdyncoupad-Tuple{Any,Any,Any,Any,Any,Any,Any}' href='#SocialDynamics.socdyncoupad-Tuple{Any,Any,Any,Any,Any,Any,Any}'>#</a>
**`SocialDynamics.socdyncoupad`** &mdash; *Method*.



```
socdyncoupad(n, adflag, belief, popfrac, soc, p, steps)
```

Media social dynamics.

Arguments:

  * `n`: population size
  * `adflag` : media influence if `adflag = 1`, do nothing otherwise.
  * `belief` : binary belief of water contamination
  * `popfrac` : fraction of population targetted with each ad campain.
  * `soc` : social record `[belief, usage, cont-accumulation, age]`.
  * `p` : consistency rate; which gives the conformity rate `(1-p)`.
  * `steps`: number of iterations each consisting of 1 interaction/person

Returns:

  * updated `soc`

<a id='SocialDynamics.treefuncexp-Tuple{Any,Any,Any,Any,Any,Any}' href='#SocialDynamics.treefuncexp-Tuple{Any,Any,Any,Any,Any,Any}'>#</a>
**`SocialDynamics.treefuncexp`** &mdash; *Method*.



```
treefuncexp(ss, expnum, soc, pconsist, simtime, iurate)
```

Expert hierarchical social dynamics according to interaction rate

Arguments:

  * `ss` : vector for branching structure. For example `[2 2 2 2]` is a binary tree with 4 levels
  * `expnum` : number of experts 
  * `soc` : social record `[belief, usage, cont-accumulation, age]`.
  * `pconsist` : consistency rate
  * `simtime` : simulation time (per interaction interval)
  * `iurate` : initial usage rate

Returns:

  * updated `soc`.

<a id='SocialDynamics.treefuncad-Tuple{Any,Any,Any,Any,Any,Any,Any}' href='#SocialDynamics.treefuncad-Tuple{Any,Any,Any,Any,Any,Any,Any}'>#</a>
**`SocialDynamics.treefuncad`** &mdash; *Method*.



```
treefuncad(ss, adflag, soc, pconsist, simtime, iurate, spreadrate)
```

Media hierarchical social dynamics according to interaction rate

Arguments:

  * `ss` : vector for branching structure. For example `[2 2 2 2]` is a binary tree with 4 levels
  * `adflag` : media influence if `adflag = 1`, do nothing otherwise.
  * `soc` : social record `[belief, usage, cont-accumulation, age]`.
  * `pconsist` : consistency rate
  * `simtime` : simulation time (per interaction interval)
  * `iurate` : initial usage rate
  * `spreadrate` : portion of population affected by ads.

Returns:

  * updated `soc`.


<a id='Coupled-Socio-Hydrology-1'></a>

## Coupled Socio-Hydrology

<a id='SocioHydrology.SocioFEHM-Tuple{}' href='#SocioHydrology.SocioFEHM-Tuple{}'>#</a>
**`SocioHydrology.SocioFEHM`** &mdash; *Method*.



```
SocioFEHM(; conc_risk = 0, exp_adv = 0, exprate_advper = 0.03 , simulationtime = 20, cthresh = 30, pid = [0, 0, 0],  measure_period = 1, predetect_time = 0, startpumptime = 10, init_urate = 0.99, popul= 10000, agelimit = 70, risk_percentile = .90,  adtargetfrac = 0.5, FEHMprefix = "cm", outputfile = "default_output_file.txt")
```

[requires names of variables]

Simulate a coupled consistency-conformity social dynamics with FEHM for contaminated aquifer.

Arguments:

  * `conc_risk` : concentration control (0), or risk control (1).
  * `exp_adv` : expert influence (0), or media influence (1).
  * `exprate_advper` : fraction of experts in population (if `exp_adv = 0`), or advertising period (if `exprate_advper = 1`).
  * `simulationtime` : Total time of coupled simulation (in years).
  * `cthresh` : concentration threshold (control reference). Risk threshold `rthresh` is calculated in equivalence.
  * `pid` : vector `[pK, dK, iK]` of proportional-derivative-integral control coefficients. 
  * `measure_period` : time interval between two successive measurement events (years).
  * `predetect_time` : time before contaminants are detected in acquifer (in years).
  * `startpumptime` : Time (from beginning of FEHM simulation) after which pumping starts (years)
  * `init_urate` : fraction of the population that initially uses the water.
  * `popul` : population size.
  * `agelimit` : age at which people die, and get replaced by a new-born (used for risk control).
  * `risk_percentile`: Percentile of people kept below risk threshold.
  * `adtargetfrac` : fraction of population reached by media influence (used for `exp_adv = 1`).
  * `FEHMprefix` : FEHM prefix of files for aquifer simulation, placed in `./contaminantion-model/`.
  * `outputfile` : Default suffix for saving data in text files; set to `""` to prevent saving.

Returns:

return times, prate, adorbel, adornumexp, ucount

  * `times`: Times in years since of FEHM simulation.
  * `adornumexp`: number of employed experts if `exp_adv = 0`, or period between sucessive ads if `exp_adv = 1`
  * `ucount`: number of water users.
  * `conchist` : aquifer concentration history


<a id='Support-Functions-1'></a>

## Support Functions

<a id='SupportFunc.pidcontrol-Tuple{Any,Any,Any,Any,Any,Any,Any,Any,Any}' href='#SupportFunc.pidcontrol-Tuple{Any,Any,Any,Any,Any,Any,Any,Any,Any}'>#</a>
**`SupportFunc.pidcontrol`** &mdash; *Method*.



```
pidcontrol(crthresh, pK, dK, iK, conchist, Dt, sig, exp_adv, expnum_advper)
```

Proportional-Derivative-Integral (PID) control of concentration or risk using a gaussian weight.

Arguments:

  * `crthresh`: concentration or risk threshold used as control reference.
  * `pK`: proportional coefficient.
  * `dK`: derivative coefficient.
  * `iK`: integral coefficient.
  * `conchist`: contaminant concentration record (all years until then)
  * `Dt`: integration time increments. 
  * `sig`: gaussian weight standard deviation.
  * `exp_adv`: expert influence (0), or media influence (1).
  * `expnum_advper` : number of experts (if `exp_adv = 0`), or advertising intervals (if `exp_adv = 1`).

Returns:

  * `belief` : boolean belief of experts or advertisers.
  * `exp_ad` : number of experts (if `exp_adv = 0`), or advertising intervals (if `exp_adv = 1`).

<a id='SupportFunc.updaterec2-Tuple{Any,Any,Any,Any}' href='#SupportFunc.updaterec2-Tuple{Any,Any,Any,Any}'>#</a>
**`SupportFunc.updaterec2`** &mdash; *Method*.



```
updaterec2(soc, cc, period, agelimit)
```

Updates the `soc` array containing social and contamination record. This method of storing records assumes that individuals will be exposed with the same concentration as that of this year for the rest of their life (for calculating `cont-accumulation`).

Arguments:

  * `soc`: `[belief, usage, cont-accumulation, age]` of every individual of the past year
  * `cc`: contaminant concentration
  * `period` : coupling time increment (years)
  * `agelimit` : age limit of each individual

Returns:

  * `soc`

<a id='SupportFunc.getrisk2-Tuple{Any,Any,Any,Any,Any,Any,Any}' href='#SupportFunc.getrisk2-Tuple{Any,Any,Any,Any,Any,Any,Any}'>#</a>
**`SupportFunc.getrisk2`** &mdash; *Method*.



```
getrisk2(soc, cc, agelimit, irbw, ef, mfi, cpf)
```

Computes risk of exposure to cancer due to water contamination for each individual. please refer to this [link](http://pubs.acs.org/doi/abs/10.1021/es400316c) for more information. 

Arguments:

  * `soc` : `[belief, usage, cont-accumulation, age]` of every individual of the past year
  * `cc` : contaminant concentration
  * `agelimit` : age limit of each individual
  * `irbw` : Ingestion rate of water per unit body weight (L kg/day)
  * `ef` : Standard exposure frequency (day/year)
  * `mfi`	: Metabolized fraction of contaminant
  * `cpf` :  Cancer potency factor (Kg day/mg)

Returns: 

  * `risk` : Vector of risk (per thousand) for each individual.


<a id='index-1'></a>

## index

- [`SocialDynamics.socdyn`](functions.md#SocialDynamics.socdyn-Tuple{Any,Any,Any,Any,Any,Any,Any,Any})
- [`SocialDynamics.socdyncoupad`](functions.md#SocialDynamics.socdyncoupad-Tuple{Any,Any,Any,Any,Any,Any,Any})
- [`SocialDynamics.socdyncoupexp`](functions.md#SocialDynamics.socdyncoupexp-Tuple{Any,Any,Any,Any,Any,Any})
- [`SocialDynamics.treefuncad`](functions.md#SocialDynamics.treefuncad-Tuple{Any,Any,Any,Any,Any,Any,Any})
- [`SocialDynamics.treefuncexp`](functions.md#SocialDynamics.treefuncexp-Tuple{Any,Any,Any,Any,Any,Any})
- [`SocioHydrology.SocioFEHM`](functions.md#SocioHydrology.SocioFEHM-Tuple{})
- [`SupportFunc.getrisk2`](functions.md#SupportFunc.getrisk2-Tuple{Any,Any,Any,Any,Any,Any,Any})
- [`SupportFunc.pidcontrol`](functions.md#SupportFunc.pidcontrol-Tuple{Any,Any,Any,Any,Any,Any,Any,Any,Any})
- [`SupportFunc.updaterec2`](functions.md#SupportFunc.updaterec2-Tuple{Any,Any,Any,Any})

