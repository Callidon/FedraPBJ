#!/usr/bin/env Rscript
# Script to calculate the average % difference between inner loop and total execution of queries
# author : Thomas Minier

outputWatDiv20ePBJHybridInner <- "../results/watDivMore/inner-outputFedXFedra-PBJ-hybridFEDERATION20Client"
outputWatDiv20ePBJHybridRef <- "../results/watDivMore/outputFedXFedra-PBJ-hybridFEDERATION20Client"

# calculate for execution time
watDivHybridTuples20eTableInner <- read.table(outputWatDiv20ePBJHybridInner)[2]
watDivHybridTuples20eTableRef <- read.table(outputWatDiv20ePBJHybridRef)[2]

timesTable <- cbind(watDivHybridTuples20eTableInner, watDivHybridTuples20eTableRef)
colnames(timesTable) <- c("inner", "total")

ratio <- function(x,y) (x/y) * 100

# output average pourcentage
print("Average % of total execution time used by the inner loop")
mean(mapply(ratio, timesTable$inner, timesTable$total))

# calculate for nb of transferred tuples
watDivHybridTuples20eTableInner <- read.table(outputWatDiv20ePBJHybridInner)[11]
watDivHybridTuples20eTableRef <- read.table(outputWatDiv20ePBJHybridRef)[11]

tuplesTable <- cbind(watDivHybridTuples20eTableInner, watDivHybridTuples20eTableRef)
colnames(tuplesTable) <- c("inner", "total")

ratio <- function(x,y) (x/y) * 100

# output average pourcentage
print("Average % of total transferred tuples by the inner loop")
mean(mapply(ratio, tuplesTable$inner, tuplesTable$total))
