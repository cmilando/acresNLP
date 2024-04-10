
## potential code for scraping and storing PDF content

import requests
import pdfplumber
import re
import tempfile
from urllib.parse import urlparse

#downloads the url as a pdf to later be used as a temporary file
def download_pdf(url):
    try:
        #make the url request
        response = requests.get(url)
        #raise an exception if one occurred
        response.raise_for_status()
        return response.content
    except Exception as e:
        print(f"Error occurred while downloading PDF: {e}")
        return None

#check whether the first page contains .us or .gov (can change to check the url)
#can also change to check for the name of the town or other government-related things
def is_url_source_us_gov(pdf_url):
    try:
        parsed_url = urlparse(pdf_url)
        # Extract the domain from the URL
        domain = parsed_url.netloc
        # Check if the domain ends with .us or .gov
        if domain.endswith('.us') or domain.endswith('.gov'):
            return True
        else:
            return False
    except Exception as e:
        print(f"Error occurred while checking source of PDF URL: {e}")
        return False

def examine_first_page(pdf_content):
    try:
        with tempfile.NamedTemporaryFile(delete=False) as tmp_file:
            tmp_file.write(pdf_content)
            tmp_file_path = tmp_file.name
            with pdfplumber.open(tmp_file_path) as pdf:
                print(type(pdf))
                first_page = pdf.pages[0] #will be specific to pdf!
                first_page_text = first_page.extract_text()
                print(first_page_text)
                all_text = pdf.extract_text()
                print(all_text)

    except Exception as e:
        print(f"Error occurred while printing first page: {e}")

#export json for each pdf



def contains_paid_keywords(pdf_content):
    try:
        with tempfile.NamedTemporaryFile(delete=False) as tmp_file:
            tmp_file.write(pdf_content)
            tmp_file_path = tmp_file.name
            with pdfplumber.open(tmp_file_path) as pdf:
                for page in pdf.pages:
                    page_text = page.extract_text()
                    # Check for keywords indicating payment information
                    if re.search(r'paid by|sponsored by|funded by', page_text, re.IGNORECASE):
                        return True
                return False
    except Exception as e:
        print(f"Error occurred while checking paid keywords in PDF: {e}")
        return False

def contains_specific_keywords(pdf_content, keywords):
    try:
        with tempfile.NamedTemporaryFile(delete=False) as tmp_file:
            tmp_file.write(pdf_content)
            tmp_file_path = tmp_file.name
            with pdfplumber.open(tmp_file_path) as pdf:
                for page in pdf.pages:
                    page_text = page.extract_text()
                    # Check if page text contains any of the specified keywords
                    for keyword in keywords:
                        if re.search(r'\b{}\b'.format(re.escape(keyword)), page_text, re.IGNORECASE):
                            return True
                return False
    except Exception as e:
        print(f"Error occurred while checking specific keywords in PDF: {e}")
        return False




# Example usage
pdf_url = "https://www.somervillema.gov/sites/default/files/6-13-2017_Somerville%20CCVA%20Final%20Report.pdf"

pdf_content = download_pdf(pdf_url)


if pdf_content:
    if is_url_source_us_gov(pdf_url):
        print("PDF source is .us or .gov")
    
    if contains_paid_keywords(pdf_content):
        print("PDF contains paid keywords")
    
    # specific_keywords = ["draft", "update"]
    # if contains_specific_keywords(pdf_content, specific_keywords):
    #     print("PDF contains specific keywords")
        
    examine_first_page(pdf_content)

else:
    print("Failed to download PDF")


