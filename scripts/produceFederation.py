#!/usr/bin/python3
# Create a new federation by dispatching fragments to endpoints
# Author : Thomas Minier

import argparse
import os
import random
import rdflib
import subprocess

FEDRA_ENDPOINTS_FILE = 'endpoints'


def divideFragments(fragments, endpoints, threshold):
    """Associate N = threshold fragments to each endpoint
    """
    bins = {key: list() for key in endpoints}
    # put fragments in N endpoints
    for fragment in fragments:
        sample = random.sample(endpoints, threshold)
        for endpoint in sample:
            bins[endpoint].append(fragment)
    return {fragment: [endpoint for (endpoint, bin) in bins.items() if fragment in bin] for fragment in fragments}


def createEndpointFile(filename, repartition, fragments):
    """Create the file used by Fedra which map each fragment to the endpoints which hold it
    """
    with open(filename, 'w') as writer:
        for fragment, endpoints in repartition.items():
            writer.write(fragment)
            for endpoint in endpoints:
                port = endpoint[8:]
                writer.write(' http://172.16.9.3:{}/ds/sparql'.format(port))
            writer.write('\n')


def dispatchFragments(fragment_folder, repartition, output_folder):
    """Fill the endpoints using a repartition of fragments
    """
    # process by each fragment
    for fragment, endpoints in repartition.items():
        # load the fragments and convert it to n-triples format
        g = rdflib.Graph()
        g.parse('{}/{}.nt'.format(fragment_folder, fragment), format='turtle')
        answer = g.serialize(format='nt').decode('utf-8')

        # add fragment data to the data file of each endpoint which holds this fragment
        for endpoint in endpoints:
            outputFilename = '{}/{}.nt'.format(output_folder, endpoint)
            with open(outputFilename, 'a') as writer:
                writer.write(answer)


def main():
    parser = argparse.ArgumentParser(description='Create a new federation by dispatching fragments to endpoints')
    parser.add_argument('-f', '--fragments-folder', type=str, required=True,
                        help='folder containing the SPARQL construct requests which define the fragments')
    parser.add_argument('-t', '--threshold', type=str, required=True,
                        help='maximum number of fragment per endpoint')
    parser.add_argument('-o', '--output-folder', type=str, required=True,
                        help='output folder for the results')
    args = parser.parse_args()

    endpoints = ['endpoint{}'.format(port) for port in range(3030, 3040)]
    fragments = [filename.split('.')[0] for filename in os.listdir(args.fragments_folder)]
    repartition = divideFragments(fragments, endpoints, int(args.threshold))
    createEndpointFile('{}/{}'.format(args.output_folder, FEDRA_ENDPOINTS_FILE), repartition, fragments)
    dispatchFragments(args.fragments_folder, repartition, args.output_folder)

if __name__ == '__main__':
    main()
