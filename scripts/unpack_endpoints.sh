#!/bin/bash
fs="diseasomeSetup  geoCoordinatesSetup  linkedMDBSetup  swdfSetup  watDiv100Setup  watDivSetup"
for i in `seq 3030 3039`; do
    for f in $fs; do
        ./hdt2rdf.sh /home/fedra/fedra/data/$f/endpoint$i.hdt /home/fedra/fedra/data/$f/endpoint$i.nt
    done
 done
