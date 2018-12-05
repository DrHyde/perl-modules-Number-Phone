#!perl

use strict;
use warnings;

if(
    (
        exists($ENV{HARNESS_PERL_SWITCHES}) &&
        $ENV{HARNESS_PERL_SWITCHES} =~ /Devel::Cover/
    ) || (
        !$ENV{AUTOMATED_TESTING}
    )
) {
    eval 'use Test::More skip_all => "slurping is too slow so skipping under Devel::Cover and for normal installs, set AUTOMATED_TESTING to run this"';
} else {
    eval 'use Number::Phone::UK::Data';
    print STDERR "# NB: this test takes a few minutes and a big ol' chunk of memory\n";
    Number::Phone::UK::Data->slurp();

    use lib '.';
    require 't/uk_data.t';
}
