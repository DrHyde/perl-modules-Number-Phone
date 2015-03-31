use strict;
use warnings;

use Test::More;
use Test::utf8;

use Number::Phone;

END { done_testing(); }

is_flagged_utf8(
    Number::Phone->new("+49 906 1234567")->areaname(),
    "Donauwörth area name isflagged as UTF-8"
);
