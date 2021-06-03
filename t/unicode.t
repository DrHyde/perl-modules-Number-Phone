use strict;
use warnings;
use utf8;
use lib 't/inc';
use nptestutils;

BEGIN { binmode STDOUT, ":utf8"; } # must be before Test::More is loaded

use Test::More;

use Number::Phone;

is(
    Number::Phone->new("+49 906 1234567")->areaname(),
    'Donauwörth',
    "Donauwörth area name is decoded to Unicode characters"
);
is(
    Number::Phone->new("+81 982 22-7006")->areaname('ja'),
    '延岡',
    "延岡 area name is decoded to Unicode characters too",
);

done_testing();
