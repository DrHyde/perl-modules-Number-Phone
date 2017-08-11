#!/usr/bin/perl -w

use strict;
if(
    exists($ENV{HARNESS_PERL_SWITCHES}) &&
    $ENV{HARNESS_PERL_SWITCHES} =~ /Devel::Cover/
) {
    eval 'use Test::More skip_all => "slurping is tooooo sloooooow under Devel::Cover"';
} else {
    eval 'use Number::Phone::UK::Data';
    print STDERR "# NB: this test takes a few minutes and a big ol' chunk of memory\n";
    Number::Phone::UK::Data->slurp();

    require 't/uk_data.t';
}
