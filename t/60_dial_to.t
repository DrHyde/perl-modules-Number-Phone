#!/usr/bin/perl -w

use strict;

use Number::Phone;
use Test::More tests => 8;

foreach my $test (
  { from => '+44 1424 220000',  to => '+44 1424 220001',  expect => '220001',          desc => 'UK local call' },
  { from => '+44 1403 200000',  to => '+44 1403 030001',  expect => '01403030001',     desc => 'UK local call to National Dialling Only number' },
  { from => '+44 1403 200000',  to => '+44 1424 220000',  expect => '01424220000',     desc => 'UK call to another area' },
  { from => '+44 1424 220000',  to => '+1 202 224 6361',  expect => '0012022246361',   desc => 'UK call to another country' },
  { from => '+44 7979 866975',  to => '+44 7979 866976',  expect => '07979866976',     desc => 'UK mobile to mobile' },
  { from => '+44 800 001 4000', to => '+44 845 505 0000', expect => '08455050000',     desc => 'UK 0800 to 0845' }, # kinda weird, I know. We only use the default for 01/02 (but even then, see NDO above)
  { from => '+1 202 224 6361',  to => '+44 1403 200000',  expect => '011441403200000', desc => 'US call to another country' },
  { from => '+1 202 224 6361',  to => '+1 202 224 4944',  expect => undef,             desc => 'US domestic call' }, # don't know how to dial this because of silly overlays in some places
) {
  test_dial_to(%{$test});
}

sub test_dial_to {
  my %params = @_;
  my $from = Number::Phone->new($params{from});
  my $to   = Number::Phone->new($params{to});

  if(!defined($params{expect})) {
    ok(!defined($from->dial_to($to)), "don't know how to dial from ".$from->format()." to ".$to->format()." ($params{desc})");
  } else {
    is($from->dial_to($to), $params{expect}, "dial $params{expect} to get from ".$from->format()." to ".$to->format()." ($params{desc})");
  }
}
