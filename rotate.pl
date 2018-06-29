#! /usr/bin/perl

use Time::Local;
use Getopt::Std;

%opt = ();
getopts("n:y:wh", \%opt);
if ($opt{h}) {
  $usage .= "rotate.pl -y 20xx -n 365 -w 1 2 3 4 5 6 7\n";
  $usage .= "  1 is whatever confession for Jan 1, 2 for Jan 2, etc\n";
  print $usage;
  exit;
}


$y = $opt{y} || 2008;
$y -= 1900;
$t = timelocal(1,0,0,1,0,$y);
$n = $opt{n} || 1000;

for $i (1..52)  { push @{$f->{hc}}, "hc/ld$i.html" }

if ($opt{w}) {
  for $dir (qw(cc sc lc wcf bcf sod)) {
    for $i (1..52) { 
      push @{$f->{$dir}}, "$dir/w$i.html" if -r "$dir/w$i.html";
    }
  }
} else {
  for $i (1..145) { push @{$f->{cc}}, "cc/q$i.html"; }
  for $i (1..107) { push @{$f->{sc}}, "sc/q$i.html"; }
  for $i (1..196) { push @{$f->{lc}}, "lc/q$i.html"; }
  for $i (1..37)  { push @{$f->{bcf}},"bcf/a$i.html"; }
  for $i (1..50)  {
    for $j (1..20) {
      push @{$f->{wcf}}, "wcf/c${i}p${j}.html" if -r "wcf/c${i}p${j}.html";
    }
  }
  for $i (1,2,34,5) {
    for $j (1..20) {
      push @{$f->{sod}}, "sod/h${i}a$j.html" if -r "sod/h${i}a$j.html";
    }
    for $j (1..10) {
      push @{$f->{sod}}, "sod/h${i}e$j.html" if -r "sod/h${i}e$j.html";
    }
  }
  push @{$f->{sod}}, "sod/c.html";
}


sub nextFile {
  my $w  = shift;
  my $i  = ($ctr{$w}++) % (@{$f->{$w}});
  return $f->{$w}->[$i];
}


for $i (0..($n-1)) {

  if ($i == 729) {
    $stophere = 1;
  }

  $date = localtime($t);
  $t += 86400;

  $whch = $ARGV[ $i % @ARGV ];
  $file = nextFile($whch);

  if ($file =~ /(ld|w)1.html/ && $date =~ /Dec/) {
    $ctr{$whch}--;
    next;
  }

  print "$date $file\n";
}
