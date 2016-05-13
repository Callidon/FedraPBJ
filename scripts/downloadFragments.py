#!/usr/bin/python3
# Download data from fragments
# Author : Thomas Minier

import os
import argparse
import subprocess


def main():
    parser = argparse.ArgumentParser(description='Download data from fragments of a dataset')
    parser.add_argument('-f', '--fragments-folder', type=str, required=True,
                        help='folder containing the SPARQL construct requests which define the fragments')
    parser.add_argument('-e', '--endpoint', type=str, required=True,
                        help='address of the endpoint which holds the data to dispatch')
    parser.add_argument('-o', '--output-folder', type=str, required=True,
                        help='output folder for the results')
    args = parser.parse_args()

    fragments = [filename for filename in os.listdir(args.fragments_folder)]
    for fragment in fragments:
        p = subprocess.Popen('ldf-client {} -f {}/{}'.format(args.endpoint, args.fragments_folder, fragment),
                             stdout=subprocess.PIPE, shell=True)
        (data, err) = p.communicate()
        answer = data.decode('utf-8')
        with open('{}/{}.ttl'.format(args.output_folder, fragment), 'w') as writer:
            writer.write(answer)

if __name__ == '__main__':
    main()
