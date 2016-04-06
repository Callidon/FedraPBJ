#!/usr/bin/env Rscript
# Script to produce boxplots for the results from various executions of the setup
# author : Thomas Minier & Naixin Wang, M1 ALMA

require(ggplot2)

# Load the datas from files

# from Diseasome
outputDiseasomeEngine <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")
outputDiseasomeFedra <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")
outputDiseasomePBJPre <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")
outputDiseasomePBJPost <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")
outputDiseasomePBJHybrid <- read.table("../results/diseasome/outputFedXFedra-PBJ-preFEDERATION10Client")

# extract the execution time columns
execTimeDiseasomeEngine <- outputDiseasomeEngine[2]
execTimeDiseasomeFedra <- outputDiseasomeFedra[2]
execTimeDiseasomePBJPre <- outputDiseasomePBJPre[2]
execTimeDiseasomePBJPost <- outputDiseasomePBJPost[2]
execTimeDiseasomePBJHybrid <- outputDiseasomePBJHybrid[2]

# create the data origin column
execTimeDiseasomeEngine$dataset <- "Diseasome"
execTimeDiseasomeFedra$dataset <- "Diseasome"
execTimeDiseasomePBJPre$dataset <- "Diseasome"
execTimeDiseasomePBJPost$dataset <- "Diseasome"
execTimeDiseasomePBJHybrid$dataset <- "Diseasome"

# create the approach column
execTimeDiseasomeEngine$approach <- "Fedx"
execTimeDiseasomeFedra$approach <- "Fedx + Fedra"
execTimeDiseasomePBJPre$approach <- "PBJ pre SC"
execTimeDiseasomePBJPost$approach <- "PBJ post SC"
execTimeDiseasomePBJHybrid$approach <- "PBJ hybrid"

# merge results by table, then into one unique table
diseasomeTable <- rbind(execTimeDiseasomeEngine, execTimeDiseasomeFedra, execTimeDiseasomePBJPre, execTimeDiseasomePBJPost, execTimeDiseasomePBJHybrid)

table <- rbind(diseasomeTable)

# set the colnames
colnames(table) <- c("time", "dataset", "Approach")

# create the boxplots
ggplot(data = table, aes(x=dataset, y=time)) + geom_boxplot(aes(fill=Approach))
