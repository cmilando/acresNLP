import pdfplumber
import re
import json
import os
import requests
from io import BytesIO
import urllib.request
from urllib.parse import urlparse


## (1) extract text from each page
## (2) combine all into a single string
## (3) remove '\n' and other weird characters

def extract_text_and_combine(pdf):
    combined_text = ""
    pages_text = []
    for page in pdf.pages:
        combined_text += page.extract_text()
        page_text = page.extract_text()
        pages_text.append(page_text.replace('\n', ' '))
    combined_text = combined_text.replace('\n', ' ')
    return combined_text, pages_text

town_name = "everetturl6"
file_prefix = "/Users/allisonjames/Desktop/bu/acresNLP/scraped_plans/"
# def process_pdf_from_url(url):
#     response = requests.get(url)
#     if response.status_code == 200:
#         pdf = pdfplumber.open(BytesIO(response.content))

#         text, pages_text = extract_text_and_combine(pdf)
#         # file_prefix = os.path.splitext(urlparse(url).path)[0]

#         output = {
#             'FILE_NAME': url,
#             'ALL TEXT': text,
#             'TEXT BY PAGE': pages_text
#         }

#         json_path = file_prefix + town_name + ".json"
#         with open(json_path, 'w') as json_file:
#             json.dump(output, json_file, ensure_ascii=False, indent=4)

#         print(f"Data has been written to {json_path}")
#     else:
#         print(f"Failed to download the PDF. Status code: {response.status_code}")

def process_pdf_from_url(url):

    # create request object
    req = urllib.request.Request(url)

    # this makes request look like it's coming from a web browser
    # lets us scrape pages that are protected to block scraping
    req.add_header('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:106.0) Gecko/20100101 Firefox/106.0')
    req.add_header('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8')
    req.add_header('Accept-Language', 'en-US,en;q=0.5')

    try:
        # try to open url and read it
        response = urllib.request.urlopen(req)
        pdf_content = response.read()

        # open pdf with pdfplumber
        pdf = pdfplumber.open(BytesIO(pdf_content))

        #scrape text
        text, pages_text = extract_text_and_combine(pdf)
        
        #initialize dictionary
        output = {
            'FILE_NAME': url,
            'ALL TEXT': text,
            'TEXT BY PAGE': pages_text
        }

        # write text to json file
        json_path = file_prefix + town_name + ".json"
        with open(json_path, 'w') as json_file:
            json.dump(output, json_file, ensure_ascii=False, indent=4)

        print(f"Data has been written to {json_path}")
    #error catching
    except urllib.error.HTTPError as e:
        print(f"Failed to download the PDF. Status code: {e.code}")
    except urllib.error.URLError as e:
        print(f"Failed to download the PDF. Reason: {e.reason}")



url = "https://www.mapc.org/wp-content/uploads/2019/04/FINAL-Chelsea-MVP-Report.6.26.18.pdf"
process_pdf_from_url(url)
