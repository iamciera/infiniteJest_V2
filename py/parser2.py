#!/usr/bin/env python
#parser2.py
#Ciera Martinez

import re
import sys	
from collections import Counter

#This sets up output file
orig_stdout = sys.stdout

sampleText = open(sys.argv[1]) #file that contains text
listOfTerms = open(sys.argv[2]) #file that contains terms to search for

sampleRead = sampleText.read() #Makes a one item string
termRead = listOfTerms.read() 

termSplit = termRead.split('\r') #splits term list by carriage return

sampleReadClean = re.sub('[^A-Za-z0-9\s]+', '', sampleRead) #removes symbols

wordData = {}
for word in termSplit:
    wordData[word] = sampleReadClean.count(word) 

print wordData

sampleText.close()
listOfTerms.close()

