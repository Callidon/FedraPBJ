#!/usr/bin/python3
# Gather multiples execution of a federation and compute the means of each values
# Author : Thomas Minier

import csv
import argparse
import os.path


def main():
    """Main function
    """
    parser = argparse.ArgumentParser(description='Gather multiples execution of a federation and compute the means of each values')
    parser.add_argument('-r', '--reference-file', type=str, required=True,
                        help='name of the reference file which contains data to gather')
    parser.add_argument('-f', '--folders', type=str, required=True, nargs="*",
                        help='folders which contains data to gather')
    parser.add_argument('-o', '--output-folder', type=str, required=True,
                        help='output file')
    args = parser.parse_args()

    files = ["{}/{}".format(folder, args.reference_file) for folder in args.folders]
    queries = dict()
    queryMeans = dict()
    nbQuery = len(files)
    ignoredFields = [1, 8]

    # for each file, load each query
    for file in files:
        with open(file, 'r', newline='') as csvfile:
            csvreader = csv.reader(csvfile, delimiter=' ', quotechar='|')
            for row in csvreader:
                queryName, queryData = row[0], row[1:]
                if queryName in queries:
                    queries[queryName].append(queryData)
                else:
                    queries[queryName] = [queryData]

    for queryName, queryData in queries.items():
        # discard queries which are not present in all files
        if len(queryData) == nbQuery:
            queryMeans[queryName] = [float(value) if ind not in ignoredFields else value for ind, value in enumerate(queryData[0])]
            # accumulate value
            for data in queryData[1:]:
                for ind, value in enumerate(data):
                    if ind not in ignoredFields:
                        queryMeans[queryName][ind] += float(value)

    # compute means
    for queryName, queryData in queryMeans.items():
        for ind, value in enumerate(queryData):
            if ind not in ignoredFields:
                queryMeans[queryName][ind] = value / nbQuery

    # output results
    with open("{}/{}".format(args.output_folder, args.reference_file), 'w', newline='') as csvfile:
        csvwriter = csv.writer(csvfile, delimiter=' ', quotechar='|', quoting=csv.QUOTE_MINIMAL)
        for queryName, queryData in queryMeans.items():
            rows = [repr(value) if ind not in ignoredFields else value for ind, value in enumerate(queryData)]
            csvwriter.writerow([queryName] + rows)
if __name__ == '__main__':
    main()
