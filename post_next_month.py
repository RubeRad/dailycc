#! /usr/bin/env python3

# pip3 install python-wordpress-xmlrpc

from wordpress_xmlrpc import Client, WordPressPost
from wordpress_xmlrpc.methods.posts import NewPost

from os.path  import exists
from datetime import datetime, date
import argparse, re, sys

def slurp(fname):
  if exists(fname):
    file  = open(fname)
    contents = file.read()
    return contents
  #else
  print('WARNING: file does not exist {}'.format(fname), file=sys.stderr)
  return ''

def post_file(wp, f, t, y, m, d):
  if exists(f):
    p = WordPressPost()
    p.title = t
    p.content = slurp(f)
    # All 3 sites are configured to UTC
    if re.search('deutsche', f):
      p.date = datetime(y,m,d,4)  #  4am UTC is 5am in UTC+1=Berlin
    else:
      p.date = datetime(y,m,d,10) # 10am UTC is 5am eastern, 2am pacific
    p.date_modified = p.date
    p.post_status = 'publish'
    p.comment_status = 'closed'
    if wp:
      wp.call(NewPost(p))
  else:
    print('WARNING: file does not exist {}'.format(f), file=sys.stderr)



parser = argparse.ArgumentParser("Post next month's Daily Confessions/Westminster")
parser.add_argument('-l', action='store_true',
                    help='Last month not next month')
parser.add_argument('-t', action='store_true',
                    help='Test (print but do not post)')
args = parser.parse_args()

# login to wordpress
dcurl = "https://dailyconfession.wordpress.com/xmlrpc.php"
dwurl = "https://dailywestminster.wordpress.com/xmlrpc.php"
tburl = "https://taeglichbekennen.wordpress.com/xmlrpc.php"
testurl = "https://dcimporttest.wordpress.com/xmlrpc.php"
try:    un = slurp('username.txt')
except: un = input("Enter username: ")
else:
  pass
try:    pw = slurp('password.txt')
except: pw = input("Enter password: ")
if args.t: # test only
  dw = dc = tb = None
else:
  dw = Client(dwurl, un, pw)
  dc = Client(dcurl, un, pw)
  tb = Client(tburl, un, pw)


# prepare to loop through days of year
tt = date.today().timetuple()
year   = tt[0]
thismo = tt[1]  # 1..12
if (args.l):
  thismo -= 1
nextmo = thismo+1
if nextmo>12:
  year+=1
  nextmo=1
monthnames = {1:'jan',2:'feb',3:'mar',4:'apr',5:'may',6:'jun',
              7:'jul',8:'aug',9:'sep',10:'oct',11:'nov',12:'dec'}
monam = monthnames[nextmo]

d      = date(year,1,1)      # count up from Jan 1
oneday = date(year,1,2) - d  # date delta of 1 day for incrementing
while True:
  if d.month > nextmo or d.year > year: # if we've made it past our month
    break                             # stop!
  elif d.month == nextmo: # if d is in the rith month, post a DC and a DW
    tt = d.timetuple()
    wday = tt[6]               # 0 = Monday
    yday = tt[7]               # 1 = jan1
    wnum = int((yday - 1) / 7) # 0..51

    # determine the appropriate Daily Confession for this day of current week #
    w = str(wnum+1) # most go weeks 1-52
    bnum = wnum # Belgic goes weeks 1-26 twice a year
    if bnum >= 26: bnum -= 26
    bw= str(bnum+1)

    if   wday == 0: dcf = 'cc/w'  + w + '.html'; dct="Children's Catechism, Week "+w
    elif wday == 1: dcf = 'sc/w'  + w + '.html'; dct=   "Shorter Catechism, Week "+w
    elif wday == 2: dcf = 'bcf/w' + bw+ '.html'; dct=   "Belgic Confession, Week "+bw
    elif wday == 3: dcf = 'lc/w'  + w + '.html'; dct=    "Larger Catechism, Week "+w
    elif wday == 4: dcf = 'sod/w' + w + '.html'; dct=     "Canons of Dordt, Week "+w
    elif wday == 5: dcf = 'wcf/w' + w + '.html'; dct="Westminster Confession, Week "+w
    elif wday == 6: dcf = 'hc/ld' + w + '.html'; dct="Heidelberg Catechism, Lord's Day "+w

    # Taeglich Bekennen!! Same as DC but with /deutsche/ subdir
    tbf = re.sub('/(w|ld)', '/deutsche/\\1', dcf)
    # post titles are in adjacent _title files
    tbt = slurp(re.sub('.html', '_title.html', tbf))

    # determine appropriate Daily Westminster for this day of the year
    month = monthnames[d.month] # number-->name
    dwf = "w/" + month
    if d.day < 10: dwf += '0'
    dwf += str(d.day) + '_esv.html'
    Month = month[0].upper() + month[1] + month[2]
    dwt = 'Daily Westminster, ' + Month + ' ' + str(d.day)

    # print and post
    print(dwf + '\t' + dwt + '\t' + dcf + '\t' + dct + '\t' + tbf + '\t' + tbt)
    post_file(dc, dcf, dct, d.year, d.month, d.day)
    post_file(dw, dwf, dwt, d.year, d.month, d.day)
    post_file(tb, tbf, tbt, d.year, d.month, d.day)

  d += oneday # keep counting
