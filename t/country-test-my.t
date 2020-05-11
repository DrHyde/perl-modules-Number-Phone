#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

use Number::Phone::Lib;
use Test::More;

END { done_testing(); }

{
    my $np = Number::Phone::Lib->new('601170002863');
    ok($np->is_valid, '+601170002863 is valid');
    ok($np->is_mobile, '... it is a mobile...');
}
