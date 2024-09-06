READ ME for NLP processing

All of the code is complete, so all you have to do is run it. Scrape_from_url.py is run individually for each town, 
and chad_test.py is run once all together.

To get the data prepared to run:
1) go to the Community PDF finder and copy paste all URL's for a particular town into a JSON file. Put them into array format: ["pdf1", "pdf2", etc]
2) save this json in the subdirectory called "url_lists" with the name format "townnameurl_list.json"
3) run scrape_from_url.py with the name format "townnameurl" (ex: bostonurl)
    - this will take a while because it's scraping long pdf's and saving the text.
    - the rate is a few pdf's a minute, but may be faster on other machines.
4) this will create a json file for each pdf in the subdirectory "scraped_plans". the pdf's themselves are saved in a subdirectory of "scraped_plans" called "pdfs".
5) once you have a .json file for each url, you are ready to run chad_test.
    - this will take way less time because the data is now in plain text format (much easier to work with).
    - this script only takes a few minutes.
6) as long as all the json's are in scraped_plans, you don't have to do anything. it will create an outputted .tsv file called "combined_output.tsv". ignore the csv version.
7) code to start analyzing this data is in R, called "hazard_counts.R".



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


# adjacent_words = find_towns(text, target_phrases)
# print(f"Most common word before the phrases: {adjacent_words['before']}")
# print(f"Most common word after the phrases: {adjacent_words['after']}")


#most_common_town = find_most_common_town(text, mystic_towns_list)
#print(f"The most common town in the text is: {most_common_town}")


# compare frequency of keys, not values (so sum up the frequency of keys and iterature through values in category)


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


### add # times target town is referenced ###