
import re
from urllib.parse import urlparse
import json
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from collections import Counter
import spacy
import os
# from nltk.stem import PorterStemmer, WordNetLemmatizer
# import spellchecker

## MODIFY ACCORDINGLY
# file_path = "/Users/allisonjames/Desktop/bu/acresNLP"
# file_name = "everetturl1"
#town_name = "Everett"
current_year = 2024
# used to find occurrence of towns - most frequent is likely the relevant town 
mystic_towns_list = ["Burlington", "Lexington", "Belmont", "Watertown",
                     "Arlington", "Winchester", "Woburn", "Reading",
                     "Stoneham", "Medford", "Somerville", "Cambridge",
                     "Boston", "Charlestown", "Everett", "Malden", "Melrose",
                     "Wakefield", "Chelsea", "Revere", "Winthrop", "Wilmington"]




# load in a file created by scrape_from_url.py
def load_json_file(filepath):
    with open(filepath, 'r') as file:
        data = json.load(file)
    return data

# data = load_json_file(file_path + "/scraped_plans/" + file_name + ".json")
# text = data['ALL TEXT']
# page_text = data['TEXT BY PAGE'] #also include text per page



##### only find 4-years with nothing in front/after ####

def find_most_common_year(text, current_year):
    """
    Finds all four-digit numbers in the given text, assumes they are years,
    and returns the most common one.

    Args:
    text (str): The text to search for years.

    Returns:
    int: The most common year found in the text. If no year is found, returns None.
    """
    # Find all occurrences of a four-digit number
    years = re.findall(r'(?<!\d)\b\d{4}\b(?!\d)', text)
    
    # Filter out years that are in the future
    valid_years = [int(year) for year in years if 1900 <= int(year) <= current_year] ###### after 1900 #####
    
    if not valid_years:
        return None, None
    
    year_counts = Counter(valid_years)
    most_common_year = year_counts.most_common(1)[0][0]
    first_year = years[0]
    
    return (most_common_year, first_year)

# most_common_year, first_year = find_most_common_year(text, current_year)
# print(f"The most common year in the text is: {most_common_year}")
# print(f"The first year found in the text is: {first_year}")


def find_towns(text, target_phrases):
    """
    Finds the most common words that occur immediately before and after "city" and "town".

    Args:
    text (str): The text in which to search for the phrases.
    target_phrases (list): List of phrases to search for.

    Returns:
    dict: A dictionary with keys 'before' and 'after' containing the most common words
          found before and after the target phrases, respectively.
    """
    # creates a pattern of a word before or afer the target phrases
    pattern = r'\b(\w+)\s+(' + '|'.join(map(re.escape, target_phrases)) + r')\s+(\w+)\b'
    
    matches = re.findall(pattern, text, re.IGNORECASE)
    
    if not matches:
        return {'before': None, 'after': None}
    
    # Split matches into before and after
    before_words = [match[0] for match in matches]
    after_words = [match[2] for match in matches]
    
    most_common_before = Counter(before_words).most_common(1)[0][0] if before_words else None
    most_common_after = Counter(after_words).most_common(1)[0][0] if after_words else None
    
    return {'before': most_common_before, 'after': most_common_after}


target_phrases = ["city of", "town of"]
#adjacent_words = find_towns(text, target_phrases)
# print(f"Most common word before the phrases: {adjacent_words['before']}")
# print(f"Most common word after the phrases: {adjacent_words['after']}")


def find_most_common_town(text, towns_list):
    """
    Finds the most common town or city name from a predefined list in the given text.

    Args:
    text (str): The text to search within.
    towns_list (list): A list of town or city names to look for.

    Returns:
    str: The most common town or city found in the text, or None if none are found.
    """

    # Create a regex pattern to find any of the town names, ensuring case-insensitive matching
    pattern = r'\b(' + '|'.join(map(re.escape, towns_list)) + r')\b'
    
    matches = re.findall(pattern, text, re.IGNORECASE)
    
    if not matches:
        return None
    
    town_counts = Counter(matches)
    most_common_town = town_counts.most_common(1)[0][0]
    
    return most_common_town


#most_common_town = find_most_common_town(text, mystic_towns_list)
#print(f"The most common town in the text is: {most_common_town}")


#compare frequency of keys, not values (so sum up the frequency of keys and iterature through values in category)

def count_keyword_occurrences(text, categories, strict): 
    """
    Counts occurrences of words in each given category.

    Args:
    text (str): The text to search within.
    categories (dict): A dictionary where keys are category names and values are lists of words or phrases in each category.

    Returns:
    dict: A dictionary with category names as keys and the sum of word counts in each category as values.
    """
    # Initialize an empty dictionary to store counts for each category
    category_counts = {category: {} for category in categories}
    category_pcts = {category: {} for category in categories}
    total_sum = 0

    # Iterate over each category
    for category, keywords in categories.items():
        # Escape keywords for use in regex and join them into a single pattern
        if strict:
            pattern = '|'.join(r'\b{}\b'.format(re.escape(keyword)) for keyword in keywords)
        else:
            pattern = '|'.join(re.escape(keyword) for keyword in keywords)

        # Use regex to find all occurrences of the pattern
        matches = re.findall(pattern, text, re.IGNORECASE)

        # Count occurrences of words in the category
        keyword_counts = Counter(matches)

        # Count occurrences of words in the category
        category_counts[category] = sum(keyword_counts.values())
        total_sum += sum(keyword_counts.values())

    for category, keywords in categories.items():
        # print(category_counts[category])
        if total_sum > 0:
            category_pcts[category] = round(category_counts[category] / total_sum * 100, ndigits = 1)
        else:
            category_pcts[category] = category_counts[category]*0
        

    return category_counts, category_pcts


### generate table of hazard frequencies for this pdf
###### also account for chars before and after #####
#list of words that begin w/ hazards, edit list manually (this new script - take multiple pdf's)
#can find old links/pdf's with wayback machine


# with open('/Users/allisonjames/Desktop/bu/acresNLP/hazards.json', 'r') as file:
#     hazard_data = json.load(file)
    
# # needs no update
# hazard_counts, hazard_pcts = count_keyword_occurrences(text, hazard_data, False)
# print(hazard_counts)
# print(hazard_pcts)


# total_words = len(text.split())
# total_pages = len(page_text)
# print(total_words, total_pages)

# #output
# headers = ["Town Name", "Total Words", "Total Pages"] + [f"{cat} Count" for cat in hazard_data.keys()] + [f"{cat} %" for cat in hazard_data.keys()]
# data = [town_name, total_words, total_pages] + [hazard_counts[cat] for cat in hazard_data.keys()] + [hazard_pcts[cat] for cat in hazard_data.keys()]

# tsv_output = "\t".join(headers) + "\n" + "\t".join(map(str, data))

# print(file)
# output_file = file_path + "/hazard_tables/" + file_name + ".tsv"
# with open(output_file, 'w') as f:
#     f.write(tsv_output)
# print(f"TSV output has been saved to {output_file}")



## do the same for outreach strategies

#https://intosaijournal.org/journal-entry/inform-consult-involve-collaborate-empower/



#outreach (ignore for now)
# with open('/Users/allisonjames/Desktop/bu/acresNLP/outreach.json', 'r') as file:
#     outreach_data = json.load(file)

# outreach_counts, outreach_pcts = count_keyword_occurrences(text, outreach_data, True)
# print(outreach_counts)
# print(outreach_pcts)

# outr_headers = ["Town Name", "Total Words", "Total Pages"] + [f"{cat} Count" for cat in outreach_data.keys()] + [f"{cat} %" for cat in outreach_data.keys()]
# outr_data = [town_name, total_words, total_pages] + [outreach_counts[cat] for cat in outreach_data.keys()] + [outreach_pcts[cat] for cat in outreach_data.keys()]

# outr_output = "\t".join(outr_headers) + "\n" + "\t".join(map(str, outr_data))

# print(file)
# output_file = file_path + "/outreach_tables/" + file_name + ".tsv"
# with open(output_file, 'w') as f:
#     f.write(outr_output)
# print(f"TSV output has been saved to {output_file}")




### community engagement (add) - should be strict breaks

# with open('/Users/allisonjames/Desktop/bu/acresNLP/community_engagement_1.json', 'r') as file:
#     engage_data = json.load(file)

# engage_counts, engage_pcts = count_keyword_occurrences(text, engage_data, True)

# engage_headers = ["Town Name", "Total Words", "Total Pages"] + [f"{cat} Count" for cat in engage_data.keys()] + [f"{cat} %" for cat in engage_data.keys()]
# eng_data = [town_name, total_words, total_pages] + [engage_counts[cat] for cat in engage_data.keys()] + [engage_pcts[cat] for cat in engage_data.keys()]

# eng_output = "\t".join(engage_headers) + "\n" + "\t".join(map(str, eng_data))

# eng_file = file_path + "/engage_tables/" + file_name + ".tsv"
# with open(eng_file, 'w') as f:
#     f.write(eng_output)
# print(f"TSV output has been saved to {eng_file}")






# steering_phrases = ["steering committee", "advisory committee", "planning council"]

# def steering_committee_pages(pages_text, phrases):
#     # Initialize a dictionary to store pages with "steering committee" or "advisory committee"
#     pages_with_phrases = {}

#     for i, p_t in enumerate(pages_text):
#         if any(phrase.lower() in p_t.lower() for phrase in phrases):
#             print(f"Phrase found on page {i+1}")
#             pages_with_phrases[i+1] = p_t
    
#     return pages_with_phrases

# steering_pages = steering_committee_pages(page_text, steering_phrases)
# steering_path = file_path + "/committee_pages/" + file_name + ".json"
# with open(steering_path, 'w') as json_file:
#     json.dump(steering_pages, json_file, ensure_ascii=False, indent=4)
#     print(f"Data has been written to {steering_path}")




def process_file(file_path, file_name, hazard_data, engage_data):
    
    #grab chunk of text from json file
    data = load_json_file(file_path + "/scraped_plans/" + file_name)
    text = data['ALL TEXT']
    page_text = data['TEXT BY PAGE']
    total_words = len(text.split())
    total_pages = len(page_text)
    
    #grab most common town
    most_common_town = find_most_common_town(text, mystic_towns_list)

    #grab most common year
    most_common_year = find_most_common_year(text, current_year)

    # create the hazard and community engagement tables (with counts and percentages)
    hazard_counts, hazard_pcts = count_keyword_occurrences(text, hazard_data, False)
    engage_counts, engage_pcts = count_keyword_occurrences(text, engage_data, True)

    #create the headers
    headers = ["File Name", "Most Common Town", "Most Mentioned Year", "Total Words", "Total Pages"]
    headers += [f"{cat} Count" for cat in hazard_data.keys()] + [f"{cat} %" for cat in hazard_data.keys()]
    headers += [f"{cat} Count" for cat in engage_data.keys()] + [f"{cat} %" for cat in engage_data.keys()]
    
    #add the tables' data
    data = [file_name, most_common_town, most_common_year, total_words, total_pages]
    data += [hazard_counts[cat] for cat in hazard_data.keys()] + [hazard_pcts[cat] for cat in hazard_data.keys()]
    data += [engage_counts[cat] for cat in engage_data.keys()] + [engage_pcts[cat] for cat in engage_data.keys()]

    return headers, data

    

file_path = "/Users/allisonjames/Desktop/bu/acresNLP"
file_names = file_names = [
    "everetturl1.json", "everetturl2.json", "everetturl3.json", "everetturl4.json", 
    "everetturl5.json", "everetturl6.json", "everetturl7.json", "everetturl8.json", 
    "everetturl9.json", "everetturl10.json", "revereurl1.json", "revereurl2.json", 
    "revereurl3.json", "revereurl4.json", "revereurl7.json", "revereurl8.json", 
    "revereurl9.json", "revereurl10.json", "somervilleurl1.json", "somervilleurl2.json", 
    "somervilleurl3.json", "somervilleurl4.json", "somervilleurl5.json", "somervilleurl6.json", 
    "somervilleurl7.json", "somervilleurl8.json", "somervilleurl9.json"
]


with open(file_path + '/hazards.json', 'r') as file:
    hazard_data = json.load(file)

with open(file_path + '/community_engagement_1.json', 'r') as file:
    engage_data = json.load(file)


# Process all files and combine results into one table
all_headers = None
all_data = []


for file_name in file_names:
    headers, data = process_file(file_path, file_name, hazard_data, engage_data)
    if all_headers is None:
        all_headers = headers
    all_data.append(data)

# Save the combined results into a single TSV file
combined_output = "\t".join(all_headers) + "\n" + "\n".join("\t".join(map(str, row)) for row in all_data)
output_file = file_path + "/combined_output.tsv"
with open(output_file, 'w') as f:
    f.write(combined_output)
print(f"Combined TSV output has been saved to {output_file}")


###############################################################



#https://bushare.sharepoint.com/:x:/r/sites/GRP-SPH-EH-ACRES/_layouts/15/doc2.aspx?sourcedoc=%7BC532C339-9BAA-42AA-87C3-C4451B03CB09%7D&file=DRAFT_ACRES%20Aim%201%20Community%20Concerns.xlsx&action=default&mobileredirect=true


# create more specific categories based on individual terms (roundtable, focus groups, etc.)
# outreach_strat = { 

#     "involve": ("involve", "roundtable", "workshops","focus groups","community forums","town hall meetings",
#                 "participatory planning", "stakeholder engagement", "community-driven","engagement sessions", 
#                 "volunteer involvement"),
#     "collaborate": ("collaborate", "partnerships","joint initiatives","coalition building","community partnerships",
#                     "multi-stakeholder collaboration","collaborative efforts","public-private partnerships",
#                     "cooperative projects","interagency cooperation","cross-sector collaboration"),
#     "inform": ("inform", "public awareness campaigns","educational seminars", "newsletters","press releases",
#                "information sessions","community briefings","public announcements","social media updates",
#                "fact sheets","awareness raising"),
#     "consult": ("public consultations", "feedback sessions", "community surveys", "public hearings",
#                 "opinion polling","consultative meetings","focus group discussions","stakeholder interviews",
#                 "community input","advisory boards")
# }


#print(outreach_counts)

# rep_perspectives = {  #needs human edits
#     "city gov": ("government", "municipal", "city of"),
#     "nonprofits": ("nonprofit", "charity", "fundraising", "volunteer programs", "NGO", "humanitarian efforts", "non-profit organizations"),
#     "businesses": ("business","corporate responsibility", "industry standards", "business development", "sustainability practices", 
#         "private sector", "innovation", "entrepreneurship", "corporate partnerships", "economic growth", 
#         "small businesses", "market trends", "commerce", "consumer demand"),
#     "climate expert": ("expert", "climate change", "global warming", "carbon emissions", "sustainability", "environmental impact", 
#         "renewable energy", "climate policy", "mitigation strategies", "adaptation", "eco-friendly", 
#         "green technology", "biodiversity", "conservation"),
#     "academic/research": ("academic", "research", "scholarly articles", "research findings", "academic journals", "studies", "data analysis", 
#         "theoretical frameworks", "educational institutions", "research grants", "scientific inquiry", 
#         "experimental results", "peer review", "academic conferences"),
#     "health": ("public health", "healthcare services", "medical research", "disease prevention", "health education", 
#         "patient care", "healthcare policy", "wellness", "mental health", "epidemiology", "health disparities", 
#         "health systems", "medical ethics"),
#     "community members": ("community member", "residents", "local issues", "community needs", "public opinion", "grassroots", "neighborhood associations", 
#         "local culture", "community engagement", "citizen feedback", "town hall", "community events", "public forums", 
#         "resident concerns")
# }

# perspective_counts = count_keyword_occurrences(text, rep_perspectives)
#print(perspective_counts)


#sites of concern = {frequency table of ALL proper nouns}
#words that are capitalized but not after a period
#should be its own function
def count_proper_nouns(text):
#ffilter out numbers

    #load the english NLP model
    nlp = spacy.load('en_core_web_sm')

    #model processes text
    processed = nlp(text)
    all_words = set(token.text for token in processed)
    lowercase_words = set(word.lower() for word in all_words if word.islower())
    proper_nouns = []

    #part of speech tagging extracts proper nouns
    for token in processed:
        if token.pos_ == 'PROPN':  # Token is a proper noun
            # Check if the lowercase version of this proper noun appears in the lowercase_words set
            if token.text.lower() not in lowercase_words:
                proper_nouns.append(token.text)

    # now count proper nouns
    frequencies = Counter(proper_nouns)

    return frequencies

# proper_noun_table = count_proper_nouns(text)
# print(proper_noun_table)


