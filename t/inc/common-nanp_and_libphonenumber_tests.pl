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

my $ca_numb = '+16135637242';
my $ca = $CLASS->new($ca_numb);
isa_ok $ca, is_libphonenumber() ? 'Number::Phone::StubCountry::CA'
                                : 'Number::Phone::NANP::CA';
is($ca->country_code(), 1, "$CLASS->new('$ca_numb')->country_code()");
is($ca->country(), 'CA', "$CLASS->new('$ca_numb')->country()");
is($ca->areaname(), 'Ottawa, ON', "$CLASS->new('$ca_numb')->areaname()");
is($ca->format(), '+1 613 563 7242', "$CLASS->new('$ca_numb')->format()");

1;
