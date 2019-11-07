#!/usr/bin/env python
#chp3.py
#Ciera Martinez

#arguments 
#1. a file that containts text to search

import re
import sys	

#This sets up output file
orig_stdout = sys.stdout
data = open("./data/pyOutputs/chapterPosition.txt", 'w')
sys.stdout = data

#prints the headers of columns
print 'chapter\tposition'

sampleText = open(sys.argv[1]) #file that contains text
sampleRead = sampleText.read() #Makes one item string

#for everytime the chapter tag is found, it will print tag and position
for m in re.finditer("<ch><\d\d>", sampleRead):
	print m.group(0), "\t", m.start()

#Outputs print
sys.stdout = orig_stdout

sampleText.close()
data.close()



