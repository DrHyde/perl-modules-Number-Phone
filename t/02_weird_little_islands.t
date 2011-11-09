#!/usr/bin/perl -w

use strict;

use Number::Phone::UK;
use Test::More;

END { done_testing(); }

my $number = Number::Phone->new('+44 7624 000000');
isa_ok($number, 'Number::Phone::IM', "isa N::P::IM");
isa_ok($number, 'Number::Phone::UK', "isa N::P::UK by inheritance");
is($number->country(), 'IM', "country() method works");
ok($number->is_mobile(), "07624 detected as being mobile");
is($number->format(), '+44 7624000000', "format() method works");
is(join(', ', sort $number->type()), 'is_allocated, is_mobile, is_valid', "type() works");

$number = Number::Phone->new('+44 1624 500000');
isa_ok($number, 'Number::Phone::IM', "isa N::P::IM");
isa_ok($number, 'Number::Phone::UK', "isa N::P::UK by inheritance");
is($number->country(), 'IM', "country() method works");
ok($number->is_geographic(), "01624 detected as being geographic");
is($number->format(), '+44 1624 500000', "format() method works");
is(join(', ', sort $number->type()), 'is_allocated, is_geographic, is_valid', "type() works");
is($number->operator(), 'Manx Telecom', "inherited operator() works");
is($number->regulator(), 'Isle of Man Communications Commission, http://www.gov.im/government/boards/telecommunications.xml', "regulator() works");
