#!/usr/bin/perl -w

use strict;

use Test::More;

END { done_testing(); }

BEGIN { $SIG{__WARN__} = sub {
    is(
        shift(),
        "Exporting from Number::Phone::Country is deprecated at t/51_number-phone-country-warns-about-exports.t line 17\n",
        "Number::Phone::Country warns when asked to export"
    );
} } 

use Number::Phone::Country;

