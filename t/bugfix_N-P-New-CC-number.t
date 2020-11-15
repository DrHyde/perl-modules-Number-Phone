use strict;
use warnings;
use lib 't/inc';
use nptestutils;

use Number::Phone;

use Test::More;
plan skip_all => 'not relevant if building --without_uk' if(building_without_uk());

ok(Number::Phone->new('UK', '07970866975'), "N::P->new('CC', '012345')");
ok(Number::Phone->new('UK', '7970866975'), "N::P->new('CC', '12345')");

ok(Number::Phone->new('+44', '7970866975'),  "N::P->new('+NN', '12345')");
ok(Number::Phone->new('+44', '07970866975'), "N::P->new('+NN', '012345')");

ok(Number::Phone->new('+447970866975'), "N::P->new('+NN12345')");

ok(Number::Phone->new('UK', '+447970866975'), "N::P->new('CC', '+NN12345')");
ok(Number::Phone->new('uk', '+447970866975'), "N::P->new('cc', '+NN12345')");

done_testing();
