#!/usr/bin/python
# Script for summing the execution time from the different executions of Fedra + Fedx + PBJ
# Authors : Thomas Minier & Naixin Wang
import json
import csv

# load the config
with open("config.json") as configFile:
	config = json.load(configFile)

for setupName, files in config["outputs_csv"].items():
	# open the result file
	with open(config["outputs_barplots"][setupName]["sum_exectime"], "w", newline="") as csvfile:
		csvwriter = csv.writer(csvfile, delimiter=";", quotechar="|", quoting=csv.QUOTE_MINIMAL)
		csvwriter.writerow(["Setup name", "Total execution time (s)"])
		# for each setup
		for setupName, files in config["outputs_csv"].items():
			# for each file for the curretn setup
			for name, filepath in files.items():
				setupTime = 0
				with open(files[name], "r", newline="") as csvfile:
					csvreader = csv.reader(csvfile, delimiter=";", quotechar="|")
					outputExec = [ row for row in csvreader ][1:] # exclude the first line with the headers
					for line in outputExec:
						setupTime += float(line[1])
					csvwriter.writerow([name, str(setupTime)])
