#!/bin/bash
# generate jetty config for endpoints in a federation
# author : Thomas Minier

FEDERATION_SIZE=$1
MAX_ENDPOINT=$((3030 + $FEDERATION_SIZE - 1))
MIN_THREAD=$2
MAX_THREAD=$3

if [$# -ne 3]; then
    echo "illegal number of parameters\nUsage : ./generate-jetty-config.sh federation_size min_thread max_thread"
fi

cd /home/fedra/logiciels/jena-fuseki-1.1.1/config
for num in `seq 3030 ${MAX_ENDPOINT}`; do
    sed -e "s/FUSEKIPORT/${num}/g" -e "s/MINTHREAD/${MIN_THREAD}/g" -e "s/MAXTHREAD/${MAX_THREAD}/g" jetty-config.xml > config-endpoint${num}.xml
done
