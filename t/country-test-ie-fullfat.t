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
        my $ie = Number::Phone->new("+35312222918");
        ok(defined($ie), 'Number::Phone object created for a Dublin number');
        isa_ok($ie, 'Number::Phone::IE');
        ok($ie->is_valid, '+35312222918 is a valid number');
        is($ie->format, '+353 1 2222918', "it formats correctly");
        is($ie->country_code, '353', "it has the right country_code");
    }

    {
        my $ni = Number::Phone->new("+442890320202");
        isa_ok($ni, 'Number::Phone::UK');
        ok(defined($ni), 'Number::Phone object created for a Belfast number, using +44 28');
        ok($ni->is_valid, '+442890320202 is a valid number');
        is($ni->format, '+44 28 9032 0202', "it formats correctly");
        is($ni->country_code, '44', "it has the right country_code");
    }

    {
        my $ni = Number::Phone->new("+3534890320202");
        isa_ok($ni, 'Number::Phone::UK');
        ok(defined($ni), 'Number::Phone object created for a Belfast number, using +353 48');
        ok($ni->is_valid, '+3534890320202 is a valid number');
        is($ni->format, '+353 48 90320202', "it formats correctly");
        is($ni->country_code, '353', "it has the right country_code");
    }
};

done_testing();
