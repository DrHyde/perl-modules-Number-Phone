use strict;
use warnings;
use lib 't/inc';
use nptestutils;

use Number::Phone;
use Number::Phone::Lib;
use Test::More;

{
    my $ni = Number::Phone::Lib->new("+3534890320202");
    ok(defined($ni), 'Number::Phone::Lib object created');
    ok($ni->is_valid, '+3534890320202 is a valid number');
}

{
    my $ni = Number::Phone->new("+3534890320202");
    ok(defined($ni), 'Number::Phone object created');
    ok($ni->is_valid, '+3534890320202 is a valid number');
}

done_testing();
