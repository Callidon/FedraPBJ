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

# same as processTable, but select only the queries with a minimum number of transferred tuples
processTableWithMinTuples <- function(setupName, minTuples, value_ind, outputEnginePath, outputFedraPath, outputPBJPrePath, outputPBJPostPath, outputPBJHybridPath) {
        # read datas from the files
        outputEngine <- subset(read.table(outputEnginePath), V11 >= minTuples)[value_ind]
        outputFedra <- subset(read.table(outputFedraPath), V11 >= minTuples)[value_ind]
        outputPBJPre <- subset(read.table(outputPBJPrePath), V11 >= minTuples)[value_ind]
        outputPBJPost <- subset(read.table(outputPBJPostPath), V11 >= minTuples)[value_ind]
        outputPBJHybrid <- subset(read.table(outputPBJHybridPath), V11 >= minTuples)[value_ind]

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
outputWatDivEngine <- "../results/watDiv/outputFedXengineFEDERATION10Client"
outputWatDivFedra <- "../results/watDiv/outputFedXFedraFEDERATION10Client"
outputWatDivPBJPre <- "../results/watDiv/outputFedXFedra-PBJ-preFEDERATION10Client"
outputWatDivPBJPost <- "../results/watDiv/outputFedXFedra-PBJ-postFEDERATION10Client"
outputWatDivPBJHybrid <- "../results/watDiv/outputFedXFedra-PBJ-hybridFEDERATION10Client"

# from watDiv100 setup
outputWatDiv100Engine <- "../results/watDiv100/outputFedXengineFEDERATION10Client"
outputWatDiv100Fedra <- "../results/watDiv100/outputFedXFedraFEDERATION10Client"
outputWatDiv100PBJPre <- "../results/watDiv100/outputFedXFedra-PBJ-preFEDERATION10Client"
outputWatDiv100PBJPost <- "../results/watDiv100/outputFedXFedra-PBJ-postFEDERATION10Client"
outputWatDiv100PBJHybrid <- "../results/watDiv100/outputFedXFedra-PBJ-hybridFEDERATION10Client"

outputWatDiv100ParallelizedEngine <- "../results/parallelized/outputFedXengineFEDERATION10Client"
outputWatDiv100ParallelizedFedra <- "../results/parallelized/outputFedXFedraFEDERATION10Client"
outputWatDiv100ParallelizedPBJPre <- "../results/parallelized/outputFedXFedra-PBJ-preFEDERATION10Client"
outputWatDiv100ParallelizedPBJPost <- "../results/parallelized/outputFedXFedra-PBJ-postFEDERATION10Client"
outputWatDiv100ParallelizedPBJHybrid <- "../results/parallelized/outputFedXFedra-PBJ-hybridFEDERATION10Client"

# For the execution time
# Process the datas & merge them into one unique table
diseasomeTable <- processTable(diseasomeSetupName, 2, outputDiseasomeEngine, outputDiseasomeFedra, outputDiseasomePBJPre, outputDiseasomePBJPost, outputDiseasomePBJHybrid)
linkedMDBTable <- processTable(linkedMDBSetupName, 2, outputLinkedMDBEngine, outputLinkedMDBFedra, outputLinkedMDBPBJPre, outputLinkedMDBPBJPost, outputLinkedMDBPBJHybrid)
geoCoordinatesTable <- processTable(geoCoordinatesSetupName, 2, outputGeoCoordinatesEngine, outputGeoCoordinatesFedra, outputGeoCoordinatesPBJPre, outputGeoCoordinatesPBJPost, outputGeoCoordinatesPBJHybrid)
SWDFTable <- processTable(swdfSetupName, 2, outputSWDFEngine, outputSWDFFedra, outputSWDFPBJPre, outputSWDFPBJPost, outputSWDFPBJHybrid)
watDivTable <- processTable(watDivSetupName, 2, outputWatDivEngine, outputWatDivFedra, outputWatDivPBJPre, outputWatDivPBJPost, outputWatDivPBJHybrid)
watDiv100Table <- processTable(watDiv100SetupName, 2, outputWatDiv100Engine, outputWatDiv100Fedra, outputWatDiv100PBJPre, outputWatDiv100PBJPost, outputWatDiv100PBJHybrid)
watDiv100ParallelizedTable <- processTable(watDiv100SetupName, 2, outputWatDiv100ParallelizedEngine, outputWatDiv100ParallelizedFedra, outputWatDiv100ParallelizedPBJPre, outputWatDiv100ParallelizedPBJPost, outputWatDiv100ParallelizedPBJHybrid)
timesTable <- rbind(diseasomeTable, linkedMDBTable, geoCoordinatesTable, SWDFTable, watDivTable, watDiv100Table)

# set the colnames
colnames(diseasomeTable) <- c("time", "dataset", "Strategy")
colnames(linkedMDBTable) <- c("time", "dataset", "Strategy")
colnames(geoCoordinatesTable) <- c("time", "dataset", "Strategy")
colnames(SWDFTable) <- c("time", "dataset", "Strategy")
colnames(watDivTable) <- c("time", "dataset", "Strategy")
colnames(watDiv100Table) <- c("time", "dataset", "Strategy")
colnames(watDiv100ParallelizedTable) <- c("time", "dataset", "Strategy")
colnames(timesTable) <- c("time", "dataset", "Strategy")

# create the boxplots
pdf("../results/execution_time.pdf", width=7, height=4)
ggplot(data = timesTable, aes(x=dataset, y=time)) + scale_y_continuous(trans = log10_trans(), breaks = trans_breaks("log10", function(x) 100^x), labels = trans_format("log10", math_format(10^.x))) + geom_boxplot(aes(fill=Strategy)) + ylab("Execution time (s)") + xlab("Dataset")
dev.off()

pdf("../results/parallelized/execution_time.pdf", width=7, height=4)
ggplot(data = watDiv100ParallelizedTable, aes(x=dataset, y=time)) + scale_y_continuous(trans = log10_trans(), breaks = trans_breaks("log10", function(x) 100^x), labels = trans_format("log10", math_format(10^.x))) + geom_boxplot(aes(fill=Strategy)) + ylab("Execution time (s)") + xlab("Dataset")
dev.off()

pdf("../results/diseasome/execution_time.pdf", width=7, height=4)
ggplot(data = diseasomeTable, aes(x=dataset, y=time)) + scale_y_continuous(trans = log10_trans(), breaks = trans_breaks("log10", function(x) 100^x), labels = trans_format("log10", math_format(10^.x))) + geom_boxplot(aes(fill=Strategy)) + ylab("Execution time (s)") + xlab("Dataset")
dev.off()

pdf("../results/linkedMDB/execution_time.pdf", width=7, height=4)
ggplot(data = linkedMDBTable, aes(x=dataset, y=time)) + scale_y_continuous(trans = log10_trans(), breaks = trans_breaks("log10", function(x) 100^x), labels = trans_format("log10", math_format(10^.x))) + geom_boxplot(aes(fill=Strategy)) + ylab("Execution time (s)") + xlab("Dataset")
dev.off()

pdf("../results/geoCoordinates/execution_time.pdf", width=7, height=4)
ggplot(data = geoCoordinatesTable, aes(x=dataset, y=time)) + scale_y_continuous(trans = log10_trans(), breaks = trans_breaks("log10", function(x) 100^x), labels = trans_format("log10", math_format(10^.x))) + geom_boxplot(aes(fill=Strategy)) + ylab("Execution time (s)") + xlab("Dataset")
dev.off()

pdf("../results/swdf/execution_time.pdf", width=7, height=4)
ggplot(data = SWDFTable, aes(x=dataset, y=time)) + scale_y_continuous(trans = log10_trans(), breaks = trans_breaks("log10", function(x) 100^x), labels = trans_format("log10", math_format(10^.x))) + geom_boxplot(aes(fill=Strategy)) + ylab("Execution time (s)") + xlab("Dataset")
dev.off()

pdf("../results/watDiv/execution_time.pdf", width=7, height=4)
ggplot(data = watDivTable, aes(x=dataset, y=time)) + scale_y_continuous(trans = log10_trans(), breaks = trans_breaks("log10", function(x) 100^x), labels = trans_format("log10", math_format(10^.x))) + geom_boxplot(aes(fill=Strategy)) + ylab("Execution time (s)") + xlab("Dataset")
dev.off()


pdf("../results/watDiv100/execution_time.pdf", width=7, height=4)
ggplot(data = watDiv100Table, aes(x=dataset, y=time)) + scale_y_continuous(trans = log10_trans(), breaks = trans_breaks("log10", function(x) 100^x), labels = trans_format("log10", math_format(10^.x))) + geom_boxplot(aes(fill=Strategy)) + ylab("Execution time (s)") + xlab("Dataset")
dev.off()

# experiment using min number of tuple
#diseasomeTable <- processTableWithMinTuples(diseasomeSetupName, minTuples, 2, outputDiseasomeEngine, outputDiseasomeFedra, outputDiseasomePBJPre, outputDiseasomePBJPost, outputDiseasomePBJHybrid)
#linkedMDBTable <- processTableWithMinTuples(linkedMDBSetupName, minTuples, 2, outputLinkedMDBEngine, outputLinkedMDBFedra, outputLinkedMDBPBJPre, outputLinkedMDBPBJPost, outputLinkedMDBPBJHybrid)
#geoCoordinatesTable <- processTableWithMinTuples(geoCoordinatesSetupName, minTuples, 2, outputGeoCoordinatesEngine, outputGeoCoordinatesFedra, outputGeoCoordinatesPBJPre, outputGeoCoordinatesPBJPost, outputGeoCoordinatesPBJHybrid)
#SWDFTable <- processTableWithMinTuples(swdfSetupName, minTuples, 2, outputSWDFEngine, outputSWDFFedra, outputSWDFPBJPre, outputSWDFPBJPost, outputSWDFPBJHybrid)
watDivTable <- processTableWithMinTuples(watDivSetupName, 100, 2, outputWatDivEngine, outputWatDivFedra, outputWatDivPBJPre, outputWatDivPBJPost, outputWatDivPBJHybrid)
watDiv100Table <- processTableWithMinTuples(watDiv100SetupName, 1000, 2, outputWatDiv100Engine, outputWatDiv100Fedra, outputWatDiv100PBJPre, outputWatDiv100PBJPost, outputWatDiv100PBJHybrid)
timesTable <- rbind(watDivTable, watDiv100Table) #rbind(diseasomeTable, linkedMDBTable, geoCoordinatesTable, SWDFTable, watDivTable, watDiv100Table)

# set the colnames
#colnames(diseasomeTable) <- c("time", "dataset", "Strategy")
#colnames(linkedMDBTable) <- c("time", "dataset", "Strategy")
#colnames(geoCoordinatesTable) <- c("time", "dataset", "Strategy")
#colnames(SWDFTable) <- c("time", "dataset", "Strategy")
colnames(watDivTable) <- c("time", "dataset", "Strategy")
colnames(watDiv100Table) <- c("time", "dataset", "Strategy")
colnames(timesTable) <- c("time", "dataset", "Strategy")

# create the boxplots
pdf("../results/execution_time_100tuples.pdf", width=7, height=4)
ggplot(data = watDivTable, aes(x=dataset, y=time)) + scale_y_continuous(trans = log10_trans(), breaks = trans_breaks("log10", function(x) 100^x), labels = trans_format("log10", math_format(10^.x))) + geom_boxplot(aes(fill=Strategy)) + ylab("Execution time (s)") + xlab("Dataset")
dev.off()

pdf("../results/execution_time_1000tuples.pdf", width=7, height=4)
ggplot(data = watDiv100Table, aes(x=dataset, y=time)) + scale_y_continuous(trans = log10_trans(), breaks = trans_breaks("log10", function(x) 100^x), labels = trans_format("log10", math_format(10^.x))) + geom_boxplot(aes(fill=Strategy)) + ylab("Execution time (s)") + xlab("Dataset")
dev.off()


# For the number of transfered tuples
# Process the datas & merge them into one unique table
diseasomeTable <- processTable(diseasomeSetupName, 11, outputDiseasomeEngine, outputDiseasomeFedra, outputDiseasomePBJPre, outputDiseasomePBJPost, outputDiseasomePBJHybrid)
linkedMDBTable <- processTable(linkedMDBSetupName, 11, outputLinkedMDBEngine, outputLinkedMDBFedra, outputLinkedMDBPBJPre, outputLinkedMDBPBJPost, outputLinkedMDBPBJHybrid)
geoCoordinatesTable <- processTable(geoCoordinatesSetupName, 11, outputGeoCoordinatesEngine, outputGeoCoordinatesFedra, outputGeoCoordinatesPBJPre, outputGeoCoordinatesPBJPost, outputGeoCoordinatesPBJHybrid)
SWDFTable <- processTable(swdfSetupName, 11, outputSWDFEngine, outputSWDFFedra, outputSWDFPBJPre, outputSWDFPBJPost, outputSWDFPBJHybrid)
watDivTable <- processTable(watDivSetupName, 11, outputWatDivEngine, outputWatDivFedra, outputWatDivPBJPre, outputWatDivPBJPost, outputWatDivPBJHybrid)
watDiv100Table <- processTable(watDiv100SetupName, 11, outputWatDiv100Engine, outputWatDiv100Fedra, outputWatDiv100PBJPre, outputWatDiv100PBJPost, outputWatDiv100PBJHybrid)
watDiv100ParallelizedTable <- processTable(watDiv100SetupName, 11, outputWatDiv100ParallelizedEngine, outputWatDiv100ParallelizedFedra, outputWatDiv100ParallelizedPBJPre, outputWatDiv100ParallelizedPBJPost, outputWatDiv100ParallelizedPBJHybrid)
tuplesTable <- rbind(diseasomeTable, linkedMDBTable, geoCoordinatesTable, SWDFTable, watDivTable, watDiv100Table)

# set the colnames
colnames(diseasomeTable) <- c("tuples", "dataset", "Strategy")
colnames(linkedMDBTable) <- c("tuples", "dataset", "Strategy")
colnames(geoCoordinatesTable) <- c("tuples", "dataset", "Strategy")
colnames(SWDFTable) <- c("tuples", "dataset", "Strategy")
colnames(watDivTable) <- c("tuples", "dataset", "Strategy")
colnames(watDiv100Table) <- c("tuples", "dataset", "Strategy")
colnames(watDiv100ParallelizedTable) <- c("tuples", "dataset", "Strategy")
colnames(tuplesTable) <- c("tuples", "dataset", "Strategy")

# create the boxplots
pdf("../results/transferred_tuples.pdf", width=7, height=4)
ggplot(data = tuplesTable, aes(x=dataset, y=tuples)) + scale_y_continuous(trans = log10_trans(), breaks = trans_breaks("log10", function(x) 100^x), labels = trans_format("log10", math_format(10^.x))) + geom_boxplot(aes(fill=Strategy)) + ylab("Number of transferred tuples") + xlab("Dataset")
dev.off()

pdf("../results/parallelized/transferred_tuples.pdf", width=7, height=4)
ggplot(data = watDiv100ParallelizedTable, aes(x=dataset, y=tuples)) + scale_y_continuous(trans = log10_trans(), breaks = trans_breaks("log10", function(x) 100^x), labels = trans_format("log10", math_format(10^.x))) + geom_boxplot(aes(fill=Strategy)) + ylab("Number of transferred tuples") + xlab("Dataset")
dev.off()

pdf("../results/diseasome/transferred_tuples.pdf", width=7, height=4)
ggplot(data = diseasomeTable, aes(x=dataset, y=tuples)) + scale_y_continuous(trans = log10_trans(), breaks = trans_breaks("log10", function(x) 100^x), labels = trans_format("log10", math_format(10^.x))) + geom_boxplot(aes(fill=Strategy)) + ylab("Number of transferred tuples") + xlab("Dataset")
dev.off()

pdf("../results/linkedMDB/transferred_tuples.pdf", width=7, height=4)
ggplot(data = linkedMDBTable, aes(x=dataset, y=tuples)) + scale_y_continuous(trans = log10_trans(), breaks = trans_breaks("log10", function(x) 100^x), labels = trans_format("log10", math_format(10^.x))) + geom_boxplot(aes(fill=Strategy)) + ylab("Number of transferred tuples") + xlab("Dataset")
dev.off()

pdf("../results/geoCoordinates/transferred_tuples.pdf", width=7, height=4)
ggplot(data = geoCoordinatesTable, aes(x=dataset, y=tuples)) + scale_y_continuous(trans = log10_trans(), breaks = trans_breaks("log10", function(x) 100^x), labels = trans_format("log10", math_format(10^.x))) + geom_boxplot(aes(fill=Strategy)) + ylab("Number of transferred tuples") + xlab("Dataset")
dev.off()

pdf("../results/swdf/transferred_tuples.pdf", width=7, height=4)
ggplot(data = SWDFTable, aes(x=dataset, y=tuples)) + scale_y_continuous(trans = log10_trans(), breaks = trans_breaks("log10", function(x) 100^x), labels = trans_format("log10", math_format(10^.x))) + geom_boxplot(aes(fill=Strategy)) + ylab("Number of transferred tuples") + xlab("Dataset")
dev.off()

pdf("../results/watDiv/transferred_tuples.pdf", width=7, height=4)
ggplot(data = watDivTable, aes(x=dataset, y=tuples)) + scale_y_continuous(trans = log10_trans(), breaks = trans_breaks("log10", function(x) 100^x), labels = trans_format("log10", math_format(10^.x))) + geom_boxplot(aes(fill=Strategy)) + ylab("Number of transferred tuples") + xlab("Dataset")
dev.off()

pdf("../results/watDiv100/transferred_tuples.pdf", width=7, height=4)
ggplot(data = watDiv100Table, aes(x=dataset, y=tuples)) + scale_y_continuous(trans = log10_trans(), breaks = trans_breaks("log10", function(x) 100^x), labels = trans_format("log10", math_format(10^.x))) + geom_boxplot(aes(fill=Strategy)) + ylab("Number of transferred tuples") + xlab("Dataset")
dev.off()

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
colnames(diseasomeTable) <- c("completness", "dataset", "Strategy")
colnames(linkedMDBTable) <- c("completness", "dataset", "Strategy")
colnames(geoCoordinatesTable) <- c("completness", "dataset", "Strategy")
colnames(SWDFTable) <- c("completness", "dataset", "Strategy")
colnames(watDivTable) <- c("completness", "dataset", "Strategy")
colnames(watDiv100Table) <- c("completness", "dataset", "Strategy")
colnames(completnessTable) <- c("completness", "dataset", "Strategy")

# create the boxplots
pdf("../results/completeness.pdf", width=7, height=4)
ggplot(data = completnessTable, aes(x=dataset, y=completness)) + geom_boxplot(aes(fill=Strategy)) + ylab("Completeness") + xlab("Dataset")
dev.off()

pdf("../results/diseasome/completeness.pdf", width=7, height=4)
ggplot(data = diseasomeTable, aes(x=dataset, y=completness)) + geom_boxplot(aes(fill=Strategy)) + ylab("Completeness") + xlab("Dataset")
dev.off()

pdf("../results/linkedMDB/completeness.pdf", width=7, height=4)
ggplot(data = linkedMDBTable, aes(x=dataset, y=completness)) + geom_boxplot(aes(fill=Strategy)) + ylab("Completeness") + xlab("Dataset")
dev.off()

pdf("../results/geoCoordinates/completeness.pdf", width=7, height=4)
ggplot(data = geoCoordinatesTable, aes(x=dataset, y=completness)) + geom_boxplot(aes(fill=Strategy)) + ylab("Completeness") + xlab("Dataset")
dev.off()

pdf("../results/swdf/completeness.pdf", width=7, height=4)
ggplot(data = SWDFTable, aes(x=dataset, y=completness)) + geom_boxplot(aes(fill=Strategy)) + ylab("Completeness") + xlab("Dataset")
dev.off()

pdf("../results/watDiv/completeness.pdf", width=7, height=4)
ggplot(data = watDivTable, aes(x=dataset, y=completness)) + geom_boxplot(aes(fill=Strategy)) + ylab("Completeness") + xlab("Dataset")
dev.off()

pdf("../results/watDiv100/completeness.pdf", width=7, height=4)
ggplot(data = watDiv100Table, aes(x=dataset, y=completness)) + geom_boxplot(aes(fill=Strategy)) + ylab("Completeness") + xlab("Dataset")
dev.off()
