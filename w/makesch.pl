#! /bin/perl

sub titleOfFile {
  my $fil = shift;

  open IN, $fil;
  my $txt = join '', (<IN>);
  close IN;

  my @rets;

  if ($txt =~ /Westminster Confession.*?c(\d+)p(\d+)/s) {
    push @rets, "WCF $1.$2";
  }

  if ($txt =~ /Larger Catechism.*?q(\d+)/s) {
    push @rets, "LC $1";
  }

  if ($txt =~ /Shorter Catechism.*?q(\d+)/s) {
    push @rets, "SC $1";
  }
  
  return (join ', ', @rets);
}



sub print_months {
  my @months = @_;
  print qq(<table border="1">\n);
  print qq( <tr><td></td>\n);
  for my $mon (@months) {
    print qq(    <td><b>$mon</b></td>\n);
  }
  print qq( </tr>\n);

  for $day (1..31) {
    print qq( <tr><td>$day</td>\n);
    for my $mon (@months) {
      $fname = sprintf "%3s%02d.html", lc($mon), $day;
      if (-r $fname) {
	printf "     <td>%s</td>\n", titleOfFile($fname);
      } else {
	printf "     <td></td>\n";
      }
    }
  }
  print qq(</table>\n);
  print "<br>\n";
}

print_months(qw(Jan Feb Mar Apr));
print_months(qw(May Jun Jul Aug));
print_months(qw(Sep Oct Nov Dec));
