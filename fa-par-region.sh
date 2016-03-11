#!/bin/bash

#bash cli.sh -verbose 3 -d examples/FaParRegion.ttl @q examples/q-erdf-1.txt > exec.txt
bash cli.sh -verbose 3 -c examples/FaParRegionSetup/fa-par-region-config.prop @q examples/q-erdf-1.txt > exec.txt