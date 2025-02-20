import pdfplumber
import re
import json
import os
import requests
from io import BytesIO
import urllib.request
from urllib.parse import urlparse
import pdfminer


def extract_text_and_combine(pdf):
    # (1) extract text from each page
    # (2) combine all into a single string
    # (3) remove '\n' and other weird characters
    combined_text = ""
    pages_text = []
    for page in pdf.pages:
        combined_text += page.extract_text()
        page_text = page.extract_text()
        pages_text.append(page_text.replace('\n', ' '))
    combined_text = combined_text.replace('\n', ' ')
    return combined_text, pages_text


def process_pdf_from_url(url, this_town_name):
    # create request object
    req = urllib.request.Request(url)

    # this chunk of code makes the request look like it's coming from a web browser rather than python.
    # it lets us scrape pages that are protected to block scraping.
    req.add_header('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:106.0) Gecko/20100101 Firefox/106.0')
    req.add_header('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8')
    req.add_header('Accept-Language', 'en-US,en;q=0.5')

    try:
        print(url)
        # try to open url and read it
        response = urllib.request.urlopen(req)
        pdf_content = response.read()

        # open pdf with pdfplumber and store it in the repository
        pdf_path = os.path.join(file_prefix, "pdfs", f"{this_town_name}.pdf")
        os.makedirs(os.path.dirname(pdf_path), exist_ok=True)

        # check if it exists first - if not, then add it
        with open(pdf_path, 'wb') as pdf_file:
            pdf_file.write(pdf_content)

        print(f"PDF has been saved to {pdf_path}")

        # scrape text
        pdf = pdfplumber.open(BytesIO(pdf_content))
        text, pages_text = extract_text_and_combine(pdf)

        # initialize dictionary
        output = {
            'FILE_NAME': url,
            'ALL TEXT': text,
            'TEXT BY PAGE': pages_text
        }

        # write text to json file
        json_path = file_prefix + this_town_name + ".json"
        with open(json_path, 'w') as json_file:
            json.dump(output, json_file, ensure_ascii=False, indent=4)

        print(f"Data has been written to {json_path}")

    # error catching
    except urllib.error.HTTPError as e:
        print(f"Failed to download the PDF. Status code: {e.code}")

    except urllib.error.URLError as e:
        print(f"Failed to download the PDF. Reason: {e.reason}")

    except pdfminer.pdfparser.PDFSyntaxError as e:
        print(f"Failed to download the PDF. Reason:")



if __name__ == "__main__":

    # save pdf's also #
    all_towns = ['waltham', 'wilmington', 'reading', 'malden', 'burlington']
    #

    xfolder_path = "/Users/cwm/Documents/GitHub/acresNLP/"
    file_prefix = "/Users/cwm/Library/CloudStorage/" + \
                  "OneDrive-SharedLibraries-BostonUniversity/" + \
                  "James, Allison - scraped_plans/"

    for town_names_base in all_towns:

        # REPLACE THIS with the town + "url" that
        town_names = town_names_base + "url"

        with open(xfolder_path + 'url_lists/' +
                  town_names + '_list' + '.json', 'r') as file:
            url_list = json.load(file)

        # if there is an error for a PDF throughout and the code stops, you can resume using this chunk.
        #muse the index of the PDF that failed (since Python indexing starts at 0)
        for i in range(0, len(url_list)):
            # print(f"------id:{town_names}{i + 1}------")
            town_name = town_names + str(i + 1)
            # just for now read the last one
            if i == (len(url_list) - 1):
                print(url_list[i])
                process_pdf_from_url(url_list[i], town_name)

        # make sure pdf's saved too
