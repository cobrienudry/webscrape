

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
url <- 'https://www.state.gov/press-releases/'

#Reading the HTML code from the website
webpage <- read_html(url)

#How to pick what information you want to extract

#what infoirmation do different "nodes" give you?

webpage %>% html_nodes(".collection-info") %>% html_text()

webpage %>% html_nodes("a") %>% html_text()

webpage %>% html_nodes(".span") %>% html_text()

webpage %>% html_nodes(".collection-content") %>% html_text()

#this node gives you the total information you need
webpage %>% html_nodes(".collection-result") %>% html_text()

#Store extracted info

press <- webpage %>% html_nodes(".collection-result") %>% html_text()

######################################################################

#but you have to then make this information legible
press <- table(press)

#I like the tidyverse so we are using the tidyverse
press <- as.data.frame(press)

#what does it look like?
press %>% head()
press %>% colnames()


#this column does not contain useful information -- delete
press$Freq <- NULL

#I want to have the information organized into type of release, title of the press release, 
#person issuing the release, and date

#this function splits the column "press" whenever it comes accross the 
#character combination "\n"

press <- cSplit(press, "press", "\n")

#what does it look like now?
press %>% head()


#rename columns
colnames(press) <- c("release_type", "title", "speaker", "date")



########################################################
#webscraping is useful when you don't want to hand-xtract every single page

#what if we want to explore the next page of hearings?

#what is different about this url?

#store url
prefix <- "https://www.state.gov/press-releases/page/"

#how many pages do we want?
suffix <- c(1:5)

#make all of the urls you want to explore
web_urls <- paste0(prefix, suffix)

#make a vector to store all of your information
dat <- list()

for(i in 1: length(web_urls)){
  #tryCatch is GREAT for webscraping because it lets the loop continue even if 
  #your script doesn't work for one of the pages
  tryCatch({
    #Download webpage
    webpage <- read_html(web_urls[i])
    
    #Extract information
    press <-webpage %>% html_nodes(".collection-result") %>% html_text()
    
    #Make information legible/organized
    press <- table(press)
    press <- as.data.frame(press)
    
    #store hearings in list
    dat[[i]] <- press
    
    
    cat(i, "page is done. \n")
  }, error=function(e){cat(i, "ERROR :",conditionMessage(e), "\n")})
}

#what does our data look like???
dat[1]

#depending on the shape of your data, this way of storing the data may or may 
#not work. GOOGLE DIFFERENT WAYS TO MAKE A LIST INTO A DF!

dat <- rbind.fill(dat)

#What does our data look like?
View(dat)

###########################################################

#same data cleaning we did before

dat %>% colnames()

#don't need this
dat$Freq <- NULL

#what does press look like?
dat$press[1]

#split as before
dat<- cSplit(dat, "press", "\n")

#what does it look like now?
dat %>% head()


#rename columns
colnames(dat) <- c("release_type", "title", "speaker", "date")

#save hearing data
write.csv(dat, "press_releases.csv")

############################################################################




