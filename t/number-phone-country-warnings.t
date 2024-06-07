use strict;
use warnings;

# plan here, don't use done_testing, as the tests will only
# get run if warnings are caught
use Test::More;

BEGIN { $SIG{__WARN__} = sub {
    is(
        shift(),
        "Deprecated, will become fatal: Unknown param to Number::Phone::Country 'wibble' at t/number-phone-country-warnings.t line 16\n",
        "Number::Phone::Country warns about bogus params"
    );
} } 

use Number::Phone::Country qw(wibble);

BEGIN { $SIG{__WARN__} = sub {
    is(
        shift(),
        "'noexport' param to Number::Phone::Country is deprecated at t/number-phone-country-warnings.t line 26\n",
        "Number::Phone::Country warns about deprecated 'noexport'"
    );
} } 

use Number::Phone::Country qw(noexport);

done_testing;
