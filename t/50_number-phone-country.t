#!/usr/bin/perl -w

use Test::More tests => 48;

use Number::Phone::Country;

# NANP formats
ok(phone2country(  "219-555-0199") eq "US",   "NANP: xxx-xxx-xxxx format");
ok(phone2country("(219) 555-0199") eq "US",   "NANP: (xxx) xxx-xxxx format");
ok(phone2country("1 219 555 0199") eq "US",   "NANP: 1 xxx xxx xxxx format");
ok(phone2country("1-219-555-0199") eq "US",   "NANP: 1-xxx-xxx-xxxx format");
ok(phone2country("1 219-555-0199") eq "US",   "NANP: 1 xxx-xxx-xxxx format");
ok(phone2country(  "+12195550199") eq "US",   "NANP: +1xxxxxxxxxx format");

ok(phone2country("1 800 555 0199") eq "NANP", "NANP: toll-free number IDed as generic NANP number");

# NANP, in area code NXX order
# FIXME make sure all the little countries are covered!
# FIXME make sure all of CA and US codes are covered!
ok(phone2country("1 226 555 0199") eq "CA", "NANP: CA: 226");
ok(phone2country("1 438 555 0199") eq "CA", "NANP: CA: 438");
ok(phone2country("1 450 555 0199") eq "CA", "NANP: CA: 450");
ok(phone2country("1 519 555 0199") eq "CA", "NANP: CA: 519");
ok(phone2country("1 601 555 0199") eq "US", "NANP: US: 601");
ok(phone2country("1 684 555 0199") eq 'AS', "NANP: AS: 684");
ok(phone2country("1 706 555 0199") eq "US", "NANP: US: 706");
ok(phone2country("1 762 555 0199") eq "US", "NANP: US: 762");
ok(phone2country("1 769 555 0199") eq "US", "NANP: US: 769");
ok(phone2country("1 809 555 0199") eq "DO", "NANP: DO: 809");
ok(phone2country("1 829 555 0199") eq "DO", "NANP: DO: 829");


# Sometimes countries move around. Pesky things.
{ no warnings;
ok(phone2country('+6841234567') ne 'AS', "+684 *not* identified as AS"); 
}

# FIXME - test all countries, in ASCIIbetical IDD/area order
ok(phone2country("+269 20 8827") eq "YT",      "+269 20   Mayotte (mobile)");
ok(phone2country("+269 60 8827") eq "YT",      "+269 60   Mayotte (land)");
ok(phone2country("+269 331 079") eq "KM",      "+269 331  Comores (mobile)");
ok(phone2country("+269 731 079") eq "KM",      "+269 731  Comores (land)");
ok(phone2country('+34123412345') eq 'ES',      "+34       Spain");
ok(phone2country('+35012345') eq 'GI',         "+350      Gibraltar");
ok(phone2country("+351-21-8463452") eq "PT",   "+351      Portugal");
ok(phone2country('+3531234567') eq 'IE',       "+353      Ireland");
ok(phone2country('+379123') eq 'VA',           "+379      Vatican (using its own code)");
ok(phone2country("+381 11 311 2979") eq "RS",  "+381      Serbia");
ok(phone2country("+382 81 311 2979") eq "ME",  "+382      Montenegro");
ok(phone2country('+3961234567') eq 'IT',       "+39       Italy");
ok(phone2country('+44 1234567890') eq 'GB',    "+44       GB");
ok(phone2country("+51-1-2217244") eq "PE",     "+51       Peru");
ok(phone2country("+61 8 9162 6696") eq "CC",   "+61 89162 Cocos");
# ok(phone2country("+61 8 9162 7592") eq "CC", "+61 89162 Cocos");
ok(phone2country("+61 8 9164 8304") eq "CX",   "+61 89164 Christmas Island");
ok(phone2country("+672 10 6657") eq "AQ",      "+672 10   Davis station, Antarctica");
ok(phone2country("+672 3 22624") eq "NF",      "+672 3    Norfolk Island");
ok(phone2country("+681 722 014") eq "WF",      "+681      Wallis and Futuna");

# non-country codes
ok(phone2country("+3883-1-234") eq "ETNS",           "+388 3 ETNS");
ok(phone2country("+881 2 12345678") eq "Ellipso",    "+881 2 Ellipso");
ok(phone2country("+881 3 45678901") eq "Ellipso",    "+881 3 Ellipso");
ok(phone2country("+881 6 31110006") eq "Iridium",    "+881 6 Iridium");
ok(phone2country("+881 7 31110006") eq "Iridium",    "+881 7 Iridium");
ok(phone2country("+881 8 73022635") eq "Globalstar", "+881 8 Globalstar");
ok(phone2country("+881 9 73022635") eq "Globalstar", "+881 9 Globalstar");

# special cases
ok(phone2country('+3534812345678') eq 'GB', "+35348 IDed as GB, in Ireland's number-space");
ok(phone2country('+34956712345') eq 'GI', "+349567 IDed as Gibraltar, in Spain's number-space");
ok(phone2country('+3966982123') eq 'VA', "+3966982 IDed as Vatican, in Italy's number space");

# FIXME - add Kazakhstan/Russia weirdness
