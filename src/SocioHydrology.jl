module SocioHydrology

export SocioFEHM

include("PathFile.jl");
import SupportFunc: updaterec2, getrisk2, pidcontrol;
import SocialDynamics: socdyncoupad, socdyncoupexp;
import BounWrite: setboun, timelimit;


"""

    SocioFEHM(; conc_risk = 0, exp_adv = 0, exprate_advper = 0.03 , simulationtime = 20, cthresh = 30, pid = [0, 0, 0],  measure_period = 1, predetect_time = 0, startpumptime = 10, init_urate = 0.99, popul= 10000, agelimit = 70, risk_percentile = .90,  adtargetfrac = 0.5, FEHMprefix = "cm", outputfile = "default_output_file.txt")
[requires names of variables]


Simulate a coupled consistency-conformity social dynamics with FEHM for contaminated aquifer.

Arguments:

- `conc_risk` : concentration control (0), or risk control (1).
- `exp_adv` : expert influence (0), or media influence (1).
- `exprate_advper` : fraction of experts in population (if `exp_adv = 0`), or advertising period (if `exprate_advper = 1`).
- `simulationtime` : Total time of coupled simulation (in years).
- `cthresh` : concentration threshold (control reference). Risk threshold `rthresh` is calculated in equivalence.
- `pid` : vector `[pK, dK, iK]` of proportional-derivative-integral control coefficients. 
- `measure_period` : time interval between two successive measurement events (years).
- `predetect_time` : time before contaminants are detected in acquifer (in years).
- `startpumptime` : Time (from beginning of FEHM simulation) after which pumping starts (years)
- `init_urate` : fraction of the population that initially uses the water.
- `popul` : population size.
- `agelimit` : age at which people die, and get replaced by a new-born (used for risk control).
- `risk_percentile`: Percentile of people kept below risk threshold.
- `adtargetfrac` : fraction of population reached by media influence (used for `exp_adv = 1`).
- `FEHMprefix` : FEHM prefix of files for aquifer simulation, placed in `./contaminantion-model/`.
- `outputfile` : Default suffix for saving data in text files; set to `""` to prevent saving.

Returns:

return times, prate, adorbel, adornumexp, ucount

- `times`: Times in years since of FEHM simulation.
- `adornumexp`: number of employed experts if `exp_adv = 0`, or period between sucessive ads if `exp_adv = 1`
- `ucount`: number of water users.
- `conchist` : aquifer concentration history

"""

function SocioFEHM(; conc_risk = 0, exp_adv = 0, exprate_advper = 0.03 , simulationtime = 20, cthresh = 30, pid = [0, 0, 0],  measure_period = 1, predetect_time = 0, startpumptime = 10, init_urate = 0.99, popul= 10000, agelimit = 70, risk_percentile = .90,  adtargetfrac = 0.5, FEHMprefix = "cm", outputfile = "default_output_file.txt")


	### Fixed Variables ###
	period 		= 1; 		# Number of social dynamics simulations for 1 year of FEHM simulations
	initialrisk 	= 0;		# Initial health risk (per thousand)
	useday 		= 2660; 	# Water use per day per person in Liters, estimated as USGS to be 80-100 gallons - 340L
	wdensity 	= 1; 		# Water density  (Kg/L)
	interfreq 	= 15; 		# Calculated such that 1000 steps make around 50 years. (DAYS)
	location 	= 3612;		# Position of well in FEHM (3612 for homogeneous)
	pcons 		= 0.35; 	# Consistency rate
	numatr		= 2; 		# Belief - Usage:  attributes
	Dt 		= 1;	 	# Integration/derivative time; TO BE FIXED IF DECISION TIME IS NOT = 1

	### RISK DATA ### 
	# Reference: http://pubs.acs.org/doi/abs/10.1021/es400316c
	# (Paper has few mistakes in units)

	irbw 		= 0.022;	# Ingestion rate of water per unit body weight (L kg/day)
	ef 		= 350;		# Standard exposure frequency (day/year)
	mfi 		= 1;		# Metabolized fraction of contaminant
	cpf 		= 0.42; 	# Cancer potency factor (Kg day/mg)


	#### INITIAL CONDITIONS ####
	socatribute 	= zeros(Bool, popul, numatr); 	# Belief(False - bel. not cont. ; True - bel. cont.) , Usage (False - using ; True - not using),
	socconc 	= zeros(Float64, popul, 1);  	# Total usage concentration
	socage		= zeros(Int, popul, 1); 	# Age
	soc 		= hcat(socatribute, socconc, socage);  

	times 		= Float32[];		# Time of pumping (years)
	prate 		= Float32[];		# pumping rate function of time
	conchist 	= Float32[];		# pumped concentration as a function of time
	riskhist 	= Float32[];		# Control risk as a function of time	
	riskarray 	= zeros(Float32, popul, 1); # Risk of all population at each iteration
	adfreqmat 	= Int64[];		# ad frequency function of time
	adflagmat	= Bool[];		# Ads or no ads per year 
	expb  		= Bool[];		# expert belief function of time
	num_expert	= Int32[];		# Number of experts function of time 
	soc_rec		= Array{Bool}[];
	ucount 		= Int32[];		# Number of people using the water
	simstep 	= round(Int, simulationtime/period);	# simluation time per iteration
	adcounter 	= 0;			# Counts years before next ad
	adf		= exprate_advper;	# ad frequency.
	adflag		= 0; 			# Flag whether to make ads (that year) or not.
	ca 		= 1;
	belief		= false;
	expmax_advper 	= convert(Bool, exp_adv) ? exprate_advper : convert(Int32, float(exprate_advper) * popul);
	cc 		= 0;		# Initial concentration
	numexp		= expmax_advper;

	risk = initialrisk;
	rthresh = getrisk2([1,1,0,0]', cthresh, agelimit, irbw, ef, mfi, cpf)[1]; # Risk threshold calculated in equivalence to concentration threshold
	rsig 	= rthresh/3;
	sig	= cthresh/3;	# Normal distribution std (concentration control) used for pid control
	
	# PID Parameters
	pK 		= pid[1];		# Proportional coefficient
	dK 		= pid[2];		# Derivative coefficient
	iK 		= pid[3];		# Integral coefficient

	# uniform distribution of ages
	for i = 1:popul
		soc[i,4] = floor(Int, rand() * agelimit);
	end

	# Specify the initial users
	soc[end - round(Int, (1-init_urate)*popul) : end, 2] = true;

	#############################################
	
	println("Simulation Parameters:");
	println(convert(Bool, exp_adv) ? "Media Influence" : "Expert Influence");
	println(convert(Bool, conc_risk) ? "Risk Control" : "Concentration Control");
	println("____________________________________________________");
	



	for i = 1:simstep

	# DECISION MAKING (CONTROL)	
		if(exp_adv == 1)
			
			adcounter += period;
			if(mod(i, measure_period) == 0 && i > predetect_time && i>1)
				println("Making Decision");
				if(adcounter >= adf)
					if(conc_risk == 1)
						belief, adf  = pidcontrol(rthresh, pK, dK, iK, riskhist, Dt, rsig, exp_adv, expmax_advper);
					elseif(conc_risk == 0)
						belief, adf  = pidcontrol(cthresh, pK, dK, iK, conchist, Dt, sig, exp_adv, expmax_advper);
					end
					adcounter = 0;
					adflag = true;
				else
					adflag = false;
				end
			end
			append!(adflagmat, [adflag]);
			append!(adfreqmat, [adf]);

			println(string("Advertising this year:\t ", convert(Bool, adflag) ? "yes!" : "no"));
			println(string("Media Belief:\t ", belief ? "It's contaminated!" : "it's not contaminated"));
			println(string("Ads counter/freq:\t ", adcounter, " out of ", adf));

		else
	    
			if(mod(i, measure_period) == 0 && i > predetect_time && i > 1)
				println("Making Decision");
				if(conc_risk==1)
					belief, numexp = pidcontrol(rthresh, pK, dK, iK, riskhist, Dt, rsig, exp_adv, expmax_advper)
				elseif(conc_risk==0)
					belief, numexp = pidcontrol(cthresh, pK, dK, iK, conchist, Dt, sig, exp_adv, expmax_advper)
				end
			end
			append!(expb, [belief]);
			append!(num_expert, [numexp]);
			
			println(string("expert belief:\t\t ", belief ? "it's contaminated" : "it's not contaminated"));
			println(string("number of experts:\t ", numexp));
		end


			println(string("year:\t\t\t ", i, " of ", simulationtime));		
			println(string("risk:\t\t\t ", Float16(risk), " to ", Float16(rthresh)));	
		
		
		# Initialize FEHM files
		usage = popul - round(Int, sum(soc,1)[2]);
		println(string("number of users:\t ", usage, " out of ", popul));
		append!(ucount, [usage]);
		append!(prate, [usage*useday/24/3600*wdensity]);
		append!(times, [startpumptime + period*(i-1)]);
		setboun(times, prate, location, FEHMprefix);
		timelimit(round(Int, times[end]*365.25/8), location, FEHMprefix);
	
		#### RUN FEHM CODE ####
		run(`sh ${srcdir}fehmrun.sh $fehmdir $FEHMprefix`);
		steps = round(Int, period*365.25/interfreq);

		
		#### SOCIAL DYNAMICS ####
		if(exp_adv == 1)
			soc[:,1:2] = socdyncoupad(popul, adflag, belief, adtargetfrac, soc[:,1:2], pcons, steps);
		else
			soc[:,1:2] = socdyncoupexp(popul, numexp, belief, soc[:,1:2], pcons, steps);
		end
		

		#### UPDATE SOCIAL RECORDS ####
		soc = updaterec2(soc, cc, period, agelimit);
		push!(soc_rec, soc[:,1:2]);


		#### RISK #### 
		population_risk = getrisk2(soc, cc, agelimit, irbw, ef, mfi, cpf);
		riskarray = hcat(riskarray, population_risk);
		
		if(length(population_risk) >= 2)
			saferank = round(Int, (1 - risk_percentile) * length(population_risk) ); 	# rank based on percentile 
			risk = sort(population_risk, rev=true)[saferank]; 			# risk associated with that rank 
		else
			risk = 0;
		end
		append!(riskhist, [risk]);


		# Read contamination level from (FEHM trc) file
		file = readdlm(string(fehmdir, FEHMprefix, ".trc"));
		cc = Float32( file[end,1] );
		append!(conchist, [cc]);
		println(string("Concentration:\t\t ", cc));
		println(string("_______________________________________________"));
	end

	if(exp_adv==1)
		adorbel = adflagmat;
		adornumexp = adfreqmat;
	else
		adorbel = expb;
		adornumexp = num_expert;
	end

	stmat = hcat(times, prate, adorbel, adornumexp, ucount); 
	
	if(outputfile != "")
		writedlm(string(fehmdirresult, "hist_", outputfile), stmat); 	# years, pumping_rate, ads_or_expertbelief, adfrequency_or_expnumber, num_users 
		writedlm(string(fehmdirresult, "risk_", outputfile), riskarray);# Risk for all individuals for all years.
		writedlm(string(fehmdirresult, "socrec_", outputfile), soc_rec);# Belief and Usage bits for all individuals for all years.
		#writedlm(string(fehmdirresult, "soc_", outputfile), soc);	# Last year's: belief, usage, concentration accumulation, age
	end

return times, adornumexp, ucount, conchist, riskhist

end


end
