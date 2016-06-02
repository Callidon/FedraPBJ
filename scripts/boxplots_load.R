#!/usr/bin/env Rscript
# Script to produce boxplots for the results of the load balancing
# author : Thomas Minier

require(ggplot2)
require(scales)

# Function used to process a value from output tables
processTable <- function(setupName, nbEndpoints, outputFedraPath, outputPBJHybridPath) {
	# read datas from the files
	outputFedra <- read.table(outputFedraPath)[13:(13 + nbEndpoints)]
	outputPBJHybrid <- read.table(outputPBJHybridPath)[13:(12 + nbEndpoints)]

	# set setup name column
	outputEngine$dataset <- setupName
	outputPBJHybrid$dataset <- setupName

	# set approach column
	outputEngine$approach <- approachFedxName
	outputFedra$approach <- approachFedxFedraName
	outputPBJPre$approach <- approachPBJPreName
	outputPBJPost$approach <- approachPBJPostName
	outputPBJHybrid$approach <- approachPBJHybridName

	# concat the tables and return it
	result <- rbind(outputEngine, outputFedra, outputPBJPre, outputPBJPost, outputPBJHybrid)
	return(result)
}

# add log10 scale + labels on X and Y axis on a ggplot's boxplot
bootstrap_ggplot <- function(plot, xLabel, yLabel, boxplotLabel = NULL, defaultScale=FALSE) {
	p <- plot + xlab(xLabel) + ylab(yLabel)

	if(! defaultScale) {
		p <- p + scale_y_continuous(trans = log10_trans(), breaks = trans_breaks("log10", function(x) 100^x), labels = trans_format("log10", math_format(10^.x)))
	}

	if(is.null(boxplotLabel)) {
		p <- p + geom_boxplot()
	} else {
		p <- p + geom_boxplot(boxplotLabel)
	}
	return(p)
}

# path to results files
# with the classic federation
outputWatDivEngine <- "../results/watDiv/outputFedXengineFEDERATION10Client"
outputWatDivFedra <- "../results/watDiv/outputFedXFedraFEDERATION10Client"
outputWatDivPBJPre <- "../results/watDiv/outputFedXFedra-PBJ-preFEDERATION10Client"
outputWatDivPBJPost <- "../results/watDiv/outputFedXFedra-PBJ-postFEDERATION10Client"
outputWatDivPBJHybrid <- "../results/watDiv/outputFedXFedra-PBJ-hybridFEDERATION10Client"

# with a federation of 20 endpoints
outputWatDiv20eEngine <- "../results/watDiv/outputFedXengineFEDERATION20Client"
outputWatDiv20eFedra <- "../results/watDivMore/outputFedXFedraFEDERATION20Client"
outputWatDiv20ePBJPre <- "../results/watDiv/outputFedXFedra-PBJ-preFEDERATION20Client"
outputWatDiv20ePBJPost <- "../results/watDiv/outputFedXFedra-PBJ-postFEDERATION20Client"
outputWatDiv20ePBJHybrid <- "../results/watDivMore/outputFedXFedra-PBJ-hybridFEDERATION20Client"

# with a federation of 30 endpoints
outputWatDiv30eEngine <- "../results/watDiv/outputFedXengineFEDERATION30Client"
outputWatDiv30eFedra <- "../results/watDivMore/outputFedXFedraFEDERATION30Client"
outputWatDiv30ePBJPre <- "../results/watDiv/outputFedXFedra-PBJ-preFEDERATION30Client"
outputWatDiv30ePBJPost <- "../results/watDiv/outputFedXFedra-PBJ-postFEDERATION30Client"
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
