#! /bin/perl

# DEPENDENCIES:
# sudo apt-get install libexpat1-dev
# sudo apt-get install libssl-dev
# ??sudo cpan MIME::Parser
# ??sudo cpan LWP::Protocol::https
# ??sudo cpan SOAP::Lite
# sudo cpan LEOCHARRE::Basename
# sudo cpan WordPress::CLI

# cpan
# > force install ...

# Edit /usr/local/share/perl/5.22.1/WordPress/CLI/
# comment out line 28 wp->getCategories

use WordPress::XMLRPC;
use Time::Local;
use Getopt::Std;
#$opt{t} = 1;
getopts('htp:', \%opt);

if ($opt{h}) {
  print "post_next_month.pl [-t] [-p password]\n";
  exit;
}
if ($opt{t}) {
    $dcblog = 'http://dcimporttest.wordpress.com/xmlrpc.php';
    $dwblog = 'http://dcimporttest.wordpress.com/xmlrpc.php';
} else {
    $dcblog = 'http://dailyconfession.wordpress.com/xmlrpc.php';
    $dwblog = 'http://dailywestminster.wordpress.com/xmlrpc.php';
}

if ($opt{p}) {
  $passwd = $opt{p};
} else {
  print "Password: ";
  $passwd = <STDIN>;
  chomp $passwd;
}

($cmo, $yr) = (localtime)[4,5];
#$cmo--;    # oopx, it's after the 1st, need to run for this month!
#$cmo = 11; # oopx, need to run for this mo: Jan 2018!
#$yr--;
$cyear = $yr+1900;
$nyear = $cyear;
$nmo = $cmo + 1;
if ($nmo >= 12) {
    $nmo -= 12;
    $nyear += 1;
}

@monames = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);


$month = $monames[$nmo];
printf "Current month is %s %d\n", $monames[$cmo], $cyear;
printf "Next    month is %s %d\n", $month, $nyear;

die "Use rotate.pl to generate $nyear.txt" unless -r "$nyear.txt";
open ROT, "$nyear.txt";
while (<ROT>) {
  next unless /$month/;
  s!00:00:01!08:00:01!;
  s!01:00:01!08:00:01!;
  push @dclines, $_;
}

sub confirm {
  print "OK? [Y/n]: ";
  my $ans = <STDIN>;
  if ($ans =~ /^\s*(y|yes|)\s*$/is) {
    return;
  } #else
  print "Buh-bye\n";
  exit;
}

print "Daily Confession posts for $month $nyear:\n", @dclines;
confirm;

$mmm = lc $month;
@dwfiles = glob "w/$mmm*_esv.html";
for (@dwfiles) {
  if (/$mmm(\d\d)_esv/) {
    $day = ($1);
    push @dwlines, "dow $month $day 08:00:01 $nyear $_\n";
  } else {
    die "what is this? $_\n";
  }
}

print "Daily Westminster posts for $month $nyear:\n", @dwlines;
confirm;

open DWTIT, "w/titles.txt" or die "Can't read w/titles.txt\n";
while (<DWTIT>) {
  chomp;
  if (s!^(\d\d)-(\d\d)\s+!!) {
    $monum = $1;
    $day = $2; # two digits!
    $title  = $_;
    $monum--;  # for 0-index of @monames
    $monam = lc($monames[$monum]);
    $key = "w/${monam}${day}_esv.html";
    $dwtit{$key} = $title;
  }
}

sub get_title {
  my $f = shift;
  $f =~ m!(\w+)/(\w+).html!;
  my $dir = $1;
  my $fil = $2;
  if ($dir eq 'w') {
    return qq("$dwtit{$f}");
  } else {
    my $art = {cc=>"Children's Catechism, week",
	       sc=>"Shorter Catechism, week",
	       bcf=>"Belgic Confession, week",
	       lc=>"Larger Catechism, week",
	       sod=>"Canons of Dordt, week",
	       wcf=>"Westminster Confession, week",
	       hc=>"Heidelberg Catechism, Lord's day"}->{$dir};
    $fil =~ /(\d+)/;
    my $week = $1;
    return qq("$art $week");
  }
}

sub post {
  my $blog = shift;
  my $pass = shift;

  for (@_) {
    my ($y, $m, $d, $t, $f) = (split)[4,1,2,3,5];
    my %monums = (Jan=>1,Feb=>2,Mar=>3,Apr=>4,May=>5,Jun=>6,
		  Jul=>7,Aug=>8,Sep=>9,Oct=>10,Nov=>11,Dec=>12);
    my $date = sprintf "%4d-%02d-%02d $t", $nyear, $monums{$m}, $d;
    my $titl = get_title($f);
    die "Need a title!" unless $titl;
    my $cmd = qq(wordpress-upload-post -d $f -t $titl -D "$date" -u RubeRad -p $pass -x $blog\n);
    print $cmd;
    system $cmd;
  }
}

post $dcblog, $passwd, @dclines;
post $dwblog, $passwd, @dwlines;


