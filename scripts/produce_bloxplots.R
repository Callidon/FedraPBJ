#!/usr/bin/env Rscript
# Script to produce boxplots for the results from various executions of the setup
# author : Thomas Minier & Naixin Wang, M1 ALMA

require(ggplot2)

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

# Function used to process a value from endpoints tables
processEndpointsTable <- function(outputEnginePath, outputFedraPath, outputPBJPrePath, outputPBJPostPath, outputPBJHybridPath) {
	# read datas from the files
	outputEngine <- read.table(outputEnginePath)
	outputFedra <- read.table(outputFedraPath)
	outputPBJPre <- read.table(outputPBJPrePath)
	outputPBJPost <- read.table(outputPBJPostPath)
	outputPBJHybrid <- read.table(outputPBJHybridPath)

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

# path to output files

# from Diseasome setup
outputDiseasomeEngine <- "../results/diseasome/outputFedXengineFEDERATION10Client"
outputDiseasomeFedra <- "../results/diseasome/outputFedXFedraFEDERATION10Client"
outputDiseasomePBJPre <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"
outputDiseasomePBJPost <- "../results/diseasome/outputFedXFedra-PBJ-postFEDERATION10Client"
outputDiseasomePBJHybrid <- "../results/diseasome/outputFedXFedra-PBJ-hybridFEDERATION10Client"

outputDiseasomeEngineEndpoints <- "../results/diseasome/outputFedXengineFEDERATION10ClientEndpoints"
outputDiseasomeFedraEndpoints <- "../results/diseasome/outputFedXFedraFEDERATION10ClientEndpoints"
outputDiseasomePBJPreEndpoints <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10ClientEndpoints"
outputDiseasomePBJPostEndpoints <- "../results/diseasome/outputFedXFedra-PBJ-postFEDERATION10ClientEndpoints"
outputDiseasomePBJHybridEndpoints <- "../results/diseasome/outputFedXFedra-PBJ-hybridFEDERATION10ClientEndpoints"

# from linkedMDB setup
outputLinkedMDBEngine <- "../results/linkedMDB/outputFedXengineFEDERATION10Client"
outputLinkedMDBFedra <- "../results/linkedMDB/outputFedXFedraFEDERATION10Client"
outputLinkedMDBPBJPre <- "../results/linkedMDB/outputFedXFedra-PBJ-preFEDERATION10Client"
outputLinkedMDBPBJPost <- "../results/linkedMDB/outputFedXFedra-PBJ-postFEDERATION10Client"
outputLinkedMDBPBJHybrid <- "../results/linkedMDB/outputFedXFedra-PBJ-hybridFEDERATION10Client"

outputLinkedMDBEngineEndpoints <- "../results/linkedMDB/outputFedXengineFEDERATION10ClientEndpoints"
outputLinkedMDBFedraEndpoints <- "../results/linkedMDB/outputFedXFedraFEDERATION10ClientEndpoints"
outputLinkedMDBPBJPreEndpoints <- "../results/linkedMDB/outputFedXFedra-PBJ-preFEDERATION10ClientEndpoints"
outputLinkedMDBPBJPostEndpoints <- "../results/linkedMDB/outputFedXFedra-PBJ-postFEDERATION10ClientEndpoints"
outputLinkedMDBPBJHybridEndpoints <- "../results/linkedMDB/outputFedXFedra-PBJ-hybridFEDERATION10ClientEndpoints"

# from geoCoordinates setup
outputGeoCoordinatesEngine <- "../results/geoCoordinates/outputFedXengineFEDERATION10Client"
outputGeoCoordinatesFedra <- "../results/geoCoordinates/outputFedXFedraFEDERATION10Client"
outputGeoCoordinatesPBJPre <- "../results/geoCoordinates/outputFedXFedra-PBJ-preFEDERATION10Client"
outputGeoCoordinatesPBJPost <- "../results/geoCoordinates/outputFedXFedra-PBJ-postFEDERATION10Client"
outputGeoCoordinatesPBJHybrid <- "../results/geoCoordinates/outputFedXFedra-PBJ-hybridFEDERATION10Client"

outputGeoCoordinatesEngineEndpoints <- "../results/geoCoordinates/outputFedXengineFEDERATION10ClientEndpoints"
outputGeoCoordinatesFedraEndpoints <- "../results/geoCoordinates/outputFedXFedraFEDERATION10ClientEndpoints"
outputGeoCoordinatesPBJPreEndpoints <- "../results/geoCoordinates/outputFedXFedra-PBJ-preFEDERATION10ClientEndpoints"
outputGeoCoordinatesPBJPostEndpoints <- "../results/geoCoordinates/outputFedXFedra-PBJ-postFEDERATION10ClientEndpoints"
outputGeoCoordinatesPBJHybridEndpoints <- "../results/geoCoordinates/outputFedXFedra-PBJ-hybridFEDERATION10ClientEndpoints"

# from swdf setup
outputSWDFEngine <- "../results/swdf/outputFedXengineFEDERATION10Client"
outputSWDFFedra <- "../results/swdf/outputFedXFedraFEDERATION10Client"
outputSWDFPBJPre <- "../results/swdf/outputFedXFedra-PBJ-preFEDERATION10Client"
outputSWDFPBJPost <- "../results/swdf/outputFedXFedra-PBJ-postFEDERATION10Client"
outputSWDFPBJHybrid <- "../results/swdf/outputFedXFedra-PBJ-hybridFEDERATION10Client"

outputSWDFEngineEndpoints <- "../results/swdf/outputFedXengineFEDERATION10ClientEndpoints"
outputSWDFFedraEndpoints <- "../results/swdf/outputFedXFedraFEDERATION10ClientEndpoints"
outputSWDFPBJPreEndpoints <- "../results/swdf/outputFedXFedra-PBJ-preFEDERATION10ClientEndpoints"
outputSWDFPBJPostEndpoints <- "../results/swdf/outputFedXFedra-PBJ-postFEDERATION10ClientEndpoints"
outputSWDFPBJHybridEndpoints <- "../results/swdf/outputFedXFedra-PBJ-hybridFEDERATION10ClientEndpoints"

# from watDiv setup
outputWatDivEngine <- "../results/watDiv/outputFedXengineFEDERATION10Client"
outputWatDivFedra <- "../results/watDiv/outputFedXFedraFEDERATION10Client"
outputWatDivPBJPre <- "../results/watDiv/outputFedXFedra-PBJ-preFEDERATION10Client"
outputWatDivPBJPost <- "../results/watDiv/outputFedXFedra-PBJ-postFEDERATION10Client"
outputWatDivPBJHybrid <- "../results/watDiv/outputFedXFedra-PBJ-hybridFEDERATION10Client"

outputWatDivEngineEndpoints <- "../results/watDiv/outputFedXengineFEDERATION10ClientEndpoints"
outputWatDivFedraEndpoints <- "../results/watDiv/outputFedXFedraFEDERATION10ClientEndpoints"
outputWatDivPBJPreEndpoints <- "../results/watDiv/outputFedXFedra-PBJ-preFEDERATION10ClientEndpoints"
outputWatDivPBJPostEndpoints <- "../results/watDiv/outputFedXFedra-PBJ-postFEDERATION10ClientEndpoints"
outputWatDivPBJHybridEndpoints <- "../results/watDiv/outputFedXFedra-PBJ-hybridFEDERATION10ClientEndpoints"

# from watDiv100 setup
outputWatDiv100Engine <- "../results/watDiv100/outputFedXengineFEDERATION10Client"
outputWatDiv100Fedra <- "../results/watDiv100/outputFedXFedraFEDERATION10Client"
outputWatDiv100PBJPre <- "../results/watDiv100/outputFedXFedra-PBJ-preFEDERATION10Client"
outputWatDiv100PBJPost <- "../results/watDiv100/outputFedXFedra-PBJ-postFEDERATION10Client"
outputWatDiv100PBJHybrid <- "../results/watDiv100/outputFedXFedra-PBJ-hybridFEDERATION10Client"

outputWatDiv100EngineEndpoints <- "../results/watDiv100/outputFedXengineFEDERATION10ClientEndpoints"
outputWatDiv100FedraEndpoints <- "../results/watDiv100/outputFedXFedraFEDERATION10ClientEndpoints"
outputWatDiv100PBJPreEndpoints <- "../results/watDiv100/outputFedXFedra-PBJ-preFEDERATION10ClientEndpoints"
outputWatDiv100PBJPostEndpoints <- "../results/watDiv100/outputFedXFedra-PBJ-postFEDERATION10ClientEndpoints"
outputWatDiv100PBJHybridEndpoints <- "../results/watDiv100/outputFedXFedra-PBJ-hybridFEDERATION10ClientEndpoints"

# For the execution time
# Process the datas & merge them into one unique table
diseasomeTable <- processTable(diseasomeSetupName, 2, outputDiseasomeEngine, outputDiseasomeFedra, outputDiseasomePBJPre, outputDiseasomePBJPost, outputDiseasomePBJHybrid)
linkedMDBTable <- processTable(linkedMDBSetupName, 2, outputLinkedMDBEngine, outputLinkedMDBFedra, outputLinkedMDBPBJPre, outputLinkedMDBPBJPost, outputLinkedMDBPBJHybrid)
geoCoordinatesTable <- processTable(geoCoordinatesSetupName, 2, outputGeoCoordinatesEngine, outputGeoCoordinatesFedra, outputGeoCoordinatesPBJPre, outputGeoCoordinatesPBJPost, outputGeoCoordinatesPBJHybrid)
SWDFTable <- processTable(swdfSetupName, 2, outputSWDFEngine, outputSWDFFedra, outputSWDFPBJPre, outputSWDFPBJPost, outputSWDFPBJHybrid)
watDivTable <- processTable(watDivSetupName, 2, outputWatDivEngine, outputWatDivFedra, outputWatDivPBJPre, outputWatDivPBJPost, outputWatDivPBJHybrid)
watDiv100Table <- processTable(watDiv100SetupName, 2, outputWatDiv100Engine, outputWatDiv100Fedra, outputWatDiv100PBJPre, outputWatDiv100PBJPost, outputWatDiv100PBJHybrid)
timesTable <- rbind(diseasomeTable, linkedMDBTable, geoCoordinatesTable, SWDFTable, watDivTable, watDiv100Table)

# set the colnames
colnames(timesTable) <- c("time", "dataset", "Approach")

# For the number of transfered tuples
# Process the datas & merge them into one unique table
diseasomeTable <- processTable(diseasomeSetupName, 11, outputDiseasomeEngine, outputDiseasomeFedra, outputDiseasomePBJPre, outputDiseasomePBJPost, outputDiseasomePBJHybrid)
linkedMDBTable <- processTable(linkedMDBSetupName, 11, outputLinkedMDBEngine, outputLinkedMDBFedra, outputLinkedMDBPBJPre, outputLinkedMDBPBJPost, outputLinkedMDBPBJHybrid)
geoCoordinatesTable <- processTable(geoCoordinatesSetupName, 11, outputGeoCoordinatesEngine, outputGeoCoordinatesFedra, outputGeoCoordinatesPBJPre, outputGeoCoordinatesPBJPost, outputGeoCoordinatesPBJHybrid)
SWDFTable <- processTable(swdfSetupName, 11, outputSWDFEngine, outputSWDFFedra, outputSWDFPBJPre, outputSWDFPBJPost, outputSWDFPBJHybrid)
watDivTable <- processTable(watDivSetupName, 11, outputWatDivEngine, outputWatDivFedra, outputWatDivPBJPre, outputWatDivPBJPost, outputWatDivPBJHybrid)
watDiv100Table <- processTable(watDiv100SetupName, 11, outputWatDiv100Engine, outputWatDiv100Fedra, outputWatDiv100PBJPre, outputWatDiv100PBJPost, outputWatDiv100PBJHybrid)
tuplesTable <- rbind(diseasomeTable, linkedMDBTable, geoCoordinatesTable, SWDFTable, watDivTable, watDiv100Table)

# set the colnames
colnames(tuplesTable) <- c("tuples", "dataset", "Approach")

# For the completness
# Process the datas & merge them into one unique table
diseasomeTable <- processTable(diseasomeSetupName, 6, outputDiseasomeEngine, outputDiseasomeFedra, outputDiseasomePBJPre, outputDiseasomePBJPost, outputDiseasomePBJHybrid)
linkedMDBTable <- processTable(linkedMDBSetupName, 6, outputLinkedMDBEngine, outputLinkedMDBFedra, outputLinkedMDBPBJPre, outputLinkedMDBPBJPost, outputLinkedMDBPBJHybrid)
geoCoordinatesTable <- processTable(geoCoordinatesSetupName, 6, outputGeoCoordinatesEngine, outputGeoCoordinatesFedra, outputGeoCoordinatesPBJPre, outputGeoCoordinatesPBJPost, outputGeoCoordinatesPBJHybrid)
SWDFTable <- processTable(swdfSetupName, 6, outputSWDFEngine, outputSWDFFedra, outputSWDFPBJPre, outputSWDFPBJPost, outputSWDFPBJHybrid)
watDivTable <- processTable(watDivSetupName, 6, outputWatDivEngine, outputWatDivFedra, outputWatDivPBJPre, outputWatDivPBJPost, outputWatDivPBJHybrid)
watDiv100Table <- processTable(watDiv100SetupName, 6, outputWatDiv100Engine, outputWatDiv100Fedra, outputWatDiv100PBJPre, outputWatDiv100PBJPost, outputWatDiv100PBJHybrid)
completnessTable <- rbind(diseasomeTable, linkedMDBTable, geoCoordinatesTable, SWDFTable, watDivTable, watDiv100Table)

# set the colnames
colnames(completnessTable) <- c("completness", "dataset", "Approach")

# For the endpoint hotspots
# Process the datas & merge them into one unique table
#diseasomeHotspotsTable <- processEndpointsTable(outputDiseasomeEngineEndpoints, outputDiseasomeFedraEndpoints, outputDiseasomePBJPreEndpoints, outputDiseasomePBJPostEndpoints, outputDiseasomePBJHybridEndpoints)
#linkedMDBHotspotsTable <- processEndpointsTable(outputLinkedMDBEngineEndpoints, outputLinkedMDBFedraEndpoints, outputLinkedMDBPBJPreEndpoints, outputLinkedMDBPBJPostEndpoints, outputLinkedMDBPBJHybridEndpoints)
#geoCoordinatesHotspotsTable <- processEndpointsTable(outputGeoCoordinatesEngineEndpoints, outputGeoCoordinatesFedraEndpoints, outputGeoCoordinatesPBJPreEndpoints, outputGeoCoordinatesPBJPostEndpoints, outputGeoCoordinatesPBJHybridEndpoints)
#SWDFHotspotsTable <- processEndpointsTable(outputSWDFEngineEndpoints, outputSWDFFedraEndpoints, outputSWDFPBJPreEndpoints, outputSWDFPBJPostEndpoints, outputSWDFPBJHybridEndpoints)
#watDivHotspotsTable <- processEndpointsTable(outputWatDivEngineEndpoints, outputWatDivFedraEndpoints, outputWatDivPBJPreEndpoints, outputWatDivPBJPostEndpoints, outputWatDivPBJHybridEndpoints)
#watDiv100HotspotsTable <- processEndpointsTable(outputWatDiv100EngineEndpoints, outputWatDiv100FedraEndpoints, outputWatDiv100PBJPreEndpoints, outputWatDiv100PBJPostEndpoints, outputWatDiv100PBJHybridEndpoints)

# set the colnames
#colnames(diseasomeHotspotsTable) <- c("query", "value", "Endpoint", "Approach")
#colnames(linkedMDBHotspotsTable) <- c("query", "value", "Endpoint", "Approach")
#colnames(geoCoordinatesHotspotsTable) <- c("query", "value", "Endpoint", "Approach")
#colnames(SWDFHotspotsTable) <- c("query", "value", "Endpoint", "Approach")
#colnames(watDivHotspotsTable) <- c("query", "value", "Endpoint", "Approach")
#colnames(watDiv100HotspotsTable) <- c("query", "value", "endpoint", "Approach")

# create the boxplots
pdf("../results/execution_time.pdf", width=7, height=4)
ggplot(data = subset(timesTable, time < 8), aes(x=dataset, y=time)) + geom_boxplot(aes(fill=Approach)) + ylab("Execution time (s)") + xlab("Dataset")
dev.off()

pdf("../results/transfered_tuples.pdf", width=7, height=4)
ggplot(data = subset(tuplesTable, tuples < 100), aes(x=dataset, y=tuples)) + geom_boxplot(aes(fill=Approach)) + ylab("Number of transfered tuples") + xlab("Dataset")
dev.off()

pdf("../results/completness.pdf", width=7, height=4)
ggplot(data = completnessTable, aes(x=dataset, y=completness)) + geom_boxplot(aes(fill=Approach)) + ylab("Completness") + xlab("Dataset")
dev.off()

#pdf("../results/hotspots_diseasome.pdf")
#ggplot(data = subset(diseasomeHotspotsTable, value < 20), aes(x=Approach, y=value)) + geom_boxplot(aes(fill=Endpoint)) + xlab("Approaches") + ylab("Number of transfered tuples")
#dev.off()

#pdf("../results/hotspots_linkedMDB.pdf")
#ggplot(data = subset(linkedMDBHotspotsTable, value < 20), aes(x=Approach, y=value)) + geom_boxplot(aes(fill=Endpoint)) + xlab("Approaches") + ylab("Number of transfered tuples")
#dev.off()
