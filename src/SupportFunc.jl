module SupportFunc
export updaterec2, getrisk2, pidcontrol;

"""

    pidcontrol(crthresh, pK, dK, iK, conchist, Dt, sig, exp_adv, expnum_advper)

Proportional-Derivative-Integral (PID) control of concentration or risk using a gaussian weight.

Arguments:

- `crthresh`: concentration or risk threshold used as control reference.
- `pK`: proportional coefficient.
- `dK`: derivative coefficient.
- `iK`: integral coefficient.
- `conchist`: contaminant concentration record (all years until then)
- `Dt`: integration time increments. 
- `sig`: gaussian weight standard deviation.
- `exp_adv`: expert influence (0), or media influence (1).
- `expnum_advper` : number of experts (if `exp_adv = 0`), or advertising intervals (if `exp_adv = 1`).

Returns:

- `belief` : boolean belief of experts or advertisers.
- `exp_ad` : number of experts (if `exp_adv = 0`), or advertising intervals (if `exp_adv = 1`).

"""


function pidcontrol(crthresh, pK, dK, iK, conchist, Dt, sig, exp_adv, expnum_advper)

	e = conchist[end] - crthresh;
	if(pK+dK+iK != 0)
		if(length(conchist) > 2)
			deriv = ( (conchist[end] - conchist[end-1])/Dt + (conchist[end-1] - conchist[end-2])/Dt )/2;
			integ = sum(conchist .- crthresh) * Dt;
		else
			deriv = 0;
			integ = 0;
		end

		K = pK * e - dK * deriv + iK * integ;
		
		if(exp_adv == 0)
			exp_ad = round(Int, expnum_advper*(1 - exp(-( K^2 / (2*sig^2)))));
		else
			exp_ad = round(Int, 1/(expnum_advper*(1 - exp(-( K^2 / (2*sig^2))))));
		end

	else
		exp_ad = expnum_advper;
	end
	

	if(e > 0)
		belief = true;
	else
		belief = false;
	end

	return belief, exp_ad

end

###########################################################

# This function does not wait for people to die in order to assign risk for their usage
# Instead it assumes that people will use water their whole life based on the usage of the last year.


"""

    updaterec2(soc, cc, period, agelimit)

Updates the `soc` array containing social and contamination record.
This method of storing records assumes that individuals will be exposed with the same concentration as that of this year for the rest of their life (for calculating `cont-accumulation`).

Arguments:

- `soc`: `[belief, usage, cont-accumulation, age]` of every individual of the past year
- `cc`: contaminant concentration
- `period` : coupling time increment (years)
- `agelimit` : age limit of each individual

Returns:

- `soc`

"""
function updaterec2(soc, cc, period, agelimit) 

soc[:,4] = soc[:,4] .+ period; 				# Adding years to their age.
soc[:,3] = soc[:,3] + !map(Bool, soc[:,2]) .* cc;		# Assuming their usage is the same for all following years.
background_concentration = 5;

# for all those who die, a new person is born.
for i = 1:length(soc[:,1])
	if(soc[i,4] >= agelimit)
		
		# For each person who dies, one is born, clean, age 0
		soc[i,3:4] = 0;	
		
		# inherits neighbor's usage and beliefs.
		kk = rand()*2-1;
		kk = round(Int, kk/abs(kk));
			if(i == 1)			# Making sure I'm not at the edge
				kk = 1;
			elseif(i == length(soc[:,1]))
				kk = -1;
			end
		soc[i,1:2] = soc[i+kk,1:2];	
	end
end

return soc

end

###########################################################


"""

    getrisk2(soc, cc, agelimit, irbw, ef, mfi, cpf)

Computes risk of exposure to cancer due to water contamination for each individual. please refer to this [link](http://pubs.acs.org/doi/abs/10.1021/es400316c) for more information. 

Arguments:

- `soc` : `[belief, usage, cont-accumulation, age]` of every individual of the past year
- `cc` : contaminant concentration
- `agelimit` : age limit of each individual
- `irbw` : Ingestion rate of water per unit body weight (L kg/day)
- `ef` : Standard exposure frequency (day/year)
- `mfi`	: Metabolized fraction of contaminant
- `cpf` :  Cancer potency factor (Kg day/mg)

Returns: 

- `risk` : Vector of risk (per thousand) for each individual.

"""

function getrisk2(soc, cc, agelimit, irbw, ef, mfi, cpf)
	age = soc[:, 4];
	accumulated_conc = soc[:, 3];

	estimated_usage = (agelimit .- age) .* cc + accumulated_conc; 	# Assume they will use same amount as this year their whole life.
	addin = estimated_usage .* 0.001 .* irbw .* ef ./ agelimit;
	risk = abs(1 - exp(-cpf .* float(addin) .* mfi));	

return risk
end

#######################################################



"""

    updaterec(liverec, soc, cc, period, simyears, agelimit)

[deprecated] Updates the `soc` and `liverec` arrays containing social and contamination record `[belief, usage, contaminant-accumulation, time, age, simulation years]`
This method of storing records is used for risk assessment of people who already died, calculating risk given their lifetime exposure.

Arguments:

- `liverec` : live record of every individual in the past year
- `soc`: `[belief, usage, cont-accumulation, age]` of every individual of the past year
- `cc`: contaminant concentration
- `period` : coupling time increment (years)
- `simyears` : number of years individual has lived in the simulation 
- `agelimit` : age limit of each individual

Returns:

- `liverec`
- `soc`

"""

function updaterec(liverec, soc, cc, period, simyears, agelimit) 

soc[:,3] = soc[:,3] + !bool(soc[:,2]) .* cc;
soc[:,4] = soc[:,4] .+ period;
background_concentration = 5;

# for all those who die, a new person is born.
for i = 1:length(soc[:,1])
	if(soc[i,4] >= agelimit)
		at = agelimit;
		if(agelimit > simyears)
			at = simyears;
		end
		if(soc[i,3] > background_concentration)
			liverec = [liverec, [(soc[i,:])', at , simyears]'];
		end
		
		# For each person who dies, one is born, clean, age 0
		soc[i,3:4] = 0;	
		kk = rand()*2-1;
		kk = kk/abs(kk);
			if(i == 1)		# Making sure I'm not at the edge
				kk = 1;
			elseif(i == length(soc[:,1]))
				kk = -1;
			end
		soc[i,1:2] = soc[i+kk,1:2];	# inherits neighbor's usage and beliefs.
	end
end

return liverec, soc

end


#################################################################

"""

    getrisk(liverec, irbw, ef, mfi, cpf)

[deprecated] Computes risk of exposure to cancer due to water contamination for each individual.

Arguments:

- `liverec` : `[belief, usage, concentration, cont-accumulation, simulation years, age]` of every individual of the past year
- `cc` : contaminant concentration
- `agelimit` : age limit of each individual
- `irbw` : Ingestion rate of water per unit body weight (L kg/day)
- `ef` : Standard exposure frequency (day/year)
- `mfi`	: Metabolized fraction of contaminant
- `cpf` :  Cancer potency factor (Kg day/mg)

Returns: 

- `risk` : Vector of risk (per thousand) for each individual.

"""


function getrisk(liverec, irbw, ef, mfi, cpf)
	addin = liverec[:,3] .* 0.001 .* irbw .* ef ./ liverec[:,5];
	risk = abs(1 - exp(-cpf .* float(addin) .* mfi));	

return risk
end



###############################################################
###############################################################
###############################################################

end
