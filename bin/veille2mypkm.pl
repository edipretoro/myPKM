#!/usr/bin/env perl

use strict;
use warnings;

use Term::ProgressBar;
use DBI;
use HTTP::Tiny;
use URI;
use URI::QueryParam;

use 5.014;

my $db_veille = shift;
my $dsn_veille = 'dbi:SQLite:dbname=' . $db_veille;
my $dbh_veille = DBI->connect( $dsn_veille );

my $query = 'SELECT link FROM entries';
my $sth = $dbh_veille->prepare( $query );
$sth->execute;
my $results = $sth->fetchall_arrayref;
my $total = scalar(@{ $results });
my $pb = Term::ProgressBar->new({
    name => 'Articles to collect (' . $total . ')',
    count => $total,
});
my $pb_cpt = 0;

my $http = HTTP::Tiny->new();
foreach my $result (@{$results}) {
    my $uri = URI->new('http://localhost:3000/read');
    $uri->query_param( 'url', $result->[0] );
    $http->get( $uri->as_string );
    $pb->update( ++$pb_cpt );
}
