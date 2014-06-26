#!/bin/bash

DATA_DIR=/cab1/wmcdowel/muri/Data/LangId/train/merged
LANGID_DIR=/home/wmcdowel/muri/Projects/LanguageSearch/langid.py
MODEL=/cab1/wmcdowel/muri/Data/LangId/model
FEATURES=/cab1/wmcdowel/muri/Data/LangId/features
EVALUATION_SCRIPT=/cab1/wmcdowel/muri/Data/LangId/train/naacl2010-langid/eval.py


#rm -f $DATA_DIR/*/*.predictions

#for filePath in $DATA_DIR/?*/?*/?*/?*
#do
#    fileName=`basename $filePath`
#    fileDomain=`basename $(dirname $(dirname $filePath))`
#    fileDataSet=`basename $(dirname $(dirname $(dirname $filePath)))`

#    if [ -z $fileDomain ]; then
#	continue
#    fi

#    echo 'Making language prediction for '$fileName' in '$fileDomain' of '$fileDataSet

#    fileModelOutput=`python $LANGID_DIR/langid.py -m $MODEL < $filePath`
#    fileLanguage=`echo $fileModelOutput | sed -n "s/.*'\(.*\)'.*/\1/p"`
    
#    echo $fileName$'\t'$fileLanguage >> $DATA_DIR/$fileDataSet/$fileDomain.predictions
#done

for goldFilePath in $DATA_DIR/*/*.meta
do
    domain=`basename $goldFilePath .meta`
    fileDataSet=`basename $(dirname $goldFilePath)`
    predictionFilePath=$DATA_DIR/$fileDataSet/$domain.predictions

    echo 'Evaluation for '$fileDataSet' data on '$domain'...'
    python $EVALUATION_SCRIPT -g $goldFilePath -c $predictionFilePath
done
