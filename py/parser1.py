#!/usr/bin/env python
#parser1.py This attaches postion number to word from a list of words
#Ciera Martinez

import re
import sys	

#This sets up output file
orig_stdout = sys.stdout
data = open("parserData.txt", 'w')
sys.stdout = data

#prints the headers of columns
print 'position\tterm'

sampleText = open(sys.argv[1]) #file that contains text
listOfTerms = open(sys.argv[2]) #file that contains terms to search for

sampleRead = sampleText.read() #Makes a one item string
termRead = listOfTerms.read() 

sampleReadClean = re.sub('[^A-Za-z0-9\s]+', '', sampleRead) #removes symbols

#splits string into list by word
sampleSplit = sampleReadClean.split() 
termSplit = termRead.split()

for x in termSplit:
	for i, j in enumerate(sampleSplit):
		if j == x:
			print '%i\t%s' % (i, j)

#Outputs print
sys.stdout = orig_stdout

sampleText.close()
listOfTerms.close()
data.close()


