#!/usr/bin/env perl
#
# test the prefix codes data.
#

use strict;

use lib 't/inc';
use nptestutils;

use Test::More;

use Number::Phone::Country qw(noexport);

while (<DATA>) {
    chomp;

    next if /^\s*#/;
    next if /^\s*$/;

    my ($country, $prefix, $idds, $ndd) = split /:/;
    my ($idd, @other_idds) = split /;/, $idds;

    $idd = undef unless length $idd;
    $ndd = undef unless length $ndd;

    is Number::Phone::Country::country_code($country), $prefix,
       "$country code";

    is Number::Phone::Country::idd_code($country), $idd,
       "$country idd prefix";

    my $idd_re = Number::Phone::Country::idd_regex($country);

    if (defined $idd) {
        like $idd, qr/ $idd_re \z /xms,
            "$country idd regex with preferred idd $idd";

        like $_, qr/ $idd_re \z /xms,
            "$country idd regex with other idd $_"
            for @other_idds;
    }
    else {
        is $idd_re, undef, "$country idd regex not available";
    }

    is Number::Phone::Country::ndd_code($country), $ndd,
       "$country ndd prefix";
}

done_testing();

__END__
# data format is:
# ISO code:CC:IDD:NDD
# ...where IDD is the preferred IDD (as returned by idd_code), followed by zero
# or more alternative IDDs separated by semi-colons.  The alternative IDDs
# lists are to test the idd regex, and are not complete.
AD:376:00:
AE:971:00:0
AF:93:00:0
AG:1:011:1
AI:1:011:1
AL:355:00:0
AM:374:00:0
BQ:599:00:
AO:244:00:
AQ:672:0011:
AR:54:00:0
AS:1:011:1
AT:43:00:0
AU:61:0011;0014;0015;0019:0
AW:297:00:
AZ:994:00:0
BA:387:00:0
BB:1:011:1
BD:880:00:0
BE:32:00:0
BF:226:00:
BG:359:00:0
BH:973:00:
BI:257:00:
BJ:229:00:
BM:1:011:1
BN:673:00:
BO:591:00:0
BR:55:0012;0014;0015;0021;0031;0041;0043:0
BS:1:011:1
BT:975:00:
BV:47:00:
BW:267:00:
BY:375:810:8
BZ:501:00:
CA:1:011:1
CC:61:0011:0
CD:243:00:0
CF:236:00:
CG:242:00:
CH:41:00:0
CI:225:00:
CK:682:00:
CL:56:00:
CM:237:00:
CN:86:00:0
CO:57:009;005;007:0
CR:506:00:
CU:53:119:0
CV:238:0:
CX:61:0011:0
CY:357:00:
CZ:420:00:
DE:49:00:0
DJ:253:00:
DK:45:00:
DM:1:011:1
DO:1:011:1
DZ:213:00:0
EC:593:00:0
EE:372:00:
EG:20:00:0
EH:212:00:0
ER:291:00:0
ES:34:00:
ET:251:00:0
FI:358:00:0
FJ:679:00:
FK:500:00:
FM:691:00:
FO:298:00:
FR:33:00:0
GA:241:00:
GB:44:00:0
UK:44:00:0
GD:1:011:1
GE:995:00:0
GF:594:00:0
GH:233:00:0
GI:350:00:
GL:299:00:
GM:220:00:
GN:224:00:
GP:590:00:0
GQ:240:00:
GR:30:00:
GS:500:00:
GT:502:00:
GU:1:011:1
GW:245:00:
GY:592:001:
HK:852:00;001;002:
HN:504:00:
HR:385:00:0
HT:509:00:
HU:36:00:06
ID:62:008;009:0
IE:353:00:0
IL:972:00;012;013;014:0
IN:91:00:0
IO:246:00:
IQ:964:00:0
IR:98:00:0
IS:354:00:
IT:39:00:
JM:1:011:1
JO:962:00:0
JP:81:010:0
KE:254:000:0
KG:996:00:0
KH:855:001;007:0
KI:686:00:0
KM:269:00:
KN:1:011:1
KP:850:00:0
KR:82:001;002;005;009:0
KW:965:00:
KY:1:011:1
KZ:7:810:8
LA:856:00:0
LB:961:00:0
LC:1:011:1
LI:423:00:0
LK:94:00:0
LR:231:00:0
LS:266:00:
LT:370:00:0
LU:352:00:
LV:371:00:
LY:218:00:0
MA:212:00:0
MC:377:00:0
MD:373:00:0
ME:382:00:0
MG:261:00:0
MH:692:011:1
MK:389:00:0
ML:223:00:
MM:95:00:0
MN:976:001:0
MO:853:00:
MP:1:011:1
MQ:596:00:0
MR:222:00:
MS:1:011:1
MT:356:00:
MU:230:020:
MV:960:00:
MW:265:00:0
MX:52:00:
MY:60:00:0
MZ:258:00:
NA:264:00:0
NC:687:00:
NE:227:00:
NF:672:00:
NG:234:009:0
NI:505:00:
NL:31:00:0
NO:47:00:
NP:977:00:0
NR:674:00:
NU:683:00:
NZ:64:00:0
OM:968:00:
PA:507:00:
PE:51:00;191200:0
PF:689:00:
PG:675:00:
PH:63:00:0
PK:92:00:0
PL:48:00:
PM:508:00:0
PR:1:011:1
PS:970:00:0
PT:351:00:
PW:680:011:
PY:595:00:0
QA:974:00:
RE:262:00:0
RO:40:00:0
RS:381:00:0
RU:7:810:8
RW:250:00:0
SA:966:00:0
SB:677:00:
SC:248:00:
SD:249:00:0
SE:46:00:0
SG:65:000;001;002;008:
SH:290:00:
SI:386:00:0
SJ:47:00:
SK:421:00:0
SL:232:00:0
SM:378:00:
SN:221:00:
SO:252:00:0
SR:597:00:
SS:211:00:0
ST:239:00:
SV:503:00:
SY:963:00:0
SZ:268:00:
TC:1:011:1
TD:235:00:
TF:596:00:0
TG:228:00:
TH:66:001:0
TJ:992:810:
TK:690:00:
TL:670:00:
TM:993:810:8
TN:216:00:
TO:676:00:
TR:90:00:0
TT:1:011:1
TV:688:00:
TW:886:002;005;006;007;009:0
TZ:255:000:0
UA:380:00:0
UG:256:000:0
US:1:011:1
UY:598:00:0
UZ:998:00:
VA:379:00:
VC:1:011:1
VE:58:00:0
VG:1:011:1
VI:1:011:1
VN:84:00:0
VU:678:00:
WF:681:00:
WS:685:0:
YE:967:00:0
YT:262:00:0
ZA:27:00:0
ZM:260:00:0
ZW:263:00:0
