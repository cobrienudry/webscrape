
library(tidyverse)
library(rvest)
library(plyr)
library(data.table)
library(splitstackshape)

#Example 1

#Hearings from the Congressional-Executive Commission on China

#Use selector gadget to find what's on the page


#Extract info

#Specifying the url for desired website to be scraped
url <- 'https://www.cecc.gov/events/hearings'

#Reading the HTML code from the website
webpage <- read_html(url)

#How to pick what information you want to extract

#what infoirmation do different "nodes" give you?
webpage %>% html_nodes(".field-content") %>% html_text()

webpage %>% html_nodes("a") %>% html_text()

webpage %>% html_nodes(".date-display-single") %>% html_text()

webpage %>% html_nodes(".section") %>% html_text()

#this node gives you the total information you need
webpage %>% html_nodes(".list-item-hearing") %>% html_text()

#Store extracted info

hearings <- webpage %>% html_nodes(".list-item-hearing") %>% html_text()

######################################################################

#but you have to then make this information legible
hearings <- table(hearings)

#I like the tidyverse so we are using the tidyverse
hearings <- as.data.frame(hearings)

#what does it look like?
hearings %>% head()
hearings %>% colnames()

#this column does not contain useful information -- delete
hearings$Freq <- NULL

#there are MANY different ways to clean data.
#SO many ways

#I want to have the information organized into title of the hearing and date
#this function splits the column "hearings" whenever it comes accross the 
#character combination "\n"

hearings <- cSplit(hearings, "hearings", "\n")

#what does it look like now?
hearings %>% head()

#what is this third columns?

#rename columns
colnames(hearings) <- c("hearing", "date", "subtitle")

########################################################
#webscraping is useful when you don't want to hand-xtract every single page

#what if we want to explore the next page of hearings?

#what is different about this url?

#store url
prefix <- "https://www.cecc.gov/events/hearings?page="

#how many pages do we want?
suffix <- c(1:3)

#make all of the urls you want to explore
web_urls <- paste0(prefix, suffix)

#make a vector to store all of your information
dat <- list()

for(i in 1: length(web_urls)){
  tryCatch({
    #Download webpage
    webpage <- read_html(web_urls[i])
    
    #Extract information
    hearings <-webpage %>% html_nodes(".list-item-hearing") %>% html_text()
    
    #Make information legible/organized
    hearings <- table(hearings)
    hearings <- as.data.frame(hearings)
    
    #Clean
    hearings$Freq <- NULL
    
    #split
    hearings <- cSplit(hearings, "hearings", "\n")
    
    #rename columns
    colnames(hearings) <- c("hearing", "date", "subtitle")
    
    dat[[i]] <- hearings
    
    
    cat(i, "page is done. \n")
  }, error=function(e){cat(i, "ERROR :",conditionMessage(e), "\n")})
}

#what does our data look like???
dat[3]

#depending on the shape of your data, this way of storing the data may or may 
#not work. GOOGLE DIFFERENT WAYS TO MAKE A LIST INTO A DF!

dat <- rbind.fill(dat)

#What does our data look like?
View(dat)

write.csv(dat, "china_hearings.csv")