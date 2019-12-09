module SocialDynamics
export socdyn, socdyncoupad, socdyncoupexp, treefuncad, treefuncexp;


"""

    socdyn(nc, ns, a, p, steps, adfreq, seed, model)

Basic consistency-conformity social dynamics simulation function.

Arguments:

- `nc` : Number of non-expert citizens
- `ns` : number of experts
- `a` : number of attributes (belief, usage)
- `steps` : number of iterations each consisting of 1 interaction/person
- `adfreq` : advertising frequency
- `model` : expert influence for `model = "scientist"`, one-time media influence for `model = "ad"`, or regular media ads for `model = "regad"`

Returns:

- `n-tuse`: number of users

"""

function socdyn(nc, ns, a, p, steps, adfreq, seed, model)

srand(seed);
af = floor(adfreq*365.25/15);  
tuse = Int64[];

if(model == "scientist")
	m = 1;
	n = ns + nc;	# Total number of the population
	
	# Set Scientist belief to 1
	soc = zeros(Bool, n,a);
	for j=1:ns
		soc[j,1]=true;
	end

elseif(model == "ad" || model == "regad")
	m = 2;
	if(model== "regad")
		m = 3;
	end
	n = nc;
	soc = zeros(Bool, n,a);
	# Informative Event
	for j=1:n
  		soc[j,1] = randbool();
	end
println("**************  End of Informative Event ***************")
end


for j = 1:steps
# Loop over all the population and update belief/usage

for i=1:n

	k=floor(rand()*n+1);

	   rcc = rand();          # sample from uniform distribution to choose CC rule
		if(m==1)
		      if(k<=ns)           # if scientist, only update second bit (usage bit)
			atr = 2;
		      else
			atr = floor(rand()*2)+1;
		      end
		elseif(m==2 || m==3)
			atr = floor(rand()*2)+1;
		else
			println("Error: unspecified model");
		end

	      if(rcc<p)           # Consistency Rule 
		 soc[k,atr]= soc[k,!convert(Bool, atr-1)+1]; 
	      else                # Conformity Rule
		  rot = floor(rand()*n)+1;
		  soc[k,atr] = soc[rot,atr];
	      end
	end


tusage = sum(soc,1)[2];
append!(tuse , [tusage]);

if (m==3) # IF ADs are introduced regularly every certain number of steps	
	if(j%af==0)
	  println("**************  NEW Informative Event ***************");
	print("steps number: ");
	println(j);
		  for j=1:n
		    soc[j,1] = randbool();
		  end
	end

# Demand << Supply
#	frac = 0.1;
#	poor = floor(frac*n);
#	if (tusage >n-1000)
#	  for j=1:poor
#	    soc[floor(rand()*n+1),2] = 0;
#	  end
#	end
end

if( tusage ==n )
  break;
end

end

return n-tuse

end







########################## COUPLED EXPERT MODEL #############
###############################################################
###############################################################

#
# Introduces the flexibility to toggle scientist belief
# Introcuces the flexibility to have non-zero initial usage and belief
# Input: expert belief (based on contamination level), social matrix belief and usage
# Belief: bool. True if belief in contamination.

"""
    socdyncoupexp(n, ns, belief, soc, p, steps)

Expert social dynamics.

Arguments:

- `n`: population size
- `ns` : number of experts
- `belief` : binary belief of water contamination
- `soc` : social record `[belief, usage, cont-accumulation, age]`.
- `p` : consistency rate; which gives the conformity rate `(1-p)`.
- `steps`: number of iterations each consisting of 1 interaction/person

Returns:

- updated `soc`

"""


function socdyncoupexp(n, ns, belief, soc, p, steps)


nc = n - ns;	# Total number of the non expert population 
for j = 1:ns
	soc[j,1]=belief;
end

for j = 1:steps
# Loop over all the population and update belief/usage

	for i=1:n
		k = floor(Int, rand()*n+1);
		rcc = rand();          		# sample from uniform distribution to choose CC rule
		if(k <= ns)           		# if scientist, only update second bit (usage bit)
			atr = 2;
		else
			atr = floor(Int, rand()*2)+1;
		end

		if(rcc < p)          		# Consistency Rule 
			soc[k,atr]= soc[k,!convert(Bool, atr-1)+1]; 
		else       			# Conformity Rule
			rot = floor(Int, rand()*n)+1;
			soc[k,atr] = soc[rot,atr];
	      end
	end
end

return soc

end



########################### COUPLED AD MODEL ##################
###############################################################
###############################################################

#
# Introduces the flexibility to toggle scientist belief
# Introcuces the flexibility to have non-zero initial usage and belief
# Input: expert belief (based on contamination level), social matrix belief and usage
# Belief: bool. True if belief in contamination.




"""
    socdyncoupad(n, adflag, belief, popfrac, soc, p, steps)

Media social dynamics.

Arguments:

- `n`: population size
- `adflag` : media influence if `adflag = 1`, do nothing otherwise.
- `belief` : binary belief of water contamination
- `popfrac` : fraction of population targetted with each ad campain.
- `soc` : social record `[belief, usage, cont-accumulation, age]`.
- `p` : consistency rate; which gives the conformity rate `(1-p)`.
- `steps`: number of iterations each consisting of 1 interaction/person

Returns:

- updated `soc`

"""


function socdyncoupad(n, adflag, belief, popfrac, soc, p, steps);


if(adflag == 1)
	for j = 1:floor(Int, popfrac*n)
		k = floor(Int, rand()*n+1)
		soc[k,1] = belief;
	end
end

for j = 1:steps
# Loop over all the population and update belief/usage

	for i = 1:n

		k = floor(Int, rand()*n+1);

		rcc = rand();  # sample from uniform distribution to choose CC rule
		atr = floor(Int, rand()*2)+1;

	      if(rcc<p)           # Consistency Rule 
		 soc[k,atr] = soc[k,!convert(Bool, atr-1)+1]; 
	      else                # Conformity Rule
		  rot = floor(Int, rand()*n)+1;
		  soc[k,atr] = soc[rot,atr];
	      end
	end

end

return soc

end











###############################################
###############################################


#;# Inputs: simtime, pconsist, strat struct (popul), initial believers,  
#;# sim = 9000;
#;# ss = [2 2 2 2];     #[indiv family community party]... 
#;# iurate = 0.8;
#;# pconsist = 0.5;

"""

    treefuncexp(ss, expnum, soc, pconsist, simtime, iurate)

Expert hierarchical social dynamics according to interaction rate

Arguments:

- `ss` : vector for branching structure. For example `[2 2 2 2]` is a binary tree with 4 levels
- `expnum` : number of experts 
- `soc` : social record `[belief, usage, cont-accumulation, age]`.
- `pconsist` : consistency rate
- `simtime` : simulation time (per interaction interval)
- `iurate` : initial usage rate

Returns:

- updated `soc`.

"""

function treefuncexp(ss, expnum, soc, pconsist, simtime, iurate)

strat = length(ss);  # number of stratification levels
popul = 1;
for i = 1:strat
	popul = popul * ss[i]; # Population count
end
peop = soc2tree(soc);
iupeop = iurate*popul;
for j = 1:iupeop
	k = ceil(Int, (rand()*popul)/2);
	peop[2*k] = 1;        # Choose iupopul to make use initially.
end

pconform = 1-pconsist;      # Conformity rate assumed to be subdivided all the rest
pmat = Array(Float32, strat); # probability matrix
pmat[1] = pconsist;         # first element in matrix is the lowest node

# Setting probability distribution
pp = pconform;
for i = 2:strat-1
	pp = pp/2;
	pmat[i] = pmat[i-1] + pp;
end
pmat[strat] = 1;

expindex = expnum*ss[1]; # Number of experts based on the number of attributes
	#;# Set the expert belief to 1 (for now).
for i = 1:expnum
	peop[(i-1)*ss[1]+1]=1;
end

for tt = 1:simtime
	for q = 1:popul
	
		j = floor(Int, popul*rand()+1);
		
		# If belief attribute of expert is chosen, reshuffle.
		while(mod(j,2)==1 && j<=expindex) 
			j = floor(Int, popul*rand()+1);
		end
		branch = findbranch(pmat, rand()) + 1;        # Pick random branch according to pmat 
		rglob = collect(findrange(branch, j, ss));        # Finds the range of under which branch falls

		rloc = findrange(branch-1, j, ss) - rglob[1] + 1;# Finds range that should be removed from br
		splice!(rglob, rloc);                        # Removes local branch from global
		otherind = rglob[floor(Int, rand()*length(rglob) + 1)];# pick a random attribute from the subbranch

		if(abs(otherind - j) >= ss[1]) 
			coro = 0;
			corj = 0;
			if(otherind%ss[1] == 0)        # Corr corrects for modulo when it's divisable
				coro = ss[1];
			end

			if(j%ss[1] == 0)
				corj = ss[1];
			end
			otherind = otherind + ( j%ss[1]+corj - (otherind%ss[1]+coro)); 
		end
		peop[j] = peop[otherind];                   # Match attributes
	end

	totcons = 0;
	for j = 1 : div(popul,2)
		totcons = totcons + peop[j*2];
	end

end

socresult = tree2soc(peop);
return socresult
end


##############################################################################
##############################################################################


"""

    treefuncad(ss, adflag, soc, pconsist, simtime, iurate, spreadrate)

Media hierarchical social dynamics according to interaction rate

Arguments:

- `ss` : vector for branching structure. For example `[2 2 2 2]` is a binary tree with 4 levels
- `adflag` : media influence if `adflag = 1`, do nothing otherwise.
- `soc` : social record `[belief, usage, cont-accumulation, age]`.
- `pconsist` : consistency rate
- `simtime` : simulation time (per interaction interval)
- `iurate` : initial usage rate
- `spreadrate` : portion of population affected by ads.

Returns:

- updated `soc`.

"""

function treefuncad(ss, adflag, soc, pconsist, simtime, iurate, spreadrate)

strat = length(ss);  # number of stratification levels
popul = 1;
for i = 1:strat
	popul = popul * ss[i];  # Population count
end
peop = soc2tree(soc);
iupeop = iurate * popul;
for j = 1:iupeop
	k = ceil(Int, (rand()*popul)/2);
	peop[2*k] = 1;        # Choose iupopul to make use initially.
end

pconform = 1-pconsist;      # Conformity rate assumed to be subdivided all the rest
pmat = Array(Float32, strat); # probability matrix
pmat[1] = pconsist;         # first element in matrix is the lowest node

# Setting probability distribution
pp = pconform;
for i = 2:strat-1
	pp = pp/2;
	pmat[i] = pmat[i-1] + pp;
end
pmat[strat] = 1;

if(adflag==1)
	for i=1:round(Int, popul*spreadrate)
		k = floor(Int, rand()*div(popul,2)) *2 + 1;
		peop[k] = 1;
	end
end

for tt = 1:simtime
	for q = 1:popul
	
		j = floor(Int, popul*rand() + 1);
		branch = findbranch(pmat, rand()) + 1;        	# Pick random branch according to pmat 
		rglob = collect(findrange(branch, j, ss));        		# Finds the range of under which branch falls

		rloc = findrange(branch - 1, j, ss) - rglob[1] + 1;	# Finds range that should be removed from br
		splice!(rglob, rloc);                        		# Removes local branch from global
		otherind = rglob[floor(Int, rand()*length(rglob) + 1)];	# pick a random attribute from the subbranch
			if(abs(otherind - j) >= ss[1]) 
				coro = 0;
				corj = 0;
				
				if(otherind % ss[1] == 0)        # Corr corrects for modulo when it's divisable
					coro = ss[1];
        				end
        				
        				if(j % ss[1] == 0)
          					corj = ss[1];
        				end
      				otherind = otherind + ( j%ss[1]+corj - (otherind%ss[1]+coro)); 
    				end
    				
    				peop[j] = peop[otherind];                   # Match attributes
  			end

			totcons = 0;
  			
  			for j = 1: div(popul, 2)
   				totcons = totcons + peop[j*2];
  			end
		
	end

socresult = tree2soc(peop);
return socresult

end






###############################################
########## TREE MODEL FUNCTIONS #############

function findbranch(A, num)
	An = A .- num;
	for k = 1:length(An) 
		if(An[k] >= 0)
			return k
			break;
		end
	end
end


function findrange(branch, j, ss)
	span = 1;
	if(branch>0)
		for k = 1:branch-1
			span = span * ss[k];
		end
	end
	localind = ceil(Int, j/span);
	i0 = round(Int, (localind-1) * span + 1);
	range = i0 : (i0 + span - 1);
	return range
end


function findrange2(branch, j)
	span = 2^(branch-1);
	localind = ceil(Int, j/span);
	i0 = round(Int, (localind-1)*span + 1);
	range = i0 : (i0+span-1);
	return range
end

function soc2tree(soc)
	treevec = zeros(size(soc,1)*size(soc,2));
	for i = 1:size(soc,1)
		for j = 1:size(soc,2)
			treevec[(i-1)*size(soc,2) + j] = soc[i,j];
		end
	end
	return treevec
end

#########################################

function tree2soc(tree)
	soc = zeros(round(Int, length(tree)/2),2);
	for i = 1:size(soc,1)
		for j = 1:size(soc,2)
			soc[i,j] = tree[(i-1)*size(soc,2) + j];
		end
	end
	return soc
end


function cenergy(ss, peop, pmat)
	function baseenergy(por)
		delta = 2*sum(por)-length(por);
		return length(por)*exp(-delta);
	end

	
	ce = zeros(length(peop)/ss[1]);
	for i = 1:(length(peop)/ss[1])
		portion = peop[ss[1]*(i-1)+1:ss[1]*i];
		ce[i] =  baseenergy(portion);		
	end
	
	for j = 2:(length(ss))
		for k = 1:(length(peop)/ss[j])	
			
			tote += pmat[j]*sum(ce);
		end
	end

end

# # # #

end
