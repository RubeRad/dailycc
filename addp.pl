#! /bin/perl

while (<>) {
  next unless /\S/;
  if (/<p>/) {
    print;
  } elsif (/which are these:/) {
    chomp;
    print "<p>$_";
  } elsif (/All which are given by inspiration/) {
    chomp;
    print "$_</p>";
  } elsif (/<\/?li>|<\/?ul>/) {
    chomp;
    print;
  } else {
    chomp;
    print "<p>$_</p>\n";
  }
}
