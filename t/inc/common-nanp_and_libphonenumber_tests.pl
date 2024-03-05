use strict;
use warnings;

use vars qw($CLASS);

{
  no warnings 'redefine';
  sub is_libphonenumber { $CLASS eq 'Number::Phone::Lib' }
  sub skip_if_libphonenumber {
    my($msg, $count, $sub) = @_;
    SKIP: {
      skip $msg, $count if(is_libphonenumber());
      $sub->();
    };
  }
}

note("Common tests for Number::Phone::NANP and Number::Phone::Lib");

my $ca_600 = $CLASS->new('+1 600 555 1000');
isa_ok $ca_600, is_libphonenumber() ? 'Number::Phone::StubCountry::CA'
                                    : 'Number::Phone::NANP::CA';
is $ca_600->country(), 'CA', "$CLASS->new('+1 600 555 1000')->country()";
is_deeply(
    [sort $ca_600->type()],
    [sort('is_valid', is_libphonenumber() ? 'is_ipphone' : ())],
    "$CLASS->new('+1 600 555 1000')->type()"
);

my $ca_604 = $CLASS->new('+1 604 555 1000');
isa_ok $ca_604, is_libphonenumber() ? 'Number::Phone::StubCountry::CA'
                                    : 'Number::Phone::NANP::CA';
is $ca_604->country(), 'CA', "$CLASS->new('+1 604 555 1000')->country()";
is_deeply(
    [sort $ca_604->type()],
    [sort qw(is_geographic is_valid)],
    "$CLASS->new('+1 604 555 1000')->type()"
);

my $the_man = '+1 (202) 456-6213';
my $us = $CLASS->new($the_man);
isa_ok $us, is_libphonenumber() ? 'Number::Phone::StubCountry::US'
                                : 'Number::Phone::NANP::US';
is($us->country_code(), 1, "$CLASS->new('$the_man')->country_code()");
is($us->country(), 'US', "$CLASS->new('$the_man')->country()");
is($us->areaname(), 'Washington D.C.', "$CLASS->new('$the_man')->areaname()");
is($us->format(), '+1 202 456 6213', "$CLASS->new('$the_man')->format()");

my $toll_free = '+1 (866) 623 2282';
my $tf = $CLASS->new($toll_free);
isa_ok $tf, is_libphonenumber() ? 'Number::Phone::StubCountry::US'
                                : 'Number::Phone::NANP';
is($tf->country_code(), 1, "$CLASS->new('$toll_free')->country_code()");
is($tf->country(), (is_libphonenumber() ? 'US' : undef),
   "$CLASS->new('$toll_free')->country()");
is($tf->areaname(), undef, "$CLASS->new('$toll_free')->areaname()");
is($tf->format(), '+1 866 623 2282', "$CLASS->new('$toll_free')->format()");
# libphonenumber thinks this is a US number, and the fixed/mobile regexes
# for the US are the same, so we define them as broken. Hence it doesn't know.
# N::P::NANP knows that this is a NANP-global and so ...
is($tf->is_mobile(),
   (is_libphonenumber() ? undef : 0),
   "$CLASS->new('$toll_free')->is_mobile()");
is($tf->is_fixed_line(),
   (is_libphonenumber() ? undef : 1),
   "$CLASS->new('$toll_free')->is_fixed_line()");
is($tf->is_geographic(), 0, "$CLASS->new('$toll_free')->is_geographic()");
is($tf->is_tollfree(), 1, "$CLASS->new('$toll_free')->is_tollfree()");

my $special_rate = '+1 (900) 623 2282';
my $sr = $CLASS->new($special_rate);
isa_ok $sr, is_libphonenumber() ? 'Number::Phone::StubCountry::US'
                                : 'Number::Phone::NANP';
is($sr->is_specialrate(), 1, "$CLASS->new('$special_rate')->is_specialrate()");

my $bb_special_rate = '+1 (246) 417 1234';
my $bbsr = $CLASS->new($bb_special_rate);
isa_ok $bbsr, is_libphonenumber() ? 'Number::Phone::StubCountry::BB'
                                  : 'Number::Phone::NANP::BB';
is($bbsr->is_specialrate(), 1, "$CLASS->new('$bb_special_rate')->is_specialrate()");

my $personal = '+1 (500) 623 2282';
my $pn = $CLASS->new($personal);
isa_ok $pn, is_libphonenumber() ? 'Number::Phone::StubCountry::US'
                                : 'Number::Phone::NANP';
is($pn->is_personal(), 1, "$CLASS->new('$personal')->is_personal()");

my $ca_numb = '+16135637242';
my $ca = $CLASS->new($ca_numb);
is($ca->is_tollfree(), 0, "$CLASS->new('$ca_numb')->is_tollfree()");
is($ca->is_specialrate(), 0, "$CLASS->new('$ca_numb')->is_specialrate()");
is($ca->is_personal(), 0, "$CLASS->new('$ca_numb')->is_personal()");
isa_ok $ca, is_libphonenumber() ? 'Number::Phone::StubCountry::CA'
                                : 'Number::Phone::NANP::CA';
is($ca->country_code(), 1, "$CLASS->new('$ca_numb')->country_code()");
is($ca->country(), 'CA', "$CLASS->new('$ca_numb')->country()");
is($ca->areaname(), 'Ottawa, ON', "$CLASS->new('$ca_numb')->areaname()");
is($ca->format(), '+1 613 563 7242', "$CLASS->new('$ca_numb')->format()");
# don't know, because CA's fixed/mobile regexes have overlaps so we define
# them as broken
is($ca->is_mobile(), undef, "$CLASS->new('$ca_numb')->is_mobile()");
is($ca->is_fixed_line(), undef, "$CLASS->new('$ca_numb')->is_fixed_line()");
is($ca->is_geographic(), 1, "$CLASS->new('$ca_numb')->is_geographic()");

my $jm_numb = '+18765013333';
my $jm = $CLASS->new($jm_numb);
isa_ok $jm, is_libphonenumber() ? 'Number::Phone::StubCountry::JM'
                                      : 'Number::Phone::NANP::JM';
is($jm->country_code(), 1, "$CLASS->new('$jm_numb')->country_code()");
is($jm->country(), 'JM', "$CLASS->new('$jm_numb')->country()");
is($jm->areaname(), undef, "$CLASS->new('$jm_numb')->areaname()");
is($jm->format(), '+1 876 501 3333', "$CLASS->new('$jm_numb')->format()");
is($jm->is_geographic(), 1,"$CLASS->new('$jm_numb')->is_geographic()");
is($jm->is_valid(), 1,"$CLASS->new('$jm_numb')->is_valid()");

# TT (Trinidad and Tobago) has good fixed line/mobile regexes ...
my $tt_fixed_numb = '+18682013333';
my $tt_fixed = $CLASS->new($tt_fixed_numb);
isa_ok $tt_fixed, is_libphonenumber() ? 'Number::Phone::StubCountry::TT'
                                       : 'Number::Phone::NANP::TT';
is($tt_fixed->country_code(), 1, "$CLASS->new('$tt_fixed_numb')->country_code()");
is($tt_fixed->country(), 'TT', "$CLASS->new('$tt_fixed_numb')->country()");
is($tt_fixed->areaname(), undef, "$CLASS->new('$tt_fixed_numb')->areaname()");
is($tt_fixed->format(), '+1 868 201 3333', "$CLASS->new('$tt_fixed_numb')->format()");
is($tt_fixed->is_mobile(), 0, "$CLASS->new('$tt_fixed_numb')->is_mobile()");
is($tt_fixed->is_fixed_line(), 1, "$CLASS->new('$tt_fixed_numb')->is_fixed_line()");
is($tt_fixed->is_geographic(), 1,"$CLASS->new('$tt_fixed_numb')->is_geographic()");
is($tt_fixed->is_valid(), 1,"$CLASS->new('$tt_fixed_numb')->is_valid()");

my $tt_mobile_numb = '+18682663333';
my $tt_mobile = $CLASS->new($tt_mobile_numb);
isa_ok $tt_mobile, is_libphonenumber() ? 'Number::Phone::StubCountry::TT'
                                      : 'Number::Phone::NANP::TT';
is($tt_mobile->country_code(), 1, "$CLASS->new('$tt_mobile_numb')->country_code()");
is($tt_mobile->country(), 'TT', "$CLASS->new('$tt_mobile_numb')->country()");
is($tt_mobile->areaname(), undef, "$CLASS->new('$tt_mobile_numb')->areaname()");
is($tt_mobile->format(), '+1 868 266 3333', "$CLASS->new('$tt_mobile_numb')->format()");
is($tt_mobile->is_mobile(), 1, "$CLASS->new('$tt_mobile_numb')->is_mobile()");
is($tt_mobile->is_fixed_line(), 0, "$CLASS->new('$tt_mobile_numb')->is_fixed_line()");
# in libphonenumber-land, fixed_line means geographic. N::P::NANP is a bit
# smarter and knows that mobiles are geographic in the NANP.
is($tt_mobile->is_geographic(),
   (is_libphonenumber() ? 0 : 1),
   "$CLASS->new('$tt_mobile_numb')->is_geographic()");

note("operator");
skip_if_libphonenumber("Stubs don't support operator", 1, sub {
    is($CLASS->new('+1 416 392 2489')->operator(), 'Bell Canada', "Canada");

    is($CLASS->new('+1 216 208 0000')->operator(), 'ONVOY, LLC - OH',
        "Unicode en-dash in some US data converted to hyphen");

    my @codes_seen = ();
    foreach my $tuple (
        ['+1 242 225 0000' => 'BARTELCO (BA)'],
        ['+1 246 223 0000' => 'ACE COMMUNICATIONS INC.'],
        ['+1 264 222 0000' => 'CABLE & WIRELESS (AI)'],
        ['+1 268 324 0000' => 'CABLE & WIRELESS (AN)'],
        ['+1 284 229 0000' => 'CABLE & WIRELESS (BV)'],
        ['+1 340 774 5666' => 'VIRGIN ISLANDS TEL. CORP. DBA INNOVATIVE TELEPHONE'],
        ['+1 345 222 0000' => 'CABLE & WIRELESS (CQ)'],
        ['+1 441 222 0000' => 'BERMUDA CABLEVISION LIMITED - BM'],
        ['+1 473 230 0000' => 'COLUMBUS COMMUNICATIONS (GRENADA) LIMITED'],
        ['+1 649 231 0000' => 'CABLE & WIRELESS (TC)'],
        # No data yet.
        # checked on 2023-12-10
        # next check due 2024-12-01 (annually) until there's data
        # at https://localcallingguide.com/xmlprefix.php?npa=658&blocks=1
        # ['+1 658 ??? 0000' => '???'],
        ['+1 664 349 0000' => 'CABLE & WIRELESS (RT)'],
        ['+1 670 233 0000' => 'MICRONESIAN TELECOMMUNICATIONS CORPORATION'],
        ['+1 671 472 7679' => 'TELEGUAM HOLDINGS, LLC'],
        ['+1 684 248 0000' => 'AST TELECOM, LLC'],
        ['+1 721 547 0000' => 'ST. MAARTEN TELEPHONE COMPANY, NV'],
        ['+1 758 234 0000' => 'CABLE & WIRELESS (SA)'],
        ['+1 767 315 0000' => 'DIGICEL GRENADA LIMITED'],
        ['+1 784 266 0000' => 'CABLE & WIRELESS (ZF)'],
        ['+1 787 200 0000' => 'LIBERTY COMMUNICATIONS OF PUERTO RICO LLC'],
        ['+1 809 202 0000' => 'ECONOMITEL, C. POR A. - DR'],
        ['+1 829 201 0000' => 'CODETEL (DR)'],
        ['+1 849 201 0000' => 'CODETEL (DR)'],
        ['+1 868 215 0000' => 'COLUMBUS COMMUNICATIONS TRINIDAD LIMITED'],
        ['+1 869 212 0000' => 'ST. KITTS NEVIS TELEC (NI)'],
        ['+1 876 202 0000' => 'JAMAICA TEL. CO. (JM)'],
        ['+1 939 201 0000' => 'LIBERTY MOBILE PUERTO RICO INC.'],
    ) {
        my($number, $op) = @{$tuple};
        push @codes_seen, substr($number, 3, 3);
        is($CLASS->new($number)->operator(), $op, "$number has the right operator");
    }
    is_deeply(
        \@codes_seen,
        [grep { $_ != 658 } Number::Phone::Country::_non_US_CA_area_codes()],
        "Oh good, the database contains data for all the non-US/CA area codes (except 658, for which no data are yet available)"
    );

    # checked on 2023-12-10 that these are consolidated ten-thousand blocks
    # next check due 2024-12-01 (annually)
    # https://localcallingguide.com/xmlprefix.php?npa=630&blocks=1
    is($CLASS->new('+1 630 847 0000')->operator(), 'YMAX COMMUNICATIONS CORP. - IL', 'USA, thousands blocks all for same operator, so consolidated into one to save space in database');
    # checked on 2022-12-10
    # next check due 2024-12-01 (annually)
    # https://localcallingguide.com/xmlprefix.php?npa=242&blocks=1
    is($CLASS->new('+1 242 367 0000')->operator(), 'BARTELCO (BA)', 'Bahamas, thousands blocks all for same operator, so consolidated into one to save space in database');

    foreach my $number(
        [ 'USA',     '+1 512 373 0000', 'METROPCS, INC.' ],
        [ 'USA',     '+1 512 373 1000', undef ],
        [ 'USA',     '+1 512 373 2000', 'METROPCS, INC.', ],
        [ 'USA',     '+1 512 373 3000', 'TIME WARNER CBLE INFO SVC (TX) DBA TIME WARNER CBL', ],
        [ 'USA',     '+1 512 373 4000', undef ],
        [ 'USA',     '+1 512 373 5000', 'METROPCS, INC.' ],
        [ 'USA',     '+1 512 373 6000', 'METROPCS, INC.' ],
        [ 'USA',     '+1 512 373 7000', undef ],
        [ 'USA',     '+1 512 373 8000', 'TIME WARNER CBLE INFO SVC (TX) DBA TIME WARNER CBL' ],
        [ 'USA',     '+1 512 373 9000', 'METROPCS, INC.' ]
    ) {
        is(
            $CLASS->new($number->[1])->operator(),
            $number->[2],
            $number->[0].', thousand block, '.$number->[1].', '.
                (defined($number->[2]) ? 'allocated' : 'unallocated')
        );
    }
});

note("is_government");
skip_if_libphonenumber("Stubs don't support is_government", 1, sub {
    is($CLASS->new('+17106274387')->is_government(), 1, "710 is the Feds man");
    is($CLASS->new('+15135737912')->is_government(), 0, "We're not supposed to know that Macy's is a front for the Feds");
});

note("is_drama");
skip_if_libphonenumber("Stubs don't support is_drama", 2, sub {
    is($CLASS->new('+12125552368')->is_drama(), 0, "Ghostbusters isn't is_drama (last four digits too high)");
    is($CLASS->new('+12125550001')->is_drama(), 0, "555-0001 isn't is_drama (last four digits too low)");
    is($CLASS->new('+12125550123')->is_drama(), 1, "555-0123 is is_drama (last four digits just right, like porridge)");
    is($CLASS->new('+12024566213')->is_drama(), 0, "The president doesn't have an is_drama number");
});

note("dodgy numbers");

ok(!defined($CLASS->new('+1 613 563 72423')), "too long");
ok(!defined($CLASS->new('+1 613 563 724')),   "too short");
ok(!defined($CLASS->new('+1 113 563 7242')),  "A  must not be 1");
ok(!defined($CLASS->new('+1 613 163 7242')),  "D  must not be 1");
ok(!defined($CLASS->new('+1 611 563 7242')),  "BC must not be 11");
#
# checked on 2024-03-05
# next check due 2025-01-01 (annually)
# https://en.wikipedia.org/wiki/List_of_North_American_Numbering_Plan_area_codes#Summary_table
ok(!defined($CLASS->new('+1 290 563 7242')),  "B  must not be 9");
ok(!defined($CLASS->new('+1 373 563 7242')),  "AB must not be 37");
ok(!defined($CLASS->new('+1 963 563 7242')),  "AB must not be 96");

# the following work with a valid area code so at this point we will be down in a stub's
# constructor before we reject the number, so we need to check this for all countries
my %areas = %Number::Phone::Country::NANP_areas;
die("Yargh, where's \%Number::Phone::Country::NANP_areas") unless(%areas);
foreach my $tuple (
    map { (my $code = $areas{$_}) =~ s/\D.*//; [ $code, $_ ] } sort keys %areas
) {
    ok(!defined($CLASS->new("+1 ".$tuple->[0]." 163 7242")),  "D digit must be 2-9 (".join(': ', $tuple->[1], $tuple->[0]).")");
}

1;
