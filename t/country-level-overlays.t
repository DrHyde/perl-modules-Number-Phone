use strict;
use warnings;
use lib 't/inc';
use nptestutils;

use Devel::Hide qw(Number::Phone::IT Number::Phone::SM);
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
            is_international  => 0,
            country_code      => '353',
            country           => 'IE',
            canonical         => '+353 1 222 2918',
            may_be_noncanonical => 1,
        },
        {
            sanity            => 1,
            constructor_class => 'Number::Phone',
            expect_class      => 'Number::Phone::StubCountry::IE',
            num               => '+353 12222918',
            formatted         => '+353 1 222 2918',
            is_international  => 0,
            country_code      => '353',
            country           => 'IE',
            canonical         => '+353 1 222 2918',
            may_be_noncanonical => 1,
        },
        # Belfast number
        {
            sanity            => 1,
            constructor_class => 'Number::Phone::Lib',
            expect_class      => 'Number::Phone::StubCountry::GB',
            num               => '+44 28 90320202',
            formatted         => '+44 28 9032 0202',
            is_international  => 0,
            country_code      => '44',
            country           => 'GB',
            canonical         => '+44 28 9032 0202',
            may_be_noncanonical => 0,
        },
        {
            sanity            => 1,
            constructor_class => 'Number::Phone',
            expect_class      => 'Number::Phone::UK',
            num               => '+44 28 90320202',
            formatted         => '+44 28 9032 0202',
            is_international  => 0,
            country_code      => '44',
            country           => 'UK',
            canonical         => '+44 28 9032 0202',
            may_be_noncanonical => 0,
        },
        {
            constructor_class => 'Number::Phone::Lib',
            expect_class      => 'Number::Phone::StubCountry::IE',
            num               => '+353 48 90320202',
            formatted         => '+353 48 9032 0202',
            is_international  => 1,
            country_code      => '353',
            country           => 'UK',
            canonical         => '+44 28 9032 0202',
        },
        {
            constructor_class => 'Number::Phone',
            expect_class      => 'Number::Phone::StubCountry::IE',
            num               => '+353 48 90320202',
            formatted         => '+353 48 9032 0202',
            is_international  => 1,
            country_code      => '353',
            country           => 'UK',
            canonical         => '+44 28 9032 0202',
        },
    ) { test_constructor($test) }
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
            is_international  => 0,
            country_code      => '378',
            country           => 'SM',
            canonical         => '+378 0549 886377',
            may_be_noncanonical => 0,
        },
        {
            sanity            => 1,
            constructor_class => 'Number::Phone',
            expect_class      => 'Number::Phone::StubCountry::SM',
            num               => '+378 886377',
            formatted         => '+378 0549 886377',
            is_international  => 0,
            country_code      => '378',
            country           => 'SM',
            canonical         => '+378 0549 886377',
            may_be_noncanonical => 0,
        },
        {
            sanity            => 1,
            constructor_class => 'Number::Phone::Lib',
            expect_class      => 'Number::Phone::StubCountry::SM',
            num               => '+378 0549 886377',
            formatted         => '+378 0549 886377',
            is_international  => 0,
            country_code      => '378',
            country           => 'SM',
            canonical         => '+378 0549 886377',
            may_be_noncanonical => 0,
        },
        {
            sanity            => 1,
            constructor_class => 'Number::Phone',
            expect_class      => 'Number::Phone::StubCountry::SM',
            num               => '+378 0549 886377',
            formatted         => '+378 0549 886377',
            is_international  => 0,
            country_code      => '378',
            country           => 'SM',
            canonical         => '+378 0549 886377',
            may_be_noncanonical => 0,
        },
        # an Italian number, using Italy's country code
        {
            sanity            => 1,
            constructor_class => 'Number::Phone::Lib',
            expect_class      => 'Number::Phone::StubCountry::IT',
            num               => '+39 0645460221',
            formatted         => '+39 06 4546 0221',
            is_international  => 0,
            country_code      => '39',
            country           => 'IT',
            canonical         => '+39 06 4546 0221',
            may_be_noncanonical => 1,
        },
        {
            sanity            => 1,
            constructor_class => 'Number::Phone',
            expect_class      => 'Number::Phone::StubCountry::IT',
            num               => '+39 0645460221',
            formatted         => '+39 06 4546 0221',
            is_international  => 0,
            country_code      => '39',
            country           => 'IT',
            canonical         => '+39 06 4546 0221',
            may_be_noncanonical => 1,
        },
        # SM number, using Italy's country code
        {
            constructor_class => 'Number::Phone::Lib',
            expect_class      => 'Number::Phone::StubCountry::IT',
            num               => '+39 0549 886377',
            formatted         => '+39 0549 886377',
            is_international  => 1,
            country_code      => '39',
            country           => 'SM',
            canonical         => '+378 0549 886377',
        },
        {
            constructor_class => 'Number::Phone',
            expect_class      => 'Number::Phone::StubCountry::IT',
            num               => '+39 0549 886377',
            formatted         => '+39 0549 886377',
            is_international  => 1,
            country_code      => '39',
            country           => 'SM',
            canonical         => '+378 0549 886377',
        },
    ) { test_constructor($test) }
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
    ) { test_constructor($test) }
};

subtest "+353 48 in dial_to", sub {
    foreach my $mapping (
        # from NI (+4428)
        { from => '+442890320202', to => '+3534890320202', expect => '003534890320202' },  # UK->IE
        { from => '+442890320202', to => '+35312222918',   expect => '0035312222918' },    # UK->IE
        { from => '+442890320202', to => '+442087712924',  expect => '02087712924' },      # UK->UK
        { from => '+442890320202', to => '+12024561111',   expect => '0012024561111' },    # UK->US
         # from GB
        { from => '+442087712924', to => '+3534890320202', expect => '003534890320202' },  # UK->IE
        { from => '+442087712924', to => '+35312222918',   expect => '0035312222918' },    # UK->IE
        { from => '+442087712924', to => '+442890320202',  expect => '02890320202' },      # UK->UK
        { from => '+442087712924', to => '+12024561111',   expect => '0012024561111' },    # UK->US
         # from US
        { from => '+12024561111',  to => '+3534890320202', expect => '0113534890320202' }, # US->IE
        { from => '+12024561111',  to => '+35312222918',   expect => '01135312222918' },   # US->IE
        { from => '+12024561111',  to => '+442890320202',  expect => '011442890320202' },  # US->UK
        { from => '+12024561111',  to => '+442087712924',  expect => '011442087712924' },  # US->UK
        # from NI (+35348)
        { from => '+3534890320202', to => '+442890320202',  expect => '02890320202' },     # UK->UK
        { from => '+3534890320202', to => '+3534890320203', expect => '003534890320203' }, # UK->IE
        { from => '+3534890320202', to => '+35312222918',   expect => '0035312222918' },   # UK->IE
        { from => '+3534890320202', to => '+442087712924',  expect => '02087712924' },     # UK->UK
        { from => '+3534890320202', to => '+12024561111',   expect => '0012024561111' },   # UK->US
        # from IE
        { from => '+35312222918',   to => '+3534890320202', expect => '04890320202' },     # IE->IE
        { from => '+35312222918',   to => '+35312222918',   expect => '012222918' },       # IE->IE
        { from => '+35312222918',   to => '+442890320202',  expect => '00442890320202' },  # IE->UK
        { from => '+35312222918',   to => '+442087712924',  expect => '00442087712924' },  # IE->UK
        { from => '+35312222918',   to => '+12024561111',   expect => '0012024561111' },   # IE->US
    ) {
        my($from, $to, $expected) = @{$mapping}{qw(from to expect)};
        subtest sprintf("from %14s to %14s should dial %16s",$from, $to, $expected) => sub {
            foreach my $from_class (qw(Number::Phone Number::Phone::Lib)) {
                foreach my $to_class (qw(Number::Phone Number::Phone::Lib)) {
                    is(
                        $from_class->new($from)->dial_to(
                            $to_class->new($to)
                        ),
                        $expected,
                        "dial_to said $expected ($from_class -> $to_class)"
                    );
                }
            }
        };
    }
};

ok(!exists($INC{'Number/Phone/IE.pm'}), "Number::Phone::IE wasn't loaded");
if(eval "use Number::Phone::IE;1;") {
    pass("... even though it is installed");
}

done_testing();

sub test_constructor {
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
        ok(!!$obj->is_international == !!$test->{is_international},
            "->is_international is correct");
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
        if(exists($test->{may_be_noncanonical})) {
            is(
                $obj->may_be_noncanonical_number,
                $test->{may_be_noncanonical},
                "objects of this class may ".
                    (!$obj->may_be_noncanonical_number ? "not " : "").
                    "have a different canonical form"
            );
        }
        if(exists($test->{canonical})) {
            is(
                $obj->canonical_number->format,
                $test->{canonical},
                "has correct canonical form $test->{canonical}"
            );
        }
    };
}
