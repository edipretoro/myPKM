#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use myPKM::Schema;

use Lucy::Search::IndexSearcher;
use Path::Class;
use feature 'say';

my $search = Lucy::Search::IndexSearcher->new(
    index => dir( $ENV{HOME}, '.mypkm', 'lucy' ),
);

my $hits = $search->hits( query => shift, num_wanted => 100 );
while (my $hit = $hits->next) {
    say $hit->{url}, ' (', sprintf('%.2f', $hit->get_score()) , ')';
}
