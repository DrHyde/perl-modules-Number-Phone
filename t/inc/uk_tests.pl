use strict;
use warnings;

$ENV{TESTINGKILLTHEWABBIT} = 1; # make sure we don't load detailed exchg data

sub is_mocked_uk { $Number::Phone::Country::idd_codes{'44'} eq 'MOCK' }
sub skip_if_mocked {
  my($msg, $count, $sub) = @_;
  SKIP: {
    skip $msg, $count if(is_mocked_uk());
    $sub->();
  };
}
 

my $number = Number::Phone->new('+44 142422 0000');
isa_ok($number, 'Number::Phone::'.(is_mocked_uk() ? 'StubCountry::MOCK' : 'UK'));
is($number->country(), (is_mocked_uk() ? 'MOCK' : 'UK'), "inherited country() method works");
ok($number->format() eq '+44 1424 220000', "4+6 number formatted OK");
skip_if_mocked("libphonenumber doesn't do areacode/subscriber", 2, sub {
  is($number->areacode(), '1424', "... right area code");
  is($number->subscriber(), '220000', "... right subscriber");
});

$number = Number::Phone->new('+44 115822 0000');
ok($number->format() eq '+44 115 822 0000', "3+7 number formatted OK");
skip_if_mocked("libphonenumber doesn't do areacode/subscriber", 2, sub {
  is($number->areacode(), '115', "... right area code");
  is($number->subscriber(), '8220000', "... right subscriber");
});

$number = Number::Phone->new('+442 0 8771 2924');
ok($number->format() eq '+44 20 8771 2924', "2+8 number formatted OK");
skip_if_mocked("libphonenumber doesn't do areacode/subscriber", 2, sub {
  ok($number->areacode() eq '20', "2+8 number has correct area code");
  ok($number->subscriber() eq '87712924', "2+8 number has correct subscriber number");
});
foreach my $method (qw(is_geographic is_valid), is_mocked_uk() ? () : qw(is_allocated)) {
    ok($number->$method(), "$method works for a London number");
}
foreach my $method (qw(is_in_use is_fixed_line is_mobile is_pager is_ipphone is_isdn is_tollfree is_specialrate is_adult is_personal is_corporate is_government is_international is_network_service is_ipphone)) {
    ok(!$number->$method(), "$method works for a London number");
}
# might be forwarded to a mobile at the switch
ok(!defined($number->is_fixed_line()), "geographic numbers return is_fixed_line == undef");
is(join(', ', sort $number->type()), join(', ', sort (qw(is_geographic is_valid), is_mocked_uk() ? () : qw(is_allocated))), "type() works");

$number = Number::Phone->new('+448450033845');
is($number->format(), is_mocked_uk() ? '+44 845 003 3845' : '+44 8450033845', "0+10 number formatted OK");
skip_if_mocked("libphonenumber doesn't do areacode/subscriber", 2, sub {
  ok($number->areacode() eq '', "0+10 number has no area code");
  ok($number->subscriber() eq '8450033845', "0+10 number has correct subscriber number");
});

$number = Number::Phone->new('+447979866975');
ok($number->is_mobile(), "mobiles correctly identified");
ok(defined($number->is_fixed_line()) && !$number->is_fixed_line(), "mobiles are identified as not fixed lines");

$number = Number::Phone->new('+447693912345');
ok($number->is_pager(), "pagers correctly identified");

$number = Number::Phone->new('+44800001012');
ok($number->is_tollfree(), "toll-free numbers with significant F digit correctly identified");
$number = Number::Phone->new('+44500123456');
ok($number->is_tollfree(), "C&W 0500 numbers correctly identified as toll-free");
$number = Number::Phone->new('+448000341234');
ok($number->is_tollfree(), "generic toll-free numbers correctly identified");

skip_if_mocked("libphonenumber doesn't know about location/operators/network-service/special-rate/adult/corporate numbers", 8, sub {
  $number = Number::Phone->new('+448450033845');
  ok($number->is_specialrate(), "special-rate numbers correctly identified");

  $number = Number::Phone->new('+449088791234');
  ok($number->is_adult() && $number->is_specialrate(), "0908 'adult' numbers correctly identified");
  $number = Number::Phone->new('+449090901234');
  ok($number->is_adult() && $number->is_specialrate(), "0909 'adult' numbers correctly identified");

  $number = Number::Phone->new('+445588301234');
  ok($number->is_corporate(), "corporate numbers correctly identified");

  $number = Number::Phone->new('+448200123456');
  ok($number->is_network_service(), "network service numbers correctly identified");

  $number = Number::Phone->new('+448450033845');
  ok($number->operator() eq 'Edge Telecom Limited', "operators correctly identified");

  $number = Number::Phone->new('+442087712924');
  ok($number->location()->[0] == 51.38309 && $number->location()->[1] == -0.336079, "geo numbers have correct location");
  $number = Number::Phone->new('+447979866975');
  ok(!defined($number->location()), "non-geo numbers have no location");
});

# but when we're mocking we do know that we know nothing about portability
ok(!defined($number->operator_ported()), "don't know anything about portability");

$number = Number::Phone->new('+447000012345');
ok($number->is_personal(), "personal numbers correctly identified");
ok(!defined($number->areaname()), "good, no area name for non-geographic numbers");

$number = Number::Phone->new('+442087712924');
is($number->areaname(), 'London', "London numbers return correct area name");

$number = Number::Phone->new('+448457283848'); # "Allocated for Migration only"
ok($number, "0845 'Allocated for Migration only' fixed");

$number = Number::Phone->new('+448701540154'); # "Allocated for Migration only"
ok($number, "0870 'Allocated for Migration only' fixed");

$number = Number::Phone->new('+447092306588'); # dodgy spaces were appearing in data
ok($number, "bad 070 data fixed");

$number = Number::Phone->new('+442030791234'); # new London 020 3 numbers
ok($number, "0203 numbers are recognised");
# libphonenumber doesn't do allocation
is_deeply([sort $number->type()], [sort ((!is_mocked_uk() ? 'is_allocated' : ()), qw(is_valid is_geographic))], "... and their type looks OK");

$number = Number::Phone->new('+445600123456');
ok($number->is_ipphone(), "VoIP correctly identified");

$number = Number::Phone->new('+443031231234');
skip_if_mocked("libphonenumber doesn't do operators", 1, sub {
  ok($number->operator() eq 'BT', "03 numbers have right operator");
});
is_deeply([sort $number->type()], [sort ((!is_mocked_uk() ? 'is_allocated' : ()), 'is_valid')], "03 numbers have right type");
skip_if_mocked("libphonenumber disagrees with me about formatting special rate numbers", 1, sub {
  is($number->format(), '+44 3031231234', "03 numbers are formatted right");
});

ok(Number::Phone->new('+44169772200')->format() eq '+44 16977 2200', "5+4 format works");

# 01768 88 is "Mixed 4+5 & 4+6".  I wish someone would just set the village on fire.

skip_if_mocked("libphonenumber knows better than OFCOM for 01768", 2, sub {
  ok(Number::Phone->new('+44 1768 88 000')->format() eq '+44 1768 88000', "4+5 (mixed) format works");
  ok(Number::Phone->new('+44 1768 88 100')->format() eq '+44 1768 88100', "4+5 (mixed) format works");
  is(Number::Phone->new('+44 1768 88 0000')->format(), '+44 1768 880000', "4+6 (mixed) format works");
  is(Number::Phone->new('+44 1768 88 1000')->format(), '+44 1768 881000', "4+6 (mixed) format works");
});
is(Number::Phone->new('+44 1768 88 1000')->areaname(), "Penrith", "01768 88 area name");

ok(!Number::Phone->new('+44 1768 88 0'), "4+3 in that range correctly fails");
ok(!Number::Phone->new('+44 1768 88 00'), "4+4 in that range correctly fails");
$number = Number::Phone->new('+44 1768 88 00000');
ok(!$number, "4+7 in that range correctly fails");

$number = Number::Phone->new('+447400000000');
ok($number->is_mobile(), "074 mobiles correctly identified");
skip_if_mocked("libphonenumber doesn't do operators", 1, sub {
  ok($number->operator() eq 'Hutchison 3G UK Ltd', "074 mobiles have right operator");
});
skip_if_mocked("libphonenumber disagrees with me about formatting mobile numbers", 1, sub {
  is($number->format(), '+44 7400000000', "074 mobiles are formatted OK");
});
$number = Number::Phone->new('+447500000000');
ok($number->is_mobile(), "075 mobiles correctly identified");
skip_if_mocked("libphonenumber doesn't do operators", 1, sub {
  ok($number->operator() eq 'Vodafone Ltd', "075 mobiles have right operator");
});
skip_if_mocked("libphonenumber disagrees with me about formatting mobile numbers", 1, sub {
  is($number->format(), '+44 7500000000', "075 mobiles are formatted OK");
});

print "# bugfixes\n";

skip_if_mocked("libphonenumber disagrees with me about formatting unallocated numbers", 1, sub {
  $number = Number::Phone->new('+441954123456');
  is($number->format(), '+44 1954123456', "unallocated numbers format OK");
});

$number = Number::Phone->new('+441954202020');
ok($number->format() eq '+44 1954 202020', "allocated numbers format OK");

$number = Number::Phone->new('+441302622123');
is($number->format(), '+44 1302 622123', "OFCOM's stupid 6+4 format for 1302 62[2459] is corrected");

$number = Number::Phone->new('+441302623123');
is($number->format(), '+44 1302 623123', "OFCOM's missing format for 1302 623 is corrected");

foreach my $tuple (
  [ 'Number::Phone::UK' => '0844000000'   ],
  [ 'Number::Phone'     => '+44844000000' ]
) {
  my($class, $number) = @{$tuple};
  skip_if_mocked("Stubs aren't intended to be constructed directly", 1, sub {
    ok(!defined($class->new($number)),
      "$class->new($number) is undef (too short)");
  });
}

$number = Number::Phone->new('+44844000000');
ok(!defined($number), "+44 844 000 000 is invalid (too short)");

foreach my $tuple (
  [ 'Number::Phone'     => '+441954202020', '+44 1954 202020' ],
  [ 'Number::Phone::UK' => '01954202020',   '+44 1954 202020' ],
  [ 'Number::Phone'     => '+441697384444', '+44 1697384444' ],
  [ 'Number::Phone::UK' => '01697384444',   '+44 1697384444' ],
) {
  my($class, $number, $result) = @{$tuple};
  skip_if_mocked("Stubs aren't intended to be constructed directly", 1, sub {
    my $obj = $class->new($number);
    is($obj->format(), $result, "$class->new($number)->format() works");
  });
}

done_testing();
1;
