use strict;
use warnings;
use lib 't/inc';
use nptestutils;

use Test::More;
use Scalar::Util qw(blessed);

use Number::Phone;

my $number;

SKIP: {
    skip("built --without_uk so not testing that full-fat implementation today", 1)
        if(building_without_uk());

    $number = Number::Phone->new("+441234567890");
    ok(blessed($number) && $number->isa('Number::Phone::UK'),
        "N::P->new() works without specifically loading a country module");
}

$number = Number::Phone->new("+12265550199");
ok(blessed($number) && $number->isa('Number::Phone::NANP::CA'),
    "... and it even works for the NANP!");

$number = Number::Phone->new("+18666232282");
ok(blessed($number) && $number->isa('Number::Phone::NANP'),
    "... and it even works for the non-geographic NANP!");

# +999 is "Proposed disaster relief (TDR) service", NYI by N::P::Country
ok(
    !blessed(Number::Phone->new("+999123")) &&
    !defined(Number::Phone->new("+999123")),
    "A country code not recognised by N::P::Country returns false"
);

$number = Number::Phone->new("+7 7172 74 32 43");
ok(blessed($number) && $number->isa('Number::Phone::StubCountry::KZ'),
    "KZ numbers correctly recognised in their corner of +7");

$number = Number::Phone->new("+7 495 606 36 02");
ok(blessed($number) && $number->isa('Number::Phone::StubCountry::RU'),
    "... the rest is Mother Russia");

done_testing();
