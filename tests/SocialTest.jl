module SocialTest 
export sdcompare, plotsdcompare

import SocialDynamics: treefuncexp, socdyncoupexp, treefuncad, socdyncoupad
import SocioHydrology: SocioFEHM
using PyPlot
#using Gadfly
# Compare tree expert model, non-tree expert model, tree ad model, and non-tree ad model.


"""
Comparing all social dynamics functions (see SocialDynamics for details of each)

Arguments:

- `soc_struc` : Hierarchy tree branching structure (bottom up)
- `pcons` : consistency rate (also 1 - conformity rate)
- `adperiod` : number of iterations for each media event
- `simtime` : number of social interaction iterations.
- `tree_initurate` : percentage of initial water users in hierarchical models

Returns:

- `usage` : number of users for each social dynamics model for all simtime steps.
		`[expert_3%, expert_6%, hier_expert_3%, hier_expert_6%, media,  hier_media] * simtime`


"""

function sdcompare(;ss = [2, 5, 5, 5, 5, 2], pcons = 0.35, adperiod = 100, simtime = 100, tree_initurate = 0)

	popul = 1;
	for i = 2:length(ss)
		popul = popul * ss[i];
	end

	atr = ss[1];			# Number of attributes
	sims = 6;
	steps = 1;
	soc = zeros(Bool, popul, atr ,sims);
	usage = popul.* ones(Int32, sims, 1); 
	kk = Array(Int32, sims, 1);
	af = 0;

	for i=1:simtime
		if(mod(i-1,adperiod) == 0)
			af=1;
		else
			af=0;
		end
		soc[:,:,1] = socdyncoupexp(popul, round(Int, 0.03*popul), true, soc[:,:,1], pcons, steps);
		soc[:,:,2] = socdyncoupexp(popul, round(Int, 0.06*popul), true, soc[:,:,2], pcons, steps);
		soc[:,:,3] = treefuncexp(ss, round(Int, 0.03*popul), soc[:,:,3], pcons, steps, 0);
		soc[:,:,4] = treefuncexp(ss, round(Int, 0.06*popul), soc[:,:,4], pcons, steps, 0);
		soc[:,:,5] = socdyncoupad(popul, af, true, 0.2, soc[:,:,5], pcons, steps);
		soc[:,:,6] = treefuncad(ss, af, soc[:,:,6], pcons, steps, 0, 0.2); 
		uu = popul .- sum(soc, 1)[1, 2, :];
		kk = reshape(uu, sims, 1);
		usage = hcat(usage , kk);

	end

	return usage

end


##############################################################




function plotsdcompare(;trials = 5, ss = [2, 5, 5, 5, 5, 2], pcons = 0.35, adperiod = 100, simtime = 100, tree_initurate = 0)

	sims = 6;
	totusage = zeros(Float32, sims, simtime + 1);
	usage = zeros(Int32, sims, simtime + 1);
	for j = 1:trials
		println( string("trial number: ", j) );
		usage = sdcompare(ss=ss, pcons=pcons, adperiod=adperiod, simtime=simtime, tree_initurate=tree_initurate)
		totusage = totusage + usage;
	end
	avgusage = totusage./trials;

	# Plot
	simarray = 1:(simtime + 1);

	

	fig, ax = subplots(figsize = (11, 9));
	p1 = plot(simarray, usage[1, :]', color = "red", label = "expert_3%", linewidth = 1.0, linestyle = "-")
	p2 = plot(simarray, usage[2, :]', color = "red", label = "expert_6%", linewidth = 1.0, linestyle = "--")
	p3 = plot(simarray, usage[3, :]', color = "black", label = "hier_expert_3%", linewidth = 1.0, linestyle = "-")
	p4 = plot(simarray, usage[4, :]', color = "black", label = "hier_expert_6%", linewidth = 1.0, linestyle = "--")
	p5 = plot(simarray, usage[5, :]', color = "blue", label = "media", linewidth = 1.0, linestyle = "-")
	p6 = plot(simarray, usage[6, :]', color = "blue", label = "hier_media", linewidth = 1.0, linestyle = "--")
	ax[:legend]()	

	xlabel("Full-social interactions")
	ylabel("Number of water users")
	title("One realization Social Dynamics")

	savefig("OneRealSD.pdf")

	figm, axm = subplots(figsize = (11, 9));
	p1m = plot(simarray, avgusage[1, :]', color = "red", label = "expert_3%", linewidth = 1.0, linestyle = "-")
	p2m = plot(simarray, avgusage[2, :]', color = "red", label = "expert_6%", linewidth = 1.0, linestyle = "--")
	p3m = plot(simarray, avgusage[3, :]', color = "black", label = "hier_expert_3%", linewidth = 2.0, linestyle = "-")
	p4m = plot(simarray, avgusage[4, :]', color = "black", label = "hier_expert_6%", linewidth = 2.0, linestyle = "--")
	p5m = plot(simarray, avgusage[5, :]', color = "blue", label = "media", linewidth = 1.0, linestyle = "-")
	p6m = plot(simarray, avgusage[6, :]', color = "blue", label = "hier_media", linewidth = 2.0, linestyle = "--")
	axm[:legend]()	

	xlabel("Full-social interactions")
	ylabel("Number of water users")
	title("Mean Social Dynamics for $trials trials")
	
	savefig("MeanSD.pdf")

	plt[:show]()



# 	Gadfly
#	p1 = plot(layer(x = simarray , y = usage[1,:], Geom.line),
#		  layer(x = simarray , y = usage[2,:], Geom.line),
#		  layer(x = simarray , y = usage[3,:], Geom.line), 
#		  layer(x = simarray , y = usage[4,:], Geom.line), 
#		  layer(x = simarray , y = usage[5,:], Geom.line), 
#		  layer(x = simarray , y = usage[6,:], Geom.line), 
#		 Guide.xlabel("Full-social Interactions"), 
#			    Guide.ylabel("Number of water users"),
#			    Guide.title("One Realiation Social Dynamics"));
#
#	p2 = plot(layer(x = simarray , y = avgusage[1,:], Geom.line),
#		  layer(x = simarray , y = avgusage[2,:], Geom.line),
#		  layer(x = simarray , y = avgusage[3,:], Geom.line), 
#		  layer(x = simarray , y = avgusage[4,:], Geom.line), 
#		  layer(x = simarray , y = avgusage[5,:], Geom.line), 
#		  layer(x = simarray , y = avgusage[6,:], Geom.line), 
#		 Guide.xlabel("Full-social Interactions"), 
#			    Guide.ylabel("Number of water users"),
#			    Guide.title("Mean Social Dynamics"));
#
#	draw(PDF("socialtests.pdf", 6inch, 6inch), vstack(p1, p2))
	

end



##############################################################

function plotRiskvsConc()

	times1, adornumexp1, ucount1, conchist1, riskhist1 = SocioFEHM(conc_risk = 0, exp_adv = 0, exprate_advper = 0.03 , simulationtime = 70, pid = [1, 0.2, 0.01], init_urate = 0.5, popul= 10000, agelimit = 80, risk_percentile = .95, FEHMprefix = "cm", outputfile = "conc_control.txt")


	times2, adornumexp2, ucount2, conchist2, riskhist2 = SocioFEHM(conc_risk = 1, exp_adv = 0, exprate_advper = 0.03 , simulationtime = 70, pid = [1, 0.2, 0.01], init_urate = 0.5, popul= 10000, agelimit = 80, risk_percentile = .95, FEHMprefix = "cm", outputfile = "risk_control.txt")



	figc, axc = subplots(figsize = (11, 9));
	p1c = plot(times1, conchist1, color = "red", label = "Concentration control", linewidth = 2.0, linestyle = "--")
	p2c = plot(times2, conchist2, color = "blue", label = "Risk control", linewidth = 2.0, linestyle = "-")
	axc[:legend]()	

	xlabel("Time (years)")
	ylabel("Concentration (ppb)")
	title("Concentration versus Risk control")

	savefig("ConcvsRisk.pdf")

	plt[:show]()

end

##################################################################


function plotHomovsHetero()
	
	println("Homogeneous Aquifer")
	times1, adornumexp1, ucount1, conchist1, riskhist1 = SocioFEHM(conc_risk = 0, exp_adv = 0, exprate_advper = 0.03 , simulationtime = 70, pid = [1, 0.2, 0.01], init_urate = 0.5, popul= 10000, agelimit = 80, risk_percentile = .95, FEHMprefix = "cm", outputfile = "homogeneous.txt")


	println("Heterogeneous Aquifer")
	times2, adornumexp2, ucount2, conchist2, riskhist2 = SocioFEHM(conc_risk = 0, exp_adv = 0, exprate_advper = 0.03 , simulationtime = 70, pid = [1, 0.2, 0.01], init_urate = 0.5, popul= 10000, agelimit = 80, risk_percentile = .95, FEHMprefix = "cmgsv02", outputfile = "heterogeneous.txt")



	figc, axc = subplots(figsize = (11, 9));
	p1c = plot(times1, conchist1, color = "red", label = "Homogeneous", linewidth = 2.0, linestyle = "--")
	p2c = plot(times2, conchist2, color = "blue", label = "Heterogeneous", linewidth = 2.0, linestyle = "-")
	axc[:legend]()	

	xlabel("Time (years)")
	ylabel("Concentration (ppb)")
	title("Homogeneous vs. Heterogeneous Aquifer")
	
	savefig("HomovsHetero.pdf")

	plt[:show]()

end



# # # #

end

