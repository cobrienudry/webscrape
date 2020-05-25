library(tidyverse)
library(rvest)
library(plyr)
library(data.table)
library(splitstackshape)
rm(list =ls())
#Looking at global voting turnout data

#https://www.idea.int/data-tools/country-view/111/40

#use our normal technique

read_html("https://www.idea.int/data-tools/country-view/111/40") %>%
  html_nodes('td') %>%
  html_text()

#not ideal formatting!

#xpath and html_table() as a solution
read_html("https://www.idea.int/data-tools/country-view/111/40")  %>%
  html_nodes(xpath = '//*[@id="country-report-41"]') %>%
  html_table()

#this gives us only parliamentary--what about presidential?

read_html("https://www.idea.int/data-tools/country-view/111/40")  %>%
  html_nodes(xpath = '//*[@id="country-report-42"]') %>%
  html_table()


#save each table

dat1 <- read_html("https://www.idea.int/data-tools/country-view/111/40")  %>%
  html_nodes(xpath = '//*[@id="country-report-41"]') %>%
  html_table()


dat2 <- read_html("https://www.idea.int/data-tools/country-view/111/40")  %>%
  html_nodes(xpath = '//*[@id="country-report-42"]') %>%
  html_table()

#transform into dataframe for easier manipulation
dat1 <- dat1 %>% as.data.frame()
dat2 <- dat2 %>% as.data.frame()

#fix column names
cols <- dat1[1,]
cols2 <- dat2[1,]

#delete redundant first row
dat1 <- dat1[-1,]
dat2 <- dat2[-1,]

#rename columns
colnames(dat1) <- cols
colnames(dat2) <- cols2


#distinguish between tables by adding a column of "election type"

read_html("https://www.idea.int/data-tools/country-view/111/40")  %>%
  html_nodes(".heading") %>%
  html_text()

election_type <- read_html("https://www.idea.int/data-tools/country-view/111/40")  %>%
  html_nodes(".heading") %>%
  html_text()

dat1$electionType <- election_type[1]
dat2$electionType <- election_type[2]

elections <- rbind(parl,pres)

#what if we want multiple countries?
read_html("https://www.idea.int/data-tools/country-view/111/40")  %>%
  html_nodes(".page-header") %>%
  html_text()


elections$country <- read_html("https://www.idea.int/data-tools/country-view/111/40")  %>%
  html_nodes(".page-header") %>%
  html_text()

#same idea of root/suffix
root <- "https://www.idea.int/data-tools/country-view/"

pages <- c(44:46)

suffix <- "/40"

urls <- paste0(root, pages, suffix)            
            
dat <- list()

for(i in 1:length(urls)){
  tryCatch({
    dat1 <- read_html("https://www.idea.int/data-tools/country-view/111/40")  %>%
      html_nodes(xpath = '//*[@id="country-report-41"]') %>%
      html_table()
    
    
    dat2 <- read_html("https://www.idea.int/data-tools/country-view/111/40")  %>%
      html_nodes(xpath = '//*[@id="country-report-42"]') %>%
      html_table()
    
    #transform into dataframe for easier manipulation
    dat1 <- dat1 %>% as.data.frame()
    dat2 <- dat2 %>% as.data.frame()
    
    #fix column names
    cols <- dat1[1,]
    cols2 <- dat2[1,]
    
    #delete redundant first row
    dat1 <- dat1[-1,]
    dat2 <- dat2[-1,]
    
    #rename columns
    colnames(dat1) <- cols
    colnames(dat2) <- cols2
    
    
    #distinguish between tables by adding a column of "election type"
    
    read_html("https://www.idea.int/data-tools/country-view/111/40")  %>%
      html_nodes(".heading") %>%
      html_text()
    
    election_type <- read_html("https://www.idea.int/data-tools/country-view/111/40")  %>%
      html_nodes(".heading") %>%
      html_text()
    
    dat1$electionType <- election_type[1]
    
    #this allows us to identify how many tables are on a page and to
    #scrape the second table iff it exists
    if(length(election_type > 1)){
      dat2$electionType <- election_type[2]
      dat1 <- rbind(dat1,dat2)
    }
  
  dat1$country <- read_html(urls[i])  %>%
    html_nodes(".page-header") %>%
    html_text()
  #save data to list
  
  dat[[i]] <- dat1
  cat(i, "page is done. \n")
  }, error=function(e){cat(i, "ERROR :",conditionMessage(e), "\n")})
  
}

dat <- rbind_fill(dat)

write_csv("dat", "voterdat.csv")



