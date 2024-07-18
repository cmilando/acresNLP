
# this file takes in a bunch of pdf/chunks of text and creates a list before and after all hazard words

import re
from urllib.parse import urlparse
import json
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from collections import Counter
import spacy
import os


## load in hazard dictionary
def load_hazard_dict(file_path):
    with open(file_path, 'r') as file:
        hazard_dict = json.load(file)
    return hazard_dict

## store the keys of the dictionary in a list



## concatenate all chunks of text together

## run string finding function, only store the words before and after each hazard in a set

## return the set

