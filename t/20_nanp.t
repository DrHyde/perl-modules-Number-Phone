#!/usr/bin/perl -w

use strict;

use Test::More tests => 132;
use Scalar::Util qw(blessed);

BEGIN { use_ok('Number::Phone::NANP'); }

my %test_numbers = (
    NANP => '866 623 2282',
    AG   => '268 480 4000',
    AI   => '264 497 3924',
    AS   => '684 633 0001',
    BB   => '246 434 3444',
    BM   => '441 292 4595',
    BS   => '242 302 7000',
    CA   => '613 563 7242',
    DM   => '767 448 1408',
    DO   => '809 547 1000',
    GD   => '473 435 6872',
    GU   => '671 632 3365',
    JM   => '876 511 5013',
    KN   => '869 465 1000',
    KY   => '345 945 8284',
    LC   => '758 453 9300',
    MP   => '670 682 4555',
    MS   => '664 491 2230',
    PR   => '787 729 3131',
    SX   => '721 555 0001',
    TC   => '649 946 5231',
    TT   => '868 624 6982',
    US   => '202 418 1440',
    VC   => '784 488 1000',
    VG   => '284 494 4444',
    VI   => '340 712 9960'
);

my %regulators = (
    NANP => 'NANPA',
    AG   => '',
    AI   => 'PUC',
    AS   => 'ASTCA',
    BB   => 'FTC',
    BM   => 'Ministry of Telecommunications and E-Commerce',
    BS   => 'PUC',
    CA   => 'CRTC',
    DM   => 'ECTEL',
    DO   => 'Indotel',
    GD   => 'NTRC',
    GU   => 'GTA',
    JM   => 'OUR',
    KN   => 'ECTEL',
    KY   => 'ICTA',
    LC   => 'ECTEL',
    MP   => '',
    MS   => '',
    PR   => '',
    SX   => '',
    TC   => '',
    TT   => 'RIC',
    US   => 'FCC',
    VC   => 'NTRC',
    VG   => 'Ministry of Communications and Works',
    VI   => ''
);

foreach my $country (sort keys %test_numbers) {
    my $targetclass = ($country eq 'NANP') ?
        'Number::Phone::NANP' :
        'Number::Phone::NANP::'.$country;
    my $number = Number::Phone->new('+1'.$test_numbers{$country});
    ok(blessed($number) eq $targetclass,         "create $targetclass");

    ok(!defined($number->country()), "NANP has no country() info")
        if($country eq 'NANP');
    ok($number->country() eq $country, "$country has right country() info")
        if($country ne 'NANP');
    ok(!defined($number->regulator()), "$country has no regulator info")
        if($regulators{$country} eq '');
    ok($number->regulator() =~ /^$regulators{$country}/, "$country has right regulator() info")
        if($regulators{$country} ne '');
    ok($number->country_code() == 1, "$country has country code 1");
    ok($number->format() =~ /\+1 \d{3} \d{3} \d{4}$/, "$country can format numbers");
}

is(Number::Phone->new('+1 201 200 1234')->areaname(), 'Jersey City, NJ', 'areaname works');
