#!/usr/bin/perl -w

use strict;

use Test::More tests => 2;

use Number::Phone::Country qw(noexport);

eval { phone2country('+44 1234567890') };
ok($@, "phone2country export can be suppressed");
eval { phone2country('+44 1234567890') };
ok(Number::Phone::Country::phone2country('+44 12345678') eq 'GB', "calling by full name still works");
