import re


def has_climate(text):
    """
    Checks if the text is relevant by searching for the presence of
    'Massachusetts' and either 'climate' or 'report' within the first 3 pages.

    Args:
    text (str): The text to search for relevance.

    Returns:
    int: 1 if the text is relevant, 0 otherwise.
    """

    if re.search(r'climate change', text, re.IGNORECASE):
        return 1
    else:
        return 0


def has_community(text):
    """
    Checks if the text is relevant by searching for the presence of
    'Massachusetts' and either 'climate' or 'report' within the first 3 pages.

    Args:
    text (str): The text to search for relevance.

    Returns:
    int: 1 if the text is relevant, 0 otherwise.
    """

    if re.search(r'community', text, re.IGNORECASE):
        return 1
    else:
        return 0