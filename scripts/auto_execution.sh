#!/bin/bash
# execute multiple times the setup against a federation
# author : Thomas Minier

FED_SIZE=10
FEDRA_DIR="/home/fedra/fedra/"
SCRIPTS_DIR="${FEDRA_DIR}/scripts/"
PNL_SCRIPTS="/home/fedra/ParallelNestedLoop/scripts/"
SETUP_DIR="${FEDRA_DIR}/data/watDivSetup/"
ENGINE_FILE="outputFedXengineFEDERATION${FED_SIZE}Client"
FEDXFEDRA_FILE="outputFedXFedraFEDERATION${FED_SIZE}Client"
PBJ_FILE="outputFedXFedra-PBJ-hybridFEDERATION${FED_SIZE}Client"
FED_DIR="/home/fedra/fedra/federations/fed${FED_SIZE}e/"
OUTPUT_DIR="/home/fedra/fedra/output/"
NB_EXEC=3

for num in `seq 1 ${NB_EXEC}`; do
  # create results folder
  RES_FOLDER="${OUTPUT_DIR}/fed${FED_SIZE}e/federation${num}/"
  mkdir -p $RES_FOLDER
  mkdir -p $RES_FOLDER/parallelized

  # clean previous results
  cd $SETUP_DIR
  rm -f outputFedX* endpoint*.nt fedraFiles/endpoints

  # copy new federation files
  cd $FED_DIR
  cp federation${num}/* $SETUP_DIR
  cd $SETUP_DIR
  mv endpoints fedraFiles/endpoints

  # run setup
  cd $SCRIPTS_DIR
  ./pbj_script.sh

  # move result files
  cd $SETUP_DIR
  cp $ENGINE_FILE $RES_FOLDER
  cp $FEDXFEDRA_FILE $RES_FOLDER
  cp $PBJ_FILE $RES_FOLDER

  # generate results for parallelized queries
  #cd $PNL_SCRIPTS
  #./identify_parallel.py -n $FED_SIZE -e $RES_FOLDER/$ENGINE_FILE -r $RES_FOLDER/$FEDXFEDRA_FILE -f $RES_FOLDER/$PBJ_FILE -o $RES_FOLDER/parallelized/ > $RES_FOLDER/parallel.log
done

# compute mean of each execution
#RES_FOLDER="${OUTPUT_DIR}/fed${FED_SIZE}e/"
#./compute_mean -f $RES_FOLDER -o $RES_FOLDER -n $NB_EXEC
