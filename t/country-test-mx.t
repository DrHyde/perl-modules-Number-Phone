#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

use Number::Phone::Lib;
use Test::More;

END { done_testing(); }

{
    my $np = Number::Phone::Lib->new('MX', '81 1234 5678');
    ok($np->is_fixed_line, '81 1234 5678 is a fixed line without national prefix...');
    ok($np->is_mobile, '... or it could be a mobile...');
    is($np->format, '+52 81 1234 5678', '...its international format is correct');
    is($np->format_using('National'), '01 81 1234 5678', '...as is its national format');
}
{
    my $np = Number::Phone::Lib->new('MX', '01 81 1234 5678');
    ok($np->is_fixed_line, '01 81 1234 5678 is a fixed line with domestic dialling prefix...');
    ok($np->is_mobile, '... or it could be a mobile...');
    is($np->format, '+52 81 1234 5678', '...its international format is correct');
    is($np->format_using('National'), '01 81 1234 5678', '...as is its national format');
}

# if we're specific that we're dialling a mobile, then things are less
# confused
{
    my $np = Number::Phone::Lib->new('MX', '044 81 1234 5678');
    ok($np->is_mobile, '044 81 1234 5678 is a local mobile as called from a fixed line...');
    ok(!$np->is_fixed_line, '...it is not a fixed line...');
    is($np->format, '+52 1 81 1234 5678', '...its international format is correct');
    is($np->format_using('National'), '044 81 1234 5678', '...as is its national format');
}
{
    my $np = Number::Phone::Lib->new('MX', '045 81 1234 5678');
    ok($np->is_mobile, '045 81 1234 5678 is a domestic mobile as called from a fixed line...');
    ok(!$np->is_fixed_line, '...it is not a fixed line...');
    is($np->format, '+52 1 81 1234 5678', '...its international format is correct');
    # 045 is the prefix used when dialling a mobile number from a fix line,
    # where the mobile and the fixed line share the same area code.  045 is
    # the code used when the area codes differ.  The area code of the caller is
    # not known, so libphonenumber always uses 044.
    is($np->format_using('National'), '044 81 1234 5678', '...as is its national format (045 becomes 044)');
}
