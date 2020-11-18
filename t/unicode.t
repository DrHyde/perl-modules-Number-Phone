use strict;
use warnings;
use lib 't/inc';
use nptestutils;

use Test::More;

use Number::Phone;

eval 'use Test::utf8';

SKIP: {
    skip("Test::utf8 not available", 1) if($@);

    is_flagged_utf8(
        Number::Phone->new("+49 906 1234567")->areaname(),
        "Donauwörth area name isflagged as UTF-8"
    );
};

done_testing();
