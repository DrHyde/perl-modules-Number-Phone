use strict;
use warnings;
use lib 't/inc';
use nptestutils;

use Test::More;
# see t/stubs.t for when uk_tests.pl are run against N::P::StubCountry::GB
plan skip_all => 'not relevant if building --without_uk' if(building_without_uk());

use Number::Phone;

require 'uk_tests.pl';

ok(Number::Phone->new('+442087712924')->regulator() eq 'OFCOM, http://www.ofcom.org.uk/', "N:P:UK->regulator() works");

done_testing();
