#!/usr/bin/env Rscript
# Script to calculate the average % difference between inner loop time and total time
# author : Thomas Minier

outputWatDiv20ePBJHybridInner <- "../results/watDivMore/inner-outputFedXFedra-PBJ-hybridFEDERATION20Client"
outputWatDiv20ePBJHybridRef <- "../results/watDivMore/outputFedXFedra-PBJ-hybridFEDERATION20Client"

watDivHybridTuples20eTableInner <- read.table(outputWatDiv20ePBJHybridInner)[2]
watDivHybridTuples20eTableRef <- read.table(outputWatDiv20ePBJHybridRef)[2]

timesTable <- cbind(watDivHybridTuples20eTableInner, watDivHybridTuples20eTableRef)
colnames(timesTable) <- c("inner", "total")

ratio <- function(x,y) (x/y) * 100

# output average pourcentage
mean(mapply(ratio, timesTable$inner, timesTable$total))
