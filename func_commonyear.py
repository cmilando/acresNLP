import re
from collections import Counter


def find_most_common_year(text, this_current_year):
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
    valid_years = [int(year) for year in years if 1900 <= int(year) <= this_current_year]  # after 1900

    if not valid_years:
        return None, None

    year_counts = Counter(valid_years)
    most_common_year = year_counts.most_common(1)[0][0]

    return most_common_year
