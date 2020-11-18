use strict;
use warnings;
use lib 't/inc';
use nptestutils;

use Test::More;
use Test::Differences;

use Number::Phone;
use Number::Phone::Lib;

my $data = {
  JE => {
    mobile     => '+44 7700 300000', # used specifically because there's a special case for 7700 900
    geographic => '+44 1534 440000',
    operator   => qr/^(JT|Sure) \(Jersey\) Limited$/,
    regulator  => 'Office of Utility Regulation, http://www.cicra.gg'
  },
  GG => {
    mobile     => '+44 7781 000000',
    geographic => '+44 1481 200000',
    operator   => 'Sure (Guernsey) Limited',
    regulator  => 'Office of Utility Regulation, http://www.cicra.gg'
  },
  IM => {
    mobile      => ['+44 7624 000000', '+44 7457 600000'],
    geographic  => '+44 1624 710000',
    specialrate => '+44 8456247890',
    operator    => qr/^(MANX TELECOM TRADING LIMITED|Sure \(Isle of Man\) Ltd)$/,
    regulator   => 'Isle of Man Communications Commission, http://www.gov.im/government/boards/telecommunications.xml'
  },
};

foreach my $class ('Number::Phone::Lib', (building_without_uk() ? () : 'Number::Phone')) {
    my $target_base_class = ($class eq 'Number::Phone::Lib') ? 'Number::Phone::StubCountry' : 'Number::Phone::UK';
    foreach my $cc (sort keys %{$data}) {
        my $data = $data->{$cc};
        foreach my $type (sort qw(mobile geographic specialrate)) {
            next unless(exists($data->{$type}));
      
            my $method = "is_$type";
            foreach my $number (sort ref($data->{$type}) ? @{$data->{$type}} : $data->{$type}) {
                SKIP: {
                    skip "libphonenumber is just plain wrong about +44 845 624 (thinks it's GB, not IM)", 1
                        if($class eq 'Number::Phone::Lib' && $number eq '+44 8456247890');
                    subtest "$class: $number" => sub {
                        my $object = $class->new($number);
                        isa_ok($object, "${target_base_class}::$cc", "isa ${target_base_class}::$cc");
                        isa_ok($object, $target_base_class, "isa $target_base_class by inheritance");
                        is($object->country(), $cc, "country() method works");
                        ok($object->$method(), $number." detected as being $type");
                        is($object->format(), $number, "format() method works");
    
                        my @expected_types = ($method, 'is_valid');
                        # only full-fat implementations know about allocation
                        push @expected_types, 'is_allocated' if($class eq 'Number::Phone');
                        # full-fat and thin-gruel differ about is_fixed_line for geographic numbers
                        # full-fat is correct, thin-gruel is in agreement with libphonenumber
                        push @expected_types, 'is_fixed_line' if($class eq 'Number::Phone::Lib' && $method eq 'is_geographic');
                        eq_or_diff(
                            [sort $object->type()],
                            [sort @expected_types],
                            "type() works"
                        );
    
                        if($target_base_class eq 'Number::Phone::UK') {
                            ref($data->{operator})
                                ? like($object->operator(), $data->{operator}, "inherited operator() works")
                                :   is($object->operator(), $data->{operator}, "inherited operator() works");
                            is($object->regulator(), $data->{regulator}, "regulator() works");
                        }
                    };
                }
            }
        }
    }
}

done_testing();
