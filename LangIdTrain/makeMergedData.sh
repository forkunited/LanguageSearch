#!/bin/bash

# IJCNLP2011 data is also available, but not currently included. 
# There is acquis, debian, and wikiraw, but they are all in different
# formats. And so it didn't seem like it was worth the time to
# merge them all into the right format.  Can do later if seems like
# a good thing to do.

# Source data directories
#IJCNLP2011_DIR=/cab1/wmcdowel/muri/Data/LangId/train/ijcnlp2011-langid/
NAACL2010_DIR=/cab1/wmcdowel/muri/Data/LangId/train/naacl2010-langid
LCTL_YORUBA_PARALLEL_DIR=/cab1/wmcdowel/muri/Data/LangId/train/LCTL_Yoruba_v0.5/Parallel_Text
LCTL_YORUBA_MONO_DIR=/cab1/wmcdowel/muri/Data/LangId/train/LCTL_Yoruba_v0.5/Monolingual_Text

# Output merged data directory
OUTPUT_DIR=/cab1/wmcdowel/muri/Data/LangId/train/merged

# Can't do IJCNLP2011 with this array because all these are in different
# formats
#IJCNLP2011_DOMAINS=( "acquis3-10k-v2" "debian-unstable-po-v2" "wikiraw" )
NAACL2010_DOMAINS=( "EuroGOV" "TCL" "Wikipedia" )

rm -rf $OUTPUT_DIR/*
mkdir $OUTPUT_DIR/evaluation
mkdir $OUTPUT_DIR/training

# Output naacl2010 data
for domain in "${NAACL2010_DOMAINS[@]}"
do
    names=(`cut -f1 $NAACL2010_DIR/$domain.meta`)
    encodings=(`cut -f2 $NAACL2010_DIR/$domain.meta`)
    languages=(`cut -f3 $NAACL2010_DIR/$domain.meta`)
    folds=(`cut -f4 $NAACL2010_DIR/$domain.meta`)    

    touch $OUTPUT_DIR/evaluation/naacl2010-$domain.meta
    touch $OUTPUT_DIR/training/naacl2010-$domain.meta

    for i in "${!folds[@]}"; do 
	echo "Making "${languages[$i]}" data in "$OUTPUT_DIR" for "$domain
	fold=`echo ${folds[$i]} | sed -e 's/^[\r\n\t ]*//' -e 's/[\n\r\t ]*$//'`
	if [ $fold -eq 0 ]; then
	    mkdir -p $OUTPUT_DIR/evaluation/naacl2010-$domain/${languages[$i]}
	    cp $NAACL2010_DIR/$domain/${names[$i]} $OUTPUT_DIR/evaluation/naacl2010-$domain/${languages[$i]}/${names[$i]}
	    echo ${names[$i]}$'\t'${encodings[$i]}$'\t'${languages[$i]}$'\t'${folds[$i]} >> $OUTPUT_DIR/evaluation/naacl2010-$domain.meta
	else
	    mkdir -p $OUTPUT_DIR/training/naacl2010-$domain/${languages[$i]}
	    cp $NAACL2010_DIR/$domain/${names[$i]} $OUTPUT_DIR/training/naacl2010-$domain/${languages[$i]}/${names[$i]}
   	    echo ${names[$i]}$'\t'${encodings[$i]}$'\t'${languages[$i]}$'\t'${folds[$i]} >> $OUTPUT_DIR/training/naacl2010-$domain.meta
	fi
    done
done

# Ouput LCTL_Yoruba parallel data
mkdir $OUTPUT_DIR/training/LCTL_Yoruba-parallel
mkdir $OUTPUT_DIR/evaluation/LCTL_Yoruba-parallel
mkdir $OUTPUT_DIR/training/LCTL_Yoruba-parallel/yo
mkdir $OUTPUT_DIR/evaluation/LCTL_Yoruba-parallel/yo
mkdir $OUTPUT_DIR/training/LCTL_Yoruba-parallel/en
mkdir $OUTPUT_DIR/evaluation/LCTL_Yoruba-parallel/en

touch $OUTPUT_DIR/evaluation/LCTL_Yoruba-parallel.meta
touch $OUTPUT_DIR/training/LCTL_Yoruba-parallel.meta

i=0
for filePath in $LCTL_YORUBA_PARALLEL_DIR/*/Translations/From_English/Yoruba/ltf/*
do
    echo "Making yo data in "$OUTPUT_DIR" for LCTL_Yoruba-parallel"

    fileName=`basename $filePath`

    if [ $(($i%10)) == '0' ]
    then
	sed -n 's/<ORIGINAL_TEXT>\(.*\)<\/ORIGINAL_TEXT>/\1/p' $filePath > $OUTPUT_DIR/evaluation/LCTL_Yoruba-parallel/yo/$fileName
	echo $fileName$'\tutf-8\tyo\t'$((i%10)) >> $OUTPUT_DIR/evaluation/LCTL_Yoruba-parallel.meta
    else
	sed -n 's/<ORIGINAL_TEXT>\(.*\)<\/ORIGINAL_TEXT>/\1/p' $filePath > $OUTPUT_DIR/training/LCTL_Yoruba-parallel/yo/$fileName
	echo $fileName$'\tutf-8\tyo\t'$((i%10)) >> $OUTPUT_DIR/training/LCTL_Yoruba-parallel.meta
    fi

    ((i++))
done

i=0
for filePath in $LCTL_YORUBA_PARALLEL_DIR/*/Translations/From_English/English/ltf/*
do
    echo "Making en data in "$OUTPUT_DIR" for LCTL_Yoruba-parallel"

    fileName=`basename $filePath`

    if [ $(($i%10)) == '0' ]
    then
	sed -n 's/<ORIGINAL_TEXT>\(.*\)<\/ORIGINAL_TEXT>/\1/p' $filePath > $OUTPUT_DIR/evaluation/LCTL_Yoruba-parallel/en/$fileName
	echo $fileName$'\tutf-8\ten\t'$((i%10)) >> $OUTPUT_DIR/evaluation/LCTL_Yoruba-parallel.meta
    else
	sed -n 's/<ORIGINAL_TEXT>\(.*\)<\/ORIGINAL_TEXT>/\1/p' $filePath > $OUTPUT_DIR/training/LCTL_Yoruba-parallel/en/$fileName
	echo $fileName$'\tutf-8\ten\t'$((i%10)) >> $OUTPUT_DIR/training/LCTL_Yoruba-parallel.meta
    fi

    ((i++))
done

# Ouput LCTL_Yoruba monolingual data
mkdir $OUTPUT_DIR/training/LCTL_Yoruba-mono
mkdir $OUTPUT_DIR/evaluation/LCTL_Yoruba-mono
mkdir $OUTPUT_DIR/training/LCTL_Yoruba-mono/yo
mkdir $OUTPUT_DIR/evaluation/LCTL_Yoruba-mono/yo

touch $OUTPUT_DIR/evaluation/LCTL_Yoruba-mono.meta
touch $OUTPUT_DIR/training/LCTL_Yoruba-mono.meta

i=0
for filePath in $LCTL_YORUBA_MONO_DIR/*/txt/*
do
    echo "Making yo data in "$OUTPUT_DIR" for LCTL_Yoruba-mono"

    fileName=`basename $filePath`

    if [ $(($i%10)) == '0' ]
    then
	cp $filePath $OUTPUT_DIR/evaluation/LCTL_Yoruba-mono/yo/$fileName
	echo $fileName$'\tutf-8\tyo\t'$((i%10)) >> $OUTPUT_DIR/evaluation/LCTL_Yoruba-mono.meta
    else
	cp $filePath $OUTPUT_DIR/training/LCTL_Yoruba-mono/yo/$fileName
	echo $fileName$'\tutf-8\tyo\t'$((i%10)) >> $OUTPUT_DIR/training/LCTL_Yoruba-mono.meta
    fi

    ((i++))
done
