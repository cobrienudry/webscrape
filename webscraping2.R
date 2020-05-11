
library(tidyverse)
library(rvest)
library(plyr)
library(data.table)
library(splitstackshape)


###########################################################################
dat <- read.csv("press_releases.csv")
#what if I want not just the names, but the content of the press release?

#name of the first press release
dat$title[1]

#url of the first press release
#https://www.state.gov/secretary-michael-r-pompeo-with-jim-daly-of-focus-on-the-family/

#unfortunately, the press release content is not indexed in the same way as the titles

#BUT what do we notice about the link?

#if title is the same as the link, we can manipulate the titles such that we can
#paste them on the end of the root link and navigate to the page to scrape

#title: Secretary Michael R. Pompeo With Jim Daly of Focus on the Family
#url:https://www.state.gov/secretary-michael-r-pompeo-with-jim-daly-of-focus-on-the-family/

#what do we have to do to make the title look like the url?

#add dashes where there are spaces; delete colon and comma

title <- "Secretary Michael R. Pompeo With Jim Daly of Focus on the Family"

#delete period
title <- gsub(".", "\\1", title)

#spaces to dashes
title <- gsub(" ", "-", title)

#add to root
root <- "https://www.state.gov/"

first_url <- paste0(root,title)

#now we can scrape this page!

webpage2 <- read_html(first_url)

#what data do we want?

#info we know
webpage2 %>% html_nodes(".featured-content__copy") %>% html_text()

#info we want
webpage2 %>% html_nodes(".entry-content") %>% html_text()


######################################################################

#we now have the means to scrape every html link from the hearings website

#putting it all together we need to:
#1) make titles into wepages
#2) extract content from pages

#1 make titles into webpages

#lots of different punctuation appears in titles but not urls!

#delete period
titles <- gsub(".", "\\1", dat$title)

#delete apostrophe
titles <- gsub("’", "\\1", dat$title)

#delete colon
titles <- gsub(":", "\\1", titles)

#delete comma
titles <- gsub(",", "\\1", titles)

#delete question mark
titles <- gsub("?", "\\1", titles)

#delete extraneous dash
titles <- gsub("-", "\\1", titles)

#delete parantheticals
titles <- gsub("(", "\\1", titles)
titles <- gsub(")", "\\1", titles)

#spaces to dashes
titles <- gsub(" ", "-", titles)

#add to root
root <- "https://www.state.gov/"

#combine
new_urls <- paste0(root,titles)

content <- rep(NA, 5)



for(i in 1:5){
  tryCatch({
  content[i] <- read_html(new_urls[i]) %>% html_nodes(".entry-content") %>% html_text()
  cat(i, "page is done. \n")
  }, error=function(e){cat(i, "ERROR :",conditionMessage(e), "\n")})
}
warnings()

content[1]


#store data
content <- as.data.frame(content)

#match data with transcripts
dat <- cbind(dat, content)

#check
dat %>% colnames()

#save

write.csv(dat, "press_content.csv")

#########################################################

