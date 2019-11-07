#infinitejestggplot.r
#Author: Ciera Martinez
#Plot character occurance by postion in book.
#There are two dataframes used to make this visualization, 
#1. Chapter Position (used to delinate chapter structuring)
#2. Character Postion 

#Required Libraries
library(ggplot2)
library(dplyr)
library(scales)
library(data.table)
library(tidyverse)
library(igraph)

#1. Chapter Position
# read in ch.parser.py output
chapPos <- read_csv("../data/pyOutputs/chapterPosition.csv")
tail(chapPos)
dim(chapPos)
chapPos[65,1] <- "endnotes" #rename endnotes (last row)

#need to clean up position
chapPos$chapter <- gsub("<", "", chapPos$chapter)
chapPos$chapter <- gsub(">", "", chapPos$chapter)
chapPos$chapter <- gsub(" ", "", chapPos$chapter)

# To get chapter range
# make new vector independently of chapPos dataframe

# Essentially removing first instance in vector and replacing last
# instance with NA, so row #'s stays the same. 
# (to-do re-do with loop)
pos2 <- (chapPos$position - 1)
pos2 <- pos2[-1] 
pos2[65] <- NA #add a NA at the end so vector is length of chapPos rows
chapPos$position2 <- pos2 #bring back

#2. Character Postion 
#To get characterPosition.txt I ran ch.parser.py
charPos <- read_csv("../data/pyOutputs/characterPosition.csv")

#first deal with endnotes
chapPos[65,3] <- max(charPos$position)

#length column
chapPos$length <- (chapPos$position2 - chapPos$position)

#Now add a chapter column to specify where is each character position
charPos <- transform(charPos, 
                 chapter = chapPos$chapter[
                   findInterval(position, 
                                chapPos$position)])


## data summary
str(charPos)
dim(charPos)
head(charPos)
head(chapPos)

#########################
## Distance matrix
## Using only charPos
### Part 1: playing
############################

## Number of times a character is mention
charPos %>% 
  group_by(chapter, term) %>%
  tally() %>%
  ggplot(., aes(chapter, n)) +
    geom_bar(stat = "identity") +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) 

## Number of times a character is mentioned
charPos %>% 
  filter() %>%
  group_by(chapter, term) %>%
  tally() %>%
  ggplot(., aes(chapter, n)) +
  geom_bar(stat = "identity") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) 

## Only certain characters
charPos %>% 
  filter() %>%
  group_by(chapter, term) %>%
  tally() %>%
  filter(term == "Hal" | term == "Gately") %>%
  ggplot(., aes(chapter, n, fill = term)) +
  geom_bar(stat = "identity") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

## Chapter length
chapPos %>%
  ggplot(., aes(chapter, (length/100))) +
           geom_bar(stat = "identity") +
           theme_bw() +
           theme(axis.text.x = element_text(angle = 90, hjust = 1))

############################
## Building edge lists
###########################

df <- charPos %>% 
  group_by(chapter, term) %>%
  select(-one_of("position")) %>%
  distinct() 

## All this to get groups of terms
df$ID <- 1:nrow(df)  #unique variable

## Basically makes a list of which characters are in 
## each chapter
lst <- df %>%
  spread(chapter,term) %>%
  select(-ID) %>% 
  as.list() 

## gets rid of all NAs
lst <- lapply(lst,function(x)x[!is.na(x)])

lst <- lst %>%
  lapply(function(x) {
    expand.grid(x, x, w = 1, stringsAsFactors = FALSE)}) %>%
    bind_rows

# Most characters have only one chapter that they share
lst %>% 
  group_by(Var1, Var2) %>%
  tally() %>%
  ggplot(., aes(n)) +
  geom_bar() +
  theme_bw()

## Find co-occurnace
lst <- apply(lst[, -3], 1, str_sort) %>%
  t %>%
  data.frame(stringsAsFactors = FALSE) %>%
  mutate(w = lst$w)

## need to add up how many of each time a character 
## is in the same chapter.
edges <- group_by(lst, X1, X2) %>%
  tally(sort = TRUE) %>%
  filter(X1 != X2) 

colnames(edges) <- c("from", "to", "weight")

head(edges, 40)

##########################################
### Igraph formatting for visualization 
#########################################

## You could add character groupings here
nodes <- charPos %>%
  select(-one_of(c("position", "chapter"))) %>%
  distinct(term)

## What I have so far
head(edges)
head(nodes)

##  [ ] missing net, what happened here.
net_if <- graph_from_data_frame(d = edges, vertices = nodes, directed = T) 
netm_if <- get.adjacency(net, attr = "weight", sparse = F)

class(net)

## Heatmap, which is useless
palf <- colorRampPalette(c("gold", "dark orange")) 
heatmap(netm_if[,17:1], Rowv = NA, Colv = NA, col = palf(100), 
        scale="none", margins=c(10,10) )


# Calculate various network properties, adding them as attributes
# to each node/vertex
# V(graph)$comm <- membership(optimal.community(graph))
# V(graph)$degree <- degree(graph)
# V(graph)$closeness <- centralization.closeness(graph)$res
# V(graph)$betweenness <- centralization.betweenness(graph)$res
# V(graph)$eigen <- centralization.evcent(graph)$vector

# Re-generate dataframes for both nodes and edges, now containing
# calculated network attributes
node_list <- get.data.frame(graph, what = "vertices")

edge_list <- get.data.frame(graph, what = "edges") %>%
  inner_join(node_list %>% select(name, comm), by = c("from" = "name")) %>%
  inner_join(node_list %>% select(name, comm), by = c("to" = "name"))

head(edge_list)

all_nodes <- sort(node_list$name)

# Adjust the 'to' and 'from' factor levels so they are equal
# to this complete list of node names
plot_data <- edge_list %>% mutate(
  to = factor(to, levels = all_nodes),
  from = factor(from, levels = all_nodes))

ggplot(plot_data, aes(x = from, y = to)) +
  geom_raster() +
  theme_bw() +
  # Because we need the x and y axis to display every node,
  # not just the nodes that have connections to each other,
  # make sure that ggplot does not drop unused factor levels
  scale_x_discrete(drop = FALSE) +
  scale_y_discrete(drop = FALSE) +
  theme(
    # Rotate the x-axis lables so they are legible
    axis.text.x = element_text(angle = 270, hjust = 0),
    # Force the plot into a square aspect ratio
    aspect.ratio = 1,
    # Hide the legend (optional)
    legend.position = "none")

########################
## Occurance Visualization
#######################

#Visualization 1
#Quickly just get a sense for how many times a character is mentioned

ggplot(charPos, aes(reorder_size(term))) +
  geom_bar(stat = "count") +
  coord_flip() +
  theme_bw() +
  theme(text = element_text(),
        axis.text.x = element_text(angle = 90, 
                                   vjust = 1)) 


reorder_size <- function(x) {
  factor(x, levels = names(sort(table(x))))
}

ggplot() + 
  geom_point(
    data = charPos, 
    aes(x = position, y = reorder_size(term), alpha = 1/40))	+
  ylab("") + 
  xlab("") +
  theme_bw() +
  theme(legend.position="none", 
        axis.text.x  = element_text(size=8))

# Merge together to make new plot.  Basically I just want chapter on the X axis
head(charPos)
head(chapPos)


# Plot that shows the length
str(chapPos)
chapPos$chapter <- gsub("ch", "", chapPos$chapter)

# Make NA endnotes
chapPos$chapter[is.na(chapPos$chapter)] <- "endnotes"

# add words per page value
chapPos$page <- chapPos$length / 250

ggplot(chapPos, aes(chapter, page)) + 
  geom_bar(stat = "identity") +
  ylab("Pages") +
  xlab("Chapter") +
  theme_bw() +
  scale_y_continuous(labels=comma) +
  theme(legend.position="none", 
        text = element_text(size=20),
        axis.text.x  = element_text(angle = 45, hjust = 1, size = 14)) 
  
# Words per minute Avg = 200
chapPos$time <- (chapPos$length / 200) / 60 
number_ticks <- 20

ggplot(chapPos, aes(chapter, time)) + 
  geom_bar(stat = "identity") +
  ylab("Time (hours)") +
  xlab("Chapter") +
  theme_bw() +
  scale_y_continuous(labels=comma, breaks = pretty_breaks(20)) +
  theme(legend.position="none", 
        text = element_text(size=20),
        axis.text.x  = element_text(angle = 45, hjust = 1, size = 14)) 

sum(chapPos$time)

## Chapters 


## Resources

[co-occurance](https://www.r-bloggers.com/turning-keywords-into-a-co-occurrence-network/)
https://matthewlincoln.net/2014/12/20/adjacency-matrix-plots-with-r-and-ggplot2.html
