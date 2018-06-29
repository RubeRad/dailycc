#! /usr/bin/perl

use FindBin;
use lib $FindBin::Bin;
use ScriptureLink;
use Getopt::Std;

%opt = ();
getopts("c:s", \%opt);

@lines = (<>);
$txt = join '', @lines;
@pars = ($txt =~ m|(<p.+?</p>)|gs);
for $par (@pars) {
  if ($par =~ m|name="(\w+)"|) {
    $nam = $1;

    if ($nam =~ /^ld\d+$/) {
      $ld = $nam;
    }

    if ($ld && $nam ne $ld) {
      $hash{$ld} .= $par;
    } else {
      $hash{$nam} = $par;
    }

  } elsif ($par =~ /Having set forth the orthodox.*the Synod rejects the errors /) {
    $hash{$nam} = $par;
  } elsif ($nam =~ /^h\d+[ae]\d+$/ ||
	   $nam =~ /^a\d+$/ || 
	   $nam eq 'c' ||
	   $nam eq 'q99' || 
	   $nam eq 'q151' || 
	   $par =~ /<\/?li>|<\/?ul>/) {
    $hash{$nam} .= $par;
  } else {
    print STDERR "Don't know what to do with:\n$par\n";
  }
}


for $nam (keys %hash) {
  if ($nam =~ /(c\d+)p\d+/) {
    $c = $1;
    $withchap = $hash{$c}.$hash{$nam};
    $hash{$nam} = $withchap;
  }

  if ($nam =~ /^(h\d+)[ae]\d+$/) {
    $head = $1;
    $full = $hash{$head};
    if ($nam =~ /^(h\d+e)/) {
      $err = $1;
      $full .= $hash{$err};
    }
    $full .= $hash{$nam};
    $hash{$nam} = $full;
  }
}


if ($opt{s}) {
  for $nam (keys %hash) {
    @refs = ScriptureLink::ParseRefs($hash{$nam});
    for $ref (@refs) {
      $href = ScriptureLink::HtmlRef($ref);
      $hash{$nam} =~ s/$ref/$href/gs;
    }
  }
}


for $nam (sort keys %hash) {
  next if $nam =~ /^(c\d+|h\d+e?)$/;
  open F, ">$nam.html";
  print F "$hash{$nam}\n";
}
  
