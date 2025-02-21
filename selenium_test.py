from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
import os
import time
import shutil

# URL of the PDF file
pdf_url = "https://www.tbf.org/-/media/tbf/reports-and-covers/2022/november/bf_climatefinal_spread.pdf"

# Set download directory (modify as needed)
download_dir = os.getcwd()  # Change this to your desired directory

# Set up Chrome options
chrome_options = Options()
chrome_options.add_experimental_option("prefs", {
    "download.default_directory": download_dir,
    "download.prompt_for_download": False,
    "download.directory_upgrade": True,
    "plugins.always_open_pdf_externally": True,  # Bypass PDF viewer
})
chrome_options.add_argument("--headless")  # Run Chrome in headless mode
chrome_options.add_argument("--disable-gpu")  # Disable GPU acceleration
chrome_options.add_argument("--no-sandbox")  # Bypass OS security model
chrome_options.add_argument("--disable-dev-shm-usage")  # Overcome limited resource issues

# Path to ChromeDriver (modify if necessary)
chrome_driver_path = "/opt/homebrew/bin/chromedriver"  # Update this path

# Start WebDriver
service = Service(chrome_driver_path)
driver = webdriver.Chrome(service=service, options=chrome_options)

# Open the PDF URL (triggers download)
driver.get(pdf_url)

# Wait for the download to complete
time.sleep(5)  # Adjust as necessary

# Close the browser
driver.quit()

print(f"Download completed! Check: {download_dir}")

save_as = 'new_name.pdf'

# Find the downloaded file (assumes it's the most recent file in the directory)
downloaded_files = sorted(
    [f for f in os.listdir(download_dir) if f.endswith(".pdf")],
    key=lambda x: os.path.getctime(os.path.join(download_dir, x)),
    reverse=True
)

if downloaded_files:
    latest_file = os.path.join(download_dir, downloaded_files[0])
    new_path = os.path.join(download_dir, save_as)

    # Rename the downloaded file to the desired filename
    shutil.move(latest_file, new_path)
    print(f"Download completed! File saved as: {new_path}")
else:
    print("Download failed: No PDF found in the directory.")