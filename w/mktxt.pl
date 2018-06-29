#! /bin/perl

while (<>) {
  next if /Westminster/;
  if (/<title>(.*)<\/title>/) {
    $title = $1;
  }
  if (/date_gmt>\d+\-(\d+)-(\d+)/) {
    $mon = $1;
    $day = $2;
    printf "%02d-%02d $title\n", $mon, $day;
  }
}
