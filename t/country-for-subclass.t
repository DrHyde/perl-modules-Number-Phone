use strict;
use warnings;
use lib 't/inc';
use nptestutils;

use Test::More;
BEGIN { plan skip_all => 'not relevant if building --without_uk' if(building_without_uk()); }

use Number::Phone;

{
    package Number::Phone::UK::SubClass;
    use base 'Number::Phone::UK';
    #sub new { bless {}, shift }
}

is(Number::Phone->new('+1 2684601234')->country, 'AG', 'Basic country() check for NANP::AG');
is(Number::Phone->new('+44 142422 0000')->country, 'UK', 'Basic country() check for UK');
is(Number::Phone->new('+43 1 21145 2358')->country, 'AT', 'Basic country() check for AT');
is(Number::Phone::UK->new('+44 142422 0000')->country, 'UK', 'Basic country() check for UK');
my $num = Number::Phone::UK::SubClass->new('+44 142422 0000');
# Because we really want to test the base implementation in Number::Phone...
is $num->can('country'), \&Number::Phone::country, 'UK does not override ->country';

# The real aim of this test file
is($num->country, 'UK', 'A subclass of UK, but still UK');

done_testing();
