#!/usr/bin/perl -w

use strict;

use Number::Phone;

use Test::More tests => 6;

ok(Number::Phone->new("442087712924")->country_code() == 44, "known countries return objects");
ok(Number::Phone->new("+442087712924")->country_code() == 44, "known countries with a + return objects");

foreach my $prefix ('', '+') {
  # can't really use a German number here, in case Number::Phone::DE
  # exists and is installed. Need a mocked country
  # FIXME
  my $object = Number::Phone->new($prefix."491774497319");
  isa_ok($object, 'Number::Phone', "unknown countries return minimal objects".($prefix? " with a +" : ""));
  ok($object->country_code() == 49, "->country_code works");

  # FIXME test other stuff like format(). what else?
}
