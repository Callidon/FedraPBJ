#!/usr/bin/env python3
# Find queries that have been parallelized & identify the fragments
# they use in order to find similar queries
# author : Thomas Minier

import csv
import random
import os
import argparse
import utilities

IDENTIFIED_QUERIES_FILE = 'identified-queries.txt'


def main():
    """Main function
    """
    parser = argparse.ArgumentParser(description='Find queries that have been '
                                     'parallelized & identify the fragments they'
                                     ' use in order to find similar queries')
    parser.add_argument('-i', '--identified-queries', type=str, required=False,
                        help='file which contains the queries already identified')
    parser.add_argument('-r', '--reference-file', type=str, required=True,
                        help='file which contains the reference execution results')
    parser.add_argument('-c', '--comparaison-file', type=str, required=True,
                        help='file which contains the execution results to compare with the reference')
    parser.add_argument('-q', '--queries-file', type=str, required=True,
                        help='file which contains the queries to analyze')
    parser.add_argument('-f', '--fragments-folder', type=str, required=True,
                        help='folder whch contains the fragment defintions')
    parser.add_argument('-o', '--output', type=str, required=True,
                        help='output file for results')
    args = parser.parse_args()

    allQueries = list()
    results = list()
    allFragments = dict()

    # find the queries that have been parallelized
    parallelizedQueries = utilities.findParallelQueries(args.reference_file, args.comparaison_file)

    # if used, load previously identified queries
    if args.identified_queries:
        with open(args.identified_queries, 'r') as reader:
            previousResults = [int(line) for line in reader]
        parallelizedQueries = list(set().union(parallelizedQueries, previousResults))
        # update the file
        with open(args.identified_queries, 'w') as writer:
            for query in parallelizedQueries:
                writer.write('{}\n'.format(query))
    else:
        # output the parallelized queries
        with open(IDENTIFIED_QUERIES_FILE, 'w') as writer:
            for query in parallelizedQueries:
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
        if (allQueries[ind] not in parallelizedQueries) and (allQueries[ind] not in results):
            for fragment in relevantFragments:
                if fragment in allQueries[ind]:
                    results.append(ind)

    # output 100 random line numbers in output file
    with open(args.output, 'w') as writer:
        if(len(results) >= 100):
            sample = random.sample(results, 100)
        else:
            # use sampling with replacement when we doesn't have engouh results
            sample = results + random.sample(results, 100 - len(results))
            random.shuffle(sample)
        for result in sample:
            writer.write('{}\n'.format(result))

if __name__ == '__main__':
    main()
