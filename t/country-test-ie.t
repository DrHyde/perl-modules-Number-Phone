use strict;
use warnings;
use lib 't/inc';
use nptestutils;

use Number::Phone;
use Number::Phone::Lib;
use Test::More;

{
    my $ni = Number::Phone::Lib->new("+35312222918");
    ok(defined($ni), 'Number::Phone::Lib object created for a Dublin number');
    ok($ni->is_valid, '+35312222918 is a valid number');
}

{
    my $ni = Number::Phone->new("+35312222918");
    ok(defined($ni), 'Number::Phone object created for a Dublin number');
    ok($ni->is_valid, '+35312222918 is a valid number');
}

{
    my $ni = Number::Phone::Lib->new("+3534890320202");
    ok(defined($ni), 'Number::Phone::Lib object created for a Belfast number, using +353 48');
    ok($ni->is_valid, '+3534890320202 is a valid number');
}

{
    my $ni = Number::Phone->new("+3534890320202");
    ok(defined($ni), 'Number::Phone object created for a Belfast number, using +353 48');
    ok($ni->is_valid, '+3534890320202 is a valid number');
}

done_testing();
