#! /usr/bin/env python3

# pip3 install python-wordpress-xmlrpc

from wordpress_xmlrpc import Client, WordPressPost
from wordpress_xmlrpc.methods.posts import NewPost
from datetime import datetime
import glob
import re

def slurp(fname):
    file = open(fname)
    contents = file.read()
    return contents

def post_file(wp, f, t, y, m, d):
    p = WordPressPost()
    p.title = t
    p.content = slurp(f)
    # 9am zulu is early Eastern-Pacific
    p.date = p.date_modified = datetime(y,m,d,9)
    p.post_status = 'publish'
    p.comment_status = 'closed'
    wp.call(NewPost(p))

dcurl = "https://dailyconfession.wordpress.com/xmlrpc.php"
dwurl = "https://dailywestminster.wordpress.com/xmlrpc.php"
testurl = "https://dcimporttest.wordpress.com/xmlrpc.php"
try:    pw = slurp('password.txt')
except: pw = input("Enter password: ")

dw = Client(dwurl, 'RubeRad', pw)
dwjul = glob.glob("w/jul*_esv.html")
dwjul.sort()
for i in range(len(dwjul)):
    d = i+1
    title = "Daily Westminster 7/" + str(d) + "/2018"
    print(title, " ", dwjul[i])
    post_file(dw, dwjul[i], title, 2018, 7, d)

dc = Client(dcurl, 'RubeRad', pw)
dcfile = open('201807.txt')
for i in range(31):
    d = i+1
    fname = dcfile.readline().rstrip()
    if   re.match("cc", fname): title = "Children's Catechism"
    elif re.match("sc", fname): title = "Shorter Catechism"
    elif re.match("lc", fname): title = "Larger Catechism"
    elif re.match("wc", fname): title = "Westminster Confession"
    elif re.match("so", fname): title = "Synod of Dordt"
    elif re.match("bc", fname): title = "Belgic Confession"
    elif re.match("hc", fname): title = "Heidelberg Confession"
    title += " 7/" + str(d) + "/2018"
    print(title, " ", fname)
    post_file(dc, fname, title, 2018, 7, d)
