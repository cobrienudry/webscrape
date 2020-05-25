library(tidyverse)
library(magick)
library(pdftools)
library(jpeg)
library(tesseract)


#Many ways to get text from a pdf

#SO many ways
#from pdftools package
pdf_text("https://www.bog.gov.gh/wp-content/uploads/2020/03/20200302-March-3-Year-Bond-Announcement.pdf") 

#add read_lines() command to made download reflect page
pdf_text("https://www.bog.gov.gh/wp-content/uploads/2020/03/20200302-March-3-Year-Bond-Announcement.pdf") %>%
  read_lines()

#from tesseract package
ocr("https://www.bog.gov.gh/wp-content/uploads/2020/03/20200302-March-3-Year-Bond-Announcement.pdf", 
    engine = tesseract("eng"))

#from magick package
image_read_pdf("https://www.bog.gov.gh/wp-content/uploads/2020/03/20200302-March-3-Year-Bond-Announcement.pdf") %>%
  image_ocr() %>%
  cat()

#works with non-pdf images!

ocr("nyt.jpg", 
    engine = tesseract("eng")) 

nyt <- ocr("nyt.jpg", 
           engine = tesseract("eng"))

nyt  %>% cSplit(".", "|")
#but the columns are read incorrectly! 

#one solution: split page by cropping
#from magick package
image <- image_read("nyt.jpg")

#crop first column -- note the + at the end -> indicates that the cropping 
#should begin 20 pixels from the left
#moving vertically adds second plus
image_crop(image, "180x2048")
image_crop(image, "180x2048 +20 + 500")


cropped <- image_crop(image, "180x2048 +20 + 500")

cropped_text <- ocr(cropped, engine = tesseract("eng"))

#crop second 
image_crop(image, "170x2048 + 210 + 220")

cropped2 <- image_crop(image,  "170x2048 + 210 + 220")

cropped_text2 <- ocr(cropped2, engine = tesseract("eng"))

#third
cropped3 <- image_crop(image, "175x2048 + 390 + 230")

#fourth 
cropped4 <- image_crop(image, "175x2048 + 570 + 230")

#fifth
cropped5 <- image_crop(image, "175x2048 + 755 + 230")

#sixth
cropped6 <- image_crop(image, "175x2048 + 940 + 230")

#combine!
all_nyt <- ocr(c(cropped,
      cropped2,
      cropped3,
      cropped4,
      cropped5,
      cropped6), engine = tesseract("eng"))

#######################
#setting up for super basic text analysis using bags of words
#what if we want to do text analysis using bags of word?
ocr_data("https://www.bog.gov.gh/wp-content/uploads/2020/03/20200302-March-3-Year-Bond-Announcement.pdf", 
    engine = tesseract("eng")) 

words <- ocr_data("https://www.bog.gov.gh/wp-content/uploads/2020/03/20200302-March-3-Year-Bond-Announcement.pdf", 
                  engine = tesseract("eng")) 
unique(words$word)

#organize by word frquency
words <- words %>%
  group_by(word) %>%
  summarize(freq = n())
View(words)
