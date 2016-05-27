#!/usr/bin/env Rscript
# Script to produce boxplots for the results from various executions of the setup
# author : Thomas Minier

require(ggplot2)
require(scales)

# Global variables
diseasomeSetupName <- "Diseasome"
linkedMDBSetupName <- "LinkedMDB"
geoCoordinatesSetupName <- "GeoCoords"
swdfSetupName <- "SWDF"
watDivSetupName <- "WatDiv"
watDiv100SetupName <- "WatDiv100"

approachFedxName <- "FedX"
approachFedxFedraName <- "FedX + Fedra"
approachPBJPreName <- "PBJ Pre"
approachPBJPostName <- "PBJ Post"
approachPBJHybridName <- "PBJ Hybrid"

execTimelabel <- "Execution time (s)"
tuplesLabel <- "Number of transferred tuples"
completenessLabel <- "Completeness"
strategyLabel <- "Strategy"
datasetLabel <- "Dataset"

# Function used to process a value from output tables
processTable <- function(setupName, value_ind, outputEnginePath, outputFedraPath, outputPBJPrePath, outputPBJPostPath, outputPBJHybridPath) {
	# read datas from the files
	outputEngine <- read.table(outputEnginePath)[value_ind]
	outputFedra <- read.table(outputFedraPath)[value_ind]
	outputPBJPre <- read.table(outputPBJPrePath)[value_ind]
	outputPBJPost <- read.table(outputPBJPostPath)[value_ind]
	outputPBJHybrid <- read.table(outputPBJHybridPath)[value_ind]

	# set setup name column
	outputEngine$dataset <- setupName
	outputFedra$dataset <- setupName
	outputPBJPre$dataset <- setupName
	outputPBJPost$dataset <- setupName
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

# from Diseasome setup
outputDiseasomeEngine <- "../results/diseasome/outputFedXengineFEDERATION10Client"
outputDiseasomeFedra <- "../results/diseasome/outputFedXFedraFEDERATION10Client"
outputDiseasomePBJPre <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"
outputDiseasomePBJPost <- "../results/diseasome/outputFedXFedra-PBJ-postFEDERATION10Client"
outputDiseasomePBJHybrid <- "../results/diseasome/outputFedXFedra-PBJ-hybridFEDERATION10Client"

# from linkedMDB setup
outputLinkedMDBEngine <- "../results/linkedMDB/outputFedXengineFEDERATION10Client"
outputLinkedMDBFedra <- "../results/linkedMDB/outputFedXFedraFEDERATION10Client"
outputLinkedMDBPBJPre <- "../results/linkedMDB/outputFedXFedra-PBJ-preFEDERATION10Client"
outputLinkedMDBPBJPost <- "../results/linkedMDB/outputFedXFedra-PBJ-postFEDERATION10Client"
outputLinkedMDBPBJHybrid <- "../results/linkedMDB/outputFedXFedra-PBJ-hybridFEDERATION10Client"

# from geoCoordinates setup
outputGeoCoordinatesEngine <- "../results/geoCoordinates/outputFedXengineFEDERATION10Client"
outputGeoCoordinatesFedra <- "../results/geoCoordinates/outputFedXFedraFEDERATION10Client"
outputGeoCoordinatesPBJPre <- "../results/geoCoordinates/outputFedXFedra-PBJ-preFEDERATION10Client"
outputGeoCoordinatesPBJPost <- "../results/geoCoordinates/outputFedXFedra-PBJ-postFEDERATION10Client"
outputGeoCoordinatesPBJHybrid <- "../results/geoCoordinates/outputFedXFedra-PBJ-hybridFEDERATION10Client"

# from swdf setup
outputSWDFEngine <- "../results/swdf/outputFedXengineFEDERATION10Client"
outputSWDFFedra <- "../results/swdf/outputFedXFedraFEDERATION10Client"
outputSWDFPBJPre <- "../results/swdf/outputFedXFedra-PBJ-preFEDERATION10Client"
outputSWDFPBJPost <- "../results/swdf/outputFedXFedra-PBJ-postFEDERATION10Client"
outputSWDFPBJHybrid <- "../results/swdf/outputFedXFedra-PBJ-hybridFEDERATION10Client"

# from watDiv setup
# with the classic federation
outputWatDivEngine <- "../results/watDiv/outputFedXengineFEDERATION10Client"
outputWatDivFedra <- "../results/watDiv/outputFedXFedraFEDERATION10Client"
outputWatDivPBJPre <- "../results/watDiv/outputFedXFedra-PBJ-preFEDERATION10Client"
outputWatDivPBJPost <- "../results/watDiv/outputFedXFedra-PBJ-postFEDERATION10Client"
outputWatDivPBJHybrid <- "../results/watDiv/outputFedXFedra-PBJ-hybridFEDERATION10Client"

# with a federation of 20 endpoints
outputWatDiv20eEngine <- "../results/watDiv/outputFedXengineFEDERATION20Client"
outputWatDiv20eFedra <- "../results/watDiv/outputFedXFedraFEDERATION20Client"
outputWatDiv20ePBJPre <- "../results/watDiv/outputFedXFedra-PBJ-preFEDERATION20Client"
outputWatDiv20ePBJPost <- "../results/watDiv/outputFedXFedra-PBJ-postFEDERATION20Client"
outputWatDiv20ePBJHybrid <- "../results/watDiv/outputFedXFedra-PBJ-hybridFEDERATION20Client"

# with only the parallelized queries
outputWatDivPll20eEngine <- "../results/watDiv/parallelized/outputFedXengineFEDERATION20Client"
outputWatDivPll20eFedra <- "../results/watDiv/parallelized/outputFedXFedraFEDERATION20Client"
outputWatDivPll20ePBJPre <- "../results/watDiv/parallelized/outputFedXFedra-PBJ-preFEDERATION20Client"
outputWatDivPll20ePBJPost <- "../results/watDiv/parallelized/outputFedXFedra-PBJ-postFEDERATION20Client"
outputWatDivPll20ePBJHybrid <- "../results/watDiv/parallelized/outputFedXFedra-PBJ-hybridFEDERATION20Client"

# with a federation of 30 endpoints
outputWatDiv30eEngine <- "../results/watDiv/outputFedXengineFEDERATION30Client"
outputWatDiv30eFedra <- "../results/watDiv/outputFedXFedraFEDERATION30Client"
outputWatDiv30ePBJPre <- "../results/watDiv/outputFedXFedra-PBJ-preFEDERATION30Client"
outputWatDiv30ePBJPost <- "../results/watDiv/outputFedXFedra-PBJ-postFEDERATION30Client"
outputWatDiv30ePBJHybrid <- "../results/watDiv/outputFedXFedra-PBJ-hybridFEDERATION30Client"

# with only the parallelized queries
outputWatDivPll30eEngine <- "../results/watDiv/parallelized/outputFedXengineFEDERATION30Client"
outputWatDivPll30eFedra <- "../results/watDiv/parallelized/outputFedXFedraFEDERATION30Client"
outputWatDivPll30ePBJPre <- "../results/watDiv/parallelized/outputFedXFedra-PBJ-preFEDERATION30Client"
outputWatDivPll30ePBJPost <- "../results/watDiv/parallelized/outputFedXFedra-PBJ-postFEDERATION30Client"
outputWatDivPll30ePBJHybrid <- "../results/watDiv/parallelized/outputFedXFedra-PBJ-hybridFEDERATION30Client"

# from watDiv100 setup
outputWatDiv100Engine <- "../results/watDiv100/outputFedXengineFEDERATION10Client"
outputWatDiv100Fedra <- "../results/watDiv100/outputFedXFedraFEDERATION10Client"
outputWatDiv100PBJPre <- "../results/watDiv100/outputFedXFedra-PBJ-preFEDERATION10Client"
outputWatDiv100PBJPost <- "../results/watDiv100/outputFedXFedra-PBJ-postFEDERATION10Client"
outputWatDiv100PBJHybrid <- "../results/watDiv100/outputFedXFedra-PBJ-hybridFEDERATION10Client"

# For the execution time
# Process the datas & merge them into one unique table
diseasomeTable <- processTable(diseasomeSetupName, 2, outputDiseasomeEngine, outputDiseasomeFedra, outputDiseasomePBJPre, outputDiseasomePBJPost, outputDiseasomePBJHybrid)
linkedMDBTable <- processTable(linkedMDBSetupName, 2, outputLinkedMDBEngine, outputLinkedMDBFedra, outputLinkedMDBPBJPre, outputLinkedMDBPBJPost, outputLinkedMDBPBJHybrid)
geoCoordinatesTable <- processTable(geoCoordinatesSetupName, 2, outputGeoCoordinatesEngine, outputGeoCoordinatesFedra, outputGeoCoordinatesPBJPre, outputGeoCoordinatesPBJPost, outputGeoCoordinatesPBJHybrid)
SWDFTable <- processTable(swdfSetupName, 2, outputSWDFEngine, outputSWDFFedra, outputSWDFPBJPre, outputSWDFPBJPost, outputSWDFPBJHybrid)
watDivTable <- processTable(watDivSetupName, 2, outputWatDivEngine, outputWatDivFedra, outputWatDivPBJPre, outputWatDivPBJPost, outputWatDivPBJHybrid)
watDiv20eTable <- processTable(watDivSetupName, 2, outputWatDiv20eEngine, outputWatDiv20eFedra, outputWatDiv20ePBJPre, outputWatDiv20ePBJPost, outputWatDiv20ePBJHybrid)
#watDiv30eTable <- processTable(watDivSetupName, 2, outputWatDiv30eEngine, outputWatDiv30eFedra, outputWatDiv30ePBJPre, outputWatDiv30ePBJPost, outputWatDiv30ePBJHybrid)
watDivPll20eTable <- processTable(watDivSetupName, 2, outputWatDivPll20eEngine, outputWatDivPll20eFedra, outputWatDivPll20ePBJPre, outputWatDivPll20ePBJPost, outputWatDivPll20ePBJHybrid)
#watDivPll30eTable <- processTable(watDivSetupName, 2, outputWatDivPll30eEngine, outputWatDivPll30eFedra, outputWatDivPll30ePBJPre, outputWatDivPll30ePBJPost, outputWatDivPll30ePBJHybrid)

# TEMP - remove when all results are here
watDiv30eTable <- processTable(watDivSetupName, 2, outputWatDivEngine, outputWatDiv30eFedra, outputWatDivPBJPre, outputWatDivPBJPost, outputWatDiv30ePBJHybrid)
watDivPll30eTable <- processTable(watDivSetupName, 2, outputWatDivEngine, outputWatDivPll30eFedra, outputWatDivPBJPre, outputWatDivPBJPost, outputWatDivPll30ePBJHybrid)
# END TEMP

watDiv100Table <- processTable(watDiv100SetupName, 2, outputWatDiv100Engine, outputWatDiv100Fedra, outputWatDiv100PBJPre, outputWatDiv100PBJPost, outputWatDiv100PBJHybrid)
timesTable <- rbind(diseasomeTable, linkedMDBTable, geoCoordinatesTable, SWDFTable, watDivTable, watDiv100Table)

# set the colnames
colnames(diseasomeTable) <- c("time", "dataset", "Strategy")
colnames(linkedMDBTable) <- c("time", "dataset", "Strategy")
colnames(geoCoordinatesTable) <- c("time", "dataset", "Strategy")
colnames(SWDFTable) <- c("time", "dataset", "Strategy")
colnames(watDivTable) <- c("time", "dataset", "Strategy")
colnames(watDiv20eTable) <- c("time", "dataset", "Strategy")
colnames(watDiv30eTable) <- c("time", "dataset", "Strategy")
colnames(watDivPll20eTable) <- c("time", "dataset", "Strategy")
colnames(watDivPll30eTable) <- c("time", "dataset", "Strategy")
colnames(watDiv100Table) <- c("time", "dataset", "Strategy")
colnames(timesTable) <- c("time", "dataset", "Strategy")

# create the boxplots
pdf("../results/execution_time.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = timesTable, aes(x=dataset, y=time)), datasetLabel, execTimelabel, aes(fill=Strategy))
dev.off()

pdf("../results/diseasome/execution_time.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = diseasomeTable, aes(x=Strategy, y=time)), strategyLabel, execTimelabel)
dev.off()

pdf("../results/linkedMDB/execution_time.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = linkedMDBTable, aes(x=Strategy, y=time)), strategyLabel, execTimelabel)
dev.off()

pdf("../results/geoCoordinates/execution_time.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = geoCoordinatesTable, aes(x=Strategy, y=time)), strategyLabel, execTimelabel)
dev.off()

pdf("../results/swdf/execution_time.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = SWDFTable, aes(x=Strategy, y=time)), strategyLabel, execTimelabel)
dev.off()

pdf("../results/watDiv/execution_time.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = watDivTable, aes(x=Strategy, y=time)), strategyLabel, execTimelabel)
dev.off()

pdf("../results/watDiv/execution_time_20endpoints.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = watDiv20eTable, aes(x=Strategy, y=time)), strategyLabel, execTimelabel)
dev.off()

pdf("../results/watDiv/execution_time_30endpoints.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = watDiv30eTable, aes(x=Strategy, y=time)), strategyLabel, execTimelabel)
dev.off()

pdf("../results/watDiv/parallelized/execution_time_20endpoints.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = watDivPll20eTable, aes(x=Strategy, y=time)), strategyLabel, execTimelabel)
dev.off()

pdf("../results/watDiv/parallelized/execution_time_30endpoints.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = watDivPll30eTable, aes(x=Strategy, y=time)), strategyLabel, execTimelabel)
dev.off()

pdf("../results/watDiv100/execution_time.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = watDiv100Table, aes(x=Strategy, y=time)), strategyLabel, execTimelabel)
dev.off()

# For the number of transfered tuples
# Process the datas & merge them into one unique table
diseasomeTable <- processTable(diseasomeSetupName, 11, outputDiseasomeEngine, outputDiseasomeFedra, outputDiseasomePBJPre, outputDiseasomePBJPost, outputDiseasomePBJHybrid)
linkedMDBTable <- processTable(linkedMDBSetupName, 11, outputLinkedMDBEngine, outputLinkedMDBFedra, outputLinkedMDBPBJPre, outputLinkedMDBPBJPost, outputLinkedMDBPBJHybrid)
geoCoordinatesTable <- processTable(geoCoordinatesSetupName, 11, outputGeoCoordinatesEngine, outputGeoCoordinatesFedra, outputGeoCoordinatesPBJPre, outputGeoCoordinatesPBJPost, outputGeoCoordinatesPBJHybrid)
SWDFTable <- processTable(swdfSetupName, 11, outputSWDFEngine, outputSWDFFedra, outputSWDFPBJPre, outputSWDFPBJPost, outputSWDFPBJHybrid)
watDivTable <- processTable(watDivSetupName, 11, outputWatDivEngine, outputWatDivFedra, outputWatDivPBJPre, outputWatDivPBJPost, outputWatDivPBJHybrid)
watDiv20eTable <- processTable(watDivSetupName, 11, outputWatDiv20eEngine, outputWatDiv20eFedra, outputWatDiv20ePBJPre, outputWatDiv20ePBJPost, outputWatDiv20ePBJHybrid)
#watDiv30eTable <- processTable(watDivSetupName, 11, outputWatDiv30eEngine, outputWatDiv30eFedra, outputWatDiv30ePBJPre, outputWatDiv30ePBJPost, outputWatDiv30ePBJHybrid)
watDivPll20eTable <- processTable(watDivSetupName, 11, outputWatDivPll20eEngine, outputWatDivPll20eFedra, outputWatDivPll20ePBJPre, outputWatDivPll20ePBJPost, outputWatDivPll20ePBJHybrid)
#watDivPll30eTable <- processTable(watDivSetupName, 11, outputWatDivPll30eEngine, outputWatDivPll30eFedra, outputWatDivPll30ePBJPre, outputWatDivPll30ePBJPost, outputWatDivPll30ePBJHybrid)

# TEMP - remove when all the results are here
watDiv30eTable <- processTable(watDivSetupName, 11, outputWatDivEngine, outputWatDiv30eFedra, outputWatDivPBJPre, outputWatDivPBJPost, outputWatDiv30ePBJHybrid)
watDivPll30eTable <- processTable(watDivSetupName, 11, outputWatDivEngine, outputWatDivPll30eFedra, outputWatDivPBJPre, outputWatDivPBJPost, outputWatDivPll30ePBJHybrid)
# END TEMP

watDiv100Table <- processTable(watDiv100SetupName, 11, outputWatDiv100Engine, outputWatDiv100Fedra, outputWatDiv100PBJPre, outputWatDiv100PBJPost, outputWatDiv100PBJHybrid)
tuplesTable <- rbind(diseasomeTable, linkedMDBTable, geoCoordinatesTable, SWDFTable, watDivTable, watDiv100Table)

# set the colnames
colnames(diseasomeTable) <- c("tuples", "dataset", "Strategy")
colnames(linkedMDBTable) <- c("tuples", "dataset", "Strategy")
colnames(geoCoordinatesTable) <- c("tuples", "dataset", "Strategy")
colnames(SWDFTable) <- c("tuples", "dataset", "Strategy")
colnames(watDivTable) <- c("tuples", "dataset", "Strategy")
colnames(watDiv20eTable) <- c("tuples", "dataset", "Strategy")
colnames(watDiv30eTable) <- c("tuples", "dataset", "Strategy")
colnames(watDivPll20eTable) <- c("tuples", "dataset", "Strategy")
colnames(watDivPll30eTable) <- c("tuples", "dataset", "Strategy")
colnames(watDiv100Table) <- c("tuples", "dataset", "Strategy")
colnames(tuplesTable) <- c("tuples", "dataset", "Strategy")

# create the boxplots
pdf("../results/transferred_tuples.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = tuplesTable, aes(x=dataset, y=tuples)), datasetLabel, tuplesLabel, aes(fill=Strategy))
dev.off()

pdf("../results/diseasome/transferred_tuples.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = diseasomeTable, aes(x=Strategy, y=tuples)), strategyLabel, tuplesLabel)
dev.off()

pdf("../results/linkedMDB/transferred_tuples.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = linkedMDBTable, aes(x=Strategy, y=tuples)), strategyLabel, tuplesLabel)
dev.off()

pdf("../results/geoCoordinates/transferred_tuples.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = geoCoordinatesTable, aes(x=Strategy, y=tuples)), strategyLabel, tuplesLabel)
dev.off()

pdf("../results/swdf/transferred_tuples.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = SWDFTable, aes(x=Strategy, y=tuples)), strategyLabel, tuplesLabel)
dev.off()

pdf("../results/watDiv/transferred_tuples.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = watDivTable, aes(x=Strategy, y=tuples)), strategyLabel, tuplesLabel)
dev.off()

pdf("../results/watDiv/transferred_tuples_20endpoints.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = watDiv20eTable, aes(x=Strategy, y=tuples)), strategyLabel, tuplesLabel)
dev.off()

pdf("../results/watDiv/transferred_tuples_30endpoints.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = watDiv30eTable, aes(x=Strategy, y=tuples)), strategyLabel, tuplesLabel)
dev.off()

pdf("../results/watDiv/parallelized/transferred_tuples_20endpoints.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = watDivPll20eTable, aes(x=Strategy, y=tuples)), strategyLabel, tuplesLabel)
dev.off()

pdf("../results/watDiv/parallelized/transferred_tuples_30endpoints.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = watDivPll30eTable, aes(x=Strategy, y=tuples)), strategyLabel, tuplesLabel)
dev.off()

pdf("../results/watDiv100/transferred_tuples.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = watDiv100Table, aes(x=Strategy, y=tuples)), strategyLabel, tuplesLabel)
dev.off()

# For the completness
# Process the datas & merge them into one unique table
diseasomeTable <- processTable(diseasomeSetupName, 6, outputDiseasomeEngine, outputDiseasomeFedra, outputDiseasomePBJPre, outputDiseasomePBJPost, outputDiseasomePBJHybrid)
linkedMDBTable <- processTable(linkedMDBSetupName, 6, outputLinkedMDBEngine, outputLinkedMDBFedra, outputLinkedMDBPBJPre, outputLinkedMDBPBJPost, outputLinkedMDBPBJHybrid)
geoCoordinatesTable <- processTable(geoCoordinatesSetupName, 6, outputGeoCoordinatesEngine, outputGeoCoordinatesFedra, outputGeoCoordinatesPBJPre, outputGeoCoordinatesPBJPost, outputGeoCoordinatesPBJHybrid)
SWDFTable <- processTable(swdfSetupName, 6, outputSWDFEngine, outputSWDFFedra, outputSWDFPBJPre, outputSWDFPBJPost, outputSWDFPBJHybrid)
watDivTable <- processTable(watDivSetupName, 6, outputWatDivEngine, outputWatDivFedra, outputWatDivPBJPre, outputWatDivPBJPost, outputWatDivPBJHybrid)
watDiv20eTable <- processTable(watDivSetupName, 6, outputWatDiv20eEngine, outputWatDiv20eFedra, outputWatDiv20ePBJPre, outputWatDiv20ePBJPost, outputWatDiv20ePBJHybrid)
#watDiv30eTable <- processTable(watDivSetupName, 6, outputWatDiv30eEngine, outputWatDiv30eFedra, outputWatDiv30ePBJPre, outputWatDiv30ePBJPost, outputWatDiv30ePBJHybrid)
watDivPll20eTable <- processTable(watDivSetupName, 6, outputWatDivPll20eEngine, outputWatDivPll20eFedra, outputWatDivPll20ePBJPre, outputWatDivPll20ePBJPost, outputWatDivPll20ePBJHybrid)
#watDivPll30eTable <- processTable(watDivSetupName, 6, outputWatDivPll30eEngine, outputWatDivPll30eFedra, outputWatDivPll30ePBJPre, outputWatDivPll30ePBJPost, outputWatDivPll30ePBJHybrid)

# TEMP - remove when all the results are here
watDiv30eTable <- processTable(watDivSetupName, 6, outputWatDivEngine, outputWatDiv30eFedra, outputWatDivPBJPre, outputWatDivPBJPost, outputWatDiv30ePBJHybrid)
watDivPll30eTable <- processTable(watDivSetupName, 6, outputWatDivEngine, outputWatDivPll30eFedra, outputWatDivPBJPre, outputWatDivPBJPost, outputWatDivPll30ePBJHybrid)
# END TEMP

watDiv100Table <- processTable(watDiv100SetupName, 6, outputWatDiv100Engine, outputWatDiv100Fedra, outputWatDiv100PBJPre, outputWatDiv100PBJPost, outputWatDiv100PBJHybrid)
completnessTable <- rbind(diseasomeTable, linkedMDBTable, geoCoordinatesTable, SWDFTable, watDivTable, watDiv100Table)

# set the colnames
colnames(diseasomeTable) <- c("completness", "dataset", "Strategy")
colnames(linkedMDBTable) <- c("completness", "dataset", "Strategy")
colnames(geoCoordinatesTable) <- c("completness", "dataset", "Strategy")
colnames(SWDFTable) <- c("completness", "dataset", "Strategy")
colnames(watDivTable) <- c("completness", "dataset", "Strategy")
colnames(watDiv20eTable) <- c("completness", "dataset", "Strategy")
colnames(watDiv30eTable) <- c("completness", "dataset", "Strategy")
colnames(watDivPll20eTable) <- c("completness", "dataset", "Strategy")
colnames(watDivPll30eTable) <- c("completness", "dataset", "Strategy")
colnames(watDiv100Table) <- c("completness", "dataset", "Strategy")
colnames(completnessTable) <- c("completness", "dataset", "Strategy")

# create the boxplots
pdf("../results/completeness.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = completnessTable, aes(x=dataset, y=completness)), datasetLabel, completenessLabel, aes(fill=Strategy), TRUE)
dev.off()

pdf("../results/diseasome/completeness.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = diseasomeTable, aes(x=Strategy, y=completness)), strategyLabel, completenessLabel, NULL, TRUE)
dev.off()

pdf("../results/linkedMDB/completeness.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = linkedMDBTable, aes(x=Strategy, y=completness)), strategyLabel, completenessLabel, NULL, TRUE)
dev.off()

pdf("../results/geoCoordinates/completeness.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = geoCoordinatesTable, aes(x=Strategy, y=completness)), strategyLabel, completenessLabel, NULL, TRUE)
dev.off()

pdf("../results/swdf/completeness.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = SWDFTable, aes(x=Strategy, y=completness)), strategyLabel, completenessLabel, NULL, TRUE)
dev.off()

pdf("../results/watDiv/completeness.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = watDivTable, aes(x=Strategy, y=completness)), strategyLabel, completenessLabel, NULL, TRUE)
dev.off()

pdf("../results/watDiv/completeness_20endpoints.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = watDiv20eTable, aes(x=Strategy, y=completness)), strategyLabel, completenessLabel, NULL, TRUE)
dev.off()

pdf("../results/watDiv/completeness_30endpoints.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = watDiv30eTable, aes(x=Strategy, y=completness)), strategyLabel, completenessLabel, NULL, TRUE)
dev.off()

pdf("../results/watDiv/parallelized/completeness_20endpoints.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = watDivPll20eTable, aes(x=Strategy, y=completness)), strategyLabel, completenessLabel, NULL, TRUE)
dev.off()

pdf("../results/watDiv/parallelized/completeness_30endpoints.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = watDivPll30eTable, aes(x=Strategy, y=completness)), strategyLabel, completenessLabel, NULL, TRUE)
dev.off()

pdf("../results/watDiv100/completeness.pdf", width=7, height=4)
bootstrap_ggplot(ggplot(data = watDiv100Table, aes(x=Strategy, y=completness)), strategyLabel, completenessLabel, NULL, TRUE)
dev.off()
