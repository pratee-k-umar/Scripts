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
  driver = webdriver.Chrome(options = options)
  driver.get("https://www.olx.in/items/q-car-cover")
  print("Page loaded...")
  
  wait = WebDriverWait(driver, 20)
  
  item_list_container = wait.until(
    EC.presence_of_element_located((By.CSS_SELECTOR, "ul[data-aut-id='itemsList1']"))
  )
  
  time.sleep(2)
  
  item_cards = item_list_container.find_elements((By.CSS_SELECTOR, "li[data-aut-id='itemBox3']"))
  
  if not item_cards:
    print("No item card found..!")
  
  for index, card in enumerate(item_cards):
    try:
      title_element = card.find_element((By.CSS_SELECTOR, "div[data-aut-id='itemTitle']"))
      
      data.append(title_element.text)
    except NoSuchElementException:
      print("No title found...")

except TimeoutException:
  print("Timed out waiting for page to load")
except Exception as e:
  print(e)
finally:
  if driver:
    print("Closing the browser")
    driver.quit()

print(data)