#!/usr/bin/python3
# Script for detecting if parallelization occurs during request execution
# Author : Thomas Minier

import csv

fedraFile = "../results/watDiv/outputFedXFedraFEDERATION10Client"
hybridFile = "../results/watDiv/outputFedXFedra-PBJ-hybridFEDERATION10Client"
outputFile = "../results/queriesParallelized.txt"

federationFiles = [ "outputFedXengineFEDERATION10Client",
                    "outputFedXFedra-PBJ-hybridFEDERATION10Client",
                    "outputFedXFedra-PBJ-postFEDERATION10Client",
                    "outputFedXFedra-PBJ-preFEDERATION10Client",
                    "outputFedXFedraFEDERATION10Client"]

def main():
    fedraHotspots = dict()
    fedraTimes = dict()
    fedraTuples = dict()

    hybridHotspots = dict()
    hybridTimes = dict()

    parallelizedQueries  = list()
    shapes = dict()
    tuples = dict()

    # load the hotspots of the reference file
    with open(fedraFile, "r", newline="") as csvfile:
        csvreader = csv.reader(csvfile, delimiter=" ", quotechar="|")
        for row in csvreader:
            fedraHotspots[row[0]] = row[12:23]
            fedraTimes[row[0]] = row[1]
            shapes[row[0]] = row[9]
            tuples[row[0]] = row[10]

    # load the hotspots of the file to compare with
    with open(hybridFile, "r", newline="") as csvfile:
        csvreader = csv.reader(csvfile, delimiter=" ", quotechar="|")
        for row in csvreader:
            hybridHotspots[row[0]] = row[12:23]
            hybridTimes[row[0]] = row[1]

    # compare the files
    with open(outputFile, "w", newline="") as csvfile:
        csvwriter = csv.writer(csvfile, delimiter=" ", quotechar="|", quoting=csv.QUOTE_MINIMAL)
        nbImprovedQueries = 0
        nbUnimprovedQueries = 0

        # search for non equal hotspot lists
        for query in fedraHotspots.keys():
            if fedraHotspots[query] != hybridHotspots[query]:
                parallelizedQueries.append(query)
                ratio = 100.0 - ( (float(hybridTimes[query]) / float(fedraTimes[query])) * 100.0)
                if ratio > 0.0:
                    nbImprovedQueries += 1
                    print("Execution time of " + query + " has been improved of " + str(ratio) + "%")
                else:
                    nbUnimprovedQueries += 1

                # print in file : query name, shape of the query, #transferred tuples, pourcentage of reduction,
                #                 execution time with fedra, hotspots with fedra, "vs", execution time with fedra and hotspots with fedra
                csvwriter.writerow([query, shapes[query], tuples[query], ratio, fedraTimes[query]] + fedraHotspots[query] + ["vs", hybridTimes[query]] + hybridHotspots[query])
        print("Number of queries with improved execution time : " + str(nbImprovedQueries) + "/" + str(len(fedraTimes)))
        print("Number of queries with unimproved execution time : " + str(nbUnimprovedQueries) + "/" + str(len(fedraTimes)))

    # create files for the boxplots
    for fileName in federationFiles:
        # collect datas about parallelized queries
        with open("../results/watDiv/" + fileName, "r", newline="") as csvfile:
            csvreader = csv.reader(csvfile, delimiter=" ", quotechar="|")
            queries = [ row for row in csvreader if (row[0] in parallelizedQueries) ]
        # output them in corresponding file
        with open("../results/parallelized/" + fileName, "w", newline="") as csvfile:
            csvwriter = csv.writer(csvfile, delimiter=" ", quotechar="|", quoting=csv.QUOTE_MINIMAL)
            for query in queries:
                csvwriter.writerow(query)

if __name__ == "__main__":
    main()
