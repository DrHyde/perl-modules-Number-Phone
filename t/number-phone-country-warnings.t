#!/usr/bin/perl -w

use strict;

use Test::More;

END { done_testing(); }

BEGIN { $SIG{__WARN__} = sub {
    is(
        shift(),
        "Exporting from Number::Phone::Country is deprecated at t/number-phone-country-warnings.t line 17\n",
        "Number::Phone::Country warns when asked to export"
    );
} } 

use Number::Phone::Country;

BEGIN { $SIG{__WARN__} = sub {
    is(
        shift(),
        "Unknown param to Number::Phone::Country 'wibble' at t/number-phone-country-warnings.t line 27\n",
        "Number::Phone::Country warns about bogus params"
    );
} } 

use Number::Phone::Country qw(noexport wibble);

