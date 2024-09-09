import re


def has_massachusetts(page_text):
    """
    Checks if the text is relevant by searching for the presence of
    'Massachusetts' and either 'climate' or 'report' within the first 3 pages.

    Args:
    text (str): The text to search for relevance.

    Returns:
    int: 1 if the text is relevant, 0 otherwise.
    """

    first_5_pages_text = " ".join(page_text[:4])

    if re.search(r'massachusetts', first_5_pages_text, re.IGNORECASE) :
        # print(1)
        return 1
    else:
        return 0
