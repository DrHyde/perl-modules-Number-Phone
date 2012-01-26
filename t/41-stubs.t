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

# let's break the UK

$Number::Phone::Country::idd_codes{'44'} = 'MOCK';
$Number::Phone::Country::prefix_codes{'MOCK'} = ['44',   '00',  undef];

require 't/inc/uk_tests.pl';
