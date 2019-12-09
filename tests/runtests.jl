push!(LOAD_PATH, "../src");
push!(LOAD_PATH, ".");

import SocialTest: sdcompare, plotsdcompare, plotRiskvsConc, plotHomovsHetero

#plotsdcompare(trials = 10, simtime = 2000)
plotRiskvsConc()
#plotHomovsHetero()
