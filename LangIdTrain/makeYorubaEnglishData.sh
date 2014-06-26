#!/bin/bash

ENGLISH_SOURCE=/cab1/wmcdowel/muri/Data/LCTL_Yoruba_v0.5/Parallel_Text/Train/Translations/From_English/English/ltf
YORUBA_SOURCE=/cab1/wmcdowel/muri/Data/LCTL_Yoruba_v0.5/Parallel_Text/Train/Translations/From_English/Yoruba/ltf

ENGLISH_TARGET=/cab1/wmcdowel/muri/Data/LangId/train/LCTL_Yoruba_v0.5/en
YORUBA_TARGET=/cab1/wmcdowel/muri/Data/LangId/train/LCTL_Yoruba_v0.5/yo

echo "Making Yoruba data in "$YORUBA_TARGET
for filePath in $YORUBA_SOURCE/*
do
    fileName=`basename $filePath`
    echo $YORUBA_TARGET/$fileName
    sed -n 's/<ORIGINAL_TEXT>\(.*\)<\/ORIGINAL_TEXT>/\1/p' $filePath > $YORUBA_TARGET/$fileName
done

echo "Making English data in "$ENGLISH_TARGET
for filePath in $ENGLISH_SOURCE/*
do
    fileName=`basename $filePath`
    echo $ENGLISH_TARGET/$fileName
    sed -n 's/<ORIGINAL_TEXT>\(.*\)<\/ORIGINAL_TEXT>/\1/p' $filePath > $ENGLISH_TARGET/$fileName
done
