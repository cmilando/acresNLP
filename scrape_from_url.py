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

### save pdf's also ###


town_names = "somervilleurl"
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

def process_pdf_from_url(url, town_name):

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

        # open pdf with pdfplumber and store it in the repository
        pdf = pdfplumber.open(BytesIO(pdf_content))
        pdf_path = file_prefix + "pdfs/"

        #check if it exists first - if not, then add it
        with open(pdf, 'wb') as pdf_file:
            pdf_file.write(pdf_content)
        print(f"PDF has been saved to {pdf_path}")

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



url_list = ["https://www.somervillema.gov/sites/default/files/6-13-2017_Somerville%20CCVA%20Final%20Report.pdf", 
            "https://www.umb.edu/media/umassboston/content-assets/documents/Report-Learning-From-MVP-Greater-Boston-2022-05-24.pdf", 
            "https://www.cambridgema.gov/-/media/Files/CDD/Climate/vulnerabilityassessment/finalreport_ccvapart2_mar2017_final2_web.pdf",
            "https://secondnature.org/wp-content/uploads/Tufts-Summary-of-Findings.pdf",
            "https://s3.amazonaws.com/somervillema-live/s3fs-public/somerville-climate-forward-plan.pdf",
            "http://www.somervision2040.com/wp-content/uploads/sites/3/2020/01/SomerVision.pdf",
            "https://noharm-uscanada.org/sites/default/files/Resilience%202.0%20Boston%20-%20Healthcare%27s%20Role%20in%20Anchoring%20Community%20Resilience.pdf",
            "http://www.somervision2040.com/wp-content/uploads/sites/3/2021/10/SomerVision-2040-Adopted.pdf",
            "https://cms5.revize.com/revize/chelseama/Document_Center/Departments/Housing%20&%20Community%20Development/Environment%20and%20Climate%20Resilience/North%20Suffolk%20Office%20of%20Resilience%20and%20Sustainability/chelsea_hazard_mitigation_plan_2022_update_-_adopted_07-08-22.pdf",
            "https://www.antioch.edu/wp-content/uploads/2018/12/Moser_CV_Nov2020.pdf"]



## create list of url's to iterate through
for u in url_list:
    town_name = town_names + str(url_list.index(u)+1)
    process_pdf_from_url(u, town_name)
    


# make sure pdf's saved too