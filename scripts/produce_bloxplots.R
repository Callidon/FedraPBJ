#!/usr/bin/env Rscript
# Script to produce boxplots for the results from various executions of the setup
# author : Thomas Minier & Naixin Wang, M1 ALMA

require(ggplot2)

# Global variables
diseasomeSetupName <- "Diseasome"
linkedMDBSetupName <- "LinkedMDB"
geoCoordinatesSetupName <- "GeoCoordinates"
swdfSetupName <- "SWDF"
watDivSetupName <- "WatDiv"
watDiv100SetupName <- "WatDiv100"

approachFedxName <- "FedX"
approachFedxFedraName <- "FedX + Fedra"
approachPBJPreName <- "PBJ pre"
approachPBJPostName <- "PBJ post"
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

# path to output files

# from Diseasome setup
outputDiseasomeEngine <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"
outputDiseasomeFedra <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"
outputDiseasomePBJPre <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"
outputDiseasomePBJPost <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"
outputDiseasomePBJHybrid <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"

# from linkedMDB setup
outputLinkedMDBEngine <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"
outputLinkedMDBFedra <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"
outputLinkedMDBPBJPre <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"
outputLinkedMDBPBJPost <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"
outputLinkedMDBPBJHybrid <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"

# from geoCoordinates setup
outputGeoCoordinatesEngine <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"
outputGeoCoordinatesFedra <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"
outputGeoCoordinatesPBJPre <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"
outputGeoCoordinatesPBJPost <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"
outputGeoCoordinatesPBJHybrid <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"

# from swdf setup
outputSWDFEngine <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"
outputSWDFFedra <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"
outputSWDFPBJPre <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"
outputSWDFPBJPost <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"
outputSWDFPBJHybrid <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"

# from watDiv setup
outputWatDivEngine <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"
outputWatDivFedra <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"
outputWatDivPBJPre <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"
outputWatDivPBJPost <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"
outputWatDivPBJHybrid <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"

# from watDiv100 setup
outputWatDiv100Engine <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"
outputWatDiv100Fedra <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"
outputWatDiv100PBJPre <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"
outputWatDiv100PBJPost <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"
outputWatDiv100PBJHybrid <- "../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client"

# Process the datas & merge them into one unique table

diseasomeTable <- processTable(diseasomeSetupName, 2, outputDiseasomeEngine, outputDiseasomeFedra, outputDiseasomePBJPre, outputDiseasomePBJPost, outputDiseasomePBJHybrid)
linkedMDBTable <- processTable(linkedMDBSetupName, 2, outputLinkedMDBEngine, outputLinkedMDBFedra, outputLinkedMDBPBJPre, outputLinkedMDBPBJPost, outputLinkedMDBPBJHybrid)
geoCoordinatesTable <- processTable(geoCoordinatesSetupName, 2, outputGeoCoordinatesEngine, outputGeoCoordinatesFedra, outputGeoCoordinatesPBJPre, outputGeoCoordinatesPBJPost, outputGeoCoordinatesPBJHybrid)
SWDFTable <- processTable(swdfSetupName, 2, outputSWDFEngine, outputSWDFFedra, outputSWDFPBJPre, outputSWDFPBJPost, outputSWDFPBJHybrid)
watDivTable <- processTable(watDivSetupName, 2, outputWatDivEngine, outputWatDivFedra, outputWatDivPBJPre, outputWatDivPBJPost, outputWatDivPBJHybrid)
watDiv100Table <- processTable(watDiv100SetupName, 2, outputWatDiv100Engine, outputWatDiv100Fedra, outputWatDiv100PBJPre, outputWatDiv100PBJPost, outputWatDiv100PBJHybrid)
table <- rbind(diseasomeTable, linkedMDBTable, geoCoordinatesTable, SWDFTable, watDivTable, watDiv100Table)

# set the colnames
colnames(table) <- c("time", "dataset", "Approach")

# create the boxplots
ggplot(data = table, aes(x=dataset, y=time)) + geom_boxplot(aes(fill=Approach))
