use strict;
use warnings;

use vars qw($CLASS);
use utf8;
use charnames qw(:full);

# turn off the user's locale settings
local %ENV;
delete @ENV{qw(
    LANGUAGE LC_ALL LC_MESSAGES LANG
    REQUEST_METHOD HTTP_ACCEPT_LANGUAGE
)};
$ENV{IGNORE_WIN32_LOCALE} = 1;

{
  no warnings 'redefine';
  sub is_libphonenumber { $CLASS eq 'Number::Phone::Lib' }
  sub skip_if_libphonenumber {
    my($msg, $count, $sub) = @_;
    SKIP: {
      skip $msg, $count if(is_libphonenumber());
      $sub->();
    };
  }
}

note("Common tests for Number::Phone::StubCountry::* and Number::Phone::Lib");

my $inmarsat870 = $CLASS->new("+870123456");
is($inmarsat870->country_code(), '870', 'Inmarsat number has right country_code');
is($inmarsat870->country(), 'Inmarsat', "$CLASS->new('+870123456')->country()");
is($inmarsat870->format(), '+870 123456', "$CLASS->new('+870123456')->format()");
is($inmarsat870->is_valid(), undef, "$CLASS->new('+870123456')->is_valid()");
is($inmarsat870->is_mobile(), undef, "$CLASS->new('+870123456')->is_mobile()");
is($inmarsat870->is_geographic(), undef, "$CLASS->new('+870123456')->is_geographic()");
is($inmarsat870->is_fixed_line(), undef, "$CLASS->new('+870123456')->is_fixed_line()");

# my $inmarsat871 = $CLASS->new("+8719744591");
# is($inmarsat871->country_code(), '871', 'Inmarsat number has right country_code');
# is($inmarsat871->country(), 'Inmarsat', "$CLASS->new('+8719744591')->country()");
# is($inmarsat871->format(), '+871 9744591', "$CLASS->new('+8719744591')->format()");
# is($inmarsat871->is_valid(), undef, "$CLASS->new('+8719744591')->is_valid()");
# is($inmarsat871->is_mobile(), undef, "$CLASS->new('+8719744591')->is_mobile()");
# is($inmarsat871->is_geographic(), undef, "$CLASS->new('+8719744591')->is_geographic()");
# is($inmarsat871->is_fixed_line(), undef, "$CLASS->new('+8719744591')->is_fixed_line()");

my $international883 = $CLASS->new("+88300000000");
isa_ok($international883, "Number::Phone::StubCountry");
is($international883->country(), 'InternationalNetworks', '$CLASS->new("+88300000000")->country()');

my $international883120 = $CLASS->new("+88312000000");
isa_ok($international883120, "Number::Phone::StubCountry");
is($international883120->country(), 'Telenor', '$CLASS->new("+88312000000")->country()');

my $fo = $CLASS->new('+298 303030'); # Faroes Telecom
is($fo->country_code(), 298, "$CLASS->new('+298 303030')->country_code()");
is($fo->country(), 'FO', "$CLASS->new('+298 303030')->country()");

my $ru = $CLASS->new('+7 499 999 82 83'); # Rostelecom
is($ru->country_code(), 7, "$CLASS->new('+7 499 999 82 83')->country_code()");
is($ru->country(), 'RU', "$CLASS->new('+7 499 999 82 83')->country()");

$ru = $CLASS->new('+7(812)315-98-83'); # national dialling prefix is 8, but
                                       # this is a valid number
is($ru->format(), '+7 812 315 98 83', '+7 8 numbers work');

ok($CLASS->new('+79607001122')->is_mobile(), "is_mobile works for Russia");

my $jp = $CLASS->new('+81 744 54 4343');
isa_ok($jp, 'Number::Phone::StubCountry::JP', "stub loaded when N::P::CC exists but isn't a proper subclass");
is($jp->areaname(), 'Yamatotakada, Nara', "area names don't have spurious \\s");

# https://github.com/DrHyde/perl-modules-Number-Phone/issues/7
my $de = $CLASS->new('+493308250565');
is($de->format(), "+49 33082 50565", "formatted Menz Kr Oberhavel number correctly");

# libphonenumber doesn't do areacodes, enable this test if we ever fake it up in stubs
# skip_if_libphonenumber(
#   "libphonenumber doesn't support areacodes", 1,
#   sub { is($de->areacode(), 33082, "extracted area code for Menz Kr Oberhavel correctly"); }
# );

$de = $CLASS->new('+493022730027'); # Bundestag
is($de->format(), "+49 30 22730027", "formatted Berlin number correctly");
is($de->areaname(), "Berlin", "got area name correctly");

my $munchen = "M\N{LATIN SMALL LETTER U WITH DIAERESIS}nchen";
$de = $CLASS->new('+498921620'); # Bavarian govt in Munich
is($de->areaname(),     "Munich", "got Munich area name correctly in English by default when there's no locale set");
is($de->areaname('en'), "Munich", "got area name correctly in English by asking for it");
is($de->areaname('de'), $munchen, "got area name correctly in German by asking for it");
is($de->areaname('ja'), undef,     "... but if we ask for it in Japanese we get nothing");
{
    local $ENV{LANGUAGE}='sv:de';
    is($de->areaname(), $munchen,     "got area name correctly in German from the locale");
    is($de->areaname('en'), "Munich", "got area name correctly in English by asking for it, over-riding a locale");
    is($jp->areaname(), 'Yamatotakada, Nara', "... and we fall back to English correctly");
    local $ENV{LANGUAGE}='en';
    is($de->areaname(), "Munich", "got area name correctly in English from the locale");
}

my $no = $CLASS->new('+4779023450'); # Some Norway islands
isa_ok($no, "Number::Phone::StubCountry");

$no = $CLASS->new('+479690448'); # invalid, should be undef. NO has no national dialling prefix
is($no, undef, "invalid numbers in countries with no national dialing prefix return undef from constructor");

my $xk = $CLASS->new('+383 43201234');
ok($xk->is_valid(),                        "+383 (Kosovo, XK) can be instantiated");
is($xk->country_code(), 383,               "... has right country_code()");
is($xk->country(),      'XK',              "... has right country()");
is($xk->format(),      '+383 43 201 234',  "... numbers format correctly");

1;
