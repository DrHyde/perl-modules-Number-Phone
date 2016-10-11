#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

use Test::More;

END { done_testing(); }

use Number::Phone::Country qw(noexport);

country_and_idd('+44 20 12345678', 'GB', '44', "phone2country_and_idd works for GB");
country_and_idd('212 333 3333',    'US',  '1', "phone2country_and_idd works for US");

sub country_and_idd {
    my ($phone, $exp_country, $exp_idd, $title) = @_;
    subtest $title => sub {
        plan tests => 2;
        my @pair = Number::Phone::Country::phone2country_and_idd($phone);
        is($pair[0], $exp_country, 'country');
        is($pair[1], $exp_idd,     'idd');
    };
    return;
}
