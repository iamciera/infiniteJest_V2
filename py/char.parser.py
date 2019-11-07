#!/usr/bin/env python
#char.parser.py 
#Ciera Martinez

#This script takes in two arguments
#1. text file (sampleText)
#2. List of terms to seach text file (listOfTerms)
# and then prints all terms and their postion in text file
# outputs results into ./data directory "charList.txt" 

#sample command to run (for infinite jest project)
#python py/char.parser.py data/bookText/David-Foster-Wallace-Infinite-Jest-v2.0.txt data/character/characters.mod.txt

import re
import sys	

#This sets up output file
orig_stdout = sys.stdout
data = open("./data/pyOutputs/characterPosition.txt", 'w')
sys.stdout = data

#prints the headers of columns
print 'term\tposition'

sampleText = open(sys.argv[1]) #file that contains text
listOfTerms = open(sys.argv[2]) #file that contains terms to search for

sampleRead = sampleText.read() #Makes one item string
termRead = listOfTerms.read() 

termSplit = termRead.split("\r") #split by new line

for term in termSplit:
	for m in re.finditer(term, sampleRead):
		print m.group(0), "\t", m.start()

#Outputs print
sys.stdout = orig_stdout

sampleText.close()
listOfTerms.close()
data.close()
