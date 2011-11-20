#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use myPKM::Schema;
use myPKM;

my $database = shift;
my $dsn = "dbi:SQLite:dbname=" . $database;
my $pkm = myPKM::Schema->connect( $dsn );

my $links_rs = $pkm->resultset('Link')->search( { content => 'not defined' } );

my $total = $links_rs->count;
print "We have $total links to process.\n";
while (my $link = $links_rs->next()) {
    $link->update( { content => myPKM::get_article( $link->url() ) } );
    print "Still ", $total--, " links to process.\n";
}
