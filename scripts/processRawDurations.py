#!/usr/bin/python3
# Process raw outputs from FedX to get the query execution time
# Author : Thomas Minier

import argparse
import os
import re
import csv


def main():
    parser = argparse.ArgumentParser(description='Process raw outputs from FedX to get the query execution time')
    parser.add_argument('-d', '--data-folder', type=str, required=True,
                        help='folder containing the data to process')
    parser.add_argument('-o', '--output-folder', type=str, required=True,
                        help='output folder for the results')
    args = parser.parse_args()

    durations = dict()

    # load duration of each query result
    for filename in os.listdir(args.fragments_folder):
        with open(filename, 'r') as reader:
            line = reader.read()
            duration[filename] = re.search("duration=(.*),", line).group(1)

    # print results in output file
    with open(args.output, 'w', newline='') as csvfile:
        csvwriter = csv.writer(csvfile, delimiter=' ', quotechar='|', quoting=csv.QUOTE_MINIMAL)
        for queryName, duration in durations.items():
            csvwriter.writerow([queryName, duration])

if __name__ == '__main__':
    main()
