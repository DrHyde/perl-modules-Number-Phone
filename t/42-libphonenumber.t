#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

use Number::Phone::Lib;
use Test::More;

use lib 't/lib';

my $inmarsat870 = Number::Phone::Lib->new("+870123456");
ok(1, "didn't die  when trying to load non-existent stub for Inmarsat +870");
is($inmarsat870->country_code(), '870', 'Inmarsat number has right country_code');
is($inmarsat870->country(), 'Inmarsat', 'Number::Phone::Lib->new("+870123456")->country()');
is($inmarsat870->format(), '+870 123456', 'Number::Phone::Lib->new("+870123456")->format()');
is($inmarsat870->is_valid(), undef, 'Number::Phone::Lib->new("+870123456")->is_valid()');
is($inmarsat870->is_mobile(), undef, 'Number::Phone::Lib->new("+870123456")->is_mobile()');
is($inmarsat870->is_geographic(), undef, 'Number::Phone::Lib->new("+870123456")->is_geographic()');
is($inmarsat870->is_fixed_line(), undef, 'Number::Phone::Lib->new("+870123456")->is_fixed_line()');

my $inmarsat871 = Number::Phone::Lib->new("+8719744591");
ok(1, "didn't die  when trying to load non-existent stub for Inmarsat +871");
is($inmarsat871->country_code(), '871', 'Inmarsat number has right country_code');
is($inmarsat871->country(), 'Inmarsat', 'Number::Phone::Lib->new("+8719744591")->country()');
is($inmarsat871->format(), '+871 9744591', 'Number::Phone::Lib->new("+8719744591")->format()');
is($inmarsat871->is_valid(), undef, 'Number::Phone::Lib->new("+8719744591")->is_valid()');
is($inmarsat871->is_mobile(), undef, 'Number::Phone::Lib->new("+8719744591")->is_mobile()');
is($inmarsat871->is_geographic(), undef, 'Number::Phone::Lib->new("+8719744591")->is_geographic()');
is($inmarsat871->is_fixed_line(), undef, 'Number::Phone::Lib->new("+8719744591")->is_fixed_line()');

eval "use Number::Phone::FO";
ok($@, "good, there's no module for the Faroes");
my $fo = Number::Phone::Lib->new('+298 303030'); # Faroes Telecom
is($fo->country_code(), 298, "Number::Phone::Lib->new('+298 303030')->country_code()");
is($fo->country(), 'FO', "Number::Phone::Lib->new('+298 303030')->country()");

eval "use Number::Phone::RU";
ok($@, "good, there's no module for Russia");
my $ru = Number::Phone::Lib->new('+7 499 999 82 83'); # Rostelecom
is($ru->country_code(), 7, "Number::Phone::Lib->new('+7 499 999 82 83')->country_code()");
is($ru->country(), 'RU', "Number::Phone::Lib->new('+7 499 999 82 83')->country()");

# good news comrade (courtesy of translate.google)
ok(Number::Phone::Lib->new('+79607001122')->is_mobile(), "Хороший товарищ новость! is_mobile works for Russia!");

my $jp = Number::Phone::Lib->new('+81 744 54 4343');
isa_ok($jp, 'Number::Phone::StubCountry::JP', "stub loaded when N::P::CC exists but isn't a proper subclass");
is($jp->areaname(), 'Yamatotakada, Nara', "area names don't have spurious \\s");

# https://github.com/DrHyde/perl-modules-Number-Phone/issues/7
my $de = Number::Phone::Lib->new('+493308250565');
# libphonenumber doesn't do areacodes, enable this test once we fake it up in stubs
# is($de->areacode(), 33082, "extracted area code for Menz Kr Oberhavel correctly");
is($de->format(), "+49 33082 50565", "formatted Menz Kr Oberhavel number correctly");
$de = Number::Phone::Lib->new('+493022730027'); # Bundestag
is($de->format(), "+49 30 22730027", "formatted Berlin number correctly");

eval "use Number::Phone::US";
ok($@, "good, there's no module for US");
my $pdx = '+1 (503) 282-3434';
my $us = Number::Phone::Lib->new($pdx);
isa_ok $us, 'Number::Phone::StubCountry::US';
is($us->country_code(), 1, "Number::Phone::Lib->new('$pdx')->country_code()");
is($us->country(), 'US', "Number::Phone::Lib->new('$pdx')->country()");

eval "use Number::Phone::GB";
ok($@, "good, there's no module for GB");
my $uk = '+449090901234';
my $gb = Number::Phone::Lib->new($uk);
isa_ok $gb, 'Number::Phone::StubCountry::GB';
is($gb->country_code(), 44, "Number::Phone::Lib->new('$uk')->country_code()");
is($gb->country(), 'GB', "Number::Phone::Lib->new('$uk')->country()");

# Try another UK number.
$uk = '+441275939345'; # 441275 is valid, but not 44275.
$gb = Number::Phone::Lib->new($uk);
isa_ok $gb, 'Number::Phone::StubCountry::GB';
is($gb->country_code(), 44, "Number::Phone::Lib->new('$uk')->country_code()");
is($gb->country(), 'GB', "Number::Phone::Lib->new('$uk')->country()");

eval "use Number::Phone::IM";
ok($@, "good, there's no module for IM");
my $ukim = '+447624376698'; # Isle of Man
my $im = Number::Phone::Lib->new($ukim);
isa_ok $im, 'Number::Phone::StubCountry::IM';
is($im->country_code(), 44, "Number::Phone::Lib->new('$ukim')->country_code()");
is($im->country(), 'IM', "Number::Phone::Lib->new('$ukim')->country()");

eval "use Number::Phone::GG";
ok($@, "good, there's no module for GG");
my $ukgg = '+441481723153'; # Guernsey
my $gg = Number::Phone::Lib->new($ukgg);
isa_ok $gg, 'Number::Phone::StubCountry::GG';
is($gg->country_code(), 44, "Number::Phone::Lib->new('$ukgg')->country_code()");
is($gg->country(), 'GG', "Number::Phone::Lib->new('$ukgg')->country()");

eval "use Number::Phone::JE";
ok($@, "good, there's no module for JE");
my $ukje = '+441534556291'; # Jersey
my $je = Number::Phone::Lib->new($ukje);
isa_ok $je, 'Number::Phone::StubCountry::JE';
is($je->country_code(), 44, "Number::Phone::Lib->new('$ukje')->country_code()");
is($je->country(), 'JE', "Number::Phone::Lib->new('$ukje')->country()");

done_testing;
