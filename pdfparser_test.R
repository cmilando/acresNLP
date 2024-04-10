## This snippet tests out R PDF parsing tools 
## Nina Cesare
## 04/10/2024


## A link to test this out with

link <- "https://www.cambridgema.gov/-/media/Files/CDD/Climate/vulnerabilityassessment/ccvareportpart1/cambridge_november2015_finalweb.pdf"

## Download and parse

download.file(link, "C:/Users/ncesare/Downloads/test_file.pdf", mode = "wb")  # you can probably just re-use the same storage file if we're just extracting text
txt <- pdf_text("C:/Users/ncesare/Downloads/test_file.pdf")

## This seems to automatically paginate. Each index is a separate page

test <- txt[9]  

rows <- scan(textConnection(test), what="character",  sep = "\n")  
rows