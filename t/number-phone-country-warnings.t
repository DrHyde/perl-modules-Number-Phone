#!/usr/bin/perl -w

use strict;

# plan here, don't use done_testing, as the tests will only
# get run if warnings are caught
use Test::More tests => 2;

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
