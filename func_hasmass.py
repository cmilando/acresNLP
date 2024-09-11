import re
from collections import Counter


def has_massachusetts(text):
    """
    Checks if 'Massachusetts' is the most common state mentioned in the provided text.

    Args:
    page_text (str): The text to search for state mentions.
    states_file_path (str): Path to the text file containing the list of US states.

    Returns:
    int: 1 if Massachusetts is the most common state, 0 otherwise.
    """
    states_file_path = 'all_states.txt'

    # Read the list of states from the file
    with open(states_file_path, 'r') as file:
        states = [line.strip().lower() for line in file.readlines()]

    # Create a regex pattern to find any of the town names, ensuring case-insensitive matching
    pattern = r'\b(' + '|'.join(map(re.escape, states)) + r')\b'

    matches = re.findall(pattern, text.lower(), re.IGNORECASE)

    if not matches:
        return None

    state_counts = Counter(matches)
    most_common_state = state_counts.most_common(1)[0][0]

    # Check if Massachusetts is the most common state
    return most_common_state

