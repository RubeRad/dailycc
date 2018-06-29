#! /bin/perl

use Time::Local;
use Getopt::Std;

%opt = ();
getopts("h:", \%opt);

open HDR, $opt{h} || die "Can't find header -h $opt{h}\n";
while (<HDR>) { print; }

%dateToNum = (Jan=>0,Feb=>1,Mar=>2,Apr=>3,May=>4,Jun=>5,
	      Jul=>6,Aug=>7,Sep=>8,Oct=>9,Nov=>10,Dec=>11);

sub dateToSMHDMY {
  $_[0] =~ /\w{3} (\w{3})\s+(\d+)\s+(\d+):(\d+):(\d+)\s+(\d+)/;
  return ($5,$4,$3,$2,$dateToNum{$1},$6);
}

sub titleOfFile {
  my $fil = shift;
  if ($fil =~ /hc\/ld(\d+)/) {
    return "Heidelberg Catechism, Lord's Day $1"; }
  if ($fil =~ /(.+)\/w(\d+)/) {
    my $which = {cc=>"Children's Catechism",
		 sc=>"Shorter Catechism",
		 lc=>"Larger Catechism",
		 wcf=>"Westminster Confession",
		 bcf=>"Belgic Confession",
		 sod=>"Canons of Dordt" }->{$1};
    return "$which, week $2";
  }
    
  if ($fil =~ /(.c)\/q(\d+)/) {
    my $which = {cc=>"Children's",
		 sc=>"Shorter",
		 lc=>"Larger"}->{$1};
    return "$which Catechism Question $2"; }

  if ($fil =~ /bcf\/a(\d+)/) {
    return "Belgic Confession, Article $1"; }

  if ($fil =~ /sod\/h(\d+)([ae])(\d+)/) {
    my $ae = ($2 eq 'a' ? 'Article' : 'Error');
    return "Canons of Dordt, Head $1, $ae $3"; }

  if ($fil =~ /sod\/c/) {
    return "Canons of Dordt, Conclusion"; }
}

sub categoryOfFile {
  $_[0] =~ /(\w+)\/.*\.html/;
  return {
    hc =>"<![CDATA[0 Lord's Day: Heidelberg Catechism]]>",
    cc =>"<![CDATA[1 Mon: Children's Catechism]]>",
    sc =>"<![CDATA[2 Tue: Shorter Catechism]]>",
    bcf=>"<![CDATA[3 Wed: Belgic Confession]]>",
    lc =>"<![CDATA[4 Thu: Larger Catechism]]>",
    sod=>"<![CDATA[5 Fri: Canons of Dordt]]>",
    wcf=>"<![CDATA[6 Sat: Westminster Confession]]>"
  }->{$1};
}


while (<>) {
  ($dw, $mw, $dy, $hms, $yr, $fl) = (split);
  $m0 = $dateToNum{$mw};
  $mn = $m0 +1;
  ($hr, $mi, $sc) = (split /:/, $hms);
  $item  = "<item>\n";

  $tl = titleOfFile($fl);
  $item .= " <title>$tl</title>\n";

  ($slug=$fl) =~ s/\.html//;
  $slug =~ s/\W/_/;
  $item .= " <link>http://dailyconfession.wordpress.com/$yr/$mn/$dy/$slug/</link>\n";

  $item .= " <pubDate>$dw, $dy $mw $yr $hms +0000</pubDate>\n";

  $item .= " <dc:creator>RubeRad</dc:creator>\n";

  $ct = categoryOfFile($fl);
  $item .= " <category>$ct</category>\n";

  $item .=qq( <guid isPermaLink="false">http://dailyconfession.wordpress.com/$yr/$mn/$dy/$slug/</guid>\n);

  $item .= " <description>$tl</description>\n";

  $item .= " <content:encoded><![CDATA[";
  open IN, $fl;
  while (<IN>) { $item .= $_ }
  close IN;
  $item =~ s/\s+$//;
  $item .= "]]></content:encoded>\n";

  $pn++;
  $gh = $hr + 8;
  $item .= " <wp:post_id>$pn</wp:post_id>\n";
  $item .= " <wp:post_date>$yr-$mn-$dy $hr:$mi:$sc</wp:post_date>\n";
  $item .= " <wp:post_date_gmt>$yr-$mn-$dy $gh:$mi:$sc</wp:post_date_gmt>\n";
  $item .= " <wp:comment_status>closed</wp:comment_status>\n";
  $item .= " <wp:ping_status>closed</wp:ping_status>\n";
  $item .= " <wp:post_name>$slug</wp:post_name>\n";
  $item .= " <wp:status>publish</wp:status>\n";
  $item .= " <wp:post_parent>0</wp:post_parent>\n";
  $item .= " <wp:menu_order>0</wp:menu_order>\n";
  $item .= " <wp:post_type>post</wp:post_type>\n";
  
  $item .= "</item>\n";
  print $item;
}
  
print "</channel>\n";
print "</rss>\n";
