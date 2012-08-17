#!/usr/bin/perl -w

use Test::More tests => 4;
use Scalar::Util qw(blessed);

use Number::Phone;

use lib 't/inc';
use fatalwarnings;

my $number = Number::Phone->new("+441234567890");
ok(blessed($number) && $number->isa('Number::Phone::UK'),
    "N::P->new() works without specifically loading a country module");

$number = Number::Phone->new("+12265550199");
ok(blessed($number) && $number->isa('Number::Phone::NANP::CA'),
    "... and it even works for the NANP!");

$number = Number::Phone->new("+18666232282");
ok(blessed($number) && $number->isa('Number::Phone::NANP'),
    "... and it even works for the non-geographic NANP!");

# +999 is "Proposed disaster relief (TDR) service", NYI by N::P::Country
ok(
    !blessed(Number::Phone->new("+999123")) &&
    !defined(Number::Phone->new("+999123")),
    "A country code not recognised by N::P::Country returns false"
);

# FIXME - Kazakhstan/Russia weirdness
