use strict;
use warnings;
use lib 't/inc';
use nptestutils;

use Number::Phone;
use Test::More;

require 'uk_tests.pl';

ok(Number::Phone->new('+442087712924')->regulator() eq 'OFCOM, http://www.ofcom.org.uk/', "N:P:UK->regulator() works");

done_testing();
