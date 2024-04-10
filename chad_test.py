
import requests
import pdfplumber
import re
import tempfile
from urllib.parse import urlparse
import json


file = "pdf/s1.pdf"
file_prefix = gsub

pdf = pdfplumber.open(file)

# Loop extracting the table on each page
page_dict = dict() # initialize with the full size

pageX = pdf.pages[6]

#
pageX.extract_text()

pageX.extract_text_lines()

## (1) extract text from each page
## (2) combine all into a single string
## (3) remove '\n' and other weird characters

output = {
    'URL': url_here,
    'REPORT_YEAR': report_year,
    'TOWN': town name,
    'ALL TEXT': <<contatnanted string, with \n removed>>
}

json.dumps(output, file_prefix + ".JSON")