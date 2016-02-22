#!/usr/bin/perl -w

use strict;
use lib 't/inc';
use fatalwarnings;

use Number::Phone;
use Test::More;
use Scalar::Util qw(blessed);

END { done_testing(); }

# number() is implemented in the base class, just make sure we
# can get there from everywhere
# those.

my %tests = (
    '+44 20 8771 2924' => '2087712924',   # UK
    '+1 202 418 1440'  => '2024181440',   # NANP::US
    '+81 3-3580-3311'  => '335803311'     # StubCountry::JP
);

while (my ($num, $expect) = each %tests) {
    my $number = Number::Phone->new($num);
    is($number->raw_number, $expect, blessed($number)."'s raw_number() works");
}
