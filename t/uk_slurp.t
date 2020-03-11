#!perl

use strict;
use warnings;

use Test::More;

if(
    $ENV{CI} || !$ENV{AUTOMATED_TESTING}
) {
    eval 'use Test::More skip_all => "slurping is too slow so skipping under CI and for normal installs, set AUTOMATED_TESTING to run this"';
} else {
    eval 'use Number::Phone::UK::Data';
    diag("NB: this test takes a few minutes and lots of memory");

    my $time = time();
    Number::Phone::UK::Data::slurp();
    my $first_db = Number::Phone::UK::Data::db();
    ok(time() - $time > 2, "the first slurp took ages");

    $time = time();
    Number::Phone::UK::Data::slurp();
    ok(time() - $time < 2, "trying to slurp again is fast cos it does nothing");

    is($first_db, Number::Phone::UK::Data::db(), "both slurps returned the same reference");

    use lib '.';
    require 't/uk_data.t';
}
