#!/usr/bin/python
# Script for validating results from Fedra + FedX with and without Parallel Bound Join algorithm
# Authors : Thomas Minier & Naixin Wang
import os
import filecmp

answers_path="/home/fedra/fedra/data/diseasomeSetup/answers/"
answers_pbj_path="/home/fedra/fedra/data/diseasomeSetup/answers_pbj/"

for file in os.listdir(answers_path):
	print "query : " + file + " | result : " + str(filecmp.cmp(answers_path + file, answers_pbj_path + file))
