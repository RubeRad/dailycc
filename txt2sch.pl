#! /bin/perl

sub fil2str {
  my $fil = shift;
  my $dir;
  my $week;
  my $txt;
  my $let;
  my $nam;
  if ($fil =~ m!(\w+)/(w|ld)(\d+)!) { $dir = $1; $week = $3 }
  open CHOP, "$dir/chop.txt";
  for (1..$week) { $txt = <CHOP> }
  close CHOP;
  my @qs = split /\s+/, $txt;
  if ($dir eq 'sod') { 
    if ($txt =~ /\bc\b/) { return "Canons of Dordt, Conclusion" }
    
    $nam = "Canons of Dordt";
    $txt =~ s/h(\d+)([ae])//g;
    $head = "Head $1";
    $aore = uc($2);
    $head =~ s/Head 34/Heads 3-4/;
    @qs = split /\s+/, $txt;
    if (@qs > 1) {
      return "$nam, $head, $aore$qs[0]-$qs[-1]";
    } else {
      return "$nam, $head, $aore$qs[0]";
    }
  }
  
  if ($dir eq 'hc')  { 
    return "Heidelberg, Lord\'s Day $week";
  }


  if    ($dir eq 'lc')  { $let = 'Q'; $nam = 'Larger Catechism' }
  elsif ($dir eq 'sc')  { $let = 'Q'; $nam = 'Shorter Catechism' }
  elsif ($dir eq 'cc')  { $let = 'Q'; $nam = "Children's Catechism" }
  elsif ($dir eq 'wcf') { $let = '' ; $nam = 'Westminster Confession';
			  for (@qs) { s/c(\d+)p(\d+)/$1.$2/ } }
  elsif ($dir eq 'bcf') { $let = 'A'; $nam = 'Belgic Confession';
			  for (@qs) { s/a// } }
  if (@qs > 1) {
    return "$nam $let$qs[0]-$qs[-1]";
  } else {
    return "$nam $let$qs[0]";
  }
}


print qq(<table border="1">\n);
while (<>) {
  print " <tr>";
  ($day, $mon, $dat, $fil) = (split)[0,1,2,-1];

  if ($i % 7 == 0) {
    $week = $i/7+1;
    print "<td>Week $week</td>";
  } else {
    print "<td></td>";
  }
  $i++;

  print "<td>$day $mon $dat</td>";

  $str = fil2str($fil);
  print "<td>$str</td>";
  print "</tr>\n";
}
print "</table>\n";

exit;



use Time::Local;
use Getopt::Std;

%opt = ();
getopts("n:y:w", \%opt);

$y = $opt{y} || 2008;
$y -= 1900;
$t = timelocal(1,0,0,1,0,$y);

open HC, 'hc/chop.txt';  @hcs = (<HC>); close HC;
open CC, 'cc/chop.txt';  @ccs = (<CC>); close CC;
open SC, 'sc/chop.txt';  @scs = (<SC>); close SC;
open BC, 'bcf/chop.txt'; @bcs = (<BC>); close BC;
open BC, 'bcf/chop.txt'; push @bcs, (<BC>); close BC;
open LC, 'lc/chop.txt';  @lcs = (<LC>); close LC;
open CD, 'sod/chop.txt'; @cds = (<CD>); close CD;
open WC, 'wcf/chop.txt'; @wcs = (<WC>); close WC;

chomp @hcs;
chomp @ccs;
chomp @scs;
chomp @bcs;
chomp @lcs;
chomp @cds;
chomp @wcs;

print qq(<table border="1">\n);

sub nextdate {
  my $date = localtime($_[0]);
  $_[0] += 86400;
  $date =~ s/ \d\d:\d\d:\d\d \d\d\d\d//;
  return $date;
}

for $week (1..52) {

  print qq(<tr>\n);
  print qq(<td>Week $week</td>\n);
  $date = nextdate($t);
  print qq(<td>$date</td>\n);
  $qs = shift @scs;
  $str = txt2str($qs);
  print qq(<td>Shorter Catechism, $str</td>\n);
  print qq(</tr>\n);
  
  print qq(<tr>\n);
  print qq(<td>&nbsp;</td>\n);
  $date = nextdate($t);
  print qq(<td>$date</td>\n);
  $as = shift @bcs;
  $as =~ s/a//g;
  $str = txt2str($as,'A');
  print qq(<td>Belgic Confession, $str</td>\n);
  print qq(</tr>\n);
  
  print qq(<tr>\n);
  print qq(<td>&nbsp;</td>\n);
  $date = nextdate($t);
  print qq(<td>$date</td>\n);
  $qs = shift @lcs;
  $str = txt2str($qs);
  print qq(<td>Larger Catechism, $str</td>\n);
  print qq(</tr>\n);
  
  print qq(<tr>\n);
  print qq(<td>&nbsp;</td>\n);
  $date = nextdate($t);
  print qq(<td>$date</td>\n);
  $ws = shift @wcs;
  $ws =~ s/c//g;
  $ws =~ s/p/./g;
  $str = txt2str($ws, '');
  $str =~ s/Q//g;
  print qq(<td>Westminster Confession, $str</td>\n);
  print qq(</tr>\n);
  
  print qq(<tr>\n);
  print qq(<td>&nbsp;</td>\n);
  $date = nextdate($t);
  print qq(<td>$date</td>\n);
  $cs = shift @cds;
  if ($cs =~ s/h(\d+)//g) {
    $head = "Head $1";
    $head =~ s|34|3/4|;
  } else {
    $txt = "Conclusion";
  }
  if ($cs =~ s/a//g) {
    $art = txt2str($cs,'A');
    $txt = "$head, $art";
  } elsif ($cs =~ s/e//g) {
    $art = txt2str($cs,'E');
    $txt = "$head, $art";
  }
  print qq(<td>Canons of Dordt, $txt</td>\n);
  print qq(</tr>\n);

  print qq(<tr>\n);
  print qq(<td>&nbsp;</td>\n);
  $date = nextdate($t);
  print qq(<td>$date</td>\n);
  print qq(<td>Heidelberg, Lord's Day $week</td>\n);
  print qq(</tr>\n);

  print qq(<tr>\n);
  print qq(<td>&nbsp;</td>\n);
  $date = nextdate($t);
  print qq(<td>$date</td>\n);
  $qs = shift @ccs;
  $str = txt2str($qs);
  print qq(<td>Children's Catechism, $str</td>\n);
  print qq(</tr>\n);
}
print qq(</table>\n);

  
