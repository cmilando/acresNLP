import re
from collections import Counter


def count_keyword_occurrences(text, categories, strict):
    """
    Counts occurrences of words in each given category.

    Args:
    text (str): The text to search within.
    categories (dict): A dictionary where keys are category names and values are
    lists of words or phrases in each category.

    Returns:
    dict: A dictionary with category names as keys and the sum of word counts in
    each category as values.
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
            category_pcts[category] = round(category_counts[category] / total_sum * 100, ndigits=3)
        else:
            category_pcts[category] = category_counts[category] * 0

    return category_counts, category_pcts

# generate table of hazard frequencies for this pdf
# also account for chars before and after #####
# list of words that begin w/ hazards, edit list manually (this new script - take multiple pdfs)
# can find old links/pdfs with way-back machine
