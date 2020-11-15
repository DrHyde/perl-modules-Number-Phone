#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use nptestutils;

use Number::Phone::UK;
use Test::More;

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

foreach my $cc (keys %{$data}) {
  my $data = $data->{$cc};
  foreach my $type (qw(mobile geographic specialrate)) {
      next unless(exists($data->{$type}));

      my $method = "is_$type";
      foreach my $number (ref($data->{$type}) ? @{$data->{$type}} : $data->{$type}) {
          subtest $number => sub {
              my $object = Number::Phone->new($number);
              isa_ok($object, "Number::Phone::UK::$cc", "isa N::P::UK::$cc");
              isa_ok($object, 'Number::Phone::UK', "isa N::P::UK by inheritance");
              is($object->country(), $cc, "country() method works");
              ok($object->$method(), $number." detected as being $type");
              is($object->format(), $number, "format() method works");
              is_deeply(
                  [sort $object->type()],
                  [sort ($method, qw(is_allocated is_valid))],
                  "type() works"
              );
              ref($data->{operator})
                  ? like($object->operator(), $data->{operator}, "inherited operator() works")
                  :   is($object->operator(), $data->{operator}, "inherited operator() works");
              is($object->regulator(), $data->{regulator}, "regulator() works");
          };
      }
  }
}

done_testing();
