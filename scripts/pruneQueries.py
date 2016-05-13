#!/usr/bin/python3
# Prune queries to find those which transfer a minimum number of tuples
# WARNING : the endpoint containing the data related to the queries will
# not be launch or shutdown ny this script
# Author : Thomas Minier

import re
import json
import argparse
import subprocess


def splitQuery(query):
    """Extract the triple pattersn from a SPARQL query
    """
    triples = list()
    bgp = re.search('WHERE {(.*)}', query).group(1)
    for triple in bgp.split(' . '):
        triples.append(triple.strip())
    return triples


def main():
    parser = argparse.ArgumentParser(description='Prune queries to find those which transfer a minimum number of tuples')
    parser.add_argument('-f', '--file', type=str, required=True,
                        help='file which contains the query to prune')
    parser.add_argument('-p', '--port', type=str, required=True,
                        help='port number associated with the endpoint which holds the data')
    parser.add_argument('-m', '--minimum', type=str, required=True,
                        help='minimum number of transferred tuples per patterns')
    parser.add_argument('-o', '--output', type=str, required=True,
                        help='output file')
    args = parser.parse_args()

    # launch federation data endpoint
    # subprocess.call('hdtEndpoint.sh --localhost --port={} --hdt={} /ds &'.format(args.port, args.endpoint_file))
    # pid, err = subprocess.Popen('echo $!', stdout=subprocess.PIPE, shell=True).communicate()
    results = list()
    with open(args.file, 'r') as reader:
        queryNumber = 0
        for query in reader:
            queryIsValid = True
            queryNumber += 1
            triples = splitQuery(query)
            # only keep queries with at least one join
            if len(triples) <= 1:
                next
            else:
                for triple in triples:
                    query = 'SELECT DISTINCT (COUNT (*) AS ?c) WHERE { ' + triple + ' }'
                    # fetch number of triples using jena
                    p = subprocess.Popen('s-query --service http://127.0.0.1:{}/ds/query --output=json \'{}\''.format(args.port, query),
                                         stdout=subprocess.PIPE, shell=True)
                    (data, err) = p.communicate()
                    answer = json.loads(data.decode('utf-8'))
                    count = answer['results']['bindings'][0]['c']['value']
                    # discard the query if any triple pattern doesn't match the criteria
                    if float(count) < float(args.minimum):
                        queryIsValid = False
                        break

                # save valid queries as results
                if queryIsValid:
                    print('query {} done processing'.format(queryNumber))
                    with open(args.output, 'a') as writer:
                        writer.write('{}\n'.format(queryNumber))

    # subprocess.call('kill -9 {}'.format(pid))

if __name__ == '__main__':
    main()
