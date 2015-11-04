#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

our $CLASS = 'Number::Phone::Lib';
eval "use $CLASS";
use Test::More;

END { done_testing(); }

# make sure we avoid instantiating stubs when supplied with just
# a +NNN country code. This is looking both for bugs in our code,
# but also bogus regexes in libphonenumber, such as
# https://github.com/googlei18n/libphonenumber/issues/749
is($CLASS->new("NL", "+312"), undef, "Country code only (CC and IDD supplied)");
foreach my $idd (1, 1246, keys %Number::Phone::Country::idd_codes) {
    is(
        $CLASS->new("+$idd"),
        undef,
        "country-code +$idd (".
            ($idd eq '1'                                   ? 'NANP' :
             $idd eq '1246'                                ? 'Barbados (NANP)' :
             ref($Number::Phone::Country::idd_codes{$idd}) ? '['.join(', ', @{$Number::Phone::Country::idd_codes{$idd}}).']' :
                                                             $Number::Phone::Country::idd_codes{$idd}
            ).
        ") alone is bogus"
    );
}

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

note("different invocation styles");

isa_ok($CLASS->new('+44 20 8771 2924'), 'Number::Phone::StubCountry::GB', "N::P::Lib->new('+44NNNNN')");
isa_ok($CLASS->new('+44', '20 8771 2924'), 'Number::Phone::StubCountry::GB', "N::P::Lib->new('+44', 'NNNNN')");
isa_ok($CLASS->new('UK', '020 8771 2924'), 'Number::Phone::StubCountry::GB', "N::P::Lib->new('UK', '0NNNNN')");
isa_ok($CLASS->new('UK', '20 8771 2924'), 'Number::Phone::StubCountry::GB', "N::P::Lib->new('UK', 'NNNNN')");
