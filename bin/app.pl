#!/usr/bin/env perl
use Dancer;
use myPKM;
use Plack::Builder;

myPKM::deploy() if not myPKM::existing_database();

my $app = sub {
    my $env     = shift;
    my $request = Dancer::Request->new( env => $env );
    Dancer->dance($request);
};

builder {
    # enable 'Debug';
    # enable 'Debug::DBITrace';
    # enable 'Debug::DBIProfile', profile => 1;

    $app;
};
