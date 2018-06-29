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
$html =~ s!</p>.*?</a>Q!SPLITHEREQ!gs;
@qs = split /SPLITHERE/, $html;
$nq = @qs;

for $q (@qs) {
  @links = ();
  while ($q =~ m!(http.*?)\&version!g) { push @links, $1 }
  $q =~ s!(<sup><a href\=\"(http.*?search\=(.*?))\&version.*?sup>)! \($3\)!g;
  $outstr .= "$q\n\n";
  #print "$q\n\n";

  for $link (@links) {
    $link =~ m!(http.*search\=)(.+)!;
    $urlbase = $1;
    $refstr = $2;
    @refs = split /,(?=[123]?[A-Z])/, $refstr;
    for $ref (@refs) {
      #print "$ref\n";
      #$outstr .= "$ref\n";
      $verse = KJV::get_passage($ref);
      #print "$verse\n\n";
      if ($verse) {
	$outstr .= "$ref: $verse\n\n";
      } else {
	print STDERR "Can't resolve $ref\n";
      }
    }
  }
}


$outstr =~ s!,([123]?[A-Z])!, $1!g;
$outstr =~ s!([123])([A-Z])!$1 $2!g;
$outstr =~ s!([A-Za-z]{3})[A-Za-z]+(\d)!$1 $2!g;
$outstr =~ s!SongOfSolomon!Song!g;
$outstr =~ s!<.*?>!!gs;
$outstr =~ s!Q\.\s*(\d+)\.!LC $1:!g;
print $outstr;
