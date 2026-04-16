use strict;
use warnings;
use lib 't/inc';
use nptestutils;

use Test::More;

eval 'use Number::Phone::IE';

SKIP: {
    skip("Number::Phone::IE isn't installed", 1)
        unless($Number::Phone::IE::VERSION);

    my $ie = Number::Phone->new("+35312222918");
    ok($ie->isa('Number::Phone::StubCountry::IE'),
        "Deprecated Number::Phone::IE isn't used");
};

done_testing();
