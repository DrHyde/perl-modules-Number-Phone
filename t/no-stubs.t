use strict;
use warnings;
use lib 't/inc';
use nptestutils;

use lib 't/lib';

use Number::Phone qw(nostubs);

use Test::More;
plan skip_all => 'not relevant if building --without_uk' if(building_without_uk());

use Number::Phone::Country;

is(Number::Phone->new("+442087712924")->country_code(), 44, "known countries return objects");

# let's break the UK
$Number::Phone::Country::idd_codes{'44'} = 'MOCK';
$Number::Phone::Country::prefix_codes{'MOCK'} = ['44',   '00',  undef];

eval { Number::Phone->new('+442087712924') };
ok($@, "nostubs works");

done_testing();
