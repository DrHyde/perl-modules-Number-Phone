#!/usr/bin/perl -w

use strict;
use lib 't/inc';
use nptestutils;

use Number::Phone;
use Number::Phone::Lib;
use Test::More;
use Scalar::Util qw(blessed);

my %tests = (
    # both UK numbers use the same code paths, but there was a bug
    # (https://github.com/DrHyde/perl-modules-Number-Phone/issues/98)
    # for invalid +44 5 numbers; this checks that everything still works
    # for valid ones
    '+44 20 8771 2924' => '2087712924',   # UK
    '+44 55 1100 0000' => '5511000000',   # UK
    '+1 202 418 1440'  => '2024181440',   # NANP::US
    '+81 3-3580-3311'  => '335803311'     # StubCountry::JP
);

note("format_using('Raw')");
while (my ($num, $expect) = each %tests) {
    my $number = Number::Phone->new($num);
    is($number->format_using('Raw'), $expect, "works for a ".blessed($number));
}

note("format_using('E123')");
is(
    Number::Phone->new('+44 20 8771 2924')->format_using('E123'),
    '+44 20 8771 2924',
    "format_using('E123') works too"
);

note("format_using('NationallyPreferredIntl')");
is(
    Number::Phone::Lib->new('+1 202 418 1440')->format_using('NationallyPreferredIntl'),
    '+1 202-418-1440',
    "format_using('NationallyPreferredIntl') works too"
);

my $fullfat = Number::Phone->new('+44 20 8771 2924');
is($fullfat->format_for_country('GB'), '020 8771 2924', "format_for_country (same country) works for full-fat implementations");
is($fullfat->format_for_country('AR'), '+44 20 8771 2924', "format_for_country (other country) works for full-fat implementations");

my $thingruel = Number::Phone::Lib->new('+44 20 8771 2924');
is($thingruel->format_for_country('GB'), '020 8771 2924', "format_for_country (same country) works for thin gruel implementations");
is($thingruel->format_for_country('AR'), '+44 20 8771 2924', "format_for_country (other country) works for thin gruel implementations");

note("format_using('non-existent formatter')");
eval { Number::Phone->new('+44 20 8771 2924')->format_using('FishAndChips') };
like(
    $@,
    qr/^Couldn't load format 'FishAndChips':/,
    "format_using dies when asked to use a non-existent formatter"
);

done_testing();
