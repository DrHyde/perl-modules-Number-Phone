#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

use Number::Phone::Lib; # need to force it to use stubs in case N::P::BR exists
use Test::More;

END { done_testing(); }

# Mobile Number
is(Number::Phone::Lib->new("+55 35 9 98 70 56 56")->is_mobile(), 1, "+55 35 turned into +55 35 9");
is(Number::Phone::Lib->new("+55 35   98 70 56 56")->is_mobile(), 1, "old format still works (according to Google anyway)");

# ignore carrier select prefixes when parsing a local number
is(Number::Phone::Lib->new("BR", "08522222222")->format(), '+55 85 2222 2222', '085 NNNN parsed ok');
is(Number::Phone::Lib->new("BR", "0318522222222")->format(), '+55 85 2222 2222', '0 31 85 NNNN parsed ok');
