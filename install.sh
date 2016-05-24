#!/bin/bash
# Installation script for the Parallel Bound Join algorithm in FedX + FedraPBJ
# author : Thomas Minier

# not engouh parameters
if [ $# -eq 0 ]; then
	echo "Error : you must use as first parameter the directory where FedX is installed."
  echo "Example : ./install.sh ./FedX-3.1"
  exit 1
fi

PROJECT_PATH=`pwd`
FEDX_PATH=$1
ALGEBRA_PATH="${FEDX_PATH}/src/com/fluidops/fedx/algebra"
OPTIMIZER_PATH="${FEDX_PATH}/src/com/fluidops/fedx/optimizer"
EVALUATION_PATH="${FEDX_PATH}/src/com/fluidops/fedx/evaluation/join"

# copy algebra files
cp $PROJECT_PATH/src/FedXStatementPattern.java $ALGEBRA_PATH/FedXStatementPattern.java

# copy optimizer files
cp $PROJECT_PATH/src/FedraSourceSelection.java $OPTIMIZER_PATH/FedraSourceSelection.java
cp $PROJECT_PATH/src/SourceSelection.java $OPTIMIZER_PATH/SourceSelection.java

#copy evaluation files
cp $PROJECT_PATH/src/ParallelFedraPartitioning.java $EVALUATION_PATH/ParallelFedraPartitioning.java
cp $PROJECT_PATH/src/ControlledWorkerBoundJoin.java $EVALUATION_PATH/ControlledWorkerBoundJoin.java

echo "Installation complete"
