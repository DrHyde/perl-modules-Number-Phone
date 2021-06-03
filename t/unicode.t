use strict;
use warnings;
use utf8;
use lib 't/inc';
use nptestutils;

use Test::More;

use Number::Phone;

is(
    Number::Phone->new("+49 906 1234567")->areaname(),
    'Donauwörth',
    "Donauwörth area name is decoded to Unicode characters"
);

done_testing();
