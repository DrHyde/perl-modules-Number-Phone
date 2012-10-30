#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

use Number::Phone;
use Test::More;

use lib 't/lib';

my $inmarsat870 = Number::Phone->new("+870123456");
ok(1, "didn't die  when trying to load non-existent stub for Inmarsat +870");
is($inmarsat870->country_code(), '870', 'Inmarsat number has right country_code');
is($inmarsat870->country(), 'Inmarsat', 'Number::Phone->new("+870123456")->country()');
is($inmarsat870->format(), '+870 123456', 'Number::Phone->new("+870123456")->format()');
is($inmarsat870->is_valid(), undef, 'Number::Phone->new("+870123456")->is_valid()');
is($inmarsat870->is_mobile(), undef, 'Number::Phone->new("+870123456")->is_mobile()');
is($inmarsat870->is_geographic(), undef, 'Number::Phone->new("+870123456")->is_geographic()');
is($inmarsat870->is_fixed_line(), undef, 'Number::Phone->new("+870123456")->is_fixed_line()');

my $inmarsat871 = Number::Phone->new("+8719744591");
ok(1, "didn't die  when trying to load non-existent stub for Inmarsat +871");
is($inmarsat871->country_code(), '871', 'Inmarsat number has right country_code');
is($inmarsat871->country(), 'Inmarsat', 'Number::Phone->new("+8719744591")->country()');
is($inmarsat871->format(), '+871 9744591', 'Number::Phone->new("+8719744591")->format()');
is($inmarsat871->is_valid(), undef, 'Number::Phone->new("+8719744591")->is_valid()');
is($inmarsat871->is_mobile(), undef, 'Number::Phone->new("+8719744591")->is_mobile()');
is($inmarsat871->is_geographic(), undef, 'Number::Phone->new("+8719744591")->is_geographic()');
is($inmarsat871->is_fixed_line(), undef, 'Number::Phone->new("+8719744591")->is_fixed_line()');

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

is(Number::Phone->new('+81 744 54 4343')->areaname(), 'Yamatotakada, Nara',
  "area names don't have spurious \\s");

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
