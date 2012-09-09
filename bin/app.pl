#!/usr/bin/env perl
use Dancer;
use myPKM;

myPKM::deploy() if not myPKM::existing_database();

dance;
