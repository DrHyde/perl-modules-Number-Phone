use strict;
use warnings;
use utf8;
use lib 't/inc';
use nptestutils;

use Devel::Hide qw(Number::Phone::DE Number::Phone::JP);

# So we can see any diagnostics from is() without moaning about wide chars;
# we may still get such moans from machines with ISO-8859 terminals if the
# tests fail there. Must be before Test::More is loaded
BEGIN { binmode STDOUT, ":utf8"; }

use Test::More;

use Number::Phone;

is(
    Number::Phone->new("+49 906 1234567")->areaname(),
    'Donauwörth',
    "German area name with rock dots is decoded to Unicode characters"
);
is(
    Number::Phone->new("+81 982 22-7006")->areaname('ja'),
    '延岡',
    "Japanese area name is decoded to Unicode characters too",
);

done_testing();
