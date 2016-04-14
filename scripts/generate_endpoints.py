#!/usr/bin/python
# Script for formatting the datas from endpoint traffic in csv
# Authors : Thomas Minier & Naixin Wang
import json
import csv

# load the config
with open("config.json") as configFile:
	config = json.load(configFile)

for setupName, files in config["outputs"].items():
	for approachName, fileName in files.items():
		# load the content of the file
		with open(fileName, "r", newline="") as csvfile:
			csvreader = csv.reader(csvfile, delimiter=" ", quotechar="|")
			outputExec = [ row for row in csvreader ]
		# generate the ouput file with endpoints data
		with open(fileName + "Endpoints", "w", newline="") as csvfile:
			csvwriter = csv.writer(csvfile, delimiter=" ", quotechar="|", quoting=csv.QUOTE_MINIMAL)
			for row in outputExec:
				i = 1
				for value in row[12:]:
					# format : query name, value, endpoint number and setup name
					csvwriter.writerow([row[0], value, "e" + str(i)])
					i += 1
