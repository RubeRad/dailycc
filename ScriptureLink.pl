#! /usr/bin/perl

use ScriptureLink;



while (<>) {
  @refs = ScriptureLink::ParseRefs($_);
#   for (@refs) {
#     print;
#     print "\n";
#   }
  @crefs = ScriptureLink::CondenseRefs(@refs);
  for (@crefs) {
    print;
    print "\n";
  }
}
