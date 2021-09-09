use strict;
use warnings;

use Test::More;
use Test::Differences;

use Number::Phone;
use Number::Phone::Lib;

foreach my $CC (qw(GB GG IM JE)) {
    foreach my $class (qw(Number::Phone Number::Phone::Lib)) {
        ok(!defined($class->new($CC, '256789')), "$class->new('$CC', '256789') fails (too short)");
    }
}

foreach my $class (qw(Number::Phone Number::Phone::Lib)) {
    ok(!defined($class->new('+44402609')), "$class: +44 XXXXXX is invalid, even if XXXXXX is a valid local number in a crown dependency (we ignore nationalPrefixTransformRule in their stubs)");
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
                "Number::Phone::Lib->new('GB', '$number') returns a Number::Phone::StubCountry::$actual_country");
        } elsif($country eq $actual_country) {
            ok($object->isa("Number::Phone::StubCountry::$actual_country"),
                "Number::Phone::Lib->new('$country', '$number') returns a Number::Phone::StubCountry::$actual_country");
        } else {
            ok(!defined($object),
                "Number::Phone::Lib->new('$country', '$number') fails because $number is actually $actual_country");
        }

        $object = Number::Phone->new($country, $number);
        if($country eq 'GB') {
            ok($object->isa("Number::Phone::UK::$actual_country"),
                "Number::Phone->new('GB', '$number') returns a Number::Phone::UK::$actual_country");
        } elsif($country eq $actual_country) {
            ok($object->isa("Number::Phone::UK::$actual_country"),
                "Number::Phone->new('$country', '$number') returns a Number::Phone::UK::$actual_country");
        } else {
            ok(!defined($object),
                "Number::Phone->new('$country', '$number') fails because $number is actually $actual_country") || diag($object);
        }
    }
}

done_testing();
