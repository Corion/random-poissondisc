package Random::PoissonDisk;
use strict;

=head1 NAME

Random::LaplaceDisk - distribute points aesthetically in a plane

=cut

# What pRNG do we use?
# Do we use/support something like PDL for speed?

sub rnd {
    my ($low,$high) = @_;
    return $low + random($high-$low);
};

sub points {
    my ($class,%options) = @_;
    
    $options{candidates} ||= 30;
    $options{dimensions} ||= [100,100]; # do we only create integral points?
    $options{r} ||= 10;
    #$options{max} ||= 10; # we want to fill the space instead?!
    
    my @result;
    my @work;
    
    # Create a first random point somewhere in our cube:
    my $p = map { rnd(0,$_) } @{ $options{ dimensions }};
    push @result, $p;
    push @work, $p;
    while (@work) {
        for (1..$options{ candidates }) {
            # Create a random distance between r and 2r
            # that is, in the annulus with radius (r,2r)
            # surrounding our current point
            my $dist = rnd( $options{r}, $options{ r}*2 );
            
            # Now choose a random angle in which to point
            # this vector
            my $angle = [map{} 
        };
    };
    
    \@result;
};

1;