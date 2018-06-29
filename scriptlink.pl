#! /usr/bin/perl

use FindBin;
use lib "$FindBin::Bin";
use ScriptureLink;

@lines = (<>);
for (@lines) {
  if (/title="q(\d+)"/) {
    $n = $1;
    next;
  }

  if (/ld4/) {
    $stophere = 1;
  }

  if (/^\(a\)/) {
    @ary = split /\s*\([a-z0-9]{1,2}\)\s*/;
    $let = 'a';
    for $s (@ary) { 
      next unless $s =~ /\S/;
      #print "$let: $s\n"; 

      @refs = ScriptureLink::ParseRefs($s);
      @crefs = ScriptureLink::CondenseRefs(@refs);
      $cref = join ',', @crefs;
      $cref =~ s/[\s\.]//g;
      $ref->{$n}->{$let} = ScriptureLink::HtmlRef($cref,"[$let]");
      #print "$n,$let: $ref->{$n}->{$let}\n\n";

      $let++;
    }
  }
}

for (@lines) {
  next if /^\(a\)/;

  if (/title="q(\d+)"/) {
    $n = $1;
  }
  
  @lets = (/\(([a-z0-9]{1,2})\)/g);
  for $let (@lets) {
    $sub = $ref->{$n}->{$let};
    s/\($let\)/$sub/;
  }

  print;
}

    
