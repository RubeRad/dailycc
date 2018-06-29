#! /usr/bin/perl

while (<>) {
    if (/name="fn\d+" target.*\[(\d+)\]/) {
	$footnum = $1;
	@refs = /<strong>(.*?)<\/strong>/g;
	$scripture{$footnum} = join ',', @refs;
	$scripture{$footnum} =~ s/\.| //g;
	next;
    }
    if (/(\d+)\.\s*Lord.s Day/) {
      $tag = "ld$1";
      chomp;
      print qq(<p align="center"><a name="$tag" title="$tag"></a><b>$_<\/b></p>\n);
      next;
    }
    s|^(\d\.\s+.*)|<p>\1</p>|;
    s|(\w)\W\W\Ws|\1's|g; # '
    s|Q\. (\d+)\. (.+)|<p><a name="q\1" title="q\1"></a>Q. \1. <b>\2</b><br />|;
    s|A\. (.+)|A. \1</p>|;
    if (/^A\.|^<p>\d/) {
	s|\[(\d+)\]|<sup><a href="http://biblegateway.com/passage/?search=$scripture{$1}\&version=47">[\1]</a></sup>|g;
    }
    print if /^<|^A\.|\(a\)/;
}
