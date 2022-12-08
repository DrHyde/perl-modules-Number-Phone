use strict;
use warnings;
use lib 't/inc';
use nptestutils;

our $CLASS = 'Number::Phone';
eval "use $CLASS";
use Test::More;
use Scalar::Util qw(blessed);

require 'common-nanp_and_libphonenumber_tests.pl';

regulators();
toll_free();

sub regulators {
    note("NANP regulators");
    my %test_numbers = (
        NANP => '866 623 2282',
        CA   => '613 563 7242',
        US   => '202 418 1440',
        AG   => '268 480 4000',
        AI   => '264 497 3924',
        AS   => '684 633 0001',
        BB   => '246 434 3444',
        BM   => '441 292 4595',
        BS   => '242 302 7000',
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
        VC   => '784 488 1000',
        VG   => '284 494 4444',
        VI   => '340 712 9960'
    );
    
    my %regulators = (
        NANP => 'NANPA',
        CA   => 'CRTC',
        US   => 'FCC',
        AG   => '',
        AI   => 'PUC',
        AS   => 'ASTCA',
        BB   => 'FTC',
        BM   => 'Ministry of Telecommunications and E-Commerce',
        BS   => 'PUC',
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
        VC   => 'NTRC',
        VG   => 'Ministry of Communications and Works',
        VI   => ''
    );
    
    foreach my $country (sort keys %test_numbers) {
        my $targetclass = ($country eq 'NANP') ?
            'Number::Phone::NANP' :
            'Number::Phone::NANP::'.$country;
        my $number = Number::Phone->new('+1'.$test_numbers{$country});
        is(blessed($number), $targetclass,         "create $targetclass");
    
        ok(!defined($number->country()), "NANP has no country() info")
            if($country eq 'NANP');
        is($number->country(), $country, "$country has right country() info")
            if($country ne 'NANP');
        ok(!defined($number->regulator()), "$country has no regulator info")
            if($regulators{$country} eq '');
        like($number->regulator(), qr/^$regulators{$country}/, "$country has right regulator() info")
            if($regulators{$country} ne '');
        is($number->country_code(), 1, "$country has country code 1");
        like($number->format(), qr/\+1 \d{3} \d{3} \d{4}$/, "$country can format numbers");
    }
}

sub toll_free {
    note("NANP tollfree numbers");
    my %test_numbers = (
        '866 623 2282' => 1,
        '888 225 5322' => 1,
        '202 418 0500' => 0,
        '888 888 8888' => 1,
        '800 800 8000' => 1,
        '808 808 1111' => 0,
        '845 321 4567' => 0
    );

    foreach my $test_number (sort keys %test_numbers) {
        my $number = Number::Phone->new('+1'.$test_number);

        ok($number->is_tollfree(), "$test_number has right is_tollfree() assignment")
            if($test_numbers{$test_number});
        ok(!$number->is_tollfree(), "$test_number has right is_tollfree() assignment")
            if(!$test_numbers{$test_number});
    }
}

done_testing();
