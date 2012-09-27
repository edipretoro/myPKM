#!/usr/bin/env perl

use Modern::Perl;

use FindBin;
use lib "$FindBin::Bin/../lib";
use myPKM::Schema;

use Lucy::Analysis::PolyAnalyzer;
use Lucy::Index::Indexer;
use Lucy::Plan::FullTextType;
use Lucy::Plan::Schema;
use Path::Class;

my $schema = Lucy::Plan::Schema->new;
my $polyanalyzer = Lucy::Analysis::PolyAnalyzer->new(
    language => 'en',
);
my $type = Lucy::Plan::FullTextType->new(
    analyzer => $polyanalyzer,
);
$schema->spec_field( name => 'content', type => $type );
$schema->spec_field( name => 'title', type => $type );
$schema->spec_field( name => 'url', type => $type );
$schema->spec_field( name => 'id', type => $type );

my $indexer = Lucy::Index::Indexer->new(
    schema => $schema,
    index => dir( $ENV{HOME}, '.mypkm', 'lucy' ),
    create => 1,
);

my $database = shift;
my $last_id = shift || undef;

my $dsn = "dbi:SQLite:dbname=" . $database;
my $pkm = myPKM::Schema->connect( $dsn );
my $link_rs = $pkm->resultset('Link');

while (my $link = $link_rs->next()) {
    $indexer->add_doc({
        id => $link->id,
        url => $link->url,
        title => $link->title,
        content => $link->content,
    });
}

$indexer->commit;
