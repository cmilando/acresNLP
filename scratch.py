## ATTEMPT1 SIMPLE:
    READIN = False
    if not READIN:
        try:
            # Open the PDF URL (triggers download)
            driver.get(url)

            # Wait for the download to complete
            time.sleep(5)  # Adjust as necessary

            # Close the browser
            print(f"Download completed! Check: {file_prefix}")

            save_as = pdf_path

            # Find the downloaded file (assumes it's the most recent file in the directory)
            downloaded_files = sorted(
                [f for f in os.listdir(file_prefix) if f.endswith(".pdf")],
                key=lambda x: os.path.getctime(os.path.join(file_prefix, x)),
                reverse=True
            )

            if downloaded_files:
                latest_file = os.path.join(file_prefix, downloaded_files[0])
                new_path = os.path.join(file_prefix, save_as)

                # Rename the downloaded file to the desired filename
                shutil.move(latest_file, new_path)
                print(f"Download completed! File saved as: {new_path}")
            else:
                print("Download failed: No PDF found in the directory.")

            READIN = True

        # error catching
        except Exception as e:
            print(url)
            print(this_town_name)
            print(f"Failed to download the PDF. HTTP ERROR: Status code: {e}")


    print(f'Did firstpass work: {READIN}')
    ## ATTEMPT2 HARDER:
    if not READIN:
        print('Trying again a second time')
        try:
            # this chunk of code makes the request look like it's coming from a web browser rather than python.
            # it lets us scrape pages that are protected to block scraping.
            req = urllib.request.Request(url)
            req.add_header('User-Agent',
                           'Mozilla/5.0 (Macintosh; Apple Silicon Mac OS X 14_0_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36')
            req.add_header('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8')
            req.add_header('Accept-Language', 'en-US,en;q=0.5')

            # try to open url and read it
            time.sleep(10)
            response = urllib.request.urlopen(req)
            pdf_content = response.read()

            # check if it exists first - if not, then add it
            with open(pdf_path, 'wb') as pdf_file:
                pdf_file.write(pdf_content)

            # print(f"PDF has been saved to {pdf_path}")

        # error catching
        except Exception as e:
            print(url)
            print(this_town_name)
            print(f"Failed to download the PDF. HTTP ERROR: Status code: {e}")