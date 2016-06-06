#!/usr/bin/env Rscript
# Script to produce barplots for the results of the load balancing by federation
# author : Thomas Minier

# path to results files
# with the classic federation
outputWatDivFedra <- "../results/watDiv/outputFedXFedraFEDERATION10Client"
outputWatDivPBJHybrid <- "../results/watDiv/outputFedXFedra-PBJ-hybridFEDERATION10Client"

# with a federation of 20 endpoints
outputWatDiv20eFedra <- "../results/watDivMore/outputFedXFedraFEDERATION20Client"
outputWatDiv20ePBJHybrid <- "../results/watDivMore/outputFedXFedra-PBJ-hybridFEDERATION20Client"

# with a federation of 30 endpoints
outputWatDiv30eFedra <- "../results/watDivMore/outputFedXFedraFEDERATION30Client"
outputWatDiv30ePBJHybrid <- "../results/watDivMore/outputFedXFedra-PBJ-hybridFEDERATION30Client"

# set the data frames
watDivFedraTuplesTable <- read.table(outputWatDivFedra)[13:22]
colnames(watDivFedraTuplesTable) <- 1:10
watDivFedraTuples20eTable <- read.table(outputWatDiv20eFedra)[13:32]
colnames(watDivFedraTuples20eTable) <- 1:20
watDivFedraTuples30eTable <- read.table(outputWatDiv30eFedra)[13:42]
colnames(watDivFedraTuples30eTable) <- 1:30

watDivFedraCallsTable <- read.table(outputWatDivFedra)[24:33]
colnames(watDivFedraCallsTable) <- 1:10
watDivFedraCalls20eTable <- read.table(outputWatDiv20eFedra)[34:53]
colnames(watDivFedraCalls20eTable) <- 1:20
watDivFedraCalls30eTable <- read.table(outputWatDiv30eFedra)[44:73]
colnames(watDivFedraCalls30eTable) <- 1:30

watDivHybridTuplesTable <- read.table(outputWatDivPBJHybrid)[13:22]
colnames(watDivHybridTuplesTable) <- 1:10
watDivHybridTuples20eTable <- read.table(outputWatDiv20ePBJHybrid)[13:32]
colnames(watDivHybridTuples20eTable) <- 1:20
watDivHybridTuples30eTable <- read.table(outputWatDiv30ePBJHybrid)[13:42]
colnames(watDivHybridTuples30eTable) <- 1:30

watDivHybridCallsTable <- read.table(outputWatDivPBJHybrid)[24:33]
colnames(watDivHybridCallsTable) <- 1:10
watDivHybridCalls20eTable <- read.table(outputWatDiv20ePBJHybrid)[34:53]
colnames(watDivHybridCalls20eTable) <- 1:20
watDivHybridCalls30eTable <- read.table(outputWatDiv30ePBJHybrid)[44:73]
colnames(watDivHybridCalls30eTable) <- 1:30

# output the barplots
pdf("../results/watDivMore/load_balancing/transferred_tuples/watDivFedra.pdf")
barplot(colSums(watDivFedraTuplesTable), ylab="Number of transferred tuples", xlab="Endpoint", col=rainbow(10), log="y")
dev.off()

pdf("../results/watDivMore/load_balancing/transferred_tuples/watDiv20eFedra.pdf")
barplot(colSums(watDivFedraTuples20eTable), ylab="Number of transferred tuples", xlab="Endpoint", col=rainbow(20), log="y")
dev.off()

pdf("../results/watDivMore/load_balancing/transferred_tuples/watDiv30eFedra.pdf")
barplot(colSums(watDivFedraTuples30eTable), ylab="Number of transferred tuples", xlab="Endpoint", col=rainbow(30), log="y")
dev.off()

pdf("../results/watDivMore/load_balancing/transferred_tuples/watDivHybrid.pdf")
barplot(colSums(watDivHybridTuplesTable), ylab="Number of transferred tuples", xlab="Endpoint", col=rainbow(10), log="y")
dev.off()

pdf("../results/watDivMore/load_balancing/transferred_tuples/watDiv20eHybrid.pdf")
barplot(colSums(watDivHybridTuples20eTable), ylab="Number of transferred tuples", xlab="Endpoint", col=rainbow(20), log="y")
dev.off()

pdf("../results/watDivMore/load_balancing/transferred_tuples/watDiv30eHybrid.pdf")
barplot(colSums(watDivHybridTuples30eTable), ylab="Number of transferred tuples", xlab="Endpoint", col=rainbow(30), log="y")
dev.off()

pdf("../results/watDivMore/load_balancing/calls/watDivFedra.pdf")
barplot(colSums(watDivFedraCallsTable), ylab="Number of transferred tuples", xlab="Endpoint", col=rainbow(10), log="y")
dev.off()

pdf("../results/watDivMore/load_balancing/calls/watDiv20eFedra.pdf")
barplot(colSums(watDivFedraCalls20eTable), ylab="Number of transferred tuples", xlab="Endpoint", col=rainbow(20), log="y")
dev.off()

pdf("../results/watDivMore/load_balancing/calls/watDiv30eFedra.pdf")
barplot(colSums(watDivFedraCalls30eTable), ylab="Number of transferred tuples", xlab="Endpoint", col=rainbow(30), log="y")
dev.off()

pdf("../results/watDivMore/load_balancing/calls/watDivHybrid.pdf")
barplot(colSums(watDivHybridCallsTable), ylab="Number of transferred tuples", xlab="Endpoint", col=rainbow(10), log="y")
dev.off()

pdf("../results/watDivMore/load_balancing/calls/watDiv20eHybrid.pdf")
barplot(colSums(watDivHybridCalls20eTable), ylab="Number of transferred tuples", xlab="Endpoint", col=rainbow(20), log="y")
dev.off()

pdf("../results/watDivMore/load_balancing/calls/watDiv30eHybrid.pdf")
barplot(colSums(watDivHybridCalls30eTable), ylab="Number of transferred tuples", xlab="Endpoint", col=rainbow(30), log="y")
dev.off()
