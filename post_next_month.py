#! /usr/bin/env python3

# pip3 install python-wordpress-xmlrpc

from wordpress_xmlrpc import Client, WordPressPost
from wordpress_xmlrpc.methods.posts import NewPost
from datetime import datetime

def slurp(fname):
    file = open(fname)
    contents = file.read()
    return contents


dcurl = "https://dailyconfession.wordpress.com/xmlrpc.php"
dwurl = "https://dailywestminster.wordpress.com/xmlrpc.php"
testurl = "https://dcimporttest.wordpress.com/xmlrpc.php"
try:    pw = slurp('password.txt')
except: pw = input("Enter password: ")
wp = Client(testurl, 'RubeRad', pw)

post = WordPressPost()
post.title = 'test6'
post.content = slurp('sc/w1.html')
dt = datetime(2018,7,1,9,0,0,0) # 9am GMT is 4/1am Eastern/Pacific
post.date = post.date_modified = dt
post.post_status = 'publish'
post.comment_status = 'closed'
wp.call(NewPost(post))






