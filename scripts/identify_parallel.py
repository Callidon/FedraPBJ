#!/usr/bin/python3
# Detect if parallelization occurs during request execution
# Author : Thomas Minier

import csv
import argparse


def main():
    """Main function
    """
    parser = argparse.ArgumentParser(description='Detect if parallelization occurs during request execution')
    parser.add_argument('-r', '--reference-file', type=str, required=True,
                        help='folder which contains query patterns for parsing')
    parser.add_argument('-f', '--file', type=str, required=True,
                        help='file which contains queries to parse')
    parser.add_argument('-n', '--number-endpoints', type=str, required=True,
                        help='number of endpoints in the federation')
    parser.add_argument('-o', '--output', type=str, required=True,
                        help='output file')
    args = parser.parse_args()

    fedraHotspots = dict()
    fedraTimes = dict()
    fedraTuples = dict()

    hybridHotspots = dict()
    hybridTimes = dict()

    parallelizedQueries = list()
    shapes = dict()
    tuples = dict()
    '''
    federation_files = ['outputFedXFedra-PBJ-hybridFEDERATION{}Client'.format(args.number_endpoints),
                        'outputFedXFedraFEDERATION{}Client'.format(args.number_endpoints),
                        'outputFedXengineFEDERATION{}Client'.format(args.number_endpoints),
                        'outputFedXFedra-PBJ-postFEDERATION{}Client'.format(args.number_endpoints),
                        'outputFedXFedra-PBJ-preFEDERATION{}Client'.format(args.number_endpoints)]
    '''
    federation_files = ['outputFedXFedra-PBJ-hybridFEDERATION{}Client'.format(args.number_endpoints),
                        'outputFedXFedraFEDERATION{}Client'.format(args.number_endpoints)]

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

    # compare the files & output the results
    with open(args.output, 'w', newline='') as csvfile:
        csvwriter = csv.writer(csvfile, delimiter=' ', quotechar='|', quoting=csv.QUOTE_MINIMAL)
        nbImprovedQueries = 0
        nbUnimprovedQueries = 0

        # search for non equal hotspot lists
        for query in fedraHotspots.keys():
            if fedraHotspots[query] != hybridHotspots[query]:
                ratio = 100.0 - ((float(hybridTimes[query]) / float(fedraTimes[query])) * 100.0)
                parallelizedQueries.append(query)
                if ratio > 0.0:
                    nbImprovedQueries += 1
                    print('Execution time of {} has been improved of {} %'.format(query, ratio))
                else:
                    nbUnimprovedQueries += 1

                # print in file : query name, shape of the query, #transferred tuples, pourcentage of reduction,
                #                 execution time with fedra, hotspots with fedra, 'vs', execution time with fedra and hotspots with fedra
                csvwriter.writerow([query, shapes[query], tuples[query], ratio, fedraTimes[query]] + fedraHotspots[query] + ['vs', hybridTimes[query]] + hybridHotspots[query])

    print('Number of queries with improved execution time : {} / {}'.format(nbImprovedQueries, len(fedraTimes)))
    print('Number of queries with unimproved execution time : {} / {}'.format(nbUnimprovedQueries, len(fedraTimes)))

    # create files for the boxplot script
    for fileName in federation_files:
        # collect datas about parallelized queries
        with open('../results/watDivMore/{}'.format(fileName), 'r', newline='') as csvfile:
            csvreader = csv.reader(csvfile, delimiter=' ', quotechar='|')
            queries = [row for row in csvreader if (row[0] in parallelizedQueries)]
        # output them in corresponding file
        with open('../results/watDivMore/parallelized/{}'.format(fileName), 'w', newline='') as csvfile:
            csvwriter = csv.writer(csvfile, delimiter=' ', quotechar='|', quoting=csv.QUOTE_MINIMAL)
            csvwriter.writerows(queries)

if __name__ == '__main__':
    main()
