#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

our $CLASS = 'Number::Phone';
eval "use $CLASS";
use Test::More;

use Number::Phone::Country::Data;

# picking NL as our random victim because https://github.com/DrHyde/perl-modules-Number-Phone/issues/22
my $nl_obj = Number::Phone->new("+31201234567");
ok($nl_obj->isa('Number::Phone::StubCountry::NL'), "NL numbers are handled by a stub");
ok($nl_obj->format() eq '+31 20 123 4567', 'Number::Phone->new("+31201234567")->format() is correct');

$nl_obj = Number::Phone->new('nl', "+31201234567");
ok($nl_obj->format() eq '+31 20 123 4567', 'Number::Phone->new("nl", "+31201234567") also works as a constructor');

$nl_obj = Number::Phone->new('NL', "+31201234567");
ok($nl_obj->format() eq '+31 20 123 4567', 'Number::Phone->new("NL", "+31201234567") also works as a constructor (specified country, and provided IDD)');

$nl_obj = Number::Phone->new('NL', "201234567");
ok($nl_obj->format() eq '+31 20 123 4567', 'Number::Phone->new("NL", "201234567") also works as a constructor (no national prefix)');

$nl_obj = Number::Phone->new('NL', "0201234567");
ok($nl_obj->format() eq '+31 20 123 4567', 'Number::Phone->new("NL", "0201234567") also works as a constructor (national prefix)');

is(Number::Phone->new("+312"),       undef, "number too short? undef");
is(Number::Phone->new("NL", "+312"), undef, "number too short? undef");
is(Number::Phone->new("NL", "2"),    undef, "number too short? undef");
is(Number::Phone->new("NL", "02"),   undef, "number too short? undef");

foreach my $idd (1, 1246, keys %Number::Phone::Country::idd_codes) {
    is(
        Number::Phone->new("+$idd"),
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

# let's break the UK
{
  # silence stupid warning about prefix_codes being used only once
  no warnings 'once';
  $Number::Phone::Country::idd_codes{'44'} = 'MOCK';
  $Number::Phone::Country::prefix_codes{'MOCK'} = ['44',   '00',  undef];
}

require 'uk_tests.pl';

done_testing;
