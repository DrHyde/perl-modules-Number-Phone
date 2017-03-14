#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

use Number::Phone::UK;
use Test::More;

END { done_testing(); }

my $data = {
  JE => {
    mobile     => '+44 7509000000',
    geographic => '+44 1534 440000',
    operator   => 'JT (Jersey) Limited',
    regulator  => 'Office of Utility Regulation, http://www.cicra.gg'
  },
  GG => {
    mobile     => '+44 7781000000',
    geographic => '+44 1481 200000',
    operator   => 'Sure (Guernsey) Limited',
    regulator  => 'Office of Utility Regulation, http://www.cicra.gg'
  },
  IM => {
    mobile      => '+44 7624000000',
    geographic  => '+44 1624 500000',
    specialrate => '+44 8456247890',
    operator    => 'Manx Telecom Trading Limited',
    regulator   => 'Isle of Man Communications Commission, http://www.gov.im/government/boards/telecommunications.xml'
  },
};

foreach my $cc (keys %{$data}) {
  my $data = $data->{$cc};
  my $number = Number::Phone->new($data->{mobile});
  isa_ok($number, "Number::Phone::UK::$cc", "isa N::P::UK::$cc");
  isa_ok($number, 'Number::Phone::UK', "isa N::P::UK by inheritance");
  is($number->country(), $cc, "country() method works");
  ok($number->is_mobile(), $data->{mobile}."detected as being mobile");
  is($number->format(), $data->{mobile}, "format() method works");
  is_deeply(
    [sort $number->type()],
    [qw(is_allocated is_mobile is_valid)],
    "type() works"
  );
  $number = Number::Phone->new($data->{geographic});
  isa_ok($number, "Number::Phone::UK::$cc", "isa N::P::UK::$cc");
  isa_ok($number, 'Number::Phone::UK', "isa N::P::UK by inheritance");
  is($number->country(), $cc, "country() method works");
  ok($number->is_geographic(), $data->{geographic}." detected as being geographic");
  is($number->format(), $data->{geographic}, "format() method works");
  is_deeply(
    [sort $number->type()],
    [qw(is_allocated is_geographic is_valid)],
    "type() works"
  );
  if(exists($data->{specialrate})) {
    $number = Number::Phone->new($data->{specialrate});
    isa_ok($number, "Number::Phone::UK::$cc", "isa N::P::UK::$cc");
    isa_ok($number, 'Number::Phone::UK', "isa N::P::UK by inheritance");
    is($number->country(), $cc, "country() method works");
    ok($number->is_specialrate(), $data->{specialrate}." detected as being specialrate");
    is($number->format(), $data->{specialrate}, "format() method works");
    is_deeply(
      [sort $number->type()],
      [qw(is_allocated is_specialrate is_valid)],
      "type() works"
    );
  }
  is($number->operator(), $data->{operator}, "inherited operator() works");
  is($number->regulator(), $data->{regulator}, "regulator() works");
}
