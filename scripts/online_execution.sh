#!/usr/bin/env bash
# Execute experiment against an online federation
# Author : Thomas Minier

DATA_PATH="/home/fedra/fedra/data/watDivSetup/"
CLI_PATH="/home/fedra/fedXModif_2016/"
CONFIG_FILE="${DATA_PATH}/confFileWatDiv" # /home/fedra/fedra/data/watDivSetup/confFileWatDiv
FEDERATION_FILE="${DATA_PATH}/federation_online.ttl" # /home/fedra/fedra/data/watDivSetup/federation.ttl
QUERIES_FILE="${DATA_PATH}/queries15_500_100_b"
QUERIES_TO_EXECUTE_FILE="${DATA_PATH}/queriesToExecute_0_bkp"
RESULTS_FOLDER="${DATA_PATH}/results"

# for each query
while IFS='' read -r line || [[ -n "$line" ]]; do
  cd $DATA_PATH
  # get query in temp file
  queryFile=`mktemp`
  sed "${line}q;d" $QUERIES_FILE > $queryFile

  # execute query
  cd $CLI_PATH
  # resultFile="${RESULTS_FOLDER}/query${line}"
  java -Xmx1024m -cp bin:lib/* com.fluidops.fedx.CLI -c $CONFIG_FILE -d $FEDERATION_FILE -f JSON -folder $RESULTS_FOLDER @q $queryFile
done < "${QUERIES_TO_EXECUTE_FILE}"
