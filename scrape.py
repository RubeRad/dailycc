#! /usr/bin/env python3

# scrape one full year of German-language Daily Confession from
# taeglichbekennen.wordpress.com/2010

import re, webbrowser, time
from datetime import datetime, date
from selenium import webdriver # pip3 install Selenium

#page = webdriver.Chrome()

today  = date(2010, 1, 1)          # Heb 3:13
oneday = date(2010, 1, 2) - today

while today.year == 2010:
  m = str(today.month)
  d = str(today.day)
  url = 'https://taeglichbekennen.wordpress.com/2010/'+m+'/'+d
  print(url)
  today += oneday
