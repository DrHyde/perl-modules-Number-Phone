#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

use Test::More tests => 1;

use Number::Phone::Country qw(uk);

ok(Number::Phone::Country::phone2country('+44 20 12345678') eq 'UK', "can return UK instead of GB");
