#! /usr/bin/env python3

# pip3 install python-wordpress-xmlrpc

from wordpress_xmlrpc import Client, WordPressPost
from wordpress_xmlrpc.methods.posts import NewPost

dcurl = "https://dailyconfession.wordpress.com/xmlrpc.php"
dwurl = "https://dailywestminster.wordpress.com/xmlrpc.php"
testurl = "https://dcimporttest.wordpress.com/xmlrpc.php"
pw    = input("Enter password: ")
wp = Client(testurl, 'RubeRad', pw)

post = WordPressPost()
post.title = 'test'
post.content = 'testing 1 2 3'
wp.call(NewPost(post))






