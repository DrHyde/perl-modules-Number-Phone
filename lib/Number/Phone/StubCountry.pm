package Number::Phone::StubCountry;

use strict;
use warnings;
use base qw(Number::Phone);

sub country_code { return shift()->{country_idd_code} }
sub format {
  my $self = shift;
  my $number = $self->{number};
  my $cc = $self->country_code();
  $number =~ s/^(\+$cc)/$1 /;
  return $number
}

1;
