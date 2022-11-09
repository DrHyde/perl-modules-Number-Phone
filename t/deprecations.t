use strict;
use warnings;

use Data::Dumper::Concise;
use Test::More;
use Test::Warnings qw(warning :no_end_test);

my $warnings = [ warning { use_ok 'Number::Phone' } ];

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
    ok(
        scalar(grep { /too old/ } @{$warnings}) == 1,
        "warned about perl being too old"
    )
} else {
    ok(
        scalar(grep { /too old/ } @{$warnings}) == 0,
        "no warnings about perl being too old"
    )
}

done_testing();
