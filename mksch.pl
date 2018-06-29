#! /bin/perl

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

sub txt2str {
  my @qs = split /\s+/, $_[0];
  my $let = $_[1] || 'Q';
  if (@qs > 1) {
    return "$let$qs[0]-$qs[-1]";
  } else {
    return "$let$qs[0]";
  }
}

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

  
