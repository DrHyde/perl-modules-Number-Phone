#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

use Test::More tests => 1;

use Number::Phone::Country qw(uk);

is(Number::Phone::Country::phone2country('+44 20 12345678'), 'UK', "can return UK instead of GB");
