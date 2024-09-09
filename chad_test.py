import json
import os
import func_hasmass
import func_hasclimate
import func_checkurl
import func_commonyear
import func_commontown
import func_countkeywords


def process_file(this_json_file_path, f_name, hazard_dict, engage_dict):
    # grab chunk of text from json file

    with open(this_json_file_path + f_name, 'r') as file:
        this_pdf_data = json.load(file)

    print(f'Adding data for {f_name}')

    text = this_pdf_data['ALL TEXT']
    page_text = this_pdf_data['TEXT BY PAGE']
    url = this_pdf_data['FILE_NAME']
    total_words = len(text.split())
    total_pages = len(page_text)

    # grab most common town
    most_common_town = func_commontown.find_most_common_town(text, mystic_towns_list)

    # grab most common year
    most_common_year = func_commonyear.find_most_common_year(text, current_year)

    # check url front
    is_ma_url = func_checkurl.ma_url(url)

    # check url end
    is_org_url = func_checkurl.org_url(url)

    # check
    has_mass = func_hasmass.has_massachusetts(page_text)
    has_climate = func_hasclimate.has_climate(page_text)

    # create the hazard and community engagement tables (with counts and percentages)
    hazard_counts, hazard_pcts = func_countkeywords.count_keyword_occurrences(text, hazard_dict, False)
    engage_counts, engage_pcts = func_countkeywords.count_keyword_occurrences(text, engage_dict, True)

    # create the headers
    f_headers = ["File Name", "URL",
                 "Most Common Town", "Most Mentioned Year",
                 "MA url", "ORG url"
                 "Has Mass", "Has climate",
                 "Total Words",
                 "Total Pages"]
    f_headers += ([f"{cat} Count" for cat in hazard_dict.keys()] +
                  [f"{cat} %" for cat in hazard_dict.keys()])
    f_headers += ([f"{cat} Count" for cat in engage_dict.keys()] +
                  [f"{cat} %" for cat in engage_dict.keys()])

    # add the tables' data
    this_pdf_data = [f_name, url,
                     most_common_town, most_common_year,
                     is_ma_url, is_org_url,
                     has_mass, has_climate,
                     total_words, total_pages]

    this_pdf_data += [hazard_counts[cat] for
                      cat in hazard_dict.keys()] + [hazard_pcts[cat] for
                                                    cat in hazard_dict.keys()]

    this_pdf_data += [engage_counts[cat] for
                      cat in engage_dict.keys()] + [engage_pcts[cat] for
                                                    cat in engage_dict.keys()]

    return f_headers, this_pdf_data


if __name__ == "__main__":

    # MODIFY ACCORDINGLY
    current_year = 2024
    # used to find occurrence of towns - most frequent is likely the relevant town
    mystic_towns_list = ["Burlington", "Lexington", "Belmont", "Watertown",
                         "Arlington", "Winchester", "Woburn", "Reading",
                         "Stoneham", "Medford", "Somerville", "Cambridge",
                         "Boston", "Charlestown", "Everett", "Malden", "Melrose",
                         "Wakefield", "Chelsea", "Revere", "Winthrop", "Wilmington"]

    target_phrases = ["city of", "town of"]

    # adjust for the path for where you have the json files
    file_path = "/Users/cwm/Documents/GitHub/acresNLP/"
    json_file_path = "/Users/cwm/Library/CloudStorage/OneDrive-SharedLibraries-BostonUniversity/James, Allison - scraped_plans/"

    # adjust this for your computer
    file_names = [file for file in os.listdir(json_file_path) if file.endswith('.json')]
    file_names = sorted(file_names)
    print(file_names)

    with open(file_path + 'hazards.json', 'r') as file:
        hazard_data = json.load(file)

    with open(file_path + 'community_engagement_1.json', 'r') as file:
        engage_data = json.load(file)

    # Process all files and combine results into one table
    all_headers = None
    all_data = []

    for file_name in file_names:
        headers, data = process_file(json_file_path, file_name, hazard_data, engage_data)
        if all_headers is None:
            all_headers = headers
        all_data.append(data)

    # Save the combined results into a single TSV file
    combined_output = "\t".join(all_headers) + "\n" + "\n".join("\t".join(map(str, row)) for row in all_data)
    output_file = file_path + "combined_output1.tsv"

    with open(output_file, 'w') as f:
        f.write(combined_output)

    print(f"Combined TSV output has been saved to {output_file}")
