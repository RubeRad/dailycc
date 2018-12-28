#! /usr/bin/env python3

# scrape one full year of German-language Daily Confession from
# taeglichbekennen.wordpress.com/2010

import re, webbrowser, time
from datetime import datetime, date
import requests
import json

url_after = 'https://public-api.wordpress.com/rest/v1.1/sites/taeglichbekennen.wordpress.com/posts/?number=1&order=ASC&after='

year   = 2010
today  = date(2010, 1, 1)          # Heb 3:13
oneday = date(2010, 1, 2) - today

problems = []

while today.year == year:
  yesterday = today - oneday
  url = url_after + yesterday.isoformat()
  iso = today.isoformat()
  response = requests.get(url)
  if response.status_code != 200:
    print("GET failed for " + iso)
    today += oneday
    continue

  post = response.json()['posts'][0]
  datestr = re.sub('T.*', '', post['date'])
  pdate = datetime.strptime(datestr, '%Y-%m-%d').date()
  if pdate != today:
    print("Date mismatch for " + iso)
    problems.append(iso)
    today += oneday
    continue
  title = post['title']
  print(datestr + ' ' + title, end=' --> ')

  if   re.match('Der k',   title): fname = 'sc'
  elif re.match('Der gro', title): fname = 'lc'
  elif re.match('Westmin', title): fname = 'wcf'
  elif re.match('Kinder',  title): fname = 'cc'
  elif re.match('Die Leh', title): fname = 'sod'
  elif re.match('Das Nie', title): fname = 'bcf'
  elif re.match('Heidelb', title): fname = 'hc'
  else:
    print("Unknown post type: "+title)
    today += oneday
    continue
  fname += '/deutsche/'

  match = re.search('(\\d+)\\.Woche', title)
  if match:
    fname += 'w' + match.group(1)
  else:
    match = re.search('(\\d+)\\.Sonntag', title)
    if match:
      fname += 'ld' + match.group(1)
    else:
      print("Could not find week number in " + title)
      today += oneday
      continue

  print(fname)
  cfile = open(fname + '.html', 'w')
  cfile.write(post['content'])
  cfile.close()
  tfile = open(fname + '_title.html', 'w')
  tfile.write(title) # this way I don't have to wrangle the Umlauts and such
  tfile.close()

  today += oneday


print("\n\nProblem dates:")
for problem in problems:
  print(problem)



