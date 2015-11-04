#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

use Number::Phone::UK;
use Test::More;

END { done_testing(); }

require 'uk_tests.pl';
