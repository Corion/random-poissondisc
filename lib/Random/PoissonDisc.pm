package Random::PoissonDisc;
use strict;

=head1 NAME

Random::PoissonDisc - distribute points aesthetically in a plane

=cut

# What pRNG do we use?
# Do we use/support something like PDL for speed?

sub rnd {
    my ($low,$high) = @_;
    return $low + random($high-$low);
};

sub grid_coords {
    my ($size,$point) = @_;
    join "\t", map { int($_/$size) } @$_;
};

sub points {
    my ($class,%options) = @_;
    # XXX Allow the grid to be passed in
    
    $options{candidates} ||= 30;
    $options{dimensions} ||= [100,100]; # do we only create integral points?
    $options{r} ||= 10;
    #$options{max} ||= 10; # we want to fill the space instead?!
    
    # This should adapt to multiple dimensions
    # I guess it's radius / n-th root of 2.
    # XXX Need to think about this
    my $grid_size = $options{ r } / sqrt(2);
    
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
        my $p = splice @work, rnd(0,$#work,1);
        for (1..$options{ candidates }) {
            # Create a random distance between r and 2r
            # that is, in the annulus with radius (r,2r)
            # surrounding our current point
            my $dist = rnd( $options{r}, $options{ r}*2 );
            
            # Now choose a random angle in which to point
            # this vector
            my $angle = [map{...}] 0..$#{$options{dimensions}};
            #
            
            # check grid
            my $c = grid_coords($grid_size, $p);
            if (! $grid{ $c }) {
                # if not already in grid, add it
                push @result, $p;
                push @work, $p;
                $grid{ $c } = $p;
            };
        };
    };
    
    @result
};

1;