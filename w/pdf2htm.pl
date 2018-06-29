#! /bin/perl

sub convert {
  my $txt = lc(shift);
  $txt =~ s/^\s+//;
  $txt =~ s/,/ /g;
  $txt =~ s/\s+$//;
  
  $txt =~ s/^(\d+)\s+(\d+)$/lc$1 sc$2/;
  $txt =~ s/^(\d+)$/lc$1/;
  $txt =~ s!([ls])c\s*(\d+)!../${1}c/q${2}.html!g;

  $txt =~ s/wcf\s+/wcf/g;
  $txt =~ s/\b([ixv]+)/wcf$1/g;
  $txt =~ s/ix/9/;
  $txt =~ s/iv/4/;
  $txt =~ s/viii/8/;
  $txt =~ s/vii/7/;
  $txt =~ s/vi/6/;
  $txt =~ s/xxx\./30./;
  $txt =~ s/xxx/3/;
  $txt =~ s/xx\./20./;
  $txt =~ s/xx/2/;
  $txt =~ s/x\./10./;
  $txt =~ s/x/1/;
  $txt =~ s/v/5/;
  $txt =~ s/iii/3/;
  $txt =~ s/ii/2/;
  $txt =~ s/i/1/;
  $txt =~ s!wcf(\d+)\.(\d+)!../wcf/c${1}p${2}.html!;

  return $txt;
}

@lines = (<>);

for (@lines) { 
  next if /January|March/;

  if (/September/) {
    $after = 1;
    next;
  }

  if ($after) {
    $txt->{sep} .= substr $_, 0,  18;
    $txt->{oct} .= substr $_, 18, 17;
    $txt->{nov} .= substr $_, 35, 18;
    $txt->{dec} .= substr $_, 53;
  } else {
    $txt->{jan} .= substr $_, 0,  15;
    $txt->{feb} .= substr $_, 15, 11;
    $txt->{mar} .= substr $_, 26, 11;
    $txt->{apr} .= substr $_, 37, 11;
    $txt->{may} .= substr $_, 48, 11;
    $txt->{jun} .= substr $_, 60, 12;
    $txt->{jul} .= substr $_, 72, 17;
    $txt->{aug} .= substr $_, 89;
  }
}

for $mon (qw(jan feb mar apr may jun jul aug sep oct nov dec)) {
  $txt->{$mon} =~ s/(\d+)\)/SPLIT${1}SPLIT/g;
  @ary = split /SPLIT/, $txt->{$mon};
  shift @ary;
  while (@ary > 1) {
    $day = shift @ary;
    $reading = shift @ary;
    $reading =~ s/^\s+//;
    $reading =~ s/\s+$//;
    $reading =~ s/\s+/ /g;
    $hsh->{$mon}->{$day} = $reading;
  }
}
  
  
for $mon (qw(jan feb mar apr may jun jul aug sep oct nov dec)) {
  for $day (1..31) {
    next unless exists $hsh->{$mon}->{$day};
    printf "$mon $day %-20s %-20s\n", $hsh->{$mon}->{$day}, 
                            convert($hsh->{$mon}->{$day}); 

    $fname = lc( sprintf "$mon%02d.html", $day );
    open OUT, ">$fname";

    @files = split /\s+/, convert($hsh->{$mon}->{$day}); 
    for $IN (@files) {
      die "Can't find $IN!" unless -r $IN;
      
      if      ($IN =~ /wcf/) {
	print OUT "<h2><center>Westminster Confession of Faith</center></h2>\n";
      } elsif ($IN =~ /lc/) {
	print OUT "<h2><center>Westminster Larger Catechism</center></h2>\n";
      } elsif ($IN =~ /sc/i) {
	print OUT "<h2><center>Westminster Shorter Catechism</center></h2>\n";
      }

      open IN;
      while (<IN>) { print OUT };
      close IN;
    }
  }
}

    
