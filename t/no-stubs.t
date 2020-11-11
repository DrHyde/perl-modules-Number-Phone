#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

use lib 't/lib';

use Number::Phone qw(nostubs);

use Test::More;

use Number::Phone::Country qw(noexport);

is(Number::Phone->new("+442087712924")->country_code(), 44, "known countries return objects");

# let's break the UK
$Number::Phone::Country::idd_codes{'44'} = 'MOCK';
$Number::Phone::Country::prefix_codes{'MOCK'} = ['44',   '00',  undef];

eval { Number::Phone->new('+442087712924') };
ok($@, "nostubs works");

done_testing();
