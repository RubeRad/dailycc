#! /bin/perl

while (<>) {
  s/biblegateway.com/esvonline.org/g;
  s/.version.47//g;
  s!passage.{1,2}search!search?q!g;
  print;
}
