use strict;
use warnings;
use lib 't/inc';
use nptestutils;

use Number::Phone::Lib;
use Test::More;

{
    my $np = Number::Phone::Lib->new('SM', '912345');
    ok($np->is_fixed_line, '912345 is a fixed line without the 0549 prefix...');
    ok(!$np->is_mobile, '...it is not a mobile...');
    is($np->format, '+378 0549 912345', '...its international format is correct');
    is($np->format_using('National'), '0549 912345', '...as is its national format');
}
{
    my $np = Number::Phone::Lib->new('SM', '0549 912345');
    ok($np->is_fixed_line, '0549 912345 is a fixed line without the 0549 prefix...');
    ok(!$np->is_mobile, '...it is not a mobile...');
    is($np->format, '+378 0549 912345', '...its international format is correct');
    is($np->format_using('National'), '0549 912345', '...as is its national format');
}
{
    my $np = Number::Phone::Lib->new('SM', '66661212');
    ok($np->is_mobile, '044 81 1234 5678 is a mobile...');
    ok(!$np->is_fixed_line, '...it is not a fixed line...');
    is($np->format, '+378 66 66 12 12', '...its international format is correct');
    is($np->format_using('National'), '66 66 12 12', '...as is its national format');
}
{
    my $np = Number::Phone::Lib->new('SM', '0549 66661212');
    ok(!defined $np, '0549 66661212 is a mobile with the 0549 prefix, which is not valid');
}

done_testing();
