#! /usr/bin/perl

use ScriptureLink;

while (<>) {
    chomp;
    if (/Article (\d+):/) {
	$ano = $1;
	$title{$ano} = $_;
	next;
    }

    s/^\s+\*?\s*//;
    $text{$ano} .= "$_ ";
}

for $ano (sort {$a<=>$b} keys %title) {
    print qq(<p align="center"><a name="a$ano" title="a$ano"></a>$title{$ano}</p>\n);
    #$text{$ano} =~ s|\^(\d+)|[\1]|gs;
    if ($text{$ano} =~ s|(\^\d+)(.*?)(\1.*)|\1\2|s) {
      $refstr = $3;
      @refs = split /\^/, $refstr;
      for $refstr (@refs) {
	if ($refstr =~ /^(\d+)\s+(.+)/) {
	  $num = $1;
	  $ref = $2;
	  $ref =~ s/\s//g;
	  $ref =~ s/\.//g;
	  $ref =~ s/\(?KJV\)?//g;
	  $bgw = ScriptureLink::HtmlRef($ref, "[$num]");
	  $text{$ano} =~ s/\^$num/$bgw/;
	}
      }
    }

    print qq(<p>$text{$ano}</p>\n);
}
