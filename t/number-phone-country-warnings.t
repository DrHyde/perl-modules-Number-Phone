use strict;
use warnings;

# plan here, don't use done_testing, as the tests will only
# get run if warnings are caught
use Test::More;

eval 'use Number::Phone::Country qw(wibble);';
like(
    $@,
    qr/Unknown param to Number::Phone::Country 'wibble'/,
    "Number::Phone::Country dies on bogus params"
);

eval 'use Number::Phone::Country qw(noexport);';
like(
    $@,
    qr/Unknown param to Number::Phone::Country 'noexport'/,
    "'noexport' flag is now a fatal error'"
);

done_testing;
