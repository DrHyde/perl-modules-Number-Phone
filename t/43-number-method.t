#!/usr/bin/perl -w

use strict;
use lib 't/inc';
use fatalwarnings;

use Number::Phone;
use Test::More;

END { done_testing(); }

# number() is implemented in UK, NANP, and StubCountry, so we test each of
# those.

my %tests = (
    '+442 0 8771 2924' => '2087712924',   # UK
    '+1 202 418 1440'  => '2024181440',   # NANP::US
    '+44 762 437 6698' => '7624376698'    # StubCountry::IM
);

while (my ($num, $expect) = each %tests) {
    my $number = new_ok 'Number::Phone', [$num];
    is $number->number, $expect;
}
