#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

use Test::More;

END { done_testing(); }

use Number::Phone::Country qw(noexport);

is(Number::Phone::Country::phone2country('+47 1234 5678'),   'NO', "first of three");
is(Number::Phone::Country::phone2country('+44 20 12345678'), 'GB', "uk not set accidentally");
