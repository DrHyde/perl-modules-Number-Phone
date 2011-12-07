#!/usr/bin/perl -w

use strict;

use Number::Phone::UK;
use Test::More;

END { done_testing(); }

my $data = {
  JE => {
    mobile     => '+44 7509 000000',
    geographic => '+44 1534 440000',
    operator   => 'Jersey Telecom',
    regulator  => 'Office of Utility Regulation, http://www.cicra.gg'
  },
  GG => {
    mobile     => '+44 7781 000000',
    geographic => '+44 1481 200000',
    operator   => 'Cable and Wireless Guernsey Limited',
    regulator  => 'Office of Utility Regulation, http://www.cicra.gg'
  },
  IM => {
    mobile     => '+44 7624 000000',
    geographic => '+44 1624 500000',
    operator   => 'Manx Telecom',
    regulator  => 'Isle of Man Communications Commission, http://www.gov.im/government/boards/telecommunications.xml'
  },
};

foreach my $cc (keys %{$data}) {
  my $data = $data->{$cc};
  my $number = Number::Phone->new($data->{mobile});
  (my $formatted = $data->{mobile}) =~ s/ (\d{6})/$1/;
  isa_ok($number, "Number::Phone::UK::$cc", "isa N::P::UK::$cc");
  isa_ok($number, 'Number::Phone::UK', "isa N::P::UK by inheritance");
  is($number->country(), $cc, "country() method works");
  ok($number->is_mobile(), $data->{mobile}."detected as being mobile");
  is($number->format(), $formatted, "format() method works");
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
  is($number->format(), '+44 '.$number->areacode().' '.$number->subscriber(), "format() method works");
  is_deeply(
    [sort $number->type()],
    [qw(is_allocated is_geographic is_valid)],
    "type() works"
  );
  is($number->operator(), $data->{operator}, "inherited operator() works");
  is($number->regulator(), $data->{regulator}, "regulator() works");
}
