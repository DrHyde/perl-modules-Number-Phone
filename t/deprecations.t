use strict;
use warnings;

use Data::Dumper::Concise;
use Test::More;
use Test::Warnings qw(warning);

my $warnings = [ warning { use_ok 'Number::Phone' } ];

if(~0 == 4294967295) {
    ok(
        scalar(grep { /32 bit/ } @{$warnings}),
        "warned about 32 bit support going away"
    )
}
if($] < 5.010) {
    ok(
        scalar(grep { /too old/ } @{$warnings}),
        "warned about perl being too old"
    )
}

done_testing();
