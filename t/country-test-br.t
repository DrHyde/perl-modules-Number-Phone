#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

use Number::Phone::Lib; # need to force it to use stubs in case N::P::BR exists
use Test::More;

END { done_testing(); }

{
    my $np = Number::Phone::Lib->new('BR', '0 85 2222 2222');
    ok($np->is_fixed_line, '0 85 2222 2222 is a fixed line without carrier select code...');
    ok(!$np->is_mobile, '...it is not a mobile...');
    is($np->format, '+55 85 2222 2222', '...its international format is correct');
    is($np->format_using('National'), '(85) 2222-2222', '...as is its national format');
}
{
    my $np = Number::Phone::Lib->new('BR', '0 31 85 2222 2222');
    ok($np->is_fixed_line, '0 31 85 2222 2222 is a fixed line with carrier select code...');
    ok(!$np->is_mobile, '...it is not a mobile...');
    is($np->format, '+55 85 2222 2222', '...its international format is correct');
    is($np->format_using('National'), '(85) 2222-2222', '...as is its national format');
}
{
    my $np = Number::Phone::Lib->new('BR', '35 9 98 70 56 56');
    ok($np->is_mobile, '35 9 98 70 56 56 is a new style 9 digit mobile with area code...');
    ok(!$np->is_fixed_line, '...it is not a fixed line...');
    is($np->format, '+55 35 99870 5656', '...its international format is correct');
    is($np->format_using('National'), '(35) 99870-5656', '...as is its national format');
}
{
    my $np = Number::Phone::Lib->new('BR', '35 98 70 56 56');
    ok($np->is_mobile, '35 9 98 70 56 56 is an old style 8 digit mobile with area code...');
    ok(!$np->is_fixed_line, '...it is not a fixed line...');
    is($np->format, '+55 35 9870 5656', '...its international format is correct');
    is($np->format_using('National'), '(35) 9870-5656', '...as is its national format');
}
