#!/bin/bash

# This script trains a langid.py language identification model
# and evaluates it

# CONSTANTS
# Below are constants that determine things like where the data is stored.  
# The original values that were used on the cab cluster are shown as examples,
# but you should change these to match your environment/needs

# Directory containing evaluation script (and probably the present script)
SCRIPT_DIR=/home/wmcdowel/muri/Projects/LanguageSearch/LangIdTrain
# Path to training data directory
TRAINING_DATA_DIR=/cab1/wmcdowel/muri/Data/LangId/train/merged/training
# Path to evaluation data directory
EVALUATION_DATA_DIR=/cab1/wmcdowel/muri/Data/LangId/train/merged/evaluation
# Path to langid.py script
LANGID_DIR=/home/wmcdowel/muri/Projects/LanguageSearch/langid.py
# Path to langid.py trained model
MODEL=/cab1/wmcdowel/muri/Data/LangId/model
# Path to langid.py features
FEATURES=/cab1/wmcdowel/muri/Data/LangId/features
# Evaluation script that came with naacl2010-langid data from Tim Baldwin
EVALUATION_CMD=/cab1/wmcdowel/muri/Data/LangId/train/naacl2010-langid/eval.py

# END CONSTANTS

# Train model
python $LANGID_DIR/LDfeatureselect.py -c $TRAINING_DATA_DIR -o $FEATURES
python $LANGID_DIR/train.py -c $TRAINING_DATA_DIR -o $MODEL -i $FEATURES

# Evaluate using evaluation script
$SCRIPT_DIR/evaluate.sh > $SCRIPT_DIR/evaluationResults.txt
