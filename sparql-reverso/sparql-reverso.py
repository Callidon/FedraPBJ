#!/usr/bin/env python3
# Find queries that have been parallelized & identify the fragments
# they use in order to find similar queries
# author : Thomas Minier

import random
import os
import sys
import argparse
import utilities

IDENTIFIED_QUERIES_FILE = 'identified-queries.txt'
CLASSIC_QUERIES_FILE = 'classic-queries.txt'


def main():
    """Main function
    """
    parser = argparse.ArgumentParser(description='Find queries that have been '
                                     'parallelized & identify the fragments they'
                                     ' use in order to find similar queries')
    parser.add_argument('-r', '--reference-file', type=str, required=True,
                        help='file which contains the reference execution results')
    parser.add_argument('-c', '--comparaison-file', type=str, required=True,
                        help='file which contains the execution results to compare with the reference')
    parser.add_argument('-q', '--queries-file', type=str, required=True,
                        help='file which contains the queries to analyze')
    parser.add_argument('-f', '--fragments-folder', type=str, required=True,
                        help='folder whch contains the fragment defintions')
    parser.add_argument('-n', '--number-endpoints', type=str, required=True,
                        help='number of endpoints in the federation')
    parser.add_argument('-o', '--output', type=str, required=True,
                        help='output file for results')
    args = parser.parse_args()

    allQueries = list()
    results = list()
    allFragments = dict()

    # find the queries that have been parallelized
    parallelizedQueries, classicQueries = utilities.findParallelQueries(args.reference_file, args.comparaison_file, int(args.number_endpoints))
    print('INFO : Found {} parallelized queries'.format(len(parallelizedQueries)))

    # load queries already identified as parallelized
    with open(IDENTIFIED_QUERIES_FILE, 'r') as reader:
        previousResults = [int(line) for line in reader]
    parallelizedQueries = list(set().union(parallelizedQueries, previousResults))
    # update the file
    with open(IDENTIFIED_QUERIES_FILE, 'w') as writer:
        for query in parallelizedQueries:
            writer.write('{}\n'.format(query))

    # same thing with queries already identified as classic
    with open(CLASSIC_QUERIES_FILE, 'r') as reader:
        previousClassics = [int(line) for line in reader]
    classicQueries = list(set().union(classicQueries, previousClassics))
    # update the file
    with open(CLASSIC_QUERIES_FILE, 'w') as writer:
        for query in classicQueries:
            writer.write('{}\n'.format(query))

    # load all the queries
    with open(args.queries_file, 'r') as reader:
        allQueries = [utilities.loadBGP(line) for line in reader]

    # load all the fragments
    for filename in os.listdir(args.fragments_folder):
        fragmentName = os.path.splitext(filename)[0]
        fragment = ''
        with open('{}/{}'.format(args.fragments_folder, filename), 'r') as reader:
            fragment = ''.join([line.rstrip() for line in reader])
        allFragments[fragmentName] = utilities.loadBGP(fragment)[0]

    # find the relevant fragments for the parallelized queries
    for queryLine in parallelizedQueries:
        relevantFragments = [
            definition
            for fragmentName, definition in allFragments.items()
            if definition in allQueries[queryLine]]

    # search for queries which use the same fragments
    for ind in range(len(allQueries)):
        if (ind not in parallelizedQueries) and (ind not in classicQueries):
            for fragment in relevantFragments:
                if fragment in allQueries[ind]:
                    results.append(ind)

    print('INFO : Found {} queries with similar fragments'.format(len(results)))

    # output 100 random line numbers in output file
    if len(results) == 0:
        print('INFO : no more queries can be identified')
        sys.exit()
    elif len(results) >= 100:
        sample = random.sample(results, 100)
    else:
        # use sampling with replacement when we doesn't have engouh results
        sample = results + random.sample(results, 100 - len(results))
        random.shuffle(sample)
    with open(args.output, 'w') as writer:
        for result in sample:
            writer.write('{}\n'.format(result))

if __name__ == '__main__':
    main()
