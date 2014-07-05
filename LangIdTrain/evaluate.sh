#!/bin/bash

# This script uses a specified langid.py model to make 
# language identification predictions on a directory
# of data, and then evaluates those predictions using
# the evaluation script that came with the original 
# naacl2010-langid data from Tim Baldwin.

# CONSTANTS
# Below are constants that determine things like where the data is stored.  
# The original values that were used on the cab cluster are shown as examples,
# but you should change these to match your environment/needs

# Directory containing evaluation data merged from various sources into sub-directories
DATA_DIR=/cab1/wmcdowel/muri/Data/LangId/train/merged
# Directory containing langid.py script to run langid.py model
LANGID_DIR=/home/wmcdowel/muri/Projects/LanguageSearch/langid.py
# Language identification model to evaluate
MODEL=/cab1/wmcdowel/muri/Data/LangId/model
# Language identification model features
FEATURES=/cab1/wmcdowel/muri/Data/LangId/features
# Evaluation script that came with naacl2010-langid data from Tim Baldwin
EVALUATION_SCRIPT=/cab1/wmcdowel/muri/Data/LangId/train/naacl2010-langid/eval.py

# END CONSTANTS

# Remove old prediction data 
rm -f $DATA_DIR/*/*.predictions

# Run model to make predictions for data set 
for filePath in $DATA_DIR/?*/?*/?*/?*
do
    fileName=`basename $filePath`
    fileDomain=`basename $(dirname $(dirname $filePath))`
    fileDataSet=`basename $(dirname $(dirname $(dirname $filePath)))`

    if [ -z $fileDomain ]; then
		continue
    fi

    echo 'Making language prediction for '$fileName' in '$fileDomain' of '$fileDataSet

    fileModelOutput=`python $LANGID_DIR/langid.py -m $MODEL < $filePath`
    fileLanguage=`echo $fileModelOutput | sed -n "s/.*'\(.*\)'.*/\1/p"`
    
    echo $fileName$'\t'$fileLanguage >> $DATA_DIR/$fileDataSet/$fileDomain.predictions
done

# Run evaluation script on predictions 
for goldFilePath in $DATA_DIR/*/*.meta
do
    domain=`basename $goldFilePath .meta`
    fileDataSet=`basename $(dirname $goldFilePath)`
    predictionFilePath=$DATA_DIR/$fileDataSet/$domain.predictions

    echo 'Evaluation for '$fileDataSet' data on '$domain'...'
    python $EVALUATION_SCRIPT -g $goldFilePath -c $predictionFilePath
done
