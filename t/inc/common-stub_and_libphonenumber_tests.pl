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

note("Common tests for Number::Phone::StubCountry::* and Number::Phone::Lib");

my $inmarsat870 = $CLASS->new("+870123456");
ok(1, "didn't die  when trying to load non-existent stub for Inmarsat +870");
is($inmarsat870->country_code(), '870', 'Inmarsat number has right country_code');
is($inmarsat870->country(), 'Inmarsat', "$CLASS->new('+870123456')->country()");
is($inmarsat870->format(), '+870 123456', "$CLASS->new('+870123456')->format()");
is($inmarsat870->is_valid(), undef, "$CLASS->new('+870123456')->is_valid()");
is($inmarsat870->is_mobile(), undef, "$CLASS->new('+870123456')->is_mobile()");
is($inmarsat870->is_geographic(), undef, "$CLASS->new('+870123456')->is_geographic()");
is($inmarsat870->is_fixed_line(), undef, "$CLASS->new('+870123456')->is_fixed_line()");

my $inmarsat871 = $CLASS->new("+8719744591");
ok(1, "didn't die  when trying to load non-existent stub for Inmarsat +871");
is($inmarsat871->country_code(), '871', 'Inmarsat number has right country_code');
is($inmarsat871->country(), 'Inmarsat', "$CLASS->new('+8719744591')->country()");
is($inmarsat871->format(), '+871 9744591', "$CLASS->new('+8719744591')->format()");
is($inmarsat871->is_valid(), undef, "$CLASS->new('+8719744591')->is_valid()");
is($inmarsat871->is_mobile(), undef, "$CLASS->new('+8719744591')->is_mobile()");
is($inmarsat871->is_geographic(), undef, "$CLASS->new('+8719744591')->is_geographic()");
is($inmarsat871->is_fixed_line(), undef, "$CLASS->new('+8719744591')->is_fixed_line()");

my $fo = $CLASS->new('+298 303030'); # Faroes Telecom
is($fo->country_code(), 298, "$CLASS->new('+298 303030')->country_code()");
is($fo->country(), 'FO', "$CLASS->new('+298 303030')->country()");

my $ru = $CLASS->new('+7 499 999 82 83'); # Rostelecom
is($ru->country_code(), 7, "$CLASS->new('+7 499 999 82 83')->country_code()");
is($ru->country(), 'RU', "$CLASS->new('+7 499 999 82 83')->country()");

# good news comrade (courtesy of translate.google)
ok($CLASS->new('+79607001122')->is_mobile(), "Хороший товарищ новость! is_mobile works for Russia!");

my $jp = $CLASS->new('+81 744 54 4343');
isa_ok($jp, 'Number::Phone::StubCountry::JP', "stub loaded when N::P::CC exists but isn't a proper subclass");
is($jp->areaname(), 'Yamatotakada, Nara', "area names don't have spurious \\s");

# https://github.com/DrHyde/perl-modules-Number-Phone/issues/7
my $de = $CLASS->new('+493308250565');
is($de->format(), "+49 33082 50565", "formatted Menz Kr Oberhavel number correctly");

# libphonenumber doesn't do areacodes, enable this test if we ever fake it up in stubs
# skip_if_libphonenumber(
#   "libphonenumber doesn't support areacodes", 1,
#   sub { is($de->areacode(), 33082, "extracted area code for Menz Kr Oberhavel correctly"); }
# );

$de = $CLASS->new('+493022730027'); # Bundestag
is($de->format(), "+49 30 22730027", "formatted Berlin number correctly");
is($de->areaname(), "Berlin", "got area name correctly");

1;
