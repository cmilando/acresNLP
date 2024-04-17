
import requests
import pdfplumber
import re
import tempfile
from urllib.parse import urlparse
import json
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
# from nltk.stem import PorterStemmer, WordNetLemmatizer
# import spellchecker


#file = "pdf/s1.pdf"
file = "/Users/allisonjames/Desktop/blackout/NLP/somerville.pdf"

#file_prefix = gsub

pdf = pdfplumber.open(file)

# Loop extracting the table on each page
page_dict = dict() # initialize with the full size

# pageX = pdf.pages[6]

# #
# pageX.extract_text()

# pageX.extract_text_lines()

## (1) extract text from each page
## (2) combine all into a single string
## (3) remove '\n' and other weird characters

def extract_text_and_combine(pdf):
    combined_text = ""
    for page in pdf.pages:
        combined_text += page.extract_text()
    combined_text = combined_text.replace('\n', ' ')
    #combined_text += ''.join([line['text'] for line in text_lines])
    return combined_text



def find_year(pdf):
    combined_text = ""
    for page in pdf.pages:
        combined_text += page.extract_text()
        # find the first occurrence of a 4-digit year
        match = re.search(r'\b\d{4}\b', combined_text)
        if match:
            year = match.group()
            return year
    return None


text = extract_text_and_combine(pdf)
year = find_year(pdf)
#print(text)
print(year)

def clean_text(text):
    
    #tokenize text
    tokens = word_tokenize(text)
    
    #lowercase
    tokens = [token.lower() for token in tokens]

    #remove special characters and numbers
    tokens = [re.sub(r'[^a-zA-Z]', '', token) for token in tokens if token.isalpha()]
    
    #remomve stop words
    stop_words = set(stopwords.words('english'))
    tokens = [token for token in tokens if token not in stop_words]

    cleaned_text = ' '.join(tokens)
    return(cleaned_text)


#see if any words match list of boston towns?





output = {
    'URL': file,
    'REPORT_YEAR': year,
    'TOWN': "",
    'ALL TEXT': text
}
# json.dumps(output, file_prefix + ".JSON")