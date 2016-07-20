#!/usr/bin/python3
# Detect if parallelization occurs during request execution
# Author : Thomas Minier

import csv
import argparse
import os.path


def main():
    """Main function
    """
    parser = argparse.ArgumentParser(description='Detect if parallelization occurs during request execution')
    parser.add_argument('-r', '--reference-file', type=str, required=True,
                        help='folder which contains query patterns for parsing')
    parser.add_argument('-f', '--file', type=str, required=True,
                        help='file which contains queries to parse')
    parser.add_argument('-e', '--engine-file', type=str, required=False,
                        help='file which contains the results for the engine strategy')
    parser.add_argument('-n', '--number-endpoints', type=str, required=True,
                        help='number of endpoints in the federation')
    parser.add_argument('-o', '--output', type=str, required=True,
                        help='output folder')
    args = parser.parse_args()

    fedraHotspots = dict()
    fedraTimes = dict()
    fedraTuples = dict()

    hybridHotspots = dict()
    hybridTimes = dict()

    parallelizedQueries = list()
    shapes = dict()
    tuples = dict()
    ratios = list()
    federation_files = [args.reference_file, args.file]
    if args.engine_file:
        federation_files.append(args.engine_file)

    # load the hotspots of the reference file
    with open(args.reference_file, 'r', newline='') as csvfile:
        csvreader = csv.reader(csvfile, delimiter=' ', quotechar='|')
        for row in csvreader:
            fedraHotspots[row[0]] = row[12:13 + int(args.number_endpoints)]
            fedraTimes[row[0]] = row[1]
            shapes[row[0]] = row[9]
            tuples[row[0]] = row[10]

    # load the hotspots of the file to compare with
    with open(args.file, 'r', newline='') as csvfile:
        csvreader = csv.reader(csvfile, delimiter=' ', quotechar='|')
        for row in csvreader:
            hybridHotspots[row[0]] = row[12:13 + int(args.number_endpoints)]
            hybridTimes[row[0]] = row[1]

    # search for non equal hotspot lists
    nbImprovedQueries = 0
    nbUnimprovedQueries = 0
    for query in fedraHotspots.keys():
        if fedraHotspots[query] != hybridHotspots[query]:
            ratio = 100.0 - ((float(hybridTimes[query]) / float(fedraTimes[query])) * 100.0)
            parallelizedQueries.append(query)
            if ratio > 0.0:
                nbImprovedQueries += 1
                ratios.append(ratio)
                print('Execution time of {} has been improved of {} %'.format(query, ratio))
            else:
                nbUnimprovedQueries += 1

    print('Number of queries with improved execution time : {} / {}'.format(nbImprovedQueries, len(fedraTimes)))
    print('Number of queries with unimproved execution time : {} / {}'.format(nbUnimprovedQueries, len(fedraTimes)))
    print('Average query execution time improvement : {}%'.format(sum(ratios) / len(ratios)))
    print('Maximum query execution time improvement : {}%'.format(max(ratios)))
    print('Minimum query execution time improvement : {}%'.format(min(ratios)))

    # create files for the boxplot script
    for fileName in federation_files:
        # collect datas about parallelized queries
        with open(fileName, 'r', newline='') as csvfile:
            csvreader = csv.reader(csvfile, delimiter=' ', quotechar='|')
            queries = [row for row in csvreader if (row[0] in parallelizedQueries)]
        # output them in corresponding file
        with open('{}/{}'.format(args.output, os.path.basename(fileName)), 'w', newline='') as csvfile:
            csvwriter = csv.writer(csvfile, delimiter=' ', quotechar='|', quoting=csv.QUOTE_MINIMAL)
            csvwriter.writerows(queries)

if __name__ == '__main__':
    main()
