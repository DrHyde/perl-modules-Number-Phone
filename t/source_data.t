use strict;
use warnings;

use Number::Phone;

use Test::More;

# eg Wed Sep 30 10:37:39 2020 UTC
ok(Number::Phone::UK->data_source() =~ /^OFCOM at (Mon|Tue|Wed|Thu|Fri|Sat|Sun).*202\d UTC$/,
    "N::P::UK->data_source() ".Number::Phone::UK->data_source()." looks vaguely plausible");
ok(Number::Phone::NANP->data_source() =~ /^localcallingguide.com at (Mon|Tue|Wed|Thu|Fri|Sat|Sun).*202\d UTC$/,
    "N::P::NANP->data_source() ".Number::Phone::NANP->data_source()." looks vaguely plausible");
ok(Number::Phone::NANP::CA->data_source() =~ /^CNAC at (Mon|Tue|Wed|Thu|Fri|Sat|Sun).*202\d UTC$/,
    "N::P::NANP::CA->data_source() ".Number::Phone::NANP::CA->data_source()." looks vaguely plausible");
ok(Number::Phone::NANP::US->data_source() =~ /^National Pooling Administrator at (Mon|Tue|Wed|Thu|Fri|Sat|Sun).*202\d UTC$/,
    "N::P::NANP::US->data_source() ".Number::Phone::NANP::US->data_source()." looks vaguely plausible");
ok(!defined(Number::Phone->data_source()),
    "N::P->data_source() is undef");

# eg v8.12.10
ok(Number::Phone->libphonenumber_tag() =~ /^v\d+\.\d+\.\d+$/,
    "N::P->libphonenumber_tag() ".Number::Phone->libphonenumber_tag()." looks vaguely plausible");

done_testing();
