use strict;
use warnings;
use lib 't/inc';
use nptestutils;

use Number::Phone::Lib;
use Test::More;

{
    my $np = Number::Phone::Lib->new('601170002863');
    ok($np->is_valid, '+601170002863 is valid');
    ok($np->is_mobile, '... it is a mobile...');
}

done_testing();
