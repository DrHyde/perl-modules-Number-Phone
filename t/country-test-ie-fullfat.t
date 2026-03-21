use strict;
use warnings;
use lib 't/inc';
use nptestutils;

use Test::More;

eval 'use Number::Phone::IE';

SKIP: {
    skip("Number::Phone::IE isn't installed", 1)
        unless($Number::Phone::IE::VERSION);

    {
        my $ni = Number::Phone->new("+35312222918");
        ok(defined($ni), 'Number::Phone object created for a Dublin number');
        isa_ok($ni, 'Number::Phone::IE');
        ok($ni->is_valid, '+35312222918 is a valid number');
    }

    {
        my $ni = Number::Phone->new("+442890320202");
        isa_ok($ni, 'Number::Phone::UK');
        ok(defined($ni), 'Number::Phone object created for a Belfast number, using +44 28');
        ok($ni->is_valid, '+442890320202 is a valid number');
    }

    {
        my $ni = Number::Phone->new("+3534890320202");
        isa_ok($ni, 'Number::Phone::IE');
        ok(defined($ni), 'Number::Phone object created for a Belfast number, using +353 48');
        ok($ni->is_valid, '+3534890320202 is a valid number');
    }
};

done_testing();
