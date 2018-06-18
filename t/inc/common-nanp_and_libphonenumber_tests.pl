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

note("is_government");
skip_if_libphonenumber("Stubs don't support is_government", 1, sub {
    is($CLASS->new('+17106274387')->is_government(), 1, "710 is the Feds man");
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
ok(!defined($CLASS->new('+1 113 563 7242')),  "A digit must be 2-9");
ok(!defined($CLASS->new('+1 373 563 7242')),  "AB must not be 37");
ok(!defined($CLASS->new('+1 963 563 7242')),  "AB must not be 96");
ok(!defined($CLASS->new('+1 611 563 7242')),  "BC must not be 11");

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
