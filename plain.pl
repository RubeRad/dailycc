#! /bin/perl

$all = join '', (<>);
while ($all =~ /<content.encoded><\!\[CDATA\[(.*?)\]\]/gs) {
  $content = $1;
  $content =~ s/<a href.*?<\/a>/ /gs;
  $content =~ s/<.*?>/ /gs;
  $content =~ s/\W/ /gs;
  $content =~ s/\s+/ /gs;
  
  print "$content\n\n";
}
