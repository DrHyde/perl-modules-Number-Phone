#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

use Test::More tests => 2;

use Number::Phone::Country;

ok((Number::Phone::Country::phone2country_and_idd('+44 20 12345678'))[0] eq 'GB' && (Number::Phone::Country::phone2country_and_idd('+44 20 12345678'))[1] eq '44', "phone2country_and_idd works for GB");
ok((Number::Phone::Country::phone2country_and_idd('212 333 3333'))[0] eq 'US' && (Number::Phone::Country::phone2country_and_idd('212 333 3333'))[1] eq '1', "phone2country_and_idd works for US");
