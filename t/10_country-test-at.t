#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

use Number::Phone;
use Test::More;

END { done_testing(); }

# Mobile Number
ok(Number::Phone->is_mobile("+43677111111111"), "is +43677 mobile");

# Land line in Vienna
ok(!Number::Phone->is_mobile("+431211452358"), "is +431 landline mobile");
ok(Number::Phone->is_fixed_line("+431211452358"), "is +431 landline fixed line");
ok(!Number::Phone->is_tollfree("+431211452358"), "is +431 landline tollfree");
ok(Number::Phone->is_geographic("+431211452358"), "is +431 landline geographic");
ok(!Number::Phone->is_specialrate("+431211452358"), "is +431 landline specialrate");

# Land line for Innsbruck
ok(Number::Phone->is_fixed_line("+4351253600"), "is +43512 landline fixed line");
ok(Number::Phone->is_geographic("+4351253600"), "is +43512 landline geographic");
is(Number::Phone->format("+4351253600"), "+43 512 53600", "is formatting for +43512 correct?");

# Non-Geo line
ok(!Number::Phone->is_fixed_line("+435050525"), "is +4350 a fixed line");
ok(!Number::Phone->is_tollfree("+435050525"), "is +4350 tollfree");
ok(Number::Phone->is_specialrate("+435050525"), "is +4350 specialrate");
ok(!Number::Phone->is_geographic("+435050525"), "is +4350 geographic");

# Non-Geo location-independant number
ok(!Number::Phone->is_fixed_line("+43720000121"), "is +43720 a fixed line");
ok(!Number::Phone->is_geographic("+43720000121"), "is +43720 geographic");
ok(!Number::Phone->is_ipphone("+43720000121"), "is +43720 IP-Phone");
ok(Number::Phone->is_specialrate("+43720000121"), "is +43720 specialrate");

# Non-Geo Convergence Number
ok(!Number::Phone->is_fixed_line("+43780392257"), "is +43780 a fixed line");
ok(!Number::Phone->is_geographic("+43780392257"), "is +43780 geographic");
ok(Number::Phone->is_ipphone("+43780392257"), "is +43780 IP-Phone");
ok(!Number::Phone->is_specialrate("+43780392257"), "is +43780 specialrate");

# Non-Geo Toll-Free Numbers
ok(!Number::Phone->is_fixed_line("+43800221800"), "is +43800 a fixed line");
ok(!Number::Phone->is_geographic("+43800221800"), "is +43800 geographic");
ok(Number::Phone->is_tollfree("+43800221800"), "is +43800 tollfree");
ok(!Number::Phone->is_specialrate("+43800221800"), "is +43800 specialrate");

# Non-Geo Number Regulated Charge 0.10 EUR / min
ok(!Number::Phone->is_fixed_line("+43810726786"), "is +43810 a fixed line");
ok(!Number::Phone->is_geographic("+43810726786"), "is +43810 geographic");
ok(!Number::Phone->is_tollfree("+43810726786"), "is +43810 tollfree");
ok(Number::Phone->is_specialrate("+43810726786"), "is +43810 specialrate");

# Non-Geo Number Regulated Charge 0.20 EUR / min
ok(!Number::Phone->is_fixed_line("+43820122122"), "is +43820 a fixed line");
ok(!Number::Phone->is_geographic("+43820122122"), "is +43820 geographic");
ok(!Number::Phone->is_tollfree("+43820122122"), "is +43820 tollfree");
ok(Number::Phone->is_specialrate("+43820122122"), "is +43820 specialrate");

# Non-Geo Number Regulated Charge 0.20 EUR / event
ok(!Number::Phone->is_fixed_line("+43821112300"), "is +43821 a fixed line");
ok(!Number::Phone->is_geographic("+43821112300"), "is +43821 geographic");
ok(!Number::Phone->is_tollfree("+43821112300"), "is +43821 tollfree");
ok(Number::Phone->is_specialrate("+43821112300"), "is +43821 specialrate");

# Non-Geo Number Regulated Charge
SKIP: {
    skip "Waiting for https://github.com/googlei18n/libphonenumber/issues/841 to be fixed",
         10
         unless(Number::Phone->is_valid("+43828 20200"));

    diag("You can get rid of the SKIP now");

    ok(!Number::Phone->is_fixed_line("+4382820200"), "is +43828 a fixed line");
    ok(!Number::Phone->is_geographic("+4382820200"), "is +43828 geographic");
    ok(!Number::Phone->is_tollfree("+4382820200"), "is +43828 tollfree");
    ok(Number::Phone->is_specialrate("+4382820200"), "is +43828 specialrate");
    
    ok(!Number::Phone->is_valid("+43820 20200"),  "+43 820 must be followed by at least six digits");
    ok( Number::Phone->is_valid("+43820 220200"), "+43 820 followed by six digits is OK");
    ok(!Number::Phone->is_valid("+43821 20200"),  "+43 821 must be followed by at least six digits");
    ok( Number::Phone->is_valid("+43821 220200"), "+43 821 followed by six digits is OK");
    
    ok(Number::Phone->is_valid("+43828 20200"),  "+43 828 can be followed by five digits");
    ok(Number::Phone->is_valid("+43828 220200"), "+43 828 can be followed by more than five digits");
}

# Non-Geo Unregulated Toll Numbers
ok(!Number::Phone->is_fixed_line("+43900030800"), "is +43900 a fixed line");
ok(!Number::Phone->is_geographic("+43900030800"), "is +43900 geographic");
ok(!Number::Phone->is_tollfree("+43900030800"), "is +43900 tollfree");
ok(Number::Phone->is_specialrate("+43900030800"), "is +43900 specialrate");

ok(!Number::Phone->is_fixed_line("+43901601600"), "is +43901 a fixed line");
ok(!Number::Phone->is_geographic("+43901601600"), "is +43901 geographic");
ok(!Number::Phone->is_tollfree("+43901601600"), "is +43901 tollfree");
ok(Number::Phone->is_specialrate("+43901601600"), "is +43901 specialrate");

ok(!Number::Phone->is_fixed_line("+43930060261"), "is +43930 a fixed line");
ok(!Number::Phone->is_geographic("+43930060261"), "is +43930 geographic");
ok(!Number::Phone->is_tollfree("+43930060261"), "is +43930 tollfree");
ok(Number::Phone->is_specialrate("+43930060261"), "is +43930 specialrate");

ok(!Number::Phone->is_fixed_line("+43931906100"), "is +43931 a fixed line");
ok(!Number::Phone->is_geographic("+43931906100"), "is +43931 geographic");
ok(!Number::Phone->is_tollfree("+43931906100"), "is +43931 tollfree");
ok(Number::Phone->is_specialrate("+43931906100"), "is +43931 specialrate");

ok(!Number::Phone->is_fixed_line("+43939609900"), "is +43939 a fixed line");
ok(!Number::Phone->is_geographic("+43939609900"), "is +43939 geographic");
ok(!Number::Phone->is_tollfree("+43939609900"), "is +43939 tollfree");
ok(Number::Phone->is_specialrate("+43939609900"), "is +43939 specialrate");

