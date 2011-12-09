#!/usr/bin/perl -w

use strict;

use Number::Phone::UK;
use Test::More;

END { done_testing(); }

do 't/inc/uk_tests.inc';
