# Utilities functions for the sparq-reverso program
# Author : Thomas Minier
import re
import csv
from node import Node
from triplePattern import TriplePattern


def loadBGP(query):
    """Extract a BGP as a list of triple patterns from a SPARQL query
    """
    queryBGP = list()
    query = re.sub(' +', ' ', query)  # remove multiples spaces
    bgp = re.search('WHERE {(.*)}', query).group(1)
    for triple in bgp.split(' . '):
        queryBGP.append(TriplePattern.from_str(triple))
    return queryBGP


def findParallelQueries(referenceResults, queriesResults):
    """Find line numbers of queries that have been parallelized
    """
    referenceHotspots = dict()
    queriesHotspots = dict()
    parallelized = list()

    # load the hotspots of the reference file
    with open(referenceResults, 'r', newline='') as csvfile:
        csvreader = csv.reader(csvfile, delimiter=' ', quotechar='|')
        for row in csvreader:
            referenceHotspots[row[0]] = row[12:23]

    # load the hotspots of the file to compare with
    with open(queriesResults, 'r', newline='') as csvfile:
        csvreader = csv.reader(csvfile, delimiter=' ', quotechar='|')
        for row in csvreader:
            queriesHotspots[row[0]] = row[12:23]

    # find the parallelized queries
    for query, hotspots in referenceHotspots.items():
        if hotspots != queriesHotspots[query]:
            parallelized.append(int(query[5:]))
    return parallelized
