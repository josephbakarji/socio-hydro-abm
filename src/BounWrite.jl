module BounWrite 
export setboun, timelimit
include("PathFile.jl");
##############################

"""

    setboun(times, heads, location, FEHMprefix)


Sets boundary conditions in the `FEHMprefix.boun` file for FEHM simulations.

Arguments:
- `times`: vector of years at which pumping rate from well is changed
- `hears`: pumping rate.
- `location`: location (FEHM code) of pumping well.
- `FEHMprefix` : FEHM files prefix in `./contaminantion-model/

"""

function setboun(times, heads, location, FEHMprefix)

ff = open(string(fehmdir, FEHMprefix, ".boun"),"w+");
write(ff,"boun
model 3 w21
tran
time\n");
write(ff,string(length(times)));
write(ff,"\n");
times = times./8;
for i = 1:length(times)
	tt = times[i];
	write(ff,"$tt \n");
end
write(ff,"year \ndsw \n");
for i = 1:length(heads)
	hh = heads[i];
	write(ff, "$hh \n");
end
write(ff,"end\n");
write(ff, "-");
write(ff, string(location));
write(ff, " 0 0 1\n ");
write(ff," ");
close(ff);


end


##################################################


"""

    timelimit(days, location, FEHMprefix)

Sets simulation horizing in the `FEHMprefix.data` FEHM file.

Argument:

- `days` : number of days limit
- `location` : location (FEHM code) of pumping well. 
- `FEHMprefix` : FEHM files prefix in `./contaminantion-model/

"""


function timelimit(days, location, FEHMprefix)

gg = open(string(fehmdir,FEHMprefix,".data"),"w+");
write(gg,"** Cr model
cont
avs 1 1e20
geo
liquid
concentration
head
velocity
material
endavs
head 1000
nobr
bous
1
airw
3
30.0 0.1
zone
file
gs01_outside.zone
flow
-3 0 0 1798.613472817     1 1e10
-5 0 0 1772.054959807     1 1e10

pres
1 0 0 1776 1 2

zone
110
4.971500000E+05 501750          501750          4.971500000E+05 4.971500000E+05 501750          501750          4.971500000E+05
5.373500000E+05 5.373500000E+05 5.406500000E+05 5.406500000E+05 5.373500000E+05 5.373500000E+05 5.406500000E+05 5.406500000E+05
-1 -1 -1 -1 1 1 1 1

flow
-110 0 0 0.000717864089902394     1 0

zonn
file
hole_coord-20120702-recharge-600p.zonn
flow
-9420 0 0 -0.0003413616876478    1 0
-9620 0 0 -0.00007255554857619   1 0

hyco
1 0 0 -2.51795 -2.51795 -2.51795

rock
1 0 0 2500. 1010. 1.0E-02

rlp
1 0. 0. 1. 1. 0. 1.

1 0 0 1

ppor
-1
1 0 0 0.000215968

stea
shea 1e-6
stim 1e20
smul 1e10
end
time
365.25 $days 10000 001 2006 1 0
0.0  -1.2 1.0 365.25

ctrl
-5 1e-6 1 350 bcgs
1 0 0 2

1.0 0 1.0
10 1000 1e-8 1e20
0 2
sol
1 -1
iter
1e-5 1e-5 0.1 1e-4 1.1
13 0 0 5 1200.
node
1
5471
zone
file
gs01_outside.zone
zonn
file
hole_coord-20140523-screen-change-100.zonn
flxz
1\n")
write(gg,"$location")
write(gg,"\nboun
file\n")
write(gg,FEHMprefix)
write(gg,".boun
zonn
file\n")
write(gg,FEHMprefix)
write(gg,".source.zonn
trac
file\n")
write(gg,FEHMprefix)
write(gg,".trac
stop");
close(gg);
end
end
