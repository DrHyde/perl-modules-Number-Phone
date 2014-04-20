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

my $ca_numb = '+16135637242';
my $ca = $CLASS->new($ca_numb);
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

my $jm_fixed_numb = '+18765013333';
my $jm_fixed = $CLASS->new($jm_fixed_numb);
isa_ok $jm_fixed, is_libphonenumber() ? 'Number::Phone::StubCountry::JM'
                                      : 'Number::Phone::NANP::JM';
is($jm_fixed->country_code(), 1, "$CLASS->new('$jm_fixed_numb')->country_code()");
is($jm_fixed->country(), 'JM', "$CLASS->new('$jm_fixed_numb')->country()");
is($jm_fixed->areaname(), undef, "$CLASS->new('$jm_fixed_numb')->areaname()");
is($jm_fixed->format(), '+1 876 501 3333', "$CLASS->new('$jm_fixed_numb')->format()");
is($jm_fixed->is_mobile(), 0, "$CLASS->new('$jm_fixed_numb')->is_mobile()");
is($jm_fixed->is_fixed_line(), 1, "$CLASS->new('$jm_fixed_numb')->is_fixed_line()");
is($jm_fixed->is_geographic(), 1,"$CLASS->new('$jm_fixed_numb')->is_geographic()");

my $jm_mobile_numb = '+18762113333';
my $jm_mobile = $CLASS->new($jm_mobile_numb);
isa_ok $jm_mobile, is_libphonenumber() ? 'Number::Phone::StubCountry::JM'
                                      : 'Number::Phone::NANP::JM';
is($jm_mobile->country_code(), 1, "$CLASS->new('$jm_mobile_numb')->country_code()");
is($jm_mobile->country(), 'JM', "$CLASS->new('$jm_mobile_numb')->country()");
is($jm_mobile->areaname(), undef, "$CLASS->new('$jm_mobile_numb')->areaname()");
is($jm_mobile->format(), '+1 876 211 3333', "$CLASS->new('$jm_mobile_numb')->format()");
is($jm_mobile->is_mobile(), 1, "$CLASS->new('$jm_mobile_numb')->is_mobile()");
is($jm_mobile->is_fixed_line(), 0, "$CLASS->new('$jm_mobile_numb')->is_fixed_line()");
# in libphonenumber-land, fixed_line means geographic. N::P::NANP is a bit
# smarter and knows that mobiles are geographic in the NANP.
is($jm_mobile->is_geographic(),
   (is_libphonenumber() ? 0 : 1),
   "$CLASS->new('$jm_mobile_numb')->is_geographic()");

1;
