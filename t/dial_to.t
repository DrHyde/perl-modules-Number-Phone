use strict;
use warnings;
use lib 't/inc';
use nptestutils;

use Number::Phone;
use Number::Phone::Lib;
use Test::More;

foreach my $test (
    # UK domestic
    { from => '+44 1424 220000',   to => '+44 1424 220001',   expect => '01424220001',     desc => 'UK local call' },
    { from => '+44 1424 220000',   to => '+44 1420 000000',   expect => undef,             desc => 'UK call to reserved (ie unused) number' },
    { from => '+44 1424 220000',   to => '+44 1224 000000',   expect => '01224000000',     desc => 'UK call to allocated 01224 0 number' },
    { from => '+44 1403 210000',   to => '+44 1403 030001',   expect => '01403030001',     desc => 'UK local call to National Dialling Only number' },
    { from => '+44 1403 210000',   to => '+44 1424 220000',   expect => '01424220000',     desc => 'UK call to another area' },
    { from => '+44 7979 866975',   to => '+44 7979 866976',   expect => '07979866976',     desc => 'UK mobile to mobile' },
    { from => '+44 800 001 4000',  to => '+44 845 505 0000',  expect => '08455050000',     desc => 'UK 0800 to 0845' },
    { from => '+44 800 001 4000',  to => '+44 800 001 4001',  expect => '08000014001',     desc => 'UK 0800 to 0800' },
    { from => '+44 1424 220000',   to => '+44 1534 440000',   expect => '01534440000',     desc => 'mainland UK to JE' },
    { from => '+44 1534 440000',   to => '+44 1424 220000',   expect => '01424220000',     desc => 'JE to mainland UK' },

    # NANP
    { from => '+1 202 224 6361',   to => '+1 202 224 4944',   expect => undef,             desc => 'NANP domestic call' },
    { from => '+1 202 224 6361',   to => '+44 1403 210000',   expect => '011441403210000', desc => 'NANP call to UK' },
    { from => '+44 1424 220000',   to => '+1 202 224 6361',   expect => '0012022246361',   desc => 'UK call to NANP' },

    # UK <-> stub
    { from => '+44 7979 866975',   to => '+49 30 277 0',      expect => '0049302770',      desc => 'UK to DE (stub)' },
    { from => '+49 30 277 0',      to => '+44 7979 866975',   expect => '00447979866975',  desc => 'DE (stub) to UK' },

    # stub1 <-> stub2
    { from => '+49 30 277 0',      to => '+33 1 49 55 49 55', expect => '0033149554955',   desc => 'DE (stub) to FR (stub)' },

    # stub domestic
    { from => '+33 1 49 55 49 55', to => '+33 826 500 500',   expect => undef,             desc => 'FR (stub) to FR (stub)' },
) {
    if(
        $test->{from} =~ /^\+44/  && $test->{to} =~ /^\+44/ &&
        !defined($test->{expect}) && building_without_uk()
    ) {
        # stubs don't know that we can't call unallocated numbers
        $test->{expect} = $test->{to};
        $test->{expect} =~ s/^\+44 /0/;
        $test->{expect} =~ s/ //g;
    }
    test_dial_to(%{$test});
}

subtest "Country-level overlays in dial_to", sub {
    foreach my $mapping (
        # +353 48 maps to +44 28, so we need to be especially thorough about testing
        # anything involving the UK or Ireland
        #
        # from NI, instantiated as a UK number (+4428)
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
        # from NI instantiated as an IE number (+35348)
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
                    # if we're building --without_uk these combinations will explode
                    next if(
                        ($from_class eq 'Number::Phone' && $from =~ /^(\+44|\+35348)/) ||
                        ($to_class   eq 'Number::Phone' && $to   =~ /^(\+44|\+35348)/)
                    );
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

sub test_dial_to {
    my %params = @_;

    my $from = _class_for($params{from})->new($params{from});
    my $to   = _class_for($params{to})->new($params{to});
  
    note("from: $params{from}\tto: $params{to}");
    is($from->dial_to($to), $params{expect}, sprintf("%s -> %s = %s (%s)", map { defined($params{$_}) ? $params{$_} : '[undef]' } qw(from to expect desc)));
}

sub _class_for {
    if($_[0] =~ /^\+44/ && building_without_uk()) { 'Number::Phone::Lib' }
     elsif($_[0] =~ /^\+(49|33)/) { 'Number::Phone::Lib' } # in case a full-fat implementation is installed
     else { 'Number::Phone' }
}

done_testing();
