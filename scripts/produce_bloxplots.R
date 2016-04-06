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

# ----------------------------------------------
# Load the datas from files
# ----------------------------------------------

# from Diseasome setup
outputDiseasomeEngine <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")
outputDiseasomeFedra <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")
outputDiseasomePBJPre <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")
outputDiseasomePBJPost <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")
outputDiseasomePBJHybrid <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")

# from linkedMDB setup
outputLinkedMDBEngine <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")
outputLinkedMDBFedra <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")
outputLinkedMDBPBJPre <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")
outputLinkedMDBPBJPost <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")
outputLinkedMDBPBJHybrid <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")

# from geoCoordinates setup
outputGeoCoordinatesEngine <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")
outputGeoCoordinatesFedra <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")
outputGeoCoordinatesPBJPre <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")
outputGeoCoordinatesPBJPost <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")
outputGeoCoordinatesPBJHybrid <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")

# from swdf setup
outputSWDFEngine <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")
outputSWDFFedra <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")
outputSWDFPBJPre <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")
outputSWDFPBJPost <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")
outputSWDFPBJHybrid <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")

# from watDiv setup
outputWatDivEngine <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")
outputWatDivFedra <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")
outputWatDivPBJPre <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")
outputWatDivPBJPost <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")
outputWatDivPBJHybrid <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")

# from watDiv100 setup
outputWatDiv100Engine <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")
outputWatDiv100Fedra <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")
outputWatDiv100PBJPre <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")
outputWatDiv100PBJPost <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")
outputWatDiv100PBJHybrid <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")

# ----------------------------------------------
# extract the execution time columns
# ----------------------------------------------

# from Diseasome setup
execTimeDiseasomeEngine <- outputDiseasomeEngine[2]
execTimeDiseasomeFedra <- outputDiseasomeFedra[2]
execTimeDiseasomePBJPre <- outputDiseasomePBJPre[2]
execTimeDiseasomePBJPost <- outputDiseasomePBJPost[2]
execTimeDiseasomePBJHybrid <- outputDiseasomePBJHybrid[2]

# from linkedMDB setup
execTimeLinkedMDBEngine <- outputLinkedMDBEngine[2]
execTimeLinkedMDBFedra <- outputLinkedMDBFedra[2]
execTimeLinkedMDBPBJPre <- outputLinkedMDBPBJPre[2]
execTimeLinkedMDBPBJPost <- outputLinkedMDBPBJPost[2]
execTimeLinkedMDBPBJHybrid <- outputLinkedMDBPBJHybrid[2]

# from geoCoordinates setup
execTimeGeoCoordinatesEngine <- outputGeoCoordinatesEngine[2]
execTimeGeoCoordinatesFedra <- outputGeoCoordinatesFedra[2]
execTimeGeoCoordinatesPBJPre <- outputGeoCoordinatesPBJPre[2]
execTimeGeoCoordinatesPBJPost <- outputGeoCoordinatesPBJPost[2]
execTimeGeoCoordinatesPBJHybrid <- outputGeoCoordinatesPBJHybrid[2]

# from swdf setup
execTimeSWDFEngine <- outputSWDFEngine[2]
execTimeSWDFFedra <- outputSWDFFedra[2]
execTimeSWDFPBJPre <- outputSWDFPBJPre[2]
execTimeSWDFPBJPost <- outputSWDFPBJPost[2]
execTimeSWDFPBJHybrid <- outputSWDFPBJHybrid[2]

# from watDiv setup
execTimeWatDivEngine <- outputWatDivEngine[2]
execTimeWatDivFedra <- outputWatDivFedra[2]
execTimeWatDivPBJPre <- outputWatDivPBJPre[2]
execTimeWatDivPBJPost <- outputWatDivPBJPost[2]
execTimeWatDivPBJHybrid <- outputWatDivPBJHybrid[2]

# from watDiv100 setup
execTimeWatDiv100Engine <- outputWatDiv100Engine[2]
execTimeWatDiv100Fedra <- outputWatDiv100Fedra[2]
execTimeWatDiv100PBJPre <- outputWatDiv100PBJPre[2]
execTimeWatDiv100PBJPost <- outputWatDiv100PBJPost[2]
execTimeWatDiv100PBJHybrid <- outputWatDiv100PBJHybrid[2]

# ----------------------------------------------
# create the data origin column
# ----------------------------------------------

# from Diseasome setup
execTimeDiseasomeEngine$dataset <- diseasomeSetupName
execTimeDiseasomeFedra$dataset <- diseasomeSetupName
execTimeDiseasomePBJPre$dataset <- diseasomeSetupName
execTimeDiseasomePBJPost$dataset <- diseasomeSetupName
execTimeDiseasomePBJHybrid$dataset <- diseasomeSetupName

# from linkedMDB setup
execTimeLinkedMDBEngine$dataset <- linkedMDBSetupName
execTimeLinkedMDBFedra$dataset <- linkedMDBSetupName
execTimeLinkedMDBPBJPre$dataset <- linkedMDBSetupName
execTimeLinkedMDBPBJPost$dataset <- linkedMDBSetupName
execTimeLinkedMDBPBJHybrid$dataset <- linkedMDBSetupName

# from geoCoordinates setup
execTimeGeoCoordinatesEngine$dataset <- geoCoordinatesSetupName
execTimeGeoCoordinatesFedra$dataset <- geoCoordinatesSetupName
execTimeGeoCoordinatesPBJPre$dataset <- geoCoordinatesSetupName
execTimeGeoCoordinatesPBJPost$dataset <- geoCoordinatesSetupName
execTimeGeoCoordinatesPBJHybrid$dataset <- geoCoordinatesSetupName

# from swdf setup
execTimeSWDFEngine$dataset <- swdfSetupName
execTimeSWDFFedra$dataset <- swdfSetupName
execTimeSWDFPBJPre$dataset <- swdfSetupName
execTimeSWDFPBJPost$dataset <- swdfSetupName
execTimeSWDFPBJHybrid$dataset <- swdfSetupName

# from watDiv setup
execTimeWatDivEngine$dataset <- watDivSetupName
execTimeWatDivFedra$dataset <- watDivSetupName
execTimeWatDivPBJPre$dataset <- watDivSetupName
execTimeWatDivPBJPost$dataset <- watDivSetupName
execTimeWatDivPBJHybrid$dataset <- watDivSetupName

# from watDiv100 setup
execTimeWatDiv100Engine$dataset <- watDiv100SetupName
execTimeWatDiv100Fedra$dataset <- watDiv100SetupName
execTimeWatDiv100PBJPre$dataset <- watDiv100SetupName
execTimeWatDiv100PBJPost$dataset <- watDiv100SetupName
execTimeWatDiv100PBJHybrid$dataset <- watDiv100SetupName

# ----------------------------------------------
# create the approach column
# ----------------------------------------------

# from Diseasome setup
execTimeDiseasomeEngine$approach <- approachFedxName
execTimeDiseasomeFedra$approach <- approachFedxFedraName
execTimeDiseasomePBJPre$approach <- approachPBJPreName
execTimeDiseasomePBJPost$approach <- approachPBJPostName
execTimeDiseasomePBJHybrid$approach <- approachPBJHybridName

# from linkedMDB setup
execTimeLinkedMDBEngine$approach <- approachFedxName
execTimeLinkedMDBFedra$approach <- approachFedxFedraName
execTimeLinkedMDBPBJPre$approach <- approachPBJPreName
execTimeLinkedMDBPBJPost$approach <- approachPBJPostName
execTimeLinkedMDBPBJHybrid$approach <- approachPBJHybridName

# from geoCoordinates setup
execTimeGeoCoordinatesEngine$approach <- approachFedxName
execTimeGeoCoordinatesFedra$approach <- approachFedxFedraName
execTimeGeoCoordinatesPBJPre$approach <- approachPBJPreName
execTimeGeoCoordinatesPBJPost$approach <- approachPBJPostName
execTimeGeoCoordinatesPBJHybrid$approach <- approachPBJHybridName

# from swdf setup
execTimeSWDFEngine$approach <- approachFedxName
execTimeSWDFFedra$approach <- approachFedxFedraName
execTimeSWDFPBJPre$approach <- approachPBJPreName
execTimeSWDFPBJPost$approach <- approachPBJPostName
execTimeSWDFPBJHybrid$approach <- approachPBJHybridName

# from watDiv setup
execTimeWatDivEngine$approach <- approachFedxName
execTimeWatDivFedra$approach <- approachFedxFedraName
execTimeWatDivPBJPre$approach <- approachPBJPreName
execTimeWatDivPBJPost$approach <- approachPBJPostName
execTimeWatDivPBJHybrid$approach <- approachPBJHybridName

# from watDiv100 setup
execTimeWatDiv100Engine$approach <- approachFedxName
execTimeWatDiv100Fedra$approach <- approachFedxFedraName
execTimeWatDiv100PBJPre$approach <- approachPBJPreName
execTimeWatDiv100PBJPost$approach <- approachPBJPostName
execTimeWatDiv100PBJHybrid$approach <- approachPBJHybridName

# ----------------------------------------------
# merge results by table, then into one unique table
# ----------------------------------------------

diseasomeTable <- rbind(execTimeDiseasomeEngine, execTimeDiseasomeFedra, execTimeDiseasomePBJPre, execTimeDiseasomePBJPost, execTimeDiseasomePBJHybrid)
linkedMDBTable <- rbind(execTimeLinkedMDBEngine, execTimeLinkedMDBFedra, execTimeLinkedMDBPBJPre, execTimeLinkedMDBPBJPost, execTimeLinkedMDBPBJHybrid)
geoCoordinatesTable <- rbind(execTimeGeoCoordinatesEngine, execTimeGeoCoordinatesFedra, execTimeGeoCoordinatesPBJPre, execTimeGeoCoordinatesPBJPost, execTimeGeoCoordinatesPBJHybrid)
SWDFTable <- rbind(execTimeSWDFEngine, execTimeSWDFFedra, execTimeSWDFPBJPre, execTimeSWDFPBJPost, execTimeSWDFPBJHybrid)
watDivTable <- rbind(execTimeWatDivEngine, execTimeWatDivFedra, execTimeWatDivPBJPre, execTimeWatDivPBJPost, execTimeWatDivPBJHybrid)
watDiv100Table <- rbind(execTimeWatDiv100Engine, execTimeWatDiv100Fedra, execTimeWatDiv100PBJPre, execTimeWatDiv100PBJPost, execTimeWatDiv100PBJHybrid)

table <- rbind(diseasomeTable, linkedMDBTable, geoCoordinatesTable, SWDFTable, watDivTable, watDiv100Table)

# set the colnames
colnames(table) <- c("time", "dataset", "Approach")

# create the boxplots
ggplot(data = table, aes(x=dataset, y=time)) + geom_boxplot(aes(fill=Approach))
