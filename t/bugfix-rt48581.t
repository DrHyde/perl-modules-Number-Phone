#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use nptestutils;

use Test::More;
plan skip_all => 'not relevant if building --without_uk' if(building_without_uk());

use Number::Phone;

my $phone = Number::Phone->new(44, '02087712924');

ok($phone->isa('Number::Phone::UK'), "N::P->new(CC, 'nnnn') returns N::P::CC object");

is($phone->format(), "+44 20 8771 2924", "and it's got the right data");

eval { Number::Phone->new(44, '02087712924', 'apples!') };
ok($@ =~ /too many params/, "dies OK on too many params");

done_testing();
