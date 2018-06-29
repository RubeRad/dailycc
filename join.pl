#! /bin/perl

while (<>) {
  s/\b(\d)/q\1/g;
  s/(\w)\b/\1.html/g;
  @files = glob;

  $OUT = sprintf ">w%d.html", ++$w;
  open OUT;
  $header = 0;
  for $IN (@files) {
    open IN;
    while (<IN>) {
      if (/"(c\d+|h\d+|h\d+e\d+)"/) { 
	if ($header) {
	  s|<p.*?</p>||;
	}
	$header = 1;
      }
      print OUT;
    }
  }
  close OUT;
}
    
