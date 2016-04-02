#!/usr/bin/python
# Script for calculating the difference bewteen results from Fedra + Fedx and Fedra + Fedx + PBJ
# Authors : Naixin Wang & Thomas Minier
import json
import csv

# load the config
with open("config.json") as configFile:
	config = json.load(configFile)

for setupName, files in config["outputs_csv"].items():
	# retrieve the reference output from fedra execution
	with open(files["fedra"], "r", newline="") as csvfile:
		csvreader = csv.reader(csvfile, delimiter=";", quotechar="|")
		outputReference = [row for row in csvreader][1:] # exclude the first line with the headers

	# remove the entry for fedra and iterate over the other execution results
	del files["fedra"]
	for name, filepath in files.items():
		# retrieve the output from the current file
		with open(files[name], "r", newline="") as csvfile:
			csvreader = csv.reader(csvfile, delimiter=";", quotechar="|")
			outputExec = [ row for row in csvreader ][1:] # exclude the first line with the headers
		# open the csv file which will contain the results of this process
		with open(config["outputs_delta"][setupName][name], "w", newline="") as csvfile:
			csvwriter = csv.writer(csvfile, delimiter=";", quotechar="|", quoting=csv.QUOTE_MINIMAL)
			csvwriter.writerow(["Query name", "Query execution time (s)", "Percentage of the CPU used",
								"Average resident set size of the process (kb)", "Maximum resident set size of the process (kb)",
								"Completeness (%)", "Soundness (%)", "Number of selected sources", "Number of selected sources",
								"Shape of the query", "Number of transferred tuples", "Number of calls sent to the endpoints"])
			# calculate the delat between the refrence and the current output
			outputDelta = list()
			for line in range(0, len(outputReference)):
				for token in range(0, len(outputReference[line])):
					# case of string value, who desn't need any process
					if (token == 0) or (token == 9):
						outputDelta.append(outputReference[line][token])
					elif (token == 2):
						# case of %
						outputDelta.append(str(float(outputReference[line][token][:-1]) - float(outputExec[line][token][:-1])) + "%")
					else:
						#case of integer or float
						outputDelta.append(float(outputReference[line][token]) - float(outputExec[line][token]))
				# save the line & reset the outputDelta
				csvwriter.writerow(outputDelta)
				outputDelta.clear()
