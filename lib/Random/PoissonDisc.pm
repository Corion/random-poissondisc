package Random::PoissonDisc;
use strict;
use List::Util qw(sum);
use Math::Random::MT::Auto qw(rand gaussian);

=head1 NAME

Random::PoissonDisc - distribute points aesthetically in a plane

=cut

# What pRNG do we use?
# Do we use/support something like PDL for speed?

sub rnd {
    my ($low,$high) = @_;
    return $low + rand($high-$low);
};

use Data::Dumper;

sub grid_coords {
    my ($size,$point) = @_;
    join "\t", map { int($_/$size) } @$point;
};

# Return x(i)+e(i) and x(i)-e(i)
# by using the grid
sub neighbour_points {
    my ($size,$point) = @_;
    my @coords = split /\t/, grid_coords( $size, $point );
    map {}
    map {} @coords;
};

sub random_unit_vector {
    # idea taken from http://burtleburtle.net/bob/rand/unitvec.html
    # resp. Knuth, _The Art of Computer Programming_, vol. 2,
    # 3rd. ed., section 3.4.1.E.6.
    # but not verified
    my ($dimensions) = @_;
    my (@vec,$len);
    
    # Create normal distributed coordinates
    # around 0 in (-1,1)    
    RETRY: {
        @vec = map { 1-2*gaussian() } 1..$dimensions;
        # Normalize our vector:
        $len = sqrt( sum @{[map {$_**2} @vec]} );
        redo RETRY unless $len;
    };
    @vec = map { $_ / $len } @vec;
    
    \@vec
};

sub points {
    my ($class,%options) = @_;
    # XXX Allow the grid to be passed in
    
    $options{candidates} ||= 30;
    $options{dimensions} ||= [100,100]; # do we only create integral points?
    $options{r} ||= 10;
    #$options{max} ||= 10; # we want to fill the space instead?!
    
    # See http://www.cs.ubc.ca/~rbridson/docs/bridson-siggraph07-poissondisk.pdf
    # This should adapt to multiple dimensions
    # I guess it's radius / n-th root of n.
    # XXX Need to think about this
    my $grid_size = $options{ r } / sqrt( 0+@{$options{dimensions}});
    # A grid can't nicely model discs, so this is only an approximation
    # Pfeh.
    
    my @result;
    my @work;
    my %grid; # well, a fakey grid, but as long as we use only integer
    # coordinates for the grid, using a hash and normalized point coordinates is convenient
        
    # Create a first random point somewhere in our cube:
    my $p = [map { rnd(0,$_) } @{ $options{ dimensions }}];
    push @result, $p;
    push @work, $p;
    my $c = grid_coords($grid_size, $p);
    $grid{ $c } = $p;
    
    while (@work) {
        my $origin = splice @work, int rnd(0,$#work), 1;
        CANDIDATE: for my $candidate ( 1..$options{ candidates } ) {
            # Create a random distance between r and 2r
            # that is, in the annulus with radius (r,2r)
            # surrounding our current point
            my $dist = rnd( $options{r}, $options{r}*2 );
            
            # Choose a random angle in which to point
            # this vector
            my $angle = random_unit_vector(0+@{$options{ dimensions}});
            
            # Generate a new point by adding the $angle*$dist to $origin
            my $p = [map { $origin->[$_] + $angle->[$_]* $dist } 0..$#$angle];
            
            # Check whether our point lies within the dimensions
            for (0..$#$p) {
                do { #warn "$candidate Rejecting";
                     ; next CANDIDATE }
                    if   $p->[$_] >= $options{ dimensions }->[ $_ ]
                      or $p->[$_] < 0
            };
            
            # check discs by using the grid
            # Here we should check the "neighbours" in the grid too
            my $c = grid_coords($grid_size, $p);
            if (! $grid{ $c }) {
                # if not already in grid, add it
                push @result, $p;
                push @work, $p;
                $grid{ $c } = $p;
                #warn "$candidate Taking";
            } else {
                #warn "$candidate Occupied";
            };
        };
    };
    
    \@result
};

1;