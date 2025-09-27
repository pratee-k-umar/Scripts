import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException

options = webdriver.ChromeOptions()

driver = None
data = []

try:
    print("Starting the browser...")
    driver = webdriver.Chrome(options=options)
    driver.get("https://www.olx.in/items/q-car-cover")
    print("Page loaded...")

    wait = WebDriverWait(driver, 20)

    item_list_container = wait.until(
        EC.presence_of_element_located(
            (By.CSS_SELECTOR, "ul[data-aut-id='itemsList1']")
        )
    )

    time.sleep(2)

    item_cards = item_list_container.find_elements(
        By.CSS_SELECTOR, "li[data-aut-id='itemBox3']"
    )

    for index, card in enumerate(item_cards):
        try:
            title_element = card.find_element(
                By.CSS_SELECTOR, "span[data-aut-id='itemTitle']"
            )
            if "car cover" not in title_element.text.lower():
                continue

            # product_url = card.find_element(By.TAG_NAME, "a").get_attribute("href")
            # product_image = card.find_element(By.TAG_NAME, "img").get_attribute("src")
            product_price = card.find_element(
                By.CSS_SELECTOR, "span[data-aut-id=itemPrice]"
            )

            product = {
                "title": title_element.text,
                "price": product_price.text,
                # "url": product_url
            }
            data.append(product)
        except NoSuchElementException:
            print(f"Could not find the title element {index}")

except TimeoutException:
    print(
        "[ERROR] Timed out waiting for the page to load. The 'itemsList' container was not found."
    )
except Exception as e:
    print(f"An unexpected error occurred: {e}")
finally:
    if driver:
        print("\nClosing the browser.")
        driver.quit()

with open("product.txt", "w", encoding="utf-8") as file:
    for product in data:
        file.write(f"Title: {product['title']}\n")
        file.write(f"Price: {product['price']}\n")
        file.write("\n")
