#!perl

use strict;
use warnings;

use Test::More ();

if(
    $ENV{CI} || !$ENV{AUTOMATED_TESTING}
) {
    eval 'use Test::More skip_all => "slurping is too slow so skipping under Devel::Cover and for normal installs, set AUTOMATED_TESTING to run this"';
} else {
    eval 'use Number::Phone::UK::Data';
    Test::More::diag("NB: this test takes a few minutes and lots of memory");
    Number::Phone::UK::Data->slurp();

    use lib '.';
    require 't/uk_data.t';
}
