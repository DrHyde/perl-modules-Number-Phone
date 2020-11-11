#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

use Number::Phone::Lib; # need to force it to use stubs in case N::P::AT exists
use Test::More;

# Mobile Number
ok(Number::Phone::Lib->new("+43677111111111")->is_mobile(), "is +43677 mobile");

# Land line in Vienna
ok(!Number::Phone::Lib->new("+431211452358")->is_mobile(), "is +431 landline mobile");
ok(Number::Phone::Lib->new("+431211452358")->is_fixed_line(), "is +431 landline fixed line");
ok(!Number::Phone::Lib->new("+431211452358")->is_tollfree(), "is +431 landline tollfree");
ok(Number::Phone::Lib->new("+431211452358")->is_geographic(), "is +431 landline geographic");
ok(!Number::Phone::Lib->new("+431211452358")->is_specialrate(), "is +431 landline specialrate");

# Land line for Innsbruck
ok(Number::Phone::Lib->new("+4351253600")->is_fixed_line(), "is +43512 landline fixed line");
ok(Number::Phone::Lib->new("+4351253600")->is_geographic(), "is +43512 landline geographic");
is(Number::Phone::Lib->new("+4351253600")->format(), "+43 512 53600", "is formatting for +43512 correct?");
is(Number::Phone::Lib->new("+4351253600")->areaname(), "Innsbruck", "+43512 has right area name");

# Non-Geo line
ok(!Number::Phone::Lib->new("+43810123456")->is_fixed_line(), "is +4350 a fixed line");
ok(!Number::Phone::Lib->new("+43810123456")->is_tollfree(), "is +4350 tollfree");
ok(Number::Phone::Lib->new("+43810123456")->is_specialrate(), "is +4350 specialrate");
ok(!Number::Phone::Lib->new("+43810123456")->is_geographic(), "is +4350 geographic");

# Non-Geo Convergence Number
ok(!Number::Phone::Lib->new("+43780392257")->is_fixed_line(), "is +43780 a fixed line");
ok(!Number::Phone::Lib->new("+43780392257")->is_geographic(), "is +43780 geographic");
ok(Number::Phone::Lib->new("+43780392257")->is_ipphone(), "is +43780 IP-Phone");
ok(!Number::Phone::Lib->new("+43780392257")->is_specialrate(), "is +43780 specialrate");

# Non-Geo Toll-Free Numbers
ok(!Number::Phone::Lib->new("+43800221800")->is_fixed_line(), "is +43800 a fixed line");
ok(!Number::Phone::Lib->new("+43800221800")->is_geographic(), "is +43800 geographic");
ok(Number::Phone::Lib->new("+43800221800")->is_tollfree(), "is +43800 tollfree");
ok(!Number::Phone::Lib->new("+43800221800")->is_specialrate(), "is +43800 specialrate");

# Non-Geo Number Regulated Charge 0.10 EUR / min
ok(!Number::Phone::Lib->new("+43810726786")->is_fixed_line(), "is +43810 a fixed line");
ok(!Number::Phone::Lib->new("+43810726786")->is_geographic(), "is +43810 geographic");
ok(!Number::Phone::Lib->new("+43810726786")->is_tollfree(), "is +43810 tollfree");
ok(Number::Phone::Lib->new("+43810726786")->is_specialrate(), "is +43810 specialrate");

# Non-Geo Number Regulated Charge 0.20 EUR / min
ok(!Number::Phone::Lib->new("+43820122122")->is_fixed_line(), "is +43820 a fixed line");
ok(!Number::Phone::Lib->new("+43820122122")->is_geographic(), "is +43820 geographic");
ok(!Number::Phone::Lib->new("+43820122122")->is_tollfree(), "is +43820 tollfree");
ok(Number::Phone::Lib->new("+43820122122")->is_specialrate(), "is +43820 specialrate");

# Non-Geo Number Regulated Charge 0.20 EUR / event
ok(!Number::Phone::Lib->new("+43821112300")->is_fixed_line(), "is +43821 a fixed line");
ok(!Number::Phone::Lib->new("+43821112300")->is_geographic(), "is +43821 geographic");
ok(!Number::Phone::Lib->new("+43821112300")->is_tollfree(), "is +43821 tollfree");
ok(Number::Phone::Lib->new("+43821112300")->is_specialrate(), "is +43821 specialrate");

# Non-Geo Number Regulated Charge
ok(!Number::Phone::Lib->new("+4382820200")->is_fixed_line(), "is +43828 a fixed line");
ok(!Number::Phone::Lib->new("+4382820200")->is_geographic(), "is +43828 geographic");
ok(!Number::Phone::Lib->new("+4382820200")->is_tollfree(), "is +43828 tollfree");
ok(Number::Phone::Lib->new("+4382820200")->is_specialrate(), "is +43828 specialrate");
    
ok(!defined(Number::Phone::Lib->new("+43820 20200")),     "+43 820 must be followed by at least six digits");
ok( Number::Phone::Lib->new("+43820 220200")->is_valid(), "+43 820 followed by six digits is OK");
ok(!defined(Number::Phone::Lib->new("+43821 20200")),     "+43 821 must be followed by at least six digits");
ok( Number::Phone::Lib->new("+43821 220200")->is_valid(), "+43 821 followed by six digits is OK");
    
ok(Number::Phone::Lib->new("+43828 20200")->is_valid(),  "+43 828 can be followed by five digits");
ok(Number::Phone::Lib->new("+43828 220200")->is_valid(), "+43 828 can be followed by more than five digits");

# Non-Geo Unregulated Toll Numbers
ok(!Number::Phone::Lib->new("+43900030800")->is_fixed_line(), "is +43900 a fixed line");
ok(!Number::Phone::Lib->new("+43900030800")->is_geographic(), "is +43900 geographic");
ok(!Number::Phone::Lib->new("+43900030800")->is_tollfree(), "is +43900 tollfree");
ok(Number::Phone::Lib->new("+43900030800")->is_specialrate(), "is +43900 specialrate");

ok(!Number::Phone::Lib->new("+43901601600")->is_fixed_line(), "is +43901 a fixed line");
ok(!Number::Phone::Lib->new("+43901601600")->is_geographic(), "is +43901 geographic");
ok(!Number::Phone::Lib->new("+43901601600")->is_tollfree(), "is +43901 tollfree");
ok(Number::Phone::Lib->new("+43901601600")->is_specialrate(), "is +43901 specialrate");

ok(!Number::Phone::Lib->new("+43930060261")->is_fixed_line(), "is +43930 a fixed line");
ok(!Number::Phone::Lib->new("+43930060261")->is_geographic(), "is +43930 geographic");
ok(!Number::Phone::Lib->new("+43930060261")->is_tollfree(), "is +43930 tollfree");
ok(Number::Phone::Lib->new("+43930060261")->is_specialrate(), "is +43930 specialrate");

ok(!Number::Phone::Lib->new("+43931906100")->is_fixed_line(), "is +43931 a fixed line");
ok(!Number::Phone::Lib->new("+43931906100")->is_geographic(), "is +43931 geographic");
ok(!Number::Phone::Lib->new("+43931906100")->is_tollfree(), "is +43931 tollfree");
ok(Number::Phone::Lib->new("+43931906100")->is_specialrate(), "is +43931 specialrate");

ok(!Number::Phone::Lib->new("+43939609900")->is_fixed_line(), "is +43939 a fixed line");
ok(!Number::Phone::Lib->new("+43939609900")->is_geographic(), "is +43939 geographic");
ok(!Number::Phone::Lib->new("+43939609900")->is_tollfree(), "is +43939 tollfree");
ok(Number::Phone::Lib->new("+43939609900")->is_specialrate(), "is +43939 specialrate");

done_testing();
