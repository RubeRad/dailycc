#! /bin/perl

use Time::Local;
use Getopt::Std;

%opt = ();
getopts("h:y:m", \%opt);

$year = $opt{y} || 2009;
$yn = $year - 1900;

$hdr = $opt{h} || 'dw.hdr';
open HDR, $hdr || die "Can't find header -h $hdr\n";
#while (<HDR>) { print; }
@hdrlines = (<HDR>);
close HDR;

%dateToNum = (Jan=>0,Feb=>1,Mar=>2,Apr=>3,May=>4,Jun=>5,
	      Jul=>6,Aug=>7,Sep=>8,Oct=>9,Nov=>10,Dec=>11,
	      jan=>0,feb=>1,mar=>2,apr=>3,may=>4,jun=>5,
	      jul=>6,aug=>7,sep=>8,oct=>9,nov=>10,dec=>11,
	      JAN=>0,FEB=>1,MAR=>2,APR=>3,MAY=>4,JUN=>5,
	      JUL=>6,AUG=>7,SEP=>8,OCT=>9,NOV=>10,DEC=>11);

sub dateToSMHDMY {
  $_[0] =~ /\w{3} (\w{3})\s+(\d+)\s+(\d+):(\d+):(\d+)\s+(\d+)/;
  return ($5,$4,$3,$2,$dateToNum{$1},$6);
}

sub titleOfFile {
  my $fil = shift;

  open IN, $fil;
  my $txt = join '', (<IN>);
  close IN;

  my @rets;

  if ($txt =~ /Westminster Confession.*c(\d+)p(\d+)/s) {
    push @rets, "WCF $1.$2";
  }

  if ($txt =~ /Larger Catechism.*?q(\d+)/s) {
    push @rets, "LC $1";
  }

  if ($txt =~ /Shorter Catechism.*?q(\d+)/s) {
    push @rets, "SC $1";
  }
  
  return (join ', ', @rets);
}

print @hdrlines unless $opt{m};

for $mon (qw(jan feb mar apr may jun jul aug sep oct nov dec)) {
  $m0 = $dateToNum{$mon};
  $mn = $m0 +1;
  if ($opt{m}) {
    $fname = sprintf "%4d%02d.xml", $year, $mn;
    open XML, ">$fname";
    print XML @hdrlines;
  }

  for $day (1..31) {
    $fl = sprintf "$mon%02d.html", $day;
    next unless -r $fl;

    $t = timelocal(1,0,0,$day,$m0,$yn);
    $_ = localtime($t);
    ($dw, $mw, $dy, $hms, $yr) = (split);
    ($hr, $mi, $sc) = (split /:/, $hms);
    $item  = "<item>\n";

    $tl = titleOfFile($fl);
    $item .= " <title>$tl</title>\n";

    $slug = lc($tl);
    $slug =~ s/\, /_/g;
    $slug =~ s/\./_/g;
    $slug =~ s/\W+//g;
    $item .= " <link>http://dailywestminster.wordpress.com/$yr/$mn/$dy/$slug/</link>\n";

    $item .= " <pubDate>$dw, $dy $mw $yr $hms +0000</pubDate>\n";

    $item .= " <dc:creator>RubeRad</dc:creator>\n";

    $ct = 'General';
    $item .= " <category>$ct</category>\n";

    $item .=qq( <guid isPermaLink="false">http://dailywestminster.wordpress.com/$yr/$mn/$dy/$slug/</guid>\n);

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
    if ($opt{m}) {
      print XML $item;
    } else {
      print $item;
    }
  } # for each day of the current month
  print XML "</channel>\n";
  print XML "</rss>\n";
  close XML;
} # for each month
  
print "</channel>\n" unless $opt{m};
print "</rss>\n"     unless $opt{m};
