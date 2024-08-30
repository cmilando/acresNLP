READ ME for NLP processing

All of the code is complete, so all you have to do is run it. Scrape_from_url.py is run individually for each town, 
and chad_test.py is run once all together.

To get the data prepared to run:
1) go to the Community PDF finder and copy paste all URL's for a particular town into a JSON file. Put them into array format: ["pdf1", "pdf2", etc]
2) save this json in the subdirectory called "url_lists" with the name format "townnameurl_list.json"
3) run scrape_from_url.py with the name format "townnameurl" (ex: bostonurl)
    - this will take a while because it's scraping long pdf's and saving the text.
    - the rate is a few pdf's a minute, but may be faster on other machines.
4) this will create a json file for each pdf in the subdirectory "scraped_plans". the pdf's themselves are saved in a subdirectory of "scraped_plans" called "pdfs".
5) once you have a .json file for each url, you are ready to run chad_test.
    - this will take way less time because the data is now in plain text format (much easier to work with).
    - this script only takes a few minutes.
6) as long as all the json's are in scraped_plans, you don't have to do anything. it will create an outputted .tsv file called "combined_output.tsv". ignore the csv version.
7) code to start analyzing this data is in R, called "hazard_counts.R".