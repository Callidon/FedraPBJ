#!/bin/bash
# Script to deploy fedx files to the server

scp src/com/fluidops/fedx/evaluation/join/ControlledWorkerBoundJoin.java src/com/fluidops/fedx/evaluation/join/ParallelFedraPartitioning.java \
    fedra@172.16.9.3:fedXModif_2016/src/com/fluidops/fedx/evaluation/join/

scp src/com/fluidops/fedx/optimizer/FedraSourceSelection.java \
    fedra@172.16.9.3:fedXModif_2016/src/com/fluidops/fedx/optimizer/