#!/usr/bin/perl -w

use strict;

use Number::Phone;
use Test::More;

# let's break the UK
$Number::Phone::Country::idd_codes{'44'} = 'MOCK';
$Number::Phone::Country::prefix_codes{'MOCK'} = ['44',   '00',  undef];

END { done_testing(); }

do 't/inc/uk_tests.inc';
