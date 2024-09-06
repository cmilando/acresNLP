import re
from collections import Counter


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
