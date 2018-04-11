#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

use Number::Phone::UK;
use Test::More;

END { done_testing(); }

my $data = {
  JE => {
    mobile     => '+44 7509 000000',
    geographic => '+44 1534 440000',
    operator   => 'JT (Jersey) Limited',
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
    geographic  => '+44 1624 500000',
    specialrate => '+44 8456247890',
    operator    => qr/^(Manx Telecom Trading Limited|Sure \(Isle of Man\) Limited)$/,
    regulator   => 'Isle of Man Communications Commission, http://www.gov.im/government/boards/telecommunications.xml'
  },
};

foreach my $cc (keys %{$data}) {
  my $data = $data->{$cc};
  foreach my $type (qw(mobile geographic specialrate)) {
      next unless(exists($data->{$type}));

      my $method = "is_$type";
      foreach my $number (ref($data->{$type}) ? @{$data->{$type}} : $data->{$type}) {
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
      }
  }
}
