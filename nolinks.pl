#! /bin/perl

$txt = join '', (<>);

$txt =~ s!\<a .*?\</a\>!!g;
$txt =~ s!\<.*?\>!!g;
$txt =~ s!Q\.\s*\d+\.\s*!!g;
$txt =~ s!A\.\s*!!g;
$txt =~ s!\d+\.\s*Lord.*Day!!g;

print $txt;
