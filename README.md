# Data Scraping and Processing Scripts

This project contains two separate scripts for fetching and processing data from different web sources.

1.  `scrape.py`: A Python script to scrape product listing data from the OLX India website.
2.  `script.sh`: A shell script to fetch and format mutual fund NAV data from AMFI India.

---

## 1. `scrape.py` - OLX Product Scraper

This Python script automates the process of scraping product data from OLX. It uses the Selenium framework to control a web browser, navigate to a specific search results page, and extract details for relevant products.

### Purpose

The script is configured to:
- Launch a Chrome browser instance.
- Navigate to the OLX search results for "car cover".
- Find all product listings on the page.
- For each product where the title contains "car cover", it extracts the **Title**, **Price**, and **Location**.
- Print the final collection of scraped products to the console in a clean JSON format.

### Dependencies

To run this script, you will need:
- **Python 3**
- **Selenium** library for Python.
- **WebDriver** for Chrome (or another browser). The script is configured for Chrome.

### How to Use

1.  **Install Dependencies**:
    If you do not have Selenium installed, open your terminal and run:
    ```
    pip install selenium
    ```
    You must also have Google Chrome and the corresponding [ChromeDriver](https://googlechromelabs.github.io/chrome-for-testing/) installed and accessible in your system's PATH.

2.  **Run the Script**:
    Execute the script from your terminal:
    ```
    python scrape.py
    ```

### Output

The script will print a JSON array of objects to your console. Each object represents a product that matched the search criteria.

**Example Output:**
```json
[
  {
    "title": "Brand new car seat cover and massager",
    "price": "₹ 2,000",
    "location": "Siddhartha Nagar, Delhi"
  },
  {
    "title": "Car cover for Maruti Suzuki eeco all new not used before",
    "price": "₹ 800",
    "location": "Igra Colony, Jamshedpur"
  }
]
```

---

## 2. `script.sh` - AMFI NAV Extractor

This is a robust shell script designed to reliably fetch and parse the latest Net Asset Value (NAV) data for all mutual fund schemes from the official AMFI India data file.

It is built to handle format changes gracefully and ensure the output is clean and well-structured.

### Purpose

The script automates the following process:
- Downloads the complete NAV text file from the AMFI India website into a secure temporary file.
- Intelligently detects if the file contains a header row.
- **If a header exists**, it dynamically finds the correct columns for "Scheme Name" and "Net Asset Value" by parsing the header names.
- **If no header exists**, it uses smart heuristics to guess the correct columns based on their content (e.g., looking for the longest text field for the name and a numeric field for the value).
- Cleans the extracted data by trimming whitespace and removing characters that could corrupt the output file.
- Saves the final, clean data into a **Tab-Separated Values (TSV)** file named `nav_scheme_asset.tsv`.

### Dependencies

This script relies on standard command-line tools that are pre-installed on most Unix-like systems (Linux, macOS, WSL on Windows).
- `curl` (for fetching the URL content)
- `awk` (for processing the text data)
- `grep`, `head`, `mktemp`

### How to Use

1.  **Make the Script Executable**:
    It's good practice to make the script executable first. In your terminal, run:
    ```
    chmod +x script.sh
    ```

2.  **Run the Script**:
    Execute the script from your terminal:
    ```
    ./script.sh
    ```

### Output

The script will create a file named `nav_scheme_asset.tsv` in the same directory. This file will contain two columns, `SchemeName` and `AssetValue`, separated by a tab.

**Example `nav_scheme_asset.tsv` content:**
```tsv
SchemeName	AssetValue
Axis Long Term Equity Fund - Direct Plan - Growth	113.63
Axis Long Term Equity Fund - Direct Plan - IDCW	48.34
Mirae Asset ELSS Tax Saver Fund - Direct - Growth	52.96
...and so on
```
