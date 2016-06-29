#!/usr/bin/env python3
# Find unique queries without any constant
# author : Thomas Minier

import random
import os
import sys
import argparse
import utilities
from node import Node


def main():
    """Main function
    """
    parser = argparse.ArgumentParser(description='Find unique queries without any constant')
    parser.add_argument('-q', '--queries-file', type=str, required=True,
                        help='file which contains the queries to analyze')
    parser.add_argument('-n', '--number', type=int, required=True,
                        help='number of queries to find')
    parser.add_argument('-o', '--output', type=str, required=True,
                        help='output file for queries')
    args = parser.parse_args()
    allQueries = list()
    processQueries = set()
    symbols = [chr(x) for x in range(97, 123)]

    # load queries
    with open(args.queries_file, 'r') as reader:
        allQueries = [utilities.loadQuery(line) for line in reader]

    # replace constants of each query & remove duplicated queries
    for query in allQueries:
        nextSymbole = 0
        bgp = query[1]
        if len(bgp) > 1 and len(bgp) < 8:
            # replace constants by variables
            for ind in range(len(bgp)):
                if not bgp[ind].subject.isBlank:
                    bgp[ind].subject = Node("?" + symbols[nextSymbole], True)
                    nextSymbole += 1

                if not bgp[ind].object.isBlank:
                    bgp[ind].object = Node("?" + symbols[nextSymbole], True)
                    nextSymbole += 1
            # add the query to a set to remove duplicates
            processQueries.add(query[0] + ' . '.join([str(triple) for triple in bgp]) + query[2])

    # output 100 random line numbers in output file
    if len(processQueries) < args.number:
        print('ERROR : not engouh queries to take a sample.')
    else:
        sample = random.sample(processQueries, args.number)
        with open(args.output, 'w') as writer:
            for result in sample:
                writer.write('{}\n'.format(result))

if __name__ == '__main__':
    main()
