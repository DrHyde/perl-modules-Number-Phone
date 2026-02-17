use strict;
use warnings;

use lib 't/inc';
use nptestutils;
# *these* tests want to fall back to using stubs instead of dying
BEGIN { shift @INC }
# don't want to pick up a module from a previous installation!
use if building_without_uk, qw(Devel::Hide Number::Phone::UK);

use Data::Dumper::Concise;
use Test2::V0;

use Number::Phone;
use Number::Phone::Lib;

like
    warning { Number::Phone->new('US', '2a1b5c5d5e5f1g2h1i2j') },
    qr/ridiculous characters in '\+12a1b5c5d5e5f1g2h1i2j'/,
    "Correctly warns about ridiculous letter characters in a number";
ok
    no_warnings { Number::Phone->new('UK', "(020) 8771\t2924") },
    "Ridiculous punctuation is tolerated";

foreach my $CC (qw(GB GG IM JE)) {
    foreach my $class (qw(Number::Phone Number::Phone::Lib)) {
        ok(!defined($class->new($CC, '256789')), "$class->new('$CC', '256789') fails (too short)");
    }
}

foreach my $class (qw(Number::Phone Number::Phone::Lib)) {
    my $object = $class->new('+44402609');
    ok(!defined($object), "$class: +44 XXXXXX is invalid, even if XXXXXX is a valid local number in a crown dependency (we ignore nationalPrefixTransformRule in their stubs)");

    is($class->new('390667791')->country(), 'IT',
        "MSISDN numbers without a leading + are accepted");
}

foreach my $tuple (
    [qw(GG 01481256789)],
    [qw(JE 01534440000)],
    [qw(IM 01624756789)],
) {
    my($actual_country, $number) = @{$tuple};
    foreach my $country (qw(GG JE IM GB)) {
        my $object = Number::Phone::Lib->new($country, $number);
        if($country eq 'GB') {
            ok($object->isa("Number::Phone::StubCountry::$actual_country"),
                "Number::Phone::Lib->new('GB', '$number') returns a Number::Phone::StubCountry::$actual_country") || diag($object);
        } elsif($country eq $actual_country) {
            ok($object->isa("Number::Phone::StubCountry::$actual_country"),
                "Number::Phone::Lib->new('$country', '$number') returns a Number::Phone::StubCountry::$actual_country") || diag($object);
        } else {
            ok(!defined($object),
                "Number::Phone::Lib->new('$country', '$number') fails because $number is actually $actual_country");
        }

        $object = Number::Phone->new($country, $number);
        if($country eq 'GB') {
            if(building_without_uk) {
                ok($object->isa("Number::Phone::StubCountry::$actual_country"),
                    "Number::Phone->new('GB', '$number') returns a Number::Phone::StubCountry::$actual_country when building --without_uk") || diag($object);
            } else {
                ok($object->isa("Number::Phone::UK::$actual_country"),
                    "Number::Phone->new('GB', '$number') returns a Number::Phone::UK::$actual_country") || diag($object);
            }
        } elsif($country eq $actual_country) {
            if(building_without_uk) {
                ok($object->isa("Number::Phone::StubCountry::$actual_country"),
                    "Number::Phone->new('$country', '$number') returns a Number::Phone::StubCountry::$actual_country when building --without_uk") || diag($object);
            } else {
                ok($object->isa("Number::Phone::UK::$actual_country"),
                    "Number::Phone->new('$country', '$number') returns a Number::Phone::UK::$actual_country") || diag($object);
            }
        } else {
            ok(!defined($object),
                "Number::Phone->new('$country', '$number') fails because $number is actually $actual_country") || diag($object);
        }
    }
}

done_testing();
