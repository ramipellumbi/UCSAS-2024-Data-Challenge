from selenium import webdriver
from selenium.webdriver.common.by import By
import time
import csv

driver = webdriver.Chrome()
driver.get("https://www.gymperium.eu/Gymnasts/")

time.sleep(5)

tables = driver.find_elements(By.TAG_NAME, 'table')

row_data = []
for table in tables:
    try:
        for i in range(0, 200):
            row = table.find_element(By.ID, f'Vertical_v13_60667780_LE_v13_DXDataRow{i}')
            if row:
                cells = row.find_elements(By.TAG_NAME, 'td')
                if cells:
                    row_data.append([cell.text for cell in cells])
    except Exception as e:
        print(e)

driver.quit()

with open('gymnasts_data.csv', 'w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerows(row_data)
