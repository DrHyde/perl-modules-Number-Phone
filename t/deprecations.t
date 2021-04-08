use strict;
use warnings;

use Data::Dumper::Concise;
use Test::More;
use Test::Warnings qw(warning);

if(~0 == 4294967295) {
    my $warning = warning { use_ok 'Number::Phone' };
    like(
        $warning,
        qr/32 bit/,
        "warned about 32 bit support going away"
    ) || diag(Dumper($warning));
}

done_testing();
