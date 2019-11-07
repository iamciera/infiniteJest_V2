#Data File Key

The data files for the text all either came from 1. Scraping a website or 2. from the text itself. 

##booktext

All data files in this directory came from `David-Foster-Wallace-Infinite-Jest-v2.0.pdf` a file that came from the internet somewhere.  Footnotes are the number of the footnote repeated twice.  Like for footnote 64, it will appear as 6464. I have not done anything more with them at this point. 

1. `David-Foster-Wallace-Infinite-Jest-v2.0.pdf` - original file
2. `David-Foster-Wallace-Infinite-Jest-v2.0.txt` - is the .txt version of the original file, cleaned up a bit to remove crazy symbol artifacts from .pdf to .txt conversion.
3. `David-Foster-Wallace-Infinite-Jest-v2.0.chptags.txt` - This is basically the simple text version with manually entered chapter tags.

##Character

1. `characters.full.txt` - full list with all terms used for the characters
2. `characters.mod.txt` - modification to the terms used most often and main characters
3. `characters.scraped.txt` - original version scraped

##Outline

1. `chapters.txt` - Chapter headers
2. `outline.csv` - scraped, needs cleaning

##pyOutputs

These are files that came from a python program.

1. `chapterPosition.txt` - figure this out and re-do
2. `characterPostion.txt` - came from char.parser.py

##sample

These are smaller sample files texts for use when writing programs. 

1. `sampleBookText.txt` - Small portion of beginning `bookText.txt`.