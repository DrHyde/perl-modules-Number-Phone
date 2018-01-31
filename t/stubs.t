#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

our $CLASS = 'Number::Phone';
eval "use $CLASS";
use Test::More;

END { done_testing(); }

use Number::Phone::Country::Data;

# picking NL as our random victim because https://github.com/DrHyde/perl-modules-Number-Phone/issues/22
my $nl_obj = Number::Phone->new("+31201234567");
ok($nl_obj->isa('Number::Phone::StubCountry::NL'), "NL numbers are handled by a stub");
is($nl_obj->format(), '+31 20 123 4567', 'Number::Phone->new("+31201234567")->format() is correct');

$nl_obj = Number::Phone->new('nl', "+31201234567");
is($nl_obj->format(), '+31 20 123 4567', 'Number::Phone->new("nl", "+31201234567") also works as a constructor');

$nl_obj = Number::Phone->new('NL', "+31201234567");
is($nl_obj->format(), '+31 20 123 4567', 'Number::Phone->new("NL", "+31201234567") also works as a constructor (specified country, and provided IDD)');

$nl_obj = Number::Phone->new('NL', "201234567");
is($nl_obj->format(), '+31 20 123 4567', 'Number::Phone->new("NL", "201234567") also works as a constructor (no national prefix)');

$nl_obj = Number::Phone->new('NL', "0201234567");
is($nl_obj->format(), '+31 20 123 4567', 'Number::Phone->new("NL", "0201234567") also works as a constructor (national prefix)');

is(Number::Phone->new("NL", "2"),    undef, "number too short? undef");
is(Number::Phone->new("NL", "02"),   undef, "number too short? undef");

note("National formatting");

my $ar_obj = Number::Phone->new('AR', '+54 9 11 1234 5678');
is($ar_obj->format_using('National'), '011 15-1234-5678', 'AR national formatting includes 0, 15, lacks 9');
is($ar_obj->format_for_country('AR'), '011 15-1234-5678', 'AR argument treated same as national');
is($ar_obj->format_for_country('+54'), '011 15-1234-5678', '+54 argument treated same as national');
is($ar_obj->format_using('NationallyPreferred'), '+54 9 11 1234-5678', 'AR international formatting includes +54, 9, lacks 15');
is($ar_obj->format_for_country('GB'), '+54 9 11 1234-5678', 'GB argument treated same as international');
is($ar_obj->format_for_country('+44'), '+54 9 11 1234-5678', '+44 argument treated same as international');
my $dk_obj = Number::Phone->new("DK", "+45 38123456");
is($dk_obj->format_using('National'), '38 12 34 56', 'DK national formatting has no prefix');

use lib 't/lib';

require 'common-stub_and_libphonenumber_tests.pl';

# let's break the UK
{
  # silence stupid warning about prefix_codes being used only once
  no warnings 'once';
  $Number::Phone::Country::idd_codes{'44'} = 'MOCK';
  $Number::Phone::Country::prefix_codes{'MOCK'} = ['44',   '00',  undef];
}

require 'uk_tests.pl';
