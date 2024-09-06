def ma_url(url):
    """
    Checks if the URL contains '.ma', indicating it is a Massachusetts government document.

    Args:
    url (str): The URL to check.

    Returns:
    int: 1 if the URL contains 'ma.', 0 otherwise.
    """
    if "ma." in url.lower():
        # print("MA url")
        return 1
    else:
        return 0


def org_url(url):
    """
    Checks if the URL contains '.ma', indicating it is a Massachusetts government document.

    Args:
    url (str): The URL to check.

    Returns:
    int: 1 if the URL contains 'ma.', 0 otherwise.
    """
    if (".org" in url.lower() or ".edu" in url.lower() or
            ".gov" in url.lower()):
        # print("known url")
        return 1
    else:
        return 0
