#!/usr/bin/perl -w
use strict;
use Random::PoissonDisc;

my $points = Random::PoissonDisc->points(
    dimensions => [100,100],
    r => 10,
);

for (@$points) {
    print join( "\t", @$_), "\n";
};