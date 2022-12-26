use strict;
use warnings;

use Data::Dumper;

$ENV{TESTINGKILLTHEWABBIT} = 1; # make sure we don't load detailed exchg data

{
  no warnings 'redefine';
  sub is_mocked_uk { $Number::Phone::Country::idd_codes{'44'} eq 'MOCK' }
  sub skip_if_mocked {
    my($msg, $count, $sub) = @_;
    SKIP: {
      skip $msg, $count if(is_mocked_uk());
      $sub->();
    };
  }
}

note("Common tests for Number::Phone::UK, and also for N::P::StubCountry::MOCK");
note("The latter is a sanity testto make sure that stubs are built correctly,");
note("and the comprehensive UK tests make a good torture-test.");

my $number = Number::Phone->new('+44 142422 0000');
isa_ok($number, 'Number::Phone::'.(is_mocked_uk() ? 'StubCountry::MOCK' : 'UK'));
is($number->country(), (is_mocked_uk() ? 'MOCK' : 'UK'), "inherited country() method works");
is($number->format(), '+44 1424 220000', "4+6 number formatted OK");
skip_if_mocked("libphonenumber doesn't do areacode/subscriber", 2, sub {
  is($number->areacode(), '1424', "... right area code");
  is($number->subscriber(), '220000', "... right subscriber");
});

$number = Number::Phone->new('+44 115822 0000');
is($number->format(), '+44 115 822 0000', "3+7 number formatted OK");
skip_if_mocked("libphonenumber doesn't do areacode/subscriber", 2, sub {
  is($number->areacode(), '115', "... right area code");
  is($number->subscriber(), '8220000', "... right subscriber");
});

$number = Number::Phone->new('+442 0 8771 2924');
is($number->format(), '+44 20 8771 2924', "2+8 number formatted OK");
skip_if_mocked("libphonenumber doesn't do areacode/subscriber", 2, sub {
  is($number->areacode(), '20', "2+8 number has correct area code");
  is($number->subscriber(), '87712924', "2+8 number has correct subscriber number");
});
foreach my $method (qw(is_geographic is_valid), is_mocked_uk() ? () : qw(is_allocated)) {
    ok($number->$method(), "$method works for a London number");
}
foreach my $method (qw(is_in_use is_mobile is_pager is_ipphone is_isdn is_tollfree is_specialrate is_adult is_personal is_corporate is_government is_international is_network_service is_ipphone)) {
    ok(!$number->$method(), "$method works for a London number");
}

# might be forwarded to a mobile at the switch
if(is_mocked_uk()) {
    ok($number->is_fixed_line(), "geographic numbers have is_fixed_line");
} else {
    ok(!defined($number->is_fixed_line()), "geographic numbers return is_fixed_line == undef");
}

# libphonenumber doesn't do allocation but does think geographic numbers are fixed lines
is_deeply(
    [sort $number->type()],
    [sort ((is_mocked_uk() ? 'is_fixed_line' : 'is_allocated'), qw(is_valid is_geographic))],
    "... and their type looks OK"
);

$number = Number::Phone->new('+44 141 999 0299');
foreach my $method (qw(is_geographic is_valid)) {
    ok($number->$method(), "$method works for a protected number");
}
foreach my $method (qw(is_in_use is_mobile is_pager is_ipphone is_isdn is_tollfree is_specialrate is_adult is_personal is_corporate is_government is_international is_network_service is_ipphone), is_mocked_uk() ? () : qw(is_allocated)) {
    ok(!$number->$method(), "$method works for a protected number");
}

$number = Number::Phone->new('+448450033845');
is($number->format(), is_mocked_uk() ? '+44 845 003 3845' : '+44 8450033845', "0+10 number formatted OK");
skip_if_mocked("libphonenumber doesn't do areacode/subscriber", 2, sub {
  is($number->areacode(), '', "0+10 number has no area code");
  is($number->subscriber(), '8450033845', "0+10 number has correct subscriber number");
});

$number = Number::Phone->new('+447979866975');
ok($number->is_mobile(), "mobiles correctly identified");
ok(defined($number->is_fixed_line()) && !$number->is_fixed_line(), "mobiles are identified as not fixed lines");

skip_if_mocked("can't check country when mocking is in place", 1, sub {
    # 74576 is an IM prefix, the rest of 7457 is UK
    $number = Number::Phone->new('+447457500000');
    is($number->country(), 'UK', "most of +44 7457 is recognised as UK. See weird little islands tests for the exception");
});

$number = Number::Phone->new('+447693912345');
ok($number->is_pager(), "pagers correctly identified");

# see https://github.com/DrHyde/perl-modules-Number-Phone/issues/112
# checked on 2022-12-24
# next check due 2023-06-01 (semi-annually)
subtest "0800 716 range has the wrong length, OFCOM says 10 digits but 0800 716 598 is diallable" => sub {
    $number = Number::Phone->new('+44800716598'); # used by Barclays
    ok($number->is_tollfree(), "valid 9 digit number in a range supposedly for 10 digit numbers");

    $number = Number::Phone->new(
        (is_mocked_uk() ? 'MOCK' : 'UK'),
        '0800716598'
    );
    ok($number->is_tollfree(), "valid 9 digit number (national format) in a range supposedly for 10 digit numbers");

    # this is invalid, it's a digit appended to the above, but this may
    # be a mixed 9 and 10 digit range, so test it to make sure the length
    # check passes
    $number = Number::Phone->new('+448007165980');
    ok($number->is_tollfree(), "10 digit number also in that range");

    # this is invalid, it's too short, in that mixed range
    $number = Number::Phone->new('+4480071659');
    is($number, undef, "too short number doesn't validate");
};

$number = Number::Phone->new('+44800001012');
ok($number->is_tollfree(), "toll-free numbers with significant F digit correctly identified");
# 0500 is Quarantined
# $number = Number::Phone->new('+44500123456');
# ok($number->is_tollfree(), "C&W 0500 numbers correctly identified as toll-free");
$number = Number::Phone->new('+448000341234');
ok($number->is_tollfree(), "generic toll-free numbers correctly identified");

skip_if_mocked("libphonenumber doesn't know about location/operators/network-service/special-rate/adult/corporate numbers", 8, sub {
  $number = Number::Phone->new('+448450033845');
  ok($number->is_specialrate(), "special-rate numbers correctly identified");

  $number = Number::Phone->new('+449088801234');
  ok($number->is_adult() && $number->is_specialrate(), "0908 'adult' numbers correctly identified");
  $number = Number::Phone->new('+449090901234');
  ok($number->is_adult() && $number->is_specialrate(), "0909 'adult' numbers correctly identified");

  $number = Number::Phone->new('+445588301234');
  ok($number->is_corporate(), "corporate numbers correctly identified");

  $number = Number::Phone->new('+448450033845');
  is($number->operator(), 'GCI Network Solutions Ltd', "operators correctly identified");

  $number = Number::Phone->new('+442087712924');
  subtest "geo numbers have correct location" => sub {
      plan tests => 2;
      # call it twice to make sure we cover the situation where N:P:UK::Exchanges
      # has already been loaded. NB this isn't tickled when we check
      # with a non-geo number
      my $loc = $number->location();
      $number->location();
      is($loc->[0], 51.38309,  "latitude");
      is($loc->[1], -0.336079, "longitude");
  };
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

# libphonenumber doesn't do allocation but does think geographic numbers are fixed lines
is_deeply(
    [sort $number->type()],
    [sort ((is_mocked_uk() ? 'is_fixed_line' : 'is_allocated'), qw(is_valid is_geographic))],
    "... and their type looks OK"
);

$number = Number::Phone->new('+445602041914');
ok($number->is_ipphone(), "VoIP correctly identified");

$number = Number::Phone->new('+443031231234');
skip_if_mocked("libphonenumber doesn't do operators", 1, sub {
  ok($number->operator() eq 'BT', "03 numbers have right operator");
});
is_deeply(
    [sort $number->type()],
    [sort ((!is_mocked_uk() ? 'is_allocated' : ()), qw(is_specialrate is_valid))],
    "03 numbers have right type"
);

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
  is($number->format(), '+44 7400 000000', "074 mobiles are formatted OK");
});
$number = Number::Phone->new('+447500000000');
ok($number->is_mobile(), "075 mobiles correctly identified");
skip_if_mocked("libphonenumber doesn't do operators", 1, sub {
  is($number->operator(), 'Vodafone Limited', "075 mobiles have right operator");
});
skip_if_mocked("libphonenumber disagrees with me about formatting mobile numbers", 1, sub {
  is($number->format(), '+44 7500 000000', "075 mobiles are formatted OK");
});

print "# bugfixes\n";

skip_if_mocked("libphonenumber disagrees with me about formatting unallocated numbers", 1, sub {
  $number = Number::Phone->new('+441954123456');
  is($number->format(), '+44 1954123456', "unallocated numbers format OK");
});

$number = Number::Phone->new('+441954202020');
ok($number->format() eq '+44 1954 202020', "allocated numbers format OK");

foreach my $tuple (
  [ 'Number::Phone'     => '+44 843 523 5305' ],
  (is_mocked_uk() ? () : [ 'Number::Phone::UK' =>   '0843 523 5305' ]),
) {
  my($class, $digits) = @{$tuple};
  $number = $class->new($digits);
  is(
      $number->format(),
      # libphonenumber can format this, N::P::UK can't because OFCOM's data is deficient
      is_mocked_uk() ? '+44 843 523 5305' : '+44 8435235305',
      "OFCOM's missing format for 843 doesn't break shit: $class->new($digits)->format()"
  );
  is_deeply(
      [sort $number->type()],
      [sort ((!is_mocked_uk() ? 'is_allocated' : ()), qw(is_specialrate is_valid))],
      "... and its type looks OK"
  ) || print Dumper($number->type());
}

foreach my $tuple (
  [ 'Number::Phone::UK' => '0800 903 900'    ],
  [ 'Number::Phone'     => '+44 800 903 900' ]
) {
  my($class, $number) = @{$tuple};
  skip_if_mocked("Stubs aren't intended to be constructed directly", 1, sub {
    ok(my $obj = $class->new($number),
      "$class->new($number) 9 digit 08 numbers are A-OK");
    is($obj->format(), '+44 800903900',
      "... and formats OK");
  });
}

foreach my $invalid (qw(+442 +44275939345 +44208771292 +44113203160 +44113325000)) {
                  #   Tiny!   Protected    Normal       Normal       Protected
    $number = Number::Phone->new($invalid);
    ok(!defined($number), "$invalid is invalid (too short)");
}
foreach my $invalid (qw(+4427593934500 +4420877129200 +4411320316000 +4411332500000)) {
                  #        Protected       Normal         Normal         Protected
    $number = Number::Phone->new($invalid);
    ok(!defined($number), "$invalid is invalid (too long)");
}
foreach my $invalid (qw(+444000000000 +445025259012 +446000000000)) {
    $number = Number::Phone->new($invalid);
    (my $range = $invalid) =~ s/^(\+44....).*/$1/;
    is($number, undef, "Invalid number identified, $range is not in a valid range");
}

foreach my $tuple (
  [ 'Number::Phone'     => '+441954202020', '+44 1954 202020' ],
  [ 'Number::Phone::UK' => '01954202020',   '+44 1954 202020' ],
  [ 'Number::Phone'     => '+441697384444', '+44 16973 84444' ],
  [ 'Number::Phone::UK' => '01697384444',   '+44 16973 84444' ],
) {
  my($class, $number, $result) = @{$tuple};
  skip_if_mocked("Stubs aren't intended to be constructed directly", 1, sub {
    my $obj = $class->new($number);
    is($obj->format(), $result, "$class->new($number)->format() works");
  });
}

skip_if_mocked("Stubs don't support is_drama", 51, sub {
    note("is_drama");
    foreach my $dn (
        ['Leeds',            'geographic',  '+44 113 496 0553', '+44 113 496 0494'],
        ['Sheffield',        'geographic',  '+44 114 496 0445'],
        ['Nottingham',       'geographic',  '+44 115 496 0881'],
        ['Leicester',        'geographic',  '+44 116 496 0712'],
        ['Bristol',          'geographic',  '+44 117 496 0838'],
        ['Reading',          'geographic',  '+44 118 496 0976'],
        ['Birmingham',       'geographic',  '+44 121 496 0835'],
        ['Edinburgh',        'geographic',  '+44 131 496 0107'],
        ['Glasgow',          'geographic',  '+44 141 496 0297'],
        ['Liverpool',        'geographic',  '+44 151 496 0787'],
        ['Manchester',       'geographic',  '+44 161 496 0508'],
        ['London',           'geographic',  '+44 20 7946 0364', '+44 20 7946 0885'],
        ['Tyneside',         'geographic',  '+44 191 498 0228'],
        ['Cardiff',          'geographic',  '+44 29 2018 0678'],
        ['Northern Ireland', 'geographic',  '+44 28 9649 6008'],
        ['No area',          'geographic',  '+44 1632 960000'],
        ['Mobile',           'mobile',      '+44 7700 900011', '+44 7700 900471'],
        ['Freephone',        'tollfree',    '+44 8081 570576', '+44 8081 570044'],
        ['Premium Rate',     'specialrate', '+44 909 879 0845'],
        ['UK-Wide',          'specialrate', '+44 3069 990965'],
    ) {
         my $area   = shift(@{$dn});
         my $method = 'is_'.shift(@{$dn});
         foreach my $num (@{$dn}) {
             my $phone = Number::Phone->new($num);
             ok($phone->is_drama(), "$area drama number $num is_drama");
             ok($phone->$method(), "$area drama number $num $method");
             if($area eq 'Mobile') {
                 is($phone->country(), 'UK', "$num is UK-wide is_drama, not Jersey");
             }
         }
    }
    foreach my $number (qw(+447979866975 +442087712924)) {
         ok(defined(Number::Phone->new($number)->is_drama()) &&
            !Number::Phone->new($number)->is_drama(),
            "normal number $number is not is_drama");
    }
});

1;
