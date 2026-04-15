use strict;
use warnings;
use lib 't/inc';
use nptestutils;

use Devel::Hide qw(Number::Phone::IE Number::Phone::IT Number::Phone::SM);
use Number::Phone;
use Number::Phone::Lib;
use Test::More;

plan skip_all => "need Number::Phone::UK to test this thoroughly"
    if(building_without_uk());

subtest "Northern Ireland, +44 28 also accessible as +353 48", sub {
    foreach my $test (
        # Dublin number
        {
            sanity            => 1,
            constructor_class => 'Number::Phone::Lib',
            expect_class      => 'Number::Phone::StubCountry::IE',
            num               => '+353 12222918',
            formatted         => '+353 1 222 2918',
            country_code      => '353',
            country           => 'IE',
        },
        {
            sanity            => 1,
            constructor_class => 'Number::Phone',
            expect_class      => 'Number::Phone::StubCountry::IE',
            num               => '+353 12222918',
            formatted         => '+353 1 222 2918',
            country_code      => '353',
            country           => 'IE',
        },
        # Belfast number
        {
            sanity            => 1,
            constructor_class => 'Number::Phone',
            expect_class      => 'Number::Phone::UK',
            num               => '+44 28 90320202',
            formatted         => '+44 28 9032 0202',
            country_code      => '44',
            country           => 'UK',
        },
        {
            constructor_class => 'Number::Phone::Lib',
            expect_class      => 'Number::Phone::StubCountry::IE',
            num               => '+353 48 90320202',
            formatted         => '+353 48 9032 0202',
            country_code      => '353',
            country           => 'UK',
        },
        {
            constructor_class => 'Number::Phone',
            expect_class      => 'Number::Phone::StubCountry::IE',
            num               => '+353 48 90320202',
            formatted         => '+353 48 9032 0202',
            country_code      => '353',
            country           => 'UK',
        },
    ) { run_test($test) }
};

subtest "San Marino, +378 also accessible as +378 0549 and as +39 0549", sub {
    foreach my $test (
        # Using SM's own country code and the optional area code
        {
            sanity            => 1,
            constructor_class => 'Number::Phone::Lib',
            expect_class      => 'Number::Phone::StubCountry::SM',
            num               => '+378 886377',
            formatted         => '+378 0549 886377',
            country_code      => '378',
            country           => 'SM',
        },
        {
            sanity            => 1,
            constructor_class => 'Number::Phone',
            expect_class      => 'Number::Phone::StubCountry::SM',
            num               => '+378 886377',
            formatted         => '+378 0549 886377',
            country_code      => '378',
            country           => 'SM',
        },
        {
            sanity            => 1,
            constructor_class => 'Number::Phone::Lib',
            expect_class      => 'Number::Phone::StubCountry::SM',
            num               => '+378 0549 886377',
            formatted         => '+378 0549 886377',
            country_code      => '378',
            country           => 'SM',
        },
        {
            sanity            => 1,
            constructor_class => 'Number::Phone',
            expect_class      => 'Number::Phone::StubCountry::SM',
            num               => '+378 0549 886377',
            formatted         => '+378 0549 886377',
            country_code      => '378',
            country           => 'SM',
        },
        {
            sanity            => 1,
            constructor_class => 'Number::Phone',
            expect_class      => 'Number::Phone::StubCountry::IT',
            num               => '+39 0645460221',
            formatted         => '+39 06 4546 0221',
            country_code      => '39',
            country           => 'IT',
        },
        # Using Italy's country code
        {
            constructor_class => 'Number::Phone::Lib',
            expect_class      => 'Number::Phone::StubCountry::IT',
            num               => '+39 0549 886377',
            formatted         => '+39 0549 886377',
            country_code      => '39',
            country           => 'SM',
        },
        {
            constructor_class => 'Number::Phone',
            expect_class      => 'Number::Phone::StubCountry::IT',
            num               => '+39 0549 886377',
            formatted         => '+39 0549 886377',
            country_code      => '39',
            country           => 'SM',
        },
    ) { run_test($test) }
};

subtest "Vatican, +379 is not in use, +39 06698 is an Italian area code", sub {
    foreach my $test (
        # Using Italy's country code
        {
            constructor_class => 'Number::Phone::Lib',
            expect_class      => 'Number::Phone::StubCountry::VA',
            num => '+39 06698 83462'
        },
        {
            constructor_class => 'Number::Phone',
            expect_class      => 'Number::Phone::StubCountry::VA',
            num => '+39 06698 83462'
        },
    ) { run_test($test) }
};

done_testing();

sub run_test {
    my $test = shift;

    subtest ''.($test->{sanity} ? 'sanity check: ' : '').
            "$test->{constructor_class}->new('$test->{num}')",
    sub {
        my $obj = $test->{constructor_class}->new($test->{num});
        ok(defined($obj),
            "$test->{constructor_class} object created"
        );
        isa_ok($obj, $test->{expect_class}) &&
        ok($obj->is_valid, "$test->{num} is a valid number");
        if($test->{formatted}) {
            is(
                $obj->format,
                $test->{formatted},
                "$test->{num} formats as $test->{formatted}"
            );
        }
        if($test->{country_code}) {
            is(
                $obj->country_code,
                $test->{country_code},
                "$test->{num} has country code $test->{country_code}"
            );
        }
        if($test->{country}) {
            is(
                $obj->country,
                $test->{country},
                "$test->{num} has country $test->{country}"
            );
        }
    };
}
