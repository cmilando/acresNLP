
## potential code for scraping and storing PDF content

import requests
import pdfplumber
import re
import tempfile

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
def is_first_page_source_us_gov(pdf_content):
    try:
        with tempfile.NamedTemporaryFile(delete=False) as tmp_file:
            tmp_file.write(pdf_content)
            tmp_file_path = tmp_file.name
            with pdfplumber.open(tmp_file_path) as pdf:
                first_page_text = pdf.pages[0].extract_text()
                print(first_page_text)
                # Check if the first page contains strings indicating .us or .gov source
                if re.search(r'\.us\b|\.gov\b', first_page_text, re.IGNORECASE):
                    return True
                else:
                    return False
    except Exception as e:
        print(f"Error occurred while checking source of PDF: {e}")
        return False

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
    if is_first_page_source_us_gov(pdf_content):
        print("PDF source is .us or .gov")
    
    if contains_paid_keywords(pdf_content):
        print("PDF contains paid keywords")
    
    specific_keywords = ["draft", "update"]
    if contains_specific_keywords(pdf_content, specific_keywords):
        print("PDF contains specific keywords")
else:
    print("Failed to download PDF")