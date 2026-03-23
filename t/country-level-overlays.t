use strict;
use warnings;
use lib 't/inc';
use nptestutils;

use Devel::Hide qw(Number::Phone::IE Number::Phone::IT Number::Phone::SM);
use Number::Phone;
use Number::Phone::Lib;
use Test::More;

subtest "Northern Ireland, +44 28 also accessible as +353 48", sub {
    foreach my $test (
        # Dublin number
        {
            constructor_class => 'Number::Phone::Lib',
            expect_class      => 'Number::Phone::StubCountry::IE',
            num => '+353 12222918', sanity => 1
        },
        {
            constructor_class => 'Number::Phone',
            expect_class      => 'Number::Phone::StubCountry::IE',
            num => '+353 12222918', sanity => 1
        },
        # Belfast number
        {
            constructor_class => 'Number::Phone',
            expect_class      => 'Number::Phone::UK',
            num => '+44 28 90320202'
        },
        {
            constructor_class => 'Number::Phone::Lib',
            expect_class      => 'Number::Phone::StubCountry::GB',
            num => '+353 48 90320202'
        },
        {
            constructor_class => 'Number::Phone',
            expect_class      => 'Number::Phone::UK',
            num => '+353 48 90320202'
        },
    ) { run_test($test) }
};

subtest "San Marino, +378 also accessible as +378 0549 and as +39 0549", sub {
    foreach my $test (
        # Using SM's own country code and the optional area code
        {
            constructor_class => 'Number::Phone::Lib',
            expect_class      => 'Number::Phone::StubCountry::SM',
            num => '+378 886377', sanity => 1
        },
        {
            constructor_class => 'Number::Phone',
            expect_class      => 'Number::Phone::StubCountry::SM',
            num => '+378 886377', sanity => 1
        },
        {
            constructor_class => 'Number::Phone::Lib',
            expect_class      => 'Number::Phone::StubCountry::SM',
            num => '+378 0549 886377', sanity => 1
        },
        {
            constructor_class => 'Number::Phone',
            expect_class      => 'Number::Phone::StubCountry::SM',
            num => '+378 0549 886377', sanity => 1
        },
        # Using Italy's country code
        {
            constructor_class => 'Number::Phone::Lib',
            expect_class      => 'Number::Phone::StubCountry::SM',
            num => '+39 0549 886377'
        },
        {
            constructor_class => 'Number::Phone',
            expect_class      => 'Number::Phone::StubCountry::SM',
            num => '+39 0549 886377'
        },
    ) { run_test($test) }
};

done_testing();

sub run_test {
    my $test = shift;

    subtest "$test->{constructor_class}->new('$test->{num}')", sub {
        my $obj = $test->{constructor_class}->new($test->{num});
        ok(defined($obj),
            ($test->{sanity} ? 'sanity check: ' : '').
            "$test->{constructor_class} object created"
        );
        isa_ok($obj, $test->{expect_class}) &&
        ok($obj->is_valid, "$test->{num} is a valid number");
    };
}
