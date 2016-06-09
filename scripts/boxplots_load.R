#!/usr/bin/env Rscript
# Script to produce barplots for the results of the load balancing by federation
# author : Thomas Minier

# path to results files
# with the classic federation
outputWatDivFedra <- "../results/watDivMore/outputFedXFedraFEDERATION10Client"
outputWatDivPBJHybrid <- "../results/watDivMore/outputFedXFedra-PBJ-hybridFEDERATION10Client"

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

watDivTuplesTable <- t(cbind(colSums(watDivFedraTuplesTable), colSums(watDivHybridTuplesTable)))
rownames(watDivTuplesTable) <- c("FedX + Fedra", "PBJ Hybrid")
pdf("../results/watDivMore/load_balancing/watDiv10Tuples.pdf")
barplot(watDivTuplesTable, ylab="Number of transferred tuples", xlab="Endpoint", col=c("cornflowerblue", "firebrick"), legend=rownames(watDivTuplesTable), beside=TRUE)
dev.off()

watDiv20eTuplesTable <- t(cbind(colSums(watDivFedraTuples20eTable), colSums(watDivHybridTuples20eTable)))
rownames(watDiv20eTuplesTable) <- c("FedX + Fedra", "PBJ Hybrid")
pdf("../results/watDivMore/load_balancing/watDiv20Tuples.pdf")
barplot(watDiv20eTuplesTable, ylab="Number of transferred tuples", xlab="Endpoint", col=c("cornflowerblue", "firebrick"), legend=rownames(watDivTuplesTable), beside=TRUE)
dev.off()

watDiv30eTuplesTable <- t(cbind(colSums(watDivFedraTuples30eTable), colSums(watDivHybridTuples30eTable)))
rownames(watDiv30eTuplesTable) <- c("FedX + Fedra", "PBJ Hybrid")
pdf("../results/watDivMore/load_balancing/watDiv30Tuples.pdf")
barplot(watDiv30eTuplesTable, ylab="Number of transferred tuples", xlab="Endpoint", col=c("cornflowerblue", "firebrick"), legend=rownames(watDivTuplesTable), beside=TRUE)
dev.off()

watDivCallsTable <- t(cbind(colSums(watDivFedraCallsTable), colSums(watDivHybridCallsTable)))
rownames(watDivCallsTable) <- c("FedX + Fedra", "PBJ Hybrid")
pdf("../results/watDivMore/load_balancing/watDiv10Calls.pdf")
barplot(watDivCallsTable, ylab="Number of calls", xlab="Endpoint", col=c("cornflowerblue", "firebrick"), legend=rownames(watDivCallsTable), beside=TRUE)
dev.off()

watDiv20eCallsTable <- t(cbind(colSums(watDivFedraCalls20eTable), colSums(watDivHybridCalls20eTable)))
rownames(watDiv20eCallsTable) <- c("FedX + Fedra", "PBJ Hybrid")
pdf("../results/watDivMore/load_balancing/watDiv20Calls.pdf")
barplot(watDiv20eCallsTable, ylab="Number of calls", xlab="Endpoint", col=c("cornflowerblue", "firebrick"), legend=rownames(watDiv20eCallsTable), beside=TRUE)
dev.off()

watDiv30eCallsTable <- t(cbind(colSums(watDivFedraCalls30eTable), colSums(watDivHybridCalls30eTable)))
rownames(watDiv30eCallsTable) <- c("FedX + Fedra", "PBJ Hybrid")
pdf("../results/watDivMore/load_balancing/watDiv30Calls.pdf")
barplot(watDiv30eCallsTable, ylab="Number of calls", xlab="Endpoint", col=c("cornflowerblue", "firebrick"), legend=rownames(watDiv30eCallsTable), beside=TRUE)
dev.off()
