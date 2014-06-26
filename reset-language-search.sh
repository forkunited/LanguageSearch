#!/bin/bash

rm -rf /cab1/wmcdowel/muri/Data/LanguageSearch/*
rm -rf /cab1/wmcdowel/muri/Data/NutchCrawl/visited/*
rm -rf /cab1/wmcdowel/muri/Data/NutchCrawl/crawl/*
rm -rf /cab1/wmcdowel/muri/Data/NutchCrawl/urls/*

mkdir /cab1/wmcdowel/muri/Data/NutchCrawl/urls/0
cp /cab1/wmcdowel/muri/Data/NutchCrawl/seed/seed.txt /cab1/wmcdowel/muri/Data/NutchCrawl/urls/0/0.txt