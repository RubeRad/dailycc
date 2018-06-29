#! /bin/perl

$bef = shift @ARGV;
$aft = shift @ARGV;
while (<>) {
  s/$bef/$aft/g;
  print;
}
