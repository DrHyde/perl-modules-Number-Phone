#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

our $CLASS = 'Number::Phone::Lib';
eval "use $CLASS";
use Test::More;

use lib 't/lib';

require 'common-stub_and_libphonenumber_tests.pl';
require 'common-nanp_and_libphonenumber_tests.pl';

note("libphonenumber-compatibility for the UK and dependencies");
my $uk = '+449090901234';
my $gb = $CLASS->new($uk);
isa_ok $gb, 'Number::Phone::StubCountry::GB';
is($gb->country_code(), 44, "$CLASS->new('$uk')->country_code()");
is($gb->country(), 'GB', "$CLASS->new('$uk')->country()");
is($gb->format(), '+44 909 090 1234', "$CLASS->new('$uk')->format()");

# Try another UK number.
$uk = '+441275939345'; # 441275 is valid, but not 44275.
$gb = $CLASS->new($uk);
isa_ok $gb, 'Number::Phone::StubCountry::GB';
is($gb->country_code(), 44, "$CLASS->new('$uk')->country_code()");
is($gb->country(), 'GB', "$CLASS->new('$uk')->country()");
is($gb->format(), '+44 1275 939345', "$CLASS->new('$uk')->format()");

my $ukim = '+447624376698'; # Isle of Man
my $im = $CLASS->new($ukim);
isa_ok $im, 'Number::Phone::StubCountry::IM';
is($im->country_code(), 44, "$CLASS->new('$ukim')->country_code()");
is($im->country(), 'IM', "$CLASS->new('$ukim')->country()");
is($im->format(), '+44 7624 376698', "$CLASS->new('$ukim')->format()");

my $ukgg = '+441481723153'; # Guernsey
my $gg = $CLASS->new($ukgg);
isa_ok $gg, 'Number::Phone::StubCountry::GG';
is($gg->country_code(), 44, "$CLASS->new('$ukgg')->country_code()");
is($gg->country(), 'GG', "$CLASS->new('$ukgg')->country()");
is($gg->format(), '+44 1481 723153', "$CLASS->new('$ukgg')->format()");

my $ukje = '+441534556291'; # Jersey
my $je = $CLASS->new($ukje);
isa_ok $je, 'Number::Phone::StubCountry::JE';
is($je->country_code(), 44, "$CLASS->new('$ukje')->country_code()");
is($je->country(), 'JE', "$CLASS->new('$ukje')->country()");
is($je->format(), '+44 1534 556291', "$CLASS->new('$ukje')->format()");

done_testing;
