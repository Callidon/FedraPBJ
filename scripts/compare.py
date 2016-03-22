#!/usr/bin/python
# Script for comparing results from Fedra + FedX with and without Parallel Bound Join algorithm
# Authors : Naixin Wang & Thomas Minier
import os

outputFedra_path = "examples/outputFedra"
outputFedraPBJ_path = "examples/outputFedraPBJ"

fedraResults = dict()
fedraPBJResults = dict()

with open(outputFedra_path, "r") as outputFedra:
	for fedraLine in outputFedra:
		fedraRows = fedraLine.split(" ")
		queryName = fedraRows[0]
		fedraResults[queryName] = [ fedraRows[ind].rstrip() for ind in range(1, len(fedraRows)) ]

with open(outputFedraPBJ_path, "r") as outputFedraPBJ:
	for fedraPBJLine in outputFedraPBJ:
		fedraPBJRows = fedraPBJLine.split(" ")
		queryName = fedraPBJRows[0]
		fedraPBJResults[queryName] = [ fedraPBJRows[ind].rstrip() for ind in range(1, len(fedraRows)) ]

for queryName, fedraResult in fedraResults.items():
	fedraPBJResult = fedraPBJResults[queryName]
	print "For query " + queryName
	for ind in range(0, len(fedraResult)):
		print "Fedra : " + fedraResult[ind] + " | FedraPBJ : " + fedraPBJResult[ind]
