#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

use Number::Phone;
use Test::More;

END { done_testing(); }

require 'uk_tests.pl';

ok(Number::Phone->new('+442087712924')->regulator() eq 'OFCOM, http://www.ofcom.org.uk/', "N:P:UK->regulator() works");
