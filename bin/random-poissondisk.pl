#!/usr/bin/perl -w
use strict;
use Random::PoissonDisk;

my $points = Random::LaplaceDisk->points(
    dimensions => [100,100],
    r => 10,
);

for (@$points) {
    print join( "\t", @$_), "\n";
};