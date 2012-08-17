#!/usr/bin/perl -w

use strict;
use lib 't/inc';
use fatalwarnings;

use lib 't/lib'; # for mocking of the UK

use Test::More tests => 11;

use Number::Phone;
use Number::Phone::Country;

ok(Number::Phone->new("442087712924")->country_code() == 44, "known countries return objects");
ok(Number::Phone->new("+442087712924")->country_code() == 44, "known countries with a + return objects");
is(Number::Phone->new("+447979866975")->format(), '+44 7979866975' , "format() works (sanity check cos it changes later)");

# let's break the UK
$Number::Phone::Country::idd_codes{'44'} = 'MOCK';
$Number::Phone::Country::prefix_codes{'MOCK'} = ['44',   '00',  undef];

foreach my $prefix ('', '+') {
  my $object = Number::Phone->new($prefix."447979866975");
  isa_ok($object, 'Number::Phone::StubCountry', "unknown countries return minimal objects".($prefix? " with a +" : ""));
  isa_ok($object, 'Number::Phone::StubCountry::MOCK', "class hierarchy is correct");
  is($object->country_code(), '44', "->country_code works");
  is($object->format(), '+44 7979 866975', "->format works");
}
