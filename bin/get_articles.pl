#!/usr/bin/env perl

use strict;
use warnings;

use Term::ProgressBar;
use FindBin;
use lib "$FindBin::Bin/../lib";

use myPKM::Schema;
use myPKM;

my $database = shift;
my $dsn = "dbi:SQLite:dbname=" . $database;
my $pkm = myPKM::Schema->connect( $dsn );

my $links_rs = $pkm->resultset('Link')->search( { content => 'not defined' } );

my $total = 0;
my $progress = Term::ProgressBar->new( { 
    name => 'Articles to collect (' . $links_rs->count . ')',
    count => $links_rs->count
});
while (my $link = $links_rs->next()) {
    $link->update( { content => myPKM::get_article( $link->url() ) } );
    $progress->update(++$total);
}
