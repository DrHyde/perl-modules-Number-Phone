#!/usr/bin/perl -w

use strict;

use Number::Phone;
use Test::More;

use lib 't/lib';

eval "use Number::Phone::FO";
ok($@, "good, there's no module for the Faroes");
my $fo = Number::Phone->new('+298 303030'); # Faroes Telecom
is($fo->country_code(), 298, "Number::Phone->new('+298 303030')->country_code()");
is($fo->country(), 'FO', "Number::Phone->new('+298 303030')->country()");

eval "use Number::Phone::RU";
ok($@, "good, there's no module for Russia");
my $ru = Number::Phone->new('+7 499 999 82 83'); # Rostelecom
is($ru->country_code(), 7, "Number::Phone->new('+7 499 999 82 83')->country_code()");
is($ru->country(), 'RU', "Number::Phone->new('+7 499 999 82 83')->country()");

# good news comrade (courtesy of translate.google)
ok(Number::Phone->new('+79607001122')->is_mobile(), "Хороший товарищ новость! is_mobile works for Russia!");

# https://github.com/DrHyde/perl-modules-Number-Phone/issues/7
my $de = Number::Phone->new('+493308250565');
# libphonenumber doesn't do areacodes, enable this test once we fake it up in stubs
# is($de->areacode(), 33082, "extracted area code for Menz Kr Oberhavel correctly");
is($de->format(), "+49 33082 50565", "formatted Menz Kr Oberhavel number correctly");
$de = Number::Phone->new('+493022730027'); # Bundestag
is($de->format(), "+49 30 22730027", "formatted Berlin number correctly");

# let's break the UK

$Number::Phone::Country::idd_codes{'44'} = 'MOCK';
$Number::Phone::Country::prefix_codes{'MOCK'} = ['44',   '00',  undef];

require 't/inc/uk_tests.pl';
