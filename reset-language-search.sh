#!/bin/bash

# This script resets the language search by clearing out the 
# Apache Nutch crawl databases and other stored language 
# search data.

# CONSTANTS
# Below are constants that determine things like where the data is stored.  
# The original values that were used on the cab cluster are shown as examples,
# but you should change these to match your environment/needs.  These should
# be set to the same values as the constants in language-search.sh.  
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
# Seed file containing list of urls (one per line) from which to start the search
SEED_URLS_FILE=/cab1/wmcdowel/muri/Data/NutchCrawl/seed/seed.txt

# END CONSTANTS

# Remove all existing data
rm -rf $LANGUAGE_OUTPUT_DIR/*
rm -rf $NUTCH_VISITED_DIR/*
rm -rf $NUTCH_CRAWL_DIR/*
rm -rf $NUTCH_URLS_DIR/*

# Make first iteration urls list directory, and
# copy seed URLs into it
mkdir $NUTCH_URLS_DIR/0
cp $SEED_URLS_FILE $NUTCH_URLS_DIR/0/0.txt