#! /usr/bin/env python3

# scrape one full year of German-language Daily Confession from
# taeglichbekennen.wordpress.com/2010

import re, webbrowser, time
from datetime import datetime, date
import requests

urlbase = 'https://public-api.wordpress.com/rest/v1.1/sites/taeglichbekennen.wordpress.com/posts/?number=1&order=ASC&after='

year   = 2010
today  = date(2010, 1, 1)          # Heb 3:13
oneday = date(2010, 1, 2) - today

while today.year == year:
  iso = today.isoformat()
  url = urlbase + iso
  print(iso)
  response = requests.get(url)
  if response.status_code != 200:
    print("GET failed for " + iso)
    continue

  today += oneday



