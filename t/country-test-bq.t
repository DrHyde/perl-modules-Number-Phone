use strict;
use warnings;

use Number::Phone;

use Test::More;

my $p = Number::Phone->new("+5997900000");

is($p->format(), "+599 7900000", "Bonaire (BQ) number correctly formatted");

done_testing();
