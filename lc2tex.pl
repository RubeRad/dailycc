#! /bin/perl

use lib "/data/perl";
use lib "/data/perl/kjv";
use KJV;
use HTTP::Lite;

use Getopt::Std;
$opt{v} = 47;
%opt = ();
getopts("v:", \%opt);

@lines = (<>);
$html = join '', @lines;

$html =~ s!<p>!!;
$html =~ s!</p>$!!;

# deal with Q99 list
$html =~ /(1. That the law is perfect.*435.*?sup.)/s;
$rulestr = $1;
@rules = split /\n/, $rulestr;
$rulestr = join "\n\n", @rules;
#print STDERR $rulestr;

#deal with Q151 list
$html =~ /(1. From the persons offending.*981.*?sup.)/s;
$heinousstr = $1;
@heinouses = split /\n/, $heinousstr;
$heinousstr = join "\n\n", @heinouses;
#print STDERR $heinousstr;

$html =~ s!</p>.*?</a>Q!SPLITHEREQ!gs;

if ($html =~ s!(these rules are to be observed.)!$1\n\n$rulestr!s) {
  print STDERR "Fixed Q99\n";
}
if ($html =~ s!(Sins receive their aggravations.)!$1\n\n$heinousstr!) {
  print STDERR "Fixed Q151\n";
}

@qs = split /SPLITHERE/, $html;
$nq = @qs;

for $q (@qs) {
  if ($q =~ /right understanding of the ten|What are those aggravations/) {
    $stophere = 1;
  }
  @links = ();
  while ($q =~ m!(http.*?)\&version!g) { push @links, $1 }

  for $link (@links) {
    $link =~ m!(http.*search\=)(.+)!;
    $urlbase = $1;
    $refstr = $2;
    @refs = split /,(?=[123]?[A-Z])/, $refstr;
    $footnote = '';
    for $ref (@refs) {
      $verse = KJV::get_passage($ref);

      if ($verse) {
	$footnote .= "$ref: $verse\n\n";
      } else {
	print STDERR "Can't resolve $ref\n";
	$footnote .= "$ref\n\n";
      }
    }
    $q =~ s!<sup><a href.*?sup>!\\footnote\{$footnote\}!;
  }

  $outstr .= "$q\n\n";
}


$outstr =~ s!,([123]?[A-Z])!, $1!g;
$outstr =~ s!([123])([A-Z])!$1 $2!g;
$outstr =~ s!([A-Za-z]{3})[A-Za-z]+(\d)!$1 $2!g;
$outstr =~ s!SongOfSolomon!Song!g;
$outstr =~ s!<.*?>!!gs;
$outstr =~ s!Q\.\s*(\d+)\.!\\item\[Q$1\] !g;
$outstr =~ s!\nA\.!\n\n\\item\[A\] !gs;


print "\\documentclass{article}\n";
print "\\usepackage[letterpaper, margin=15mm]{geometry}\n";
print "\\begin{document}\n";
print "\\begin{center}\\bf{\\Large Westminster Larger Catechism} \\\\ \n";
print "\\bf with full text of scripture proofs\\end{center}\n\n";
print "\\begin{description}\n";

print $outstr;

print "\\end{description}\n";
print "\\end{document}\n";

