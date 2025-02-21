import time

import pdfplumber
import re
import json
import os
import requests
from io import BytesIO
import urllib.request
from urllib.parse import urlparse
import pdfminer
import concurrent.futures
import os.path
from os import access, R_OK
from os.path import isfile
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
import os
import time
import shutil

#
xfolder_path = "/Users/cwm/Documents/GitHub/acresNLP/"

#
file_prefix = "/Users/cwm/Library/CloudStorage/" + \
              "OneDrive-SharedLibraries-BostonUniversity/" + \
              "James, Allison - scraped_plans/"

# Set up Chrome options
chrome_options = Options()
chrome_options.add_experimental_option("prefs", {
    "download.default_directory": file_prefix,
    "download.prompt_for_download": False,
    "download.directory_upgrade": True,
    "plugins.always_open_pdf_externally": True,  # Bypass PDF viewer
})
chrome_options.add_argument("--headless")  # Run Chrome in headless mode
chrome_options.add_argument("--disable-gpu")  # Disable GPU acceleration
chrome_options.add_argument("--no-sandbox")  # Bypass OS security model
chrome_options.add_argument("--disable-dev-shm-usage")  # Overcome limited resource issues

# Path to ChromeDriver (modify if necessary)
chrome_driver_path = "/opt/homebrew/bin/chromedriver"  # Update this path

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


def process_pdf_from_url(url, this_town_name, file_prefix):

    ## ---------------------------------------------------------------
    ## PROCESS URL
    # first check it if exists already
    # open pdf with pdfplumber and store it in the repository
    pdf_path = os.path.join(file_prefix, "pdfs", f"{this_town_name}.pdf")
    if os.path.isfile(pdf_path) and os.path.getsize(pdf_path)/1000 >= 50:
        # print(f'file exists and has size > 50 KB: {this_town_name}')
        return
    else:
        os.makedirs(os.path.dirname(pdf_path), exist_ok=True)

    # use selenium
    # Open the PDF URL (triggers download)
    try:
        driver.get(url)

        # Wait for the download to complete
        time.sleep(10)  # Adjust as necessary
        print(' > something was downloaded')

        # Find the downloaded file (assumes it's the most recent file in the directory)
        downloaded_files = sorted(
            [f for f in os.listdir(file_prefix) if f.endswith(".pdf")],
            key=lambda x: os.path.getctime(os.path.join(file_prefix, x)),
            reverse=True
        )

        if downloaded_files:
            latest_file = os.path.join(file_prefix, downloaded_files[0])

            # Rename the downloaded file to the desired filename
            shutil.move(latest_file, pdf_path)
            print(f" > file renamed! File saved as: {pdf_path}")
        else:
            print(" > file rename failed")

    except Exception as e:
        print('download failed')
        return



    ## ---------------------------------------------------------------
    ## PROCESS PDF
    try:

        # scrape text
        # updated to read from path
        print(pdf_path)
        pdf = pdfplumber.open(pdf_path)
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

        # print(f"Data has been written to {json_path}")

    except Exception as e:
        print(url)
        print(this_town_name)
        print(f"Failed to parse the PDF. PARSER: Reason: {e}")



if __name__ == "__main__":


    # save pdf's also #
    # all_towns = ['arlington', 'belmont', 'boston', 'brookline', 'burlington', 'cambridge',
    #              'chelsea', 'everett', 'lexington', 'lynn', 'malden', 'medford', 'melrose',
    #              'milton', 'needham', 'newton', 'quincy', 'reading', 'revere', 'saugus',
    #              'somerville', 'stoneham', 'wakefield', 'waltham', 'watertown', 'wilmington',
    #              'winchester', 'winthrop', 'woburn']

    all_towns = ['revere', 'saugus', 'somerville', 'stoneham', 'wakefield', 'waltham', 'watertown', 'wilmington',
                 'winchester', 'winthrop', 'woburn']
    #
    print(all_towns)



    ## START CHROME
    service = Service(chrome_driver_path)
    driver = webdriver.Chrome(service=service, options=chrome_options)

    def process_in_parallel(all_towns, xfolder_path, file_prefix):

        for town_names_base in all_towns:
            # REPLACE THIS with the town + "url" that
            town_names = town_names_base + "url"

            with open(xfolder_path + 'url_lists/' +
                      town_names + '_list' + '.json', 'r') as file:
                url_list = json.load(file)

            # with concurrent.futures.ThreadPoolExecutor() as executor:

            # if there is an error for a PDF throughout and the code stops, you can resume using this chunk.
            # muse the index of the PDF that failed (since Python indexing starts at 0)
            for i in range(0, len(url_list)):
                print(f"------id:{town_names}{i + 1}------")
                town_name = town_names + str(i + 1)
                # just for now read the last one
                # if i > (len(url_list) - 4):
                # print(url_list[i])
                process_pdf_from_url(url_list[i], town_name, file_prefix)

                # comment this out to NOT process in parallel
                # submit tasks to the executor
                # executor.submit(process_pdf_from_url, url_list[i], town_name, file_prefix)


    # make sure pdf's saved too
    process_in_parallel(all_towns, xfolder_path, file_prefix)

    # Close the browser
    driver.quit()