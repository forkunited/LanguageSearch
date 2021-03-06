# LanguageSearch #

This repository contains scripts used for performing 
a breadth-first search from seed pages using Apache Nutch 
(https://nutch.apache.org), terminating at pages that are 
not written in a pre-specified language according to langid.py 
(https://github.com/saffsd/langid.py).  The scripts at the
root at the repository deal directly with this search,
and the scripts in the *LangIdTrain* directory are used to 
train and evaluate
the langid.py language identification models.

Generally, the scripts in this repository were quickly hacked together
in a disorganized way and using some inefficient methods.  This was done
under the assumption that there was a good chance that 
crawling web pages would not yield much Yoruba data (the language
these scripts were used for).  If it turns out that you want to use the
language searching methods from this project more extensively or at a larger scale
 in the future,
then you might want to just start over and do it better.  For example,
the searching could be performed more efficiently using in-memory 
data-structures
instead of frequently accessing the databases storing the Nutch data on
disk.  Even if you continue to use the currently 
inefficient shell scripts, you might still want to make things more organized
by
merging all of the constant values 
defined across the scripts into a single
file so that you don't have to re-define them separately in each script.

Even if the scripts here are somewhat disorganized 
and inefficient, it shouldn't 
be too hard to get them to work.  At least the 
*language-search.py* and
*reset-language-search.py* scripts that carry out 
the actual language search
should be useful to you if you want to scrape some 
data of a single specified 
language.  On the other hand, if you want to 
re-train the langid.py language
identification model with new languages, then 
you might want to write your
own scripts to do that instead of trying to 
understand the mess of things
in the *LangIdTrain* directory.

