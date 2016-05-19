#!/usr/bin/env bash
# Automaticaly prune queries in order to find 100 parallelized queries
# Author : Thomas Minier

DATA_PATH="${HOME}/fedra/data/watDivSetup/"
REVERSO_PATH="${HOME}/FedraPBJ/sparql-reverso/"
QUERIES_FILE="${DATA_PATH}/queries15_500_100_b"
QUERIES_EXECUTED_FILE="${DATA_PATH}/queriesToExecute_0_bkp"
FEDRA_OUTPUT="${DATA_PATH}/outputFedXFedraFEDERATION10Client"
HYBRID_OUTPUT="${DATA_PATH}/outputFedXFedra-PBJ-hybridFEDERATION10Client"
SETUP_SCRIPT_PATH="${HOME}/fedra/scripts/"

cd $REVERSO_PATH
# init results files
if [ ! -f "identified-queries.txt" ]; then
  touch identified-queries.txt
fi
if [ ! -f "classic-queries.txt" ]; then
  touch classic-queries.txt
fi

lines=`wc -l identified-queries.txt | cut -f1 -d ' '`
nbQueries=`wc -l $QUERIES_FILE | cut -f1 -d ' '`

# while they are'nt enought queries identified
while [ $(($lines)) -lt 100 ]; do
  # clean previous results & execute the setup
  cd $SETUP_SCRIPT_PATH
  rm -f $FEDRA_OUTPUT $HYBRID_OUTPUT
  ./pbj_script.sh > pb_script.log 2> pbj_script.err

  # execute sparql-reverso to prune queries
  cd $REVERSO_PATH
  ./sparql-reverso.py -r $FEDRA_OUTPUT -c $HYBRID_OUTPUT -q $QUERIES_FILE -f $DATA_PATH/fedraFiles/fragments -o $QUERIES_EXECUTED_FILE >> reverso.log

  # recount lines
  lines=`wc -l identified-queries.txt | cut -f1 -d ' '`
  classicLines=`wc -l classic-queries.txt | cut -f1 -d ' '`
  total = $(($lines)) + $(($classicLines))

  # if all the queries have been pruned
  if [ $total -eq  $(($nbQueries))]; then
    echo "no more queries to prune"
    exit 1
  fi
done

echo "Pruning done. Found ${lines} queries"
