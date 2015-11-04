#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

use Test::More;

END { done_testing(); }

use Number::Phone::Country qw(noexport);

eval { phone2country('+44 1234567890') };
ok($@, "phone2country export can be suppressed");
is(Number::Phone::Country::phone2country('+44 12345678'), 'GB', "calling by full name still works");
