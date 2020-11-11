#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

use Number::Phone::Lib;
use Test::More;

{
    my $np = Number::Phone::Lib->new('AR', '3715 65 4320');
    ok($np->is_fixed_line, '3715 65 4320 is a fixed line without national prefix...');
    ok(!$np->is_mobile, '...it is not a mobile...');
    is($np->format, '+54 3715 65 4320', '...its international format is correct');
    is($np->format_using('National'), '03715 65-4320', '...as is its national format');
}
{
    my $np = Number::Phone::Lib->new('AR', '0 3715 65 4320');
    ok($np->is_fixed_line, '03715 65 4320 is a fixed line with a national prefix...');
    ok(!$np->is_mobile, '...it is not a mobile...');
    is($np->format, '+54 3715 65 4320', '...its international format is correct');
    is($np->format_using('National'), '03715 65-4320', '...as is its national format');
}
{
    my $np = Number::Phone::Lib->new('AR', '3715 15 65 4320');
    ok($np->is_mobile, '3715 15 65 4320 is a mobile with a national prefix...');
    ok(!$np->is_fixed_line, '...it is not a fixed line...');
    is($np->format, '+54 9 3715 65 4320', '...its international format is correct');
    is($np->format_using('National'), '03715 15-65-4320', '...as is its national format');
}
{
    my $np = Number::Phone::Lib->new('AR', '0 3715 15 65 4320');
    ok($np->is_mobile, '03715 15 65 4320 is a mobile with a national prefix...');
    ok(!$np->is_fixed_line, '...it is not a fixed line...');
    is($np->format, '+54 9 3715 65 4320', '...its international format is correct');
    is($np->format_using('National'), '03715 15-65-4320', '...as is its national format');
}

done_testing();
