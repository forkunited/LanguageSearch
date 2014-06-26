#!/bin/bash

SCRIPT_DIR=/home/wmcdowel/muri/Projects/LanguageSearch/LangIdTrain
TRAINING_DATA_DIR=/cab1/wmcdowel/muri/Data/LangId/train/merged/training
EVALUATION_DATA_DIR=/cab1/wmcdowel/muri/Data/LangId/train/merged/evaluation
LANGID_DIR=/home/wmcdowel/muri/Projects/LanguageSearch/langid.py
MODEL=/cab1/wmcdowel/muri/Data/LangId/model
FEATURES=/cab1/wmcdowel/muri/Data/LangId/features
EVALUATION_CMD=/cab1/wmcdowel/muri/Data/LangId/train/naacl2010-langid/eval.py

python $LANGID_DIR/LDfeatureselect.py -c $TRAINING_DATA_DIR -o $FEATURES
python $LANGID_DIR/train.py -c $TRAINING_DATA_DIR -o $MODEL -i $FEATURES

#$SCRIPT_DIR/evaluate.sh > $SCRIPT_DIR/evaluationResults.txt
