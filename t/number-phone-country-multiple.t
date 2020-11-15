use strict;
use warnings;
use lib 't/inc';
use nptestutils;

use Test::More;

use Number::Phone::Country qw(noexport);

is(Number::Phone::Country::phone2country('+47 1234 5678'),   'NO', "first of three");
is(Number::Phone::Country::phone2country('+44 20 12345678'), 'GB', "uk not set accidentally");

done_testing();
