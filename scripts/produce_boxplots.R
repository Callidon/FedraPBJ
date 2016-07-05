#!/usr/bin/env Rscript
# Script to produce boxplots for the results from various executions of the setup
# author : Thomas Minier

require(ggplot2)
require(scales)

# Global variables
watDivSetupName <- "WatDiv"
watDiv100SetupName <- "WatDiv100"

approachFedxName <- "FedX"
approachFedxFedraName <- "FedX + Fedra"
approachPBJPreName <- "PBJ Pre"
approachPBJPostName <- "PBJ Post"
approachPBJHybridName <- "PBJ Hybrid"

execTimelabel <- "Execution time (s)"
endpointsLabel <- "Number of endpoints in federation"
tuplesLabel <- "Number of transferred tuples"
completenessLabel <- "Completeness"
strategyLabel <- "Strategy"
datasetLabel <- "Dataset"

# Function used to process a value from output tables with different federation sizes
processFederationTables <- function(value_ind, outputFedraPath, outputPBJHybridPath, outputFedra20ePath, outputPBJHybrid20ePath, outputFedra30ePath, outputPBJHybrid30ePath) {
	# read datas from the files
	outputFedra <- read.table(outputFedraPath)[value_ind]
	outputPBJHybrid <- read.table(outputPBJHybridPath)[value_ind]
  outputFedra20e <- read.table(outputFedra20ePath)[value_ind]
	outputPBJHybrid20e <- read.table(outputPBJHybrid20ePath)[value_ind]
  outputFedra30e <- read.table(outputFedra30ePath)[value_ind]
	outputPBJHybrid30e <- read.table(outputPBJHybrid30ePath)[value_ind]

	# set setup name column
  outputFedra$endpoints <- "10"
	outputPBJHybrid$endpoints <- "10"
  outputFedra20e$endpoints <- "20"
	outputPBJHybrid20e$endpoints <- "20"
  outputFedra30e$endpoints <- "30"
	outputPBJHybrid30e$endpoints <- "30"

	# set approach column
	outputFedra$approach <- approachFedxFedraName
	outputPBJHybrid$approach <- approachPBJHybridName
  outputFedra20e$approach <- approachFedxFedraName
	outputPBJHybrid20e$approach <- approachPBJHybridName
  outputFedra30e$approach <- approachFedxFedraName
	outputPBJHybrid30e$approach <- approachPBJHybridName

	# concat the tables and return it
	result <- rbind(outputFedra, outputPBJHybrid, outputFedra20e, outputPBJHybrid20e, outputFedra30e, outputPBJHybrid30e)
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

# from watDiv setup
# with a federation of 10 endpoints
outputWatDivEngine <- "../results/watDiv/outputFedXengineFEDERATION10Client"
outputWatDivFedra <- "../results/watDivMore/outputFedXFedraFEDERATION10Client"
outputWatDivPBJHybrid <- "../results/watDivMore/outputFedXFedra-PBJ-hybridFEDERATION10Client"

# with only the parallelized queries
outputWatDivPll10eEngine <- "../results/watDiv/parallelized/outputFedXengineFEDERATION10Client"
outputWatDivPll10eFedra <- "../results/watDivMore/parallelized/outputFedXFedraFEDERATION10Client"
outputWatDivPll10ePBJHybrid <- "../results/watDivMore/parallelized/outputFedXFedra-PBJ-hybridFEDERATION10Client"

# with a federation of 20 endpoints
outputWatDiv20eEngine <- "../results/watDiv/outputFedXengineFEDERATION20Client"
outputWatDiv20eFedra <- "../results/watDivMore/outputFedXFedraFEDERATION20Client"
outputWatDiv20ePBJHybrid <- "../results/watDivMore/outputFedXFedra-PBJ-hybridFEDERATION20Client"

# with only the parallelized queries
outputWatDivPll20eEngine <- "../results/watDiv/parallelized/outputFedXengineFEDERATION20Client"
outputWatDivPll20eFedra <- "../results/watDivMore/parallelized/outputFedXFedraFEDERATION20Client"
outputWatDivPll20ePBJHybrid <- "../results/watDivMore/parallelized/outputFedXFedra-PBJ-hybridFEDERATION20Client"

# with a federation of 30 endpoints
outputWatDiv30eEngine <- "../results/watDiv/outputFedXengineFEDERATION30Client"
outputWatDiv30eFedra <- "../results/watDivMore/outputFedXFedraFEDERATION30Client"
outputWatDiv30ePBJHybrid <- "../results/watDivMore/outputFedXFedra-PBJ-hybridFEDERATION30Client"

# with only the parallelized queries
outputWatDivPll30eEngine <- "../results/watDiv/parallelized/outputFedXengineFEDERATION30Client"
outputWatDivPll30eFedra <- "../results/watDivMore/parallelized/outputFedXFedraFEDERATION30Client"
outputWatDivPll30ePBJHybrid <- "../results/watDivMore/parallelized/outputFedXFedra-PBJ-hybridFEDERATION30Client"

# For the execution time
# Process the datas & merge them into one unique table
watDivMoreTable <- processFederationTables(2, outputWatDivFedra, outputWatDivPBJHybrid, outputWatDiv20eFedra, outputWatDiv20ePBJHybrid, outputWatDiv30eFedra, outputWatDiv30ePBJHybrid)
watDivMorePllTable <- processFederationTables(2, outputWatDivPll10eFedra, outputWatDivPll10ePBJHybrid, outputWatDivPll20eFedra, outputWatDivPll20ePBJHybrid, outputWatDivPll30eFedra, outputWatDivPll30ePBJHybrid)

# set the colnames
colnames(watDivMoreTable) <- c("time", "endpoints", "Strategy")
colnames(watDivMorePllTable) <- c("time", "endpoints", "Strategy")

# create the boxplots
pdf("../results/watDivMore/execution_time.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = watDivMoreTable, aes(x=endpoints, y=time)), endpointsLabel, execTimelabel, aes(fill=Strategy))
dev.off()

pdf("../results/watDivMore/parallelized/execution_time.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = watDivMorePllTable, aes(x=endpoints, y=time)), endpointsLabel, execTimelabel, aes(fill=Strategy))
dev.off()


# For the number of transfered tuples
# Process the datas & merge them into one unique table
watDivMoreTable <- processFederationTables(11, outputWatDivFedra, outputWatDivPBJHybrid, outputWatDiv20eFedra, outputWatDiv20ePBJHybrid, outputWatDiv30eFedra, outputWatDiv30ePBJHybrid)
watDivMorePllTable <- processFederationTables(11, outputWatDivPll10eFedra, outputWatDivPll10ePBJHybrid, outputWatDivPll20eFedra, outputWatDivPll20ePBJHybrid, outputWatDivPll30eFedra, outputWatDivPll30ePBJHybrid)
# set the colnames
colnames(watDivMoreTable) <- c("tuples", "endpoints", "Strategy")
colnames(watDivMorePllTable) <- c("tuples", "endpoints", "Strategy")

# create the boxplots
pdf("../results/watDivMore/transferred_tuples.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = watDivMoreTable, aes(x=endpoints, y=tuples)), endpointsLabel, tuplesLabel, aes(fill=Strategy))
dev.off()

pdf("../results/watDivMore/parallelized/transferred_tuples.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = watDivMorePllTable, aes(x=endpoints, y=tuples)), endpointsLabel, tuplesLabel, aes(fill=Strategy))
dev.off()


# For the completness
# Process the datas & merge them into one unique table
watDivMoreTable <- processFederationTables(6, outputWatDivFedra, outputWatDivPBJHybrid, outputWatDiv20eFedra, outputWatDiv20ePBJHybrid, outputWatDiv30eFedra, outputWatDiv30ePBJHybrid)
watDivMorePllTable <- processFederationTables(6, outputWatDivPll10eFedra, outputWatDivPll10ePBJHybrid, outputWatDivPll20eFedra, outputWatDivPll20ePBJHybrid, outputWatDivPll30eFedra, outputWatDivPll30ePBJHybrid)

# set the colnames
colnames(watDivMoreTable) <- c("completness", "endpoints", "Strategy")
colnames(watDivMorePllTable) <- c("completness", "endpoints", "Strategy")

# create the boxplots

pdf("../results/watDivMore/completeness.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = watDivMoreTable, aes(x=endpoints, y=completness)), endpointsLabel, completenessLabel, aes(fill=Strategy), TRUE)
dev.off()

pdf("../results/watDivMore/parallelized/completeness.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = watDivMorePllTable, aes(x=endpoints, y=completness)), endpointsLabel, completenessLabel, aes(fill=Strategy), TRUE)
dev.off()
