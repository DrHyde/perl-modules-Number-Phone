use strict;
use warnings;
use lib 't/inc';
use nptestutils;

use Test::More;
plan skip_all => 'not relevant if building --without_uk' if(building_without_uk());

use Number::Phone;

my $mobile = '+447979866975';
my $pager  = '+447679866975';

# order is important. This first one will spot that +44 is a UK number and
# load N::P::UK accordingly, so we can use it directly in the future
ok(1 == Number::Phone->new($mobile)->is_mobile(), "true N::P->new('+CC12345')->is_method()");
ok(1 == Number::Phone::UK->new($mobile)->is_mobile(), "true N::P::CC->new('+CC12345')->is_method()");

ok(0 == Number::Phone->new($pager)->is_mobile(), "false N::P->new('+CC12345')->is_method()");
ok(0 == Number::Phone::UK->new($pager)->is_mobile(), "false N::P::CC->new('+CC12345')->is_method()");

ok(!defined(Number::Phone->new($pager)->is_government()), "undef N::P->new('+CC12345')->is_method()");
ok(!defined(Number::Phone::UK->new($pager)->is_government()), "undef N::P::CC->new('+CC12345')->is_method()");

is_deeply(
    scalar(Number::Phone::UK->new($mobile)->type()),
    [qw(is_valid is_allocated is_mobile)],
    "scalar N::P::CC->new('+CC12345')->type()"
);
is_deeply(
    scalar(Number::Phone->new($mobile)->type()),
    [qw(is_valid is_allocated is_mobile)],
    "scalar N::P->new('+CC12345')->type()"
);

is_deeply(
    [(Number::Phone::UK->new($mobile)->type())],
    [qw(is_valid is_allocated is_mobile)],
    "list N::P::CC->new('+CC12345')->type()"
);
is_deeply(
    [(Number::Phone->new($mobile)->type())],
    [qw(is_valid is_allocated is_mobile)],
    "list N::P->new('+CC12345')->type()"
);

$mobile = '07979866975';
$pager  = '07679866975';
ok(1 == Number::Phone::UK->new($mobile)->is_mobile(), "true N::P::CC->new('12345')->is_method()");
ok(0 == Number::Phone::UK->new($pager)->is_mobile(), "false N::P::CC->new('12345')->is_method()");
ok(!defined(Number::Phone::UK->new($pager)->is_government()), "undef N::P::CC->new('12345')->is_method()");

is_deeply(
    scalar(Number::Phone::UK->new($mobile)->type()),
    [qw(is_valid is_allocated is_mobile)],
    "scalar N::P::CC->new('12345')->type()"
);
is_deeply(
    [(Number::Phone::UK->new($mobile)->type())],
    [qw(is_valid is_allocated is_mobile)],
    "list N::P::CC->new('12345')->type()"
);

done_testing();
