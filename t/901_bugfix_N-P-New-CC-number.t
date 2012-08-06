#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

use Number::Phone;

use Test::More tests => 7;

ok(Number::Phone->new('UK', '07970866975'), "N::P->new('CC', '012345')");
ok(Number::Phone->new('UK', '7970866975'), "N::P->new('CC', '12345')");

ok(Number::Phone->new('+44', '7970866975'),  "N::P->new('+NN', '12345')");
ok(Number::Phone->new('+44', '07970866975'), "N::P->new('+NN', '012345')");

ok(Number::Phone->new('+447970866975'), "N::P->new('+NN12345')");

ok(Number::Phone->new('UK', '+447970866975'), "N::P->new('CC', '+NN12345')");
ok(Number::Phone->new('uk', '+447970866975'), "N::P->new('cc', '+NN12345')");
