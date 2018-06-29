#! /bin/perl

use WordPress::XMLRPC;
use Getopt::Std;
%opt = ();
getopts('tp:', \%opt);

$testblog = 'http://dcimporttest.wordpress.com/xmlrpc.php';
$realblog = 'http://dailyconfession.wordpress.com/xmlrpc.php';
if ($opt{p}) {
  $passwd = $opt{p};
} else {
  print "Password for '$blog': ";
  $passwd = <STDIN>;
  chomp $passwd;
}


$wp = WordPress::XMLRPC->new({
			      username => 'RubeRad',
			      password => $passwd,
			      proxy => $realblog,
});

$rec = $wp->getRecentPosts();
$p = shift @$rec;


$wp2 = WordPress::XMLRPC->new({
			      username => 'RubeRad',
			      password => $passwd,
			      proxy => $testblog,
});

$postid = $wp2->newPost($p);



