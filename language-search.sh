#!/bin/bash

# This script performs a single crawling iteration using Apache Nutch,
# checking the scraped web-page data to see if it is in the specified 
# language (e.g. Yoruba) using a langid.py language identification 
# model.  The scraped data is stored in directories that correspond to
# whether or not it is in the specified language.  URLs of pages in the
# specified language are saved as the starting point for the next 
# iteration of this script.

# This process can become much more efficient if it is completed directly through
# Java (or just using in-memory instead of on-disk data scructures to keep
# track of the data) rather than this shell script, but the shell script should 
# work for now. 

# CONSTANTS
# Below are constants that determine things like where the data is stored.  
# The original values that were used on the cab cluster are shown as examples,
# but you should change these to match your environment/needs

# langid.py identified language for which to search
LANGUAGE=yo 
# Path to directory in which to store final web-page data categorized by whether
# it is of the specified language or not
LANGUAGE_OUTPUT_DIR=/cab1/wmcdowel/muri/Data/LanguageSearch
# Path to the langid.py script used to run the langid.py model
LANGID_CMD=/home/wmcdowel/muri/Projects/LanguageSearch/langid.py/langid/langid.py
# Path to the langid.py language identification model
LANGID_MODEL=/cab1/wmcdowel/muri/Data/LangId/model
# Path to the Apache nutch command used to crawl webpages
NUTCH_CMD=/home/wmcdowel/muri/Projects/LanguageSearch/apache-nutch-1.8/bin/nutch
# Path to the Nutch db in which to store all visited webpages
NUTCH_VISITED_DIR=/cab1/wmcdowel/muri/Data/NutchCrawl/visited
# Path to directory in which to store Nutch dbs for each crawl iteration
NUTCH_CRAWL_DIR=/cab1/wmcdowel/muri/Data/NutchCrawl/crawl
# Directory in which to store URLs from which to search on future iterations
NUTCH_URLS_DIR=/cab1/wmcdowel/muri/Data/NutchCrawl/urls

# END CONSTANTS

# Find the current crawl iteration by looking through directory of
# past reached urls, organized by past iteration
crawlIter=0
for dirPath in $NUTCH_URLS_DIR/*
do
	dirPathIter=`basename $dirPath` 
	crawlIter=$(($dirPathIter>$crawlIter?$dirPathIter:$crawlIter))
done


# Set this iteration urls directory and crawl data (nutch) directory
iterUrlsDir=$NUTCH_URLS_DIR/$crawlIter
iterCrawlDataDir=$NUTCH_CRAWL_DIR/$crawlIter
mkdir $iterCrawlDataDir


# Run nutch for this iteration
echo "Iteration ${crawlIter}: Nutch injecting urls into crawl db..."
$NUTCH_CMD inject $iterCrawlDataDir/crawlDb $iterUrlsDir

echo "Iteration ${crawlIter}: Nutch generating a fetch list in segments directory..."
$NUTCH_CMD generate $iterCrawlDataDir/crawlDb $iterCrawlDataDir/segments
s1=`ls -d $iterCrawlDataDir/segments/2* | tail -1`
echo "Segment generated for ${s1}"

echo "Iteration ${crawlIter}: Nutch running fetcher on segment..."
$NUTCH_CMD fetch $s1

echo "Iteration ${crawlIter}: Nutch parsing entries..."
$NUTCH_CMD parse $s1

echo "Iteration ${crawlIter}: Nutch updating database with fetch results..."
$NUTCH_CMD updatedb $iterCrawlDataDir/crawlDb $s1

echo "Iteration ${crawlIter}: Nutch invert links so that incoming anchor links can be indexed with pages... (this probably is not actually necessary.)"
$NUTCH_CMD invertlinks $iterCrawlDataDir/linkDb -dir $iterCrawlDataDir/segments

echo "Iteration ${crawlIter}: Nutch deduping data..."
$NUTCH_CMD dedup $iterCrawlDataDir/crawlDb


# Inject this iteration's urls into 'visited' nutch crawl db
echo "Iteration ${crawlIter}: Nutch injecting urls into visited db..."
$NUTCH_CMD inject $NUTCH_VISITED_DIR/crawlDb $iterUrlsDir


# Iterate over this iteration's urls, deciding whether their contents are of the specified language
neighborUrls=''
while read iterUrlLine; do
    # Get full text summary for this url's result
    iterUrlResult=`$NUTCH_CMD readseg -get $s1 $iterUrlLine`
    
    # Get text content from this url's result (after 'ParseText::')
    iterUrlTextContent=`echo $iterUrlResult | sed -e 's#.*ParseText::\(\)#\1#'`
    
    # Check to see if text content is in specified language
    iterLanguage=`echo $iterUrlTextContent | $LANGID_CMD -m $LANGID_MODEL`
    iterLanguageSpecified=`echo $iterLanguage | grep $LANGUAGE`
    iterLanguageDist=`echo $iterUrlTextContent | $LANGID_CMD -d -n -m $LANGID_MODEL`

    if [[ -z $iterLanguageSpecified ]];
	then
		# Text is not of the specified language
        # Save non-specified language text to non-specified language directory	
		echo "Iteration ${crawlIter}: Outputting non-${LANGUAGE} data to ${LANGUAGE_OUTPUT_DIR}/other/${iterUrlLine}"
		mkdir -p $LANGUAGE_OUTPUT_DIR/other/$iterUrlLine
		echo $iterUrlResult > $LANGUAGE_OUTPUT_DIR/other/$iterUrlLine/info
		echo $iterUrlTextContent > $LANGUAGE_OUTPUT_DIR/other/$iterUrlLine/text
		echo $iterLanguageDist > $LANGUAGE_OUTPUT_DIR/other/$iterUrlLine/dist

		continue
    else
		# Text is of the specified language
        # Save specified language text content to specified language directory
		echo "Iteration ${crawlIter}: Outputting ${LANGUAGE} data to ${LANGUAGE_OUTPUT_DIR}/${LANGUAGE}/${iterUrlLine}"
		mkdir -p $LANGUAGE_OUTPUT_DIR/$LANGUAGE/$iterUrlLine
		echo $iterUrlResult > $LANGUAGE_OUTPUT_DIR/$LANGUAGE/$iterUrlLine/info
		echo $iterUrlTextContent > $LANGUAGE_OUTPUT_DIR/$LANGUAGE/$iterUrlLine/text
		echo $iterLanguageDist > $LANGUAGE_OUTPUT_DIR/$LANGUAGE/$iterUrlLine/dist
    fi


    # If in specified language, get neighbors (out-links) from this url
    # Put all non-visited outlink in next URLS file
    while read -r neighborUrlLine; do
		neighborUrl=`echo $neighborUrlLine | sed -n 's/outlink: toUrl: \(.*\) anchor: .*/\1/p'`
		if [[  -z $neighborUrl ]];
			then 
			continue
		fi

		neighborUrlVisited=`$NUTCH_CMD readdb $NUTCH_VISITED_DIR/crawlDb -url $neighborUrl`
		neighborUrlVisited=`echo $neighborUrlVisited | grep 'not found'`
		if [[ -z $neighborUrlVisited ]];
			then
			continue
		fi

		echo "Iteration ${crawlIter}: Appending ${neighborUrl} to next iteration urls to search"
		neighborUrls=$neighborUrls$'\n'$neighborUrl
	done <<< "$iterUrlResult"
done < $iterUrlsDir/${crawlIter}.txt


# Create next iteration urls file
neighborUrlsFile=$NUTCH_URLS_DIR/$((crawlIter+1))/$((crawlIter+1)).txt
echo "Iteration ${crawlIter}: Outputting next urls to ${neighborUrlsFile}"
mkdir $NUTCH_URLS_DIR/$((crawlIter+1))
echo "$neighborUrls" > $neighborUrlsFile
