#!/usr/bin/env Rscript
# Script to produce results of wilcoxon ranking test
# author : Thomas Minier

# from definitive setup
# with a federation of 10 endpoints
outputWatDivFedra <- "../results/definitive/fed10e/avg/outputFedXFedraFEDERATION10Client"
outputWatDivPeneloop <- "../results/definitive/fed10e/avg/outputFedXFedra-PBJ-hybridFEDERATION10Client"

# with a federation of 20 endpoints
outputWatDiv20eFedra <- "../results/definitive/fed20e/avg/outputFedXFedraFEDERATION20Client"
outputWatDiv20ePeneloop <- "../results/definitive/fed20e/avg/outputFedXFedra-PBJ-hybridFEDERATION20Client"

# with a federation of 30 endpoints
outputWatDiv30eFedra <- "../results/definitive/fed30e/avg/outputFedXFedraFEDERATION30Client"
outputWatDiv30ePeneloop <- "../results/definitive/fed30e/avg/outputFedXFedra-PBJ-hybridFEDERATION30Client"

outputFedra <- read.table(outputWatDivFedra)
outputPeneloop <- read.table(outputWatDivPeneloop)
outputFedra20e <- read.table(outputWatDiv20eFedra)
outputPeneloop20e <- read.table(outputWatDiv20ePeneloop)
outputFedra30e <- read.table(outputWatDiv30eFedra)
outputPeneloop30e <- read.table(outputWatDiv30ePeneloop)

# test for execution time
print("fed10e : Wilcoxon ranking test for query execution time")
wilcox.test(as.numeric(unlist(outputPeneloop[2])), as.numeric(unlist(outputFedra[2])), alternative="less", conf.level=0.90, paired=TRUE)

# test for execution time
print("fed20e : Wilcoxon ranking test for query execution time")
wilcox.test(as.numeric(unlist(outputPeneloop20e[2])), as.numeric(unlist(outputFedra20e[2])), alternative="less", conf.level=0.90, paired=TRUE)

# test for execution time
print("fed30e : Wilcoxon ranking test for query execution time")
wilcox.test(as.numeric(unlist(outputPeneloop30e[2])), as.numeric(unlist(outputFedra30e[2])), alternative="less", conf.level=0.90, paired=TRUE)
