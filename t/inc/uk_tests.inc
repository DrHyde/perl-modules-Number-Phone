use strict;

$ENV{TESTINGKILLTHEWABBIT} = 1; # make sure we don't load detailed exchg data

my $number = Number::Phone->new('+44 142422 0000');
isa_ok($number, 'Number::Phone::UK', 'isa N::P::UK');
ok($number->country() eq 'UK', "inherited country() method works");
ok($number->format() eq '+44 1424 220000', "4+6 number formatted OK");
$number = Number::Phone->new('+44 115822 0000');
ok($number->format() eq '+44 115 822 0000', "3+7 number formatted OK");
$number = Number::Phone->new('+442 0 8771 2924');
ok($number->format() eq '+44 20 8771 2924', "2+8 number formatted OK");
ok($number->areacode() eq '20', "2+8 number has correct area code");
ok($number->subscriber() eq '87712924', "2+8 number has correct subscriber number");
foreach my $method (qw(is_allocated is_geographic is_valid)) {
    ok($number->$method(), "$method works for a London number");
}
foreach my $method (qw(is_in_use is_fixed_line is_mobile is_pager is_ipphone is_isdn is_tollfree is_specialrate is_adult is_personal is_corporate is_government is_international is_network_service is_ipphone)) {
    ok(!$number->$method(), "$method works for a London number");
}
ok(!defined($number->is_fixed_line()), "geographic numbers return undef for is_fixed_line");
ok(join(', ', sort $number->type()) eq 'is_allocated, is_geographic, is_valid', "type() works");

$number = Number::Phone->new('+448450033845');
ok($number->format() eq '+44 8450033845', "0+10 number formatted OK");
ok($number->areacode() eq '', "0+10 number has no area code");
ok($number->subscriber() eq '8450033845', "0+10 number has correct subscriber number");

$number = Number::Phone->new('+447979866975');
ok($number->is_mobile(), "mobiles correctly identified");
ok(defined($number->is_fixed_line()) && !$number->is_fixed_line(), "mobiles are identified as not fixed lines");

$number = Number::Phone->new('+445600123456');
ok($number->is_ipphone(), "VoIP correctly identified");

$number = Number::Phone->new('+447693912345');
ok($number->is_pager(), "pagers correctly identified");

$number = Number::Phone->new('+44800001012');
ok($number->is_tollfree(), "toll-free numbers with significant F digit correctly identified");
$number = Number::Phone->new('+44500123456');
ok($number->is_tollfree(), "C&W 0500 numbers correctly identified as toll-free");
$number = Number::Phone->new('+448000341234');
ok($number->is_tollfree(), "generic toll-free numbers correctly identified");

$number = Number::Phone->new('+448450033845');
ok($number->is_specialrate(), "special-rate numbers correctly identified");

$number = Number::Phone->new('+449088791234');
ok($number->is_adult() && $number->is_specialrate(), "0908 'adult' numbers correctly identified");
$number = Number::Phone->new('+449090901234');
ok($number->is_adult() && $number->is_specialrate(), "0909 'adult' numbers correctly identified");

$number = Number::Phone->new('+447000012345');
ok($number->is_personal(), "personal numbers correctly identified");

$number = Number::Phone->new('+445588301234');
ok($number->is_corporate(), "corporate numbers correctly identified");

$number = Number::Phone->new('+448200123456');
ok($number->is_network_service(), "network service numbers correctly identified");

$number = Number::Phone->new('+448450033845');
ok($number->operator() eq 'Edge Telecom Limited', "operators correctly identified");

ok(!defined($number->areaname()), "good, no area name for non-geographic numbers");
$number = Number::Phone->new('+442087712924');
ok($number->areaname() eq 'London', "London numbers return correct area name");

$number = Number::Phone->new('+448457283848'); # "Allocated for Migration only"
ok($number, "0845 'Allocated for Migration only' fixed");

$number = Number::Phone->new('+448701540154'); # "Allocated for Migration only"
ok($number, "0870 'Allocated for Migration only' fixed");

$number = Number::Phone->new('+447092306588'); # dodgy spaces were appearing in data
ok($number, "bad 070 data fixed");

$number = Number::Phone->new('+442030791234'); # new London 020 3 numbers
ok($number, "0203 numbers are recognised");
ok($number->is_allocated() && $number->is_geographic(), "... and their type looks OK");

$number = Number::Phone->new('+442087712924');
ok($number->location()->[0] == 51.38309 && $number->location()->[1] == -0.336079, "geo numbers have correct location");
$number = Number::Phone->new('+447979866975');
ok(!defined($number->location()), "non-geo numbers have no location");

$number = Number::Phone->new('+443031231234');
ok($number->operator() eq 'BT', "03 numbers have right operator");
ok(join(',', sort { $a cmp $b } $number->type()) eq 'is_allocated,is_valid', "03 numbers have right type");
ok($number->format() eq '+44 3031231234', "03 numbers are formatted right");

ok(Number::Phone->new('+44169772200')->format() eq '+44 16977 2200', "5+4 format works");

# 01768 88 is "Mixed 4+5 & 4+6".  I wish someone would just set the village on fire.
ok(Number::Phone->new('+44 1768 88 000')->format() eq '+44 1768 88000', "4+5 (mixed) format works");
ok(Number::Phone->new('+44 1768 88 100')->format() eq '+44 1768 88100', "4+5 (mixed) format works");

ok(Number::Phone->new('+44 1768 88 0000')->format() eq '+44 1768 880000', "4+6 (mixed) format works");
ok(Number::Phone->new('+44 1768 88 1000')->format() eq '+44 1768 881000', "4+6 (mixed) format works");

ok(!Number::Phone->new('+44 1768 88 0'), "4+3 in that range correctly fails");
ok(!Number::Phone->new('+44 1768 88 00'), "4+4 in that range correctly fails");
ok(!Number::Phone->new('+44 1768 88 00000'), "4+7 in that range correctly fails");

$number = Number::Phone->new('+447400000000');
ok($number->is_mobile(), "074 mobiles correctly identified");
ok($number->operator() eq 'Hutchison 3G UK Ltd', "074 mobiles have right operator");
ok($number->format() eq '+44 7400000000', "074 mobiles have right operator");

$number = Number::Phone->new('+447500000000');
ok($number->is_mobile(), "075 mobiles correctly identified");
ok($number->operator() eq 'Vodafone Ltd', "075 mobiles have right operator");
ok($number->format() eq '+44 7500000000', "075 mobiles have right operator");

print "# bugfixes\n";

$number = Number::Phone->new('+441954123456');
ok($number->format() eq '+44 1954123456', "unallocated numbers format OK");

$number = Number::Phone->new('+441954202020');
ok($number->format() eq '+44 1954 202020', "allocated numbers format OK");

$number = Number::Phone::UK->new('0844000000');
ok(!defined($number), "0844 000 000 is invalid (too short)");

$number = Number::Phone->new('+44844000000');
ok(!defined($number), "+44 844 000 000 is invalid (too short)");

$number = Number::Phone->new('+441302622123');
ok($number->format() eq '+44 1302 622123', "OFCOM's stupid 6+4 format for 1302 62[2459] is corrected");

$number = Number::Phone->new('+441302623123');
ok($number->format() eq '+44 1302 623123', "OFCOM's missing format for 1302 623 is corrected");

foreach my $tuple (
  [ 'Number::Phone'     => '+441954202020', '+44 1954 202020' ],
  [ 'Number::Phone::UK' => '01954202020',   '+44 1954 202020' ],
  [ 'Number::Phone'     => '+441697384444', '+44 1697384444' ],
  [ 'Number::Phone::UK' => '01697384444',   '+44 1697384444' ],
) {
  $number = $tuple->[0]->new($tuple->[1]);
  ok($number->format() eq $tuple->[2], $tuple->[0].'->new('.$tuple->[1].')->format() works ('.$tuple->[2].")");
}
