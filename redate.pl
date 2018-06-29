#! /usr/bin/perl

use Time::Local;
use Getopt::Std;
use POSIX (qw(strftime));


%opt = ();
getopts("n:y:w", \%opt);

$yr = $opt{y} || 2013;
$t = timelocal(1,0,8,1,0,$yr-1900);



@alllns = (<>);
$alltxt = join '', @alllns;

$alltxt =~ s!(.*?)<item>!<item>!s;
$header = $1;
@olditems = ($alltxt =~ m!(<item>.*?</item>)!gs);

for $item (@olditems) {
  $item =~ m!<title>(.*?)</title>!;
  $title = $1;

  $title =~ m!(\d+)$!;
  $week = $1;
  $week--;

  if    ($title =~ /Heidelberg/) { $hc[$week] = $item }
  elsif ($title =~ /Children/)   { $cc[$week] = $item }
  elsif ($title =~ /Shorter/)    { $sc[$week] = $item }
  elsif ($title =~ /Larger/)     { $lc[$week] = $item }
  elsif ($title =~ /ster Con/)   { $wc[$week] = $item }
  elsif ($title =~ /Belgic/)     { $bc[$week] = $bc[$week+26] = $item }
  elsif ($title =~ /Dordt/)      { $cd[$week] = $item }
  #else { die "what's this?: $title\n"; }
}

for $day (1..364) {
  #$pubDate = strftime "%a, %0e %b %Y %H:%M:%S +0000", localtime($t);
  $pubDate = strftime "%a, %0e %b %Y", localtime($t);
  $post_date = strftime "%Y-%0m-%0e", localtime($t);
  #($post_date_gmt = $post_date) =~ s!00:00:01!08:00:01!;
  #$pubDate = localtime($t);
  #print "$pubDate\n";

  if    ($pubDate =~ /^Sun/) { $item = shift @hc }
  elsif ($pubDate =~ /^Mon/) { $item = shift @cc }
  elsif ($pubDate =~ /^Tue/) { $item = shift @sc }
  elsif ($pubDate =~ /^Wed/) { $item = shift @bc }
  elsif ($pubDate =~ /^Thu/) { $item = shift @lc }
  elsif ($pubDate =~ /^Fri/) { $item = shift @cd }
  elsif ($pubDate =~ /^Sat/) { $item = shift @wc }
  else { die "what day is it? $pubDate\n" }

  $item =~ s!<pubDate>(.*?20\d\d)(.*?)</pubDate>!<pubDate>$pubDate$2</pubDate>!;
  $item =~ s!<wp:post_date>(20\d\d\-\d+\-\d+)(.*?)</wp:post_date>!<wp:post_date>$post_date$2</wp:post_date>!;
  $item =~ s!<wp:post_date_gmt>(20\d\d\-\d+\-\d+)(.*?)</wp:post_date_gmt>!<wp:post_date_gmt>$post_date$2</wp:post_date_gmt>!;
  #$item =~ s!<wp:post_name>(.*)</wp:post_name>!<wp:post_name>${1}_$yr</wp:post_name>!;
  $item =~ s!/2012/!/$yr/!g;
  $item =~ s!<wp:status.*</wp:status>!<wp:status>future</wp:status>!;
  #$item =~ s!\s*<wp:postmeta.*?wp:postmeta>!!gs;
  #$item =~ s!\s*<link>.*?</link!!;
  #$item =~ s!\s*<guid.*</guid>!!;
  #$item =~ s!\s*<description.*</description>!!;
  #$item =~ s!\s*<excerpt:endocde.*</excerpt:encoded>!!;
  #$item =~ s!\s*<wp:post_id.*</wp:post_id>!!;
  #$item =~ s!\s*<wp:post_parent.*</wp:post_parent>!!;
  #$item =~ s!\s*<wp:menu_order.*</wp:menu_order>!!;
  #$item =~ s!\s*<wp:post_password.*</wp:post_password>!!;
  #$item =~ s!\s*<category.*</category>!!;
  #$item =~ s!\s*<wp:post_date>.*</wp:post_date>!!;
  push @items, $item;

  $t += 86400;
}

for $mo (qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)) {
    open XML, ">dc$yr$mo.xml";
    print XML $header;
    for (@items) {
      next unless /pubDate.*$mo $yr.*pubDate/;
      print XML;
    }
    print XML "</channel>\n";
    print XML "</rss>\n";
    close XML;
}






