
library(tidyverse)
library(rvest)
library(plyr)
library(data.table)
library(splitstackshape)
library(pdftools)

###########################################################################
dat <- read.csv("china_hearings.csv")
#what if I want not just the names, but the content of the hearing?

#name of the first hearing
dat$hearing[1]

#url of the first hearing
#https://www.cecc.gov/events/hearings/china-in-1989-and-2015-tiananmen-human-rights-and-democracy

#unfortunately, the hearing content is not indexed in the same way as the titles

#BUT what do we notice about the link?

#if title is the same as the link, we can manipulate the titles such that we can
#paste them on the end of the root link and navigate to the page to scrape

#title: China in 1989 and 2015: Tiananmen, Human Rights, and Democracy
#url: china-in-1989-and-2015-tiananmen-human-rights-and-democracy

#what do we have to do to make the title look like the url?

#add dashes where there are spaces; delete colon and comma

title <- "China in 1989 and 2015: Tiananmen, Human Rights, and Democracy"

#delete colon
title <- gsub(":", "\\1", title)

#delete comma
title <- gsub(",", "\\1", title)

#spaces to dashes
title <- gsub(" ", "-", title)

#add to root
root <- "https://www.cecc.gov/events/hearings/"

first_hearing_url <- paste0(root,title)

#now we can scrape this page!

webpage2 <- read_html(first_hearing_url)

#what data do we want?

#location of hearing
webpage2 %>% html_nodes(".sub-loc-date") %>% html_text()

#all info
webpage2 %>% html_nodes(".field-label-hidden") %>% html_text()

##############################################################

#extract link

link <- webpage2 %>% html_nodes("a") %>% html_attr("href")

#find all websites
pdfs <- ifelse(grepl(".pdf", link),1,0)
htmls <- ifelse(grepl(".htm", link),1,0)

#this will be useful
link <- as.data.frame(link)

link <- link %>%
  mutate(pdf = pdfs,
         html = htmls) 

#which links have pdfs
pdf_links <- link$link[link$pdf ==1]

#what is wrong with these links?
#no initial root
#check wesite for root
#https://www.cecc.gov/
pdf_links <- as.character(pdf_links)
pdf_links[c(2:7)] <- paste0("https://www.cecc.gov", pdf_links[c(2:7)])

#which links have htmls
html_links <- link$link[link$html ==1]
html_links <- as.character(html_links)

#check with link--what is it labeled
html_text <- read_html(html_links) %>% html_nodes("pre") %>% html_text()

######################################################################

#we now have the means to scrape every html link from the hearings website

#putting it all together we need to:
#1) make titles into wepages
#2) identify html links on webpages
#3) extract transcripts from pages

#1 make titles into webpages


titles <- gsub(":", "\\1", dat$hearing)

#delete colon
titles <- gsub(":", "\\1", titles)

#delete comma
titles <- gsub(",", "\\1", titles)

#delete question mark
titles <- gsub("?", "\\1", titles)

#spaces to dashes
titles <- gsub(" ", "-", titles)

#add to root
root <- "https://www.cecc.gov/events/hearings/"

#combine
new_urls <- paste0(root,titles)

transcripts <- rep(NA, nrow(dat))
for(i in 1:nrow(dat)){
  tryCatch({
  link <- read_html(new_urls[i]) %>% html_nodes("a") %>% html_attr("href")  
  htmls <- ifelse(grepl(".htm", link),1,0) 
  link <- as.data.frame(link)
  link <- link %>%
    mutate(html = htmls) 
  html_links <- link$link[link$html ==1]
  html_links <- as.character(html_links)
  transcripts[i] <- read_html(html_links) %>% html_nodes("pre") %>% html_text()
  cat(i, "page is done. \n")
  }, error=function(e){cat(i, "ERROR :",conditionMessage(e), "\n")})
}

#store data
transcripts <- as.data.frame(transcripts)

#match data with transcripts
dat <- cbind(dat, transcripts)

#check
dat %>% colnames()

dat[1,]

#how many hearings are missing transcripts?
sum(is.na(dat$transcripts))

#########################################################
#some of these transcripts will be stored as pdfs; others simply won't exist

#let's go back to the page to look at the pdf links

pdf_links %>% head()

#what is wrong with these links?
#no initial root
#check wesite for root
#https://www.cecc.gov/
pdf_links <- as.character(pdf_links)
pdf_links[c(2:7)] <- paste0("https://www.cecc.gov", pdf_links[c(2:7)])

#open up pdf link 

pdf_text(pdf_links[1])

#what to do with lots of links?

#what is in the links? does this differ by page?

#gonna have to play around with if_else() statements to not double-scrape info


