#!/usr/bin/env Rscript
# Script to produce boxplots for the results from various executions of the setup
# author : Thomas Minier

require(ggplot2)
require(scales)

# Global variables
definitiveSetupName <- "WatDiv"
approachEngineName <- "FedX"
approachFedxFedraName <- "FedX + Fedra"
approachPeneloopName <- "FedX + Fedra + PeNeLoop"

execTimelabel <- "Execution time (s)"
endpointsLabel <- "Number of endpoints in federation"
tuplesLabel <- "Number of transferred tuples"
completenessLabel <- "Completeness"
strategyLabel <- "Strategy"
datasetLabel <- "Dataset"

# Function used to process a value from output tables with different federation sizes
processFederationTables <- function(value_ind, outputEnginePath, outputFedraPath, outputPeneloopPath, outputEngine20ePath, outputFedra20ePath, outputPeneloop20ePath, outputEngine30ePath, outputFedra30ePath, outputPeneloop30ePath) {
	# read datas from the files
	outputEngine <- read.table(outputEnginePath)[value_ind]
	outputFedra <- read.table(outputFedraPath)[value_ind]
	outputPeneloop <- read.table(outputPeneloopPath)[value_ind]
	outputEngine20e <- read.table(outputEngine20ePath)[value_ind]
  outputFedra20e <- read.table(outputFedra20ePath)[value_ind]
	outputPeneloop20e <- read.table(outputPeneloop20ePath)[value_ind]
	outputEngine30e <- read.table(outputEngine30ePath)[value_ind]
  outputFedra30e <- read.table(outputFedra30ePath)[value_ind]
	outputPeneloop30e <- read.table(outputPeneloop30ePath)[value_ind]

	# set setup name column
	outputEngine$endpoints <- "10"
  outputFedra$endpoints <- "10"
	outputPeneloop$endpoints <- "10"
	outputEngine20e$endpoints <- "20"
  outputFedra20e$endpoints <- "20"
	outputPeneloop20e$endpoints <- "20"
	outputEngine30e$endpoints <- "30"
  outputFedra30e$endpoints <- "30"
	outputPeneloop30e$endpoints <- "30"

	# set approach column
	outputEngine$approach <- approachEngineName
	outputFedra$approach <- approachFedxFedraName
	outputPeneloop$approach <- approachPeneloopName
	outputEngine20e$approach <- approachEngineName
  outputFedra20e$approach <- approachFedxFedraName
	outputPeneloop20e$approach <- approachPeneloopName
	outputEngine30e$approach <- approachEngineName
  outputFedra30e$approach <- approachFedxFedraName
	outputPeneloop30e$approach <- approachPeneloopName

	# concat the tables and return it
	result <- rbind(outputEngine, outputFedra, outputPeneloop, outputEngine20e, outputFedra20e, outputPeneloop20e, outputEngine30e, outputFedra30e, outputPeneloop30e)
	return(result)
}

# add log10 scale + labels on X and Y axis on a ggplot"s boxplot
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

# from definitive setup
# with a federation of 10 endpoints
outputWatDivEngine <- "../results/definitive/fed10e/federation3/outputFedXengineFEDERATION10Client"
outputWatDivFedra <- "../results/definitive/fed10e/federation3/outputFedXFedraFEDERATION10Client"
outputWatDivPeneloop <- "../results/definitive/fed10e/federation3/outputFedXFedra-PBJ-hybridFEDERATION10Client"

# with only the parallelized queries
outputWatDivPll10eEngine <- "../results/definitive/fed10e/federation3/parallelized/outputFedXengineFEDERATION10Client"
outputWatDivPll10eFedra <- "../results/definitive/fed10e/federation3/parallelized/outputFedXFedraFEDERATION10Client"
outputWatDivPll10ePeneloop <- "../results/definitive/fed10e/federation3/parallelized/outputFedXFedra-PBJ-hybridFEDERATION10Client"

# with a federation of 20 endpoints
outputWatDiv20eEngine <- "../results/definitive/fed20e/federation3/outputFedXengineFEDERATION20Client"
outputWatDiv20eFedra <- "../results/definitive/fed20e/federation3/outputFedXFedraFEDERATION20Client"
outputWatDiv20ePeneloop <- "../results/definitive/fed20e/federation3/outputFedXFedra-PBJ-hybridFEDERATION20Client"

# with only the parallelized queries
outputWatDivPll20eEngine <- "../results/definitive/fed20e/federation3/parallelized/outputFedXengineFEDERATION20Client"
outputWatDivPll20eFedra <- "../results/definitive/fed20e/federation3/parallelized/outputFedXFedraFEDERATION20Client"
outputWatDivPll20ePeneloop <- "../results/definitive/fed20e/federation3/parallelized/outputFedXFedra-PBJ-hybridFEDERATION20Client"

# with a federation of 30 endpoints
outputWatDiv30eEngine <- "../results/definitive/fed30e/federation3/outputFedXengineFEDERATION30Client"
outputWatDiv30eFedra <- "../results/definitive/fed30e/federation3/outputFedXFedraFEDERATION30Client"
outputWatDiv30ePeneloop <- "../results/definitive/fed30e/federation3/outputFedXFedra-PBJ-hybridFEDERATION30Client"

# with only the parallelized queries
outputWatDivPll30eEngine <- "../results/definitive/fed30e/federation3/parallelized/outputFedXengineFEDERATION30Client"
outputWatDivPll30eFedra <- "../results/definitive/fed30e/federation3/parallelized/outputFedXFedraFEDERATION30Client"
outputWatDivPll30ePeneloop <- "../results/definitive/fed30e/federation3/parallelized/outputFedXFedra-PBJ-hybridFEDERATION30Client"

# For the execution time
# Process the datas & merge them into one unique table
definitiveTable <- processFederationTables(2, outputWatDivEngine, outputWatDivFedra, outputWatDivPeneloop, outputWatDiv20eEngine, outputWatDiv20eFedra, outputWatDiv20ePeneloop, outputWatDiv30eEngine, outputWatDiv30eFedra, outputWatDiv30ePeneloop)
definitivePllTable <- processFederationTables(2, outputWatDivPll10eEngine, outputWatDivPll10eFedra, outputWatDivPll10ePeneloop, outputWatDivPll20eEngine, outputWatDivPll20eFedra, outputWatDivPll20ePeneloop, outputWatDivPll30eEngine, outputWatDivPll30eFedra, outputWatDivPll30ePeneloop)

# set the colnames
colnames(definitiveTable) <- c("time", "endpoints", "Strategy")
colnames(definitivePllTable) <- c("time", "endpoints", "Strategy")

# create the boxplots
pdf("../results/definitive/fed3_execution_time.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = definitiveTable, aes(x=endpoints, y=time)), endpointsLabel, execTimelabel, aes(fill=Strategy))
dev.off()

pdf("../results/definitive/fed3_pll_execution_time.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = definitivePllTable, aes(x=endpoints, y=time)), endpointsLabel, execTimelabel, aes(fill=Strategy))
dev.off()


# For the number of transfered tuples
# Process the datas & merge them into one unique table
definitiveTable <- processFederationTables(11, outputWatDivEngine, outputWatDivFedra, outputWatDivPeneloop, outputWatDiv20eEngine, outputWatDiv20eFedra, outputWatDiv20ePeneloop, outputWatDiv30eEngine, outputWatDiv30eFedra, outputWatDiv30ePeneloop)
definitivePllTable <- processFederationTables(11, outputWatDivPll10eEngine, outputWatDivPll10eFedra, outputWatDivPll10ePeneloop, outputWatDivPll20eEngine, outputWatDivPll20eFedra, outputWatDivPll20ePeneloop, outputWatDivPll30eEngine, outputWatDivPll30eFedra, outputWatDivPll30ePeneloop)

# set the colnames
colnames(definitiveTable) <- c("tuples", "endpoints", "Strategy")
colnames(definitivePllTable) <- c("tuples", "endpoints", "Strategy")

# create the boxplots
pdf("../results/definitive/fed3_transferred_tuples.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = definitiveTable, aes(x=endpoints, y=tuples)), endpointsLabel, tuplesLabel, aes(fill=Strategy))
dev.off()

pdf("../results/definitive/fed3_pll_transferred_tuples.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = definitivePllTable, aes(x=endpoints, y=tuples)), endpointsLabel, tuplesLabel, aes(fill=Strategy))
dev.off()

# For the completness
# Process the datas & merge them into one unique table
definitiveTable <- processFederationTables(6, outputWatDivEngine, outputWatDivFedra, outputWatDivPeneloop, outputWatDiv20eEngine, outputWatDiv20eFedra, outputWatDiv20ePeneloop, outputWatDiv30eEngine, outputWatDiv30eFedra, outputWatDiv30ePeneloop)
definitivePllTable <- processFederationTables(6, outputWatDivPll10eEngine, outputWatDivPll10eFedra, outputWatDivPll10ePeneloop, outputWatDivPll20eEngine, outputWatDivPll20eFedra, outputWatDivPll20ePeneloop, outputWatDivPll30eEngine, outputWatDivPll30eFedra, outputWatDivPll30ePeneloop)

# set the colnames
colnames(definitiveTable) <- c("completness", "endpoints", "Strategy")
colnames(definitivePllTable) <- c("completness", "endpoints", "Strategy")

# create the boxplots

pdf("../results/definitive/fed3_completeness.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = definitiveTable, aes(x=endpoints, y=completness)), endpointsLabel, completenessLabel, aes(colour=Strategy, fill=Strategy), TRUE)
dev.off()

pdf("../results/definitive/fed3_pll_completeness.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = definitivePllTable, aes(x=endpoints, y=completness)), endpointsLabel, completenessLabel, aes(colour=Strategy, fill=Strategy), TRUE)
dev.off()
