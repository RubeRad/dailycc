#! /usr/bin/perl



while (<>) {
    if (/<p class="Center">(Chapter [IVX]+)<\/p>/) {
	$chpno++;
	$parno = 0;
	#print "Chapter $chpno\n";
	next;
    }

    if (/<p class="Center">(Of .*)<\/p>/) {
	$ttl->{$chpno} = $1;
	#print "$ttl->{$chpno}\n";
	next;
    }

    if (/<p class="Center">(.+)<\/p>/) {
	$ttl->{$chpno} .= " $1";
	#print "$ttl->{$chpno}\n";
	next;
    }

    if (/<p class="Paragraph">[IVX]+\.\W+(.+)<\/p>/) {
	$parno++;
	#print "$parno\n";
	$par->{$chpno}->{$parno} = $1;
	next;
    }

    if (/<p class="MsoList">\W*(.+)<\/p>|(Of the New Testament:)|(The Gospels according to)/) {
	$txt = $1.$2.$3;
	if ($txt =~ /Of the Old Testament/) {
	    $par->{$chpno}->{$parno} .= "\n<ul>\n";
	}
	if ($txt =~ /All which are given by inspiration/) {
	    $par->{$chpno}->{$parno} .= "$txt\n"
	} else {
	    $par->{$chpno}->{$parno} .= "<li>$txt</li>\n";
	}
	    
	if ($txt =~ /Testament:|Gospels|Epistles to the/) {
	    $par->{$chpno}->{$parno} .= "<ul>\n";
	}
	if ($txt =~/Malachi|^John$|Philemon|Revelation/) {
	    $par->{$chpno}->{$parno} .= "</ul>\n";
	}
	if ($txt =~/Revelation/) {
	    $par->{$chpno}->{$parno} .= "</ul>\n";
	}
    }

    if (/<p class="Footnote">.*(_ftnref\d+)/) {
      $footnum = $1;
      @refs = (/ ([A-Z123]{3} \d+:\d+|\d+:\d+|\d+) /g);
      $refstr = '';
      for $i (0..$#refs) {
	$refstr =~ /(\d+)$/;
	$lastnum = $1;
	$refs[$i] =~ s/ //g;
	if ($refs[$i] =~ /:/) {
	  $refstr .= ($refstr ? ",$refs[$i]" : "$refs[$i]");
	} elsif ($refs[$i] == $lastnum+1) {
	  $refstr =~ s/-\d+$/-$refs[$i]/
	      or
	  $refstr .= "-$refs[$i]";
	} elsif ($refs[$i] > $lastnum+1) {
	  $refstr .= ",$refs[$i]";
	}
      }
      $scripture->{$footnum} = $refstr;
      next;
    }
}

for $chpno (sort {$a<=>$b} keys %$par) {
    print qq(<p align="center"><a name="c$chpno" title="c$chpno"></a>Chapter $chpno: $ttl->{$chpno}</p>\n);
    for $parno (sort {$a<=>$b} keys %{$par->{$chpno}}) {
	$par->{$chpno}->{$parno} =~ 
	    s|<a id="(_ftnref\d+)".*?(\[\d+\]).*?</a>|<sup><a href="http://biblegateway.com/passage/\?search=$scripture->{$1}\&version=47">\2</a></sup>|g;
#	$par->{$chpno}->{$parno} =~ 
#	    s|<a id="(_ftnref\d+)".*?(\[\d+\]).*?</a>||g;
	print qq(<p><a name="c${chpno}p${parno}" title="c${chpno}p${parno}"></a>$parno: $par->{$chpno}->{$parno}</p>\n);
    }
}
