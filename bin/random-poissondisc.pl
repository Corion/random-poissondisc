#!/usr/bin/perl -w
use strict;
use Random::PoissonDisc;
use Getopt::Long;

GetOptions(
    'r:s' => \my $r,
);

$r ||= 10;

my $points = Random::PoissonDisc->points(
    dimensions => [100,100],
    r => $r,
);

for (@$points) {
    print join( "\t", @$_), "\n";
};