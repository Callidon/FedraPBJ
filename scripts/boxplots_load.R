#!/usr/bin/env Rscript
# Script to produce boxplots for the results of the load balancing by federation
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
watDivFedraTable <- read.table(outputWatDivFedra)[13:22]
colnames(watDivFedraTable) <- 1:10
watDivFedra20eTable <- read.table(outputWatDiv20eFedra)[13:32]
colnames(watDivFedra20eTable) <- 1:20
watDivFedra30eTable <- read.table(outputWatDiv30eFedra)[13:42]
colnames(watDivFedra30eTable) <- 1:30

watDivHybridTable <- read.table(outputWatDivPBJHybrid)[13:22]
colnames(watDivHybridTable) <- 1:10
watDivHybrid20eTable <- read.table(outputWatDiv20ePBJHybrid)[13:32]
colnames(watDivHybrid20eTable) <- 1:20
watDivHybrid30eTable <- read.table(outputWatDiv30ePBJHybrid)[13:42]
colnames(watDivHybrid30eTable) <- 1:30

# output the boxplots
pdf("../results/watDivMore/load_balancing/watDivFedra.pdf")
boxplot(watDivFedraTable, ylab="Number of transferred tuples", xlab="Endpoint", col=rainbow(10), log="y")
dev.off()

pdf("../results/watDivMore/load_balancing/watDiv20eFedra.pdf")
boxplot(watDivFedra20eTable, ylab="Number of transferred tuples", xlab="Endpoint", col=rainbow(20), log="y")
dev.off()

pdf("../results/watDivMore/load_balancing/watDiv30eFedra.pdf")
boxplot(watDivFedra30eTable, ylab="Number of transferred tuples", xlab="Endpoint", col=rainbow(30), log="y")
dev.off()

pdf("../results/watDivMore/load_balancing/watDivHybrid.pdf")
boxplot(watDivHybridTable, ylab="Number of transferred tuples", xlab="Endpoint", col=rainbow(10), log="y")
dev.off()

pdf("../results/watDivMore/load_balancing/watDiv20eHybrid.pdf")
boxplot(watDivHybrid20eTable, ylab="Number of transferred tuples", xlab="Endpoint", col=rainbow(20), log="y")
dev.off()

pdf("../results/watDivMore/load_balancing/watDiv30eHybrid.pdf")
boxplot(watDivHybrid30eTable, ylab="Number of transferred tuples", xlab="Endpoint", col=rainbow(30), log="y")
dev.off()
