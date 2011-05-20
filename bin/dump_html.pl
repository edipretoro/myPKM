#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Template;

use myPKM::Schema;
use Digest::SHA1;
use Path::Class;
use DateTime::Format::SQLite;
use File::Path;

my $database = shift;
my $dsn = "dbi:SQLite:dbname=" . $database;
my $pkm = myPKM::Schema->connect( $dsn );

my $output_dir = './';
mkdir $output_dir unless -e $output_dir;

my $tt = Template->new();
my $template = 'html.tt';

my $result_rs = $pkm->resultset('Link');

while (my $link = $result_rs->next) {
    my $filename = get_filename( $link->creation_date );
    $tt->process( $template, { link => $link }, "$filename", binmode => 1 ) or die $tt->error(), "\n";
}

sub get_filename {
    my ( $date ) = shift;
    my $dt = DateTime::Format::SQLite->parse_datetime( $date );
    my $dir = $dt->ymd('/');
    mkpath( $dir ) if not -e $dir;
    return $dir . '/' . $dt->hms('-') . '.html';
}
