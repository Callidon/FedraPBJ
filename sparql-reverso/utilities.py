# Utilities functions for the sparql-reverso program
# Author : Thomas Minier
import re
import csv
from node import Node
from triplePattern import TriplePattern


def loadBGP(query):
    """Extract a BGP as a list of triple patterns from a SPARQL query
    """
    query = re.sub(' +', ' ', query)  # compact multiples spaces
    bgp = re.search('WHERE {(.*)}', query).group(1)
    return [TriplePattern.from_str(triple) for triple in bgp.split(' . ')]


def findParallelQueries(referenceResults, queriesResults):
    """Find line numbers of queries that have been parallelized
    """
    referenceHotspots = dict()
    queriesHotspots = dict()

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

    # find & return the parallelized queries
    parallelized = [int(query[5:]) for query, hotspots in referenceHotspots.items() if hotspots != queriesHotspots[query]]
    classics = [int(query[5:]) for query, hotspots in referenceHotspots.items() if hotspots == queriesHotspots[query]]
    return parallelized, classics
