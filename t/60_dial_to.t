#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

use Number::Phone;
use Test::More tests => 12;

foreach my $test (
  # including the area code in dialstring works for local calls in the UK, and
  # copes with OFCOM's shenanigans in 01202
  # see http://consumers.ofcom.org.uk/dial-the-code/
  { from => '+44 1424 220000',  to => '+44 1424 220001',  expect => '01424220001',     desc => 'UK local call' },
  { from => '+44 1424 220000',  to => '+44 1424 990001',  expect => undef,             desc => 'UK call to reserved (ie unused) number' },
  { from => '+44 1403 200000',  to => '+44 1403 030001',  expect => '01403030001',     desc => 'UK local call to National Dialling Only number' },
  { from => '+44 1403 200000',  to => '+44 1424 220000',  expect => '01424220000',     desc => 'UK call to another area' },
  { from => '+44 7979 866975',  to => '+44 7979 866976',  expect => '07979866976',     desc => 'UK mobile to mobile' },
  { from => '+44 800 001 4000', to => '+44 845 505 0000', expect => '08455050000',     desc => 'UK 0800 to 0845' },
  { from => '+44 800 001 4000', to => '+44 800 001 4001', expect => '08000014001',     desc => 'UK 0800 to 0800' },


  { from => '+44 1424 220000',  to => '+44 1534 440000',  expect => '01534440000',     desc => 'mainland UK to JE' },
  { from => '+44 1534 440000',  to => '+44 1424 220000',  expect => '01424220000',     desc => 'JE to mainland UK' },
  # don't know how to dial this because of silly overlays in some places
  { from => '+1 202 224 6361',  to => '+1 202 224 4944',  expect => undef,             desc => 'US domestic call' },
  { from => '+44 1424 220000',  to => '+1 202 224 6361',  expect => '0012022246361',   desc => 'UK call to another country' },
  { from => '+1 202 224 6361',  to => '+44 1403 200000',  expect => '011441403200000', desc => 'US call to another country' },
) {
  test_dial_to(%{$test});
}

sub test_dial_to {
  my %params = @_;
  my $from = Number::Phone->new($params{from});
  my $to   = Number::Phone->new($params{to});

  if(!defined($params{expect})) {
    ok(!defined($from->dial_to($to)), sprintf("%s -> %s = [unknown] (%s)", map { $params{$_} } qw(from to desc)));
  } else {
    is($from->dial_to($to), $params{expect}, sprintf("%s -> %s = %s (%s)", map { $params{$_} } qw(from to expect desc)));
  }
}
