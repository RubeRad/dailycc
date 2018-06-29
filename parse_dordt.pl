#! /usr/bin/perl


while (<>) {

    chomp;

    next unless /\S/;

    if (/The (.+) Heads? of Doctrine:/) {
	$head = {First=>1,Second=>2,'Third and Fourth'=>34,Fifth=>5}->{$1};
	$tag = "h$head";
	print qq(<p align="center"><b><a name="$tag" title="$tag"></a>$_</b></p>\n);
	$error = 0;
	next;
    }

    if (/Article (\d+):/) {
	$article = $1;
	$tag = "h${head}a${article}";
	print qq(<p><b><a name="$tag" title="$tag"></a>$_</b></p>\n);
	next;
    }

    if (/^Rejection of the Errors/) {
	$tag = "h${head}e";
	print qq(<p align="center"><b><a name="$tag" title="$tag"></a>$_</b></p>\n);
	next;
	$error = 0;
    }

    if (/^[IVX]+$/) {
	$error++;
	$tag = "h${head}e${error}";
	print qq(<p align="center"><b><a name="$tag" title="$tag"></a>$_</b></p>\n);
	$_ = <>;
	print qq(<p><em>$_</em></p>\n);
	next;
    }

    if (/Conclusion/) {
	$tag = "c";
	print qq(<p align="center"><b><a name="$tag" title="$tag"></a>$_</b></p>\n);
	next;
    }

    if (s/^\* //) {
	print qq(<li>$_</li>\n);
	next;
    }

    if (/Therefore this Synod of Dort in the name of the Lord/) {
	print "</ul>\n";
    }

    
    print qq(<p>$_</p>\n);
    

    if (/wishing to make the public believe:\s*$/) {
	print "<ul>\n";
    }

}
