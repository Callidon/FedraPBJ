#!/usr/bin/env Rscript
# Script to produce boxplot for the results from various executions of the setup
# author : Thomas Minier

require(ggplot2)
require(gridExtra)

# Load the datas from files
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

# create the approach column
execTimeDiseasomeEngine$approach <- "Fedx"
execTimeDiseasomeFedra$approach <- "Fedx + Fedra"
execTimeDiseasomePBJPre$approach <- "PBJ pre SC"
execTimeDiseasomePBJPost$approach <- "PBJ post SC"
execTimeDiseasomePBJHybrid$approach <- "PBJ hybrid"

# merge results in one table
graph <- rbind(execTimeDiseasomeEngine, execTimeDiseasomeFedra, execTimeDiseasomePBJPre, execTimeDiseasomePBJPost, execTimeDiseasomePBJHybrid)

# set the colnames
colnames(graph) <- c("QueryExecutionTime", "Approach")

# create the boxplots
ggplot(data = graph, aes(x=Approach, y=QueryExecutionTime)) + geom_boxplot(aes(fill=Approach))
