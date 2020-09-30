use strict;
use warnings;

use Number::Phone::UK;

use Test::More;

# eg Wed Sep 30 10:37:39 2020
ok(Number::Phone::UK->data_source() =~ /^OFCOM at (Mon|Tue|Wed|Thu|Fri|Sat|Sun).*202\d$/,
    "N::P::UK->data_source() ".Number::Phone::UK->data_source()." looks vaguely plausible");
ok(!defined(Number::Phone->data_source()),
    "N::P->data_source() is undef");

# eg v8.12.10
ok(Number::Phone->libphonenumber_tag() =~ /^v\d+\.\d+\.\d+$/,
    "N::P->libphonenumber_tag() ".Number::Phone->libphonenumber_tag()." looks vaguely plausible");

done_testing();
