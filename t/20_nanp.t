#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

our $CLASS = 'Number::Phone';
eval "use $CLASS";
use Test::More;
use Scalar::Util qw(blessed);

require 'common-nanp_and_libphonenumber_tests.pl';

regulators();

done_testing;

sub regulators {
    note("NANP regulators");
    my %test_numbers = (
        NANP => '866 623 2282',
        CA   => '613 563 7242',
        US   => '202 418 1440',
    );
    
    my %regulators = (
        NANP => 'NANPA',
        CA   => 'CRTC',
        US   => 'FCC',
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
}
