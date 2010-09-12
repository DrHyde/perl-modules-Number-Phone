#!/usr/bin/perl -w

use strict;

use Number::Phone;

use Test::More tests => 9;

use Number::Phone::Country;

ok(Number::Phone->new("442087712924")->country_code() == 44, "known countries return objects");
ok(Number::Phone->new("+442087712924")->country_code() == 44, "known countries with a + return objects");
ok(Number::Phone->new("+442087712924")->format() eq '+44 20 87712924' , "format() works (sanity check cos it changes later)");

# let's break the UK
$Number::Phone::Country::idd_codes{'44'} = 'MOCK';
$Number::Phone::Country::prefix_codes{'MOCK'} = ['44',   '00',  undef];

foreach my $prefix ('', '+') {
  my $object = Number::Phone->new($prefix."442087712924");
  isa_ok($object, 'Number::Phone::StubCountry', "unknown countries return minimal objects".($prefix? " with a +" : ""));
  is($object->country_code(), '44', "->country_code works");
  is($object->format(), '+44 2087712924', "->format works");
}
