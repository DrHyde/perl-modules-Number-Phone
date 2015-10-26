#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

use Number::Phone;
use Test::More;

END { done_testing(); }

# Mobile Number
is(Number::Phone->is_mobile("+55 35 9 98 70 56 56"), 1, "is +55 35 turned into +55 35 9");
is(Number::Phone->is_mobile("+55 35   98 70 56 56"), 1, "old format still works (according to Google anyway)");
