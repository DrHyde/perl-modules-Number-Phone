#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use nptestutils;

use Test::More;

use Number::Phone::Country qw(noexport uk);

is(Number::Phone::Country::phone2country('+44 20 12345678'), 'UK', "can return UK instead of GB");

done_testing();
