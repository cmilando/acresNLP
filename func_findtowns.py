import re
from collections import Counter


def find_towns(text, these_target_phrases):
    """
    Finds the most common words that occur immediately before and after "city" and "town".

    Args:
    text (str): The text in which to search for the phrases.
    target_phrases (list): List of phrases to search for.

    Returns:
    dict: A dictionary with keys 'before' and 'after' containing the most common words
          found before and after the target phrases, respectively.
    """
    # creates a pattern of a word before or after the target phrases
    pattern = r'\b(\w+)\s+(' + '|'.join(map(re.escape, these_target_phrases)) + r')\s+(\w+)\b'

    matches = re.findall(pattern, text, re.IGNORECASE)

    if not matches:
        return {'before': None, 'after': None}

    # Split matches into before and after
    before_words = [match[0] for match in matches]
    after_words = [match[2] for match in matches]

    most_common_before = Counter(before_words).most_common(1)[0][0] if before_words else None
    most_common_after = Counter(after_words).most_common(1)[0][0] if after_words else None

    return {'before': most_common_before, 'after': most_common_after}
