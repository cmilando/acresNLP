import spacy
from collections import Counter


# sites of concern = {frequency table of ALL proper nouns}
# words that are capitalized but not after a period
# should be its own function
def count_proper_nouns(text):
    # filter out numbers

    # load the english NLP model
    nlp = spacy.load('en_core_web_sm')

    # model processes text
    processed = nlp(text)
    all_words = set(token.text for token in processed)
    lowercase_words = set(word.lower() for word in all_words if word.islower())
    proper_nouns = []

    # part of speech tagging extracts proper nouns
    for token in processed:
        if token.pos_ == 'PROPN':  # Token is a proper noun
            # Check if the lowercase version of this proper noun appears in the lowercase_words set
            if token.text.lower() not in lowercase_words:
                proper_nouns.append(token.text)

    # now count proper nouns
    frequencies = Counter(proper_nouns)

    return frequencies

# proper_noun_table = count_proper_nouns(text)
# print(proper_noun_table)
