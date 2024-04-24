
import pdfplumber
import re
from urllib.parse import urlparse
import json
import os

file = "/Users/allisonjames/Desktop/blackout/NLP/somerville5.pdf"
file_prefix = file[:-4]
file_prefix = os.path.splitext(file)[0]

pdf = pdfplumber.open(file)

## (1) extract text from each page
## (2) combine all into a single string
## (3) remove '\n' and other weird characters

def extract_text_and_combine(pdf):
    combined_text = ""
    for page in pdf.pages:
        combined_text += page.extract_text()
    combined_text = combined_text.replace('\n', ' ')
    return combined_text


text = extract_text_and_combine(pdf)

output = {
    'FILE_NAME': file,
    'ALL TEXT': text
}

#json.dumps(output, file_prefix + ".JSON")
json_path = file_prefix + ".json"
with open(json_path, 'w') as json_file:
    json.dump(output, json_file)

print(f"Data has been written to {json_path}")
