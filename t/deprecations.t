use strict;
use warnings;

use Data::Dumper::Concise;
use Test::More;
use Test::Warnings qw(warnings :no_end_test);

my $warnings = [ warnings { use_ok 'Number::Phone' } ];

if(~0 == 4294967295) {
    ok(
        scalar(grep { /32 bit/ } @{$warnings}) == 1,
        "warned about 32 bit support going away"
    )
} else {
    ok(
        scalar(grep { /32 bit/ } @{$warnings}) == 0,
        "no warnings about 32 bit support going away"
    )
}

if($] < 5.010) {
    is(
        scalar(grep { /too old/ } @{$warnings}), 2,
        "warned about perl being too old (older than 5.10, 5.12, and 5.14)"
    )
} elsif($] < 5.012) {
    is(
        scalar(grep { /too old/ } @{$warnings}), 2,
        "warned about perl being too old (older than 5.14 and 5.14)"
    )
} elsif($] < 5.014) {
    is(
        scalar(grep { /too old/ } @{$warnings}), 1,
        "warned about perl being too old (older than 5.14)"
    )
} else {
    is(
        scalar(grep { /too old/ } @{$warnings}), 0,
        "no warnings about perl being too old"
    )
}

done_testing();
