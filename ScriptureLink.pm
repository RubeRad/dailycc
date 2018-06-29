#! /usr/bin/perl

use strict;

package ScriptureLink;

my @books = qw(
Genesis
	ge
	gen
Exodus
	ex
	exo
	exod
Leviticus
	lev
Numbers
	nu
	num
Deuteronomy
	de
	dt
	deu
	deut
Joshua
	jos
	josh
Judges
	judg
	jdg
Ruth
	ru
	rut
Esther
	est
	esth
Isaiah
	is
	isa
Haggai
	hag
Jonah
	jon
Joel
Daniel
	da
	dan
James
	jas
Hosea
	ho
	hos
Zechariah
	zec
	zech
Obadiah
	ob
	obad
	oba
Jeremiah
	jer
Acts
	ac
	act
Habakkuk
	hab
Ezra
	ezr
Jude
	jud
Ecclesiastes
	ecc
	eccl
	qoh
Philemon
	phm
	philem
Lamentations
	la
	lam
Zephaniah
	zep
	zeph
Proverbs
	pro
	prov
Colossians
	co
	col
Romans
	ro
	rom
Micah
	mic
Luke
Malachi
	mal
Job
Ephesians
	ep
	eph
Mark
Amos
	am
	amo
Matthew
Nahum
	na
	nah
Song of Solomon
	song of songs
Ezekiel
	eze
	ezek
Hebrews
	heb
Revelation
	re
	rev
	apoc
	apocalypse
Psalms
	ps
	psalm
	psa
	pss
Galatians
	ga
	gal
Philippians
	php
	phil
Titus
	tit
Nehemiah
	ne
	neh
);

for my $book (qw(
Samuel
	Sam
        Sa
Kings
	Kin
        Ki
Chronicles
	Chron
	Chr
        Ch
Corinthians
        Cor
        Co
Thessalonians
	Thess
        Th
Timothy
	Tim
        Ti
Peter
	Pet
        Pe
John
	Jn
)) {

  my $top = ($book =~ /^J/ ? 3 : 2);
  for my $i (1..$top) {
    push @books, "$i $book";
    push @books, "${i}$book";
    my $italic = 'I'x$i;
    push @books, "$italic $book";
    push @books, "${italic}$book";
  }
}

my $bookre = join '|', @books;

sub ParseRefs {
  my @refs = ();

  for (@_) { push @refs, (/((?:$bookre)\.?\s*\d{1,}\:[\d,-\s]+)/gi) }
  for (@refs) { s/\s+$// }
  return @refs;
}


sub BookChapterVerse {
  if ($_[0] =~ /Luke/) {
    my $stophere = 1;
  }
  my @bcv = ($_[0] =~ /($bookre)\.?\s*(\d+)\:?(\d*)/i);
  return @bcv;
}


sub CondenseRefs {
  my @out;
  my ($b0,$c0,$v0,$v1);
  for my $i (0..$#_) {
    my ($b,$c,$v) = BookChapterVerse($_[$i]);
    if ($b eq $b0 && $c eq $c0 && $v == $v1+1) {
      $out[-1] =~ s/:(\d+)(-?\d*)/:\1-$v/;
      $v1 = $v;
      next;
    }
    push @out, $_[$i];
    ($b0,$c0,$v0) = ($b,$c,$v);
    $v0 =~ /(\d+)$/;
    $v1 = $1;
  }
  return @out;
}


sub HtmlRef {
  my $ref = shift;
  my $txt = shift || $ref;

  return qq(<a href="http://biblegateway.com/passage?search=$ref&version=47">$txt</a>);
}

1;
