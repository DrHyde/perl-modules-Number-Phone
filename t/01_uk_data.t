#!/usr/bin/perl -w

my $loaded;

use strict;

use Number::Phone::UK;

BEGIN { $| = 1; print "1..50\n"; }

my $test = 0;

$ENV{TESTINGKILLTHEWABBIT} = 1; # make sure we don't load detailed exchg data

my $number = Number::Phone->new('+44 142422 0000');
print 'not ' unless($number->country() eq 'UK');
print 'ok '.(++$test)." inherited country() method works\n";
print 'not ' unless($number->format() eq '+44 1424 220000');
print 'ok '.(++$test)." 4+6 number formatted OK\n";
$number = Number::Phone->new('+44 115822 0000');
print 'not ' unless($number->format() eq '+44 115 8220000');
print 'ok '.(++$test)." 3+7 number formatted OK\n";
$number = Number::Phone->new('+442 0 8771 2924');
print 'not ' unless($number->format() eq '+44 20 87712924');
print 'ok '.(++$test)." 2+8 number formatted OK\n";
print 'not ' unless($number->areacode() eq '20');
print 'ok '.(++$test)." 2+8 number has correct area code\n";
print 'not ' unless($number->subscriber() eq '87712924');
print 'ok '.(++$test)." 2+8 number has correct subscriber number\n";
foreach my $method (qw(is_allocated is_fixed_line is_geographic is_valid)) {
    print 'not ' unless($number->$method());
    print 'ok '.(++$test)." $method works for a London number\n";
}
foreach my $method (qw(is_in_use is_mobile is_pager is_ipphone is_isdn is_tollfree is_specialrate is_adult is_personal is_corporate is_government is_international is_network_service is_ipphone)) {
    print 'not ' if($number->$method());
    print 'ok '.(++$test)." $method works for a London number\n";
}
print 'not ' unless(join(', ', sort $number->type()) eq 'is_allocated, is_fixed_line, is_geographic, is_valid');
print 'ok '.(++$test)." type() works\n";

$number = Number::Phone->new('+448450033845');
print 'not ' unless($number->format() eq '+44 8450033845');
print 'ok '.(++$test)." 0+10 number formatted OK\n";
print 'not ' unless($number->areacode() eq '');
print 'ok '.(++$test)." 0+10 number has no area code\n";
print 'not ' unless($number->subscriber() eq '8450033845');
print 'ok '.(++$test)." 0+10 number has correct subscriber number\n";

$number = Number::Phone->new('+447979866975');
print 'not ' unless($number->is_mobile());
print 'ok '.(++$test)." mobiles correctly identified\n";

$number = Number::Phone->new('+445600123456');
print 'not ' unless($number->is_ipphone());
print 'ok '.(++$test)." VoIP correctly identified\n";

# toll-free pagers no longer exist
# # $number = Number::Phone->new('+447600212345');
# # print 'not ' unless($number->is_pager());
# # print 'ok '.(++$test)." pagers correctly identified\n";
# # print 'not ' unless($number->is_tollfree());
# # print 'ok '.(++$test)." toll-free pagers correctly identified\n";
$number = Number::Phone->new('+447693912345');
print 'not ' unless($number->is_pager());
print 'ok '.(++$test)." pagers correctly identified\n";

$number = Number::Phone->new('+44800001012');
print 'not ' unless($number->is_tollfree());
print 'ok '.(++$test)." toll-free numbers with significant F digit correctly identified\n";
$number = Number::Phone->new('+44500123456');
print 'not ' unless($number->is_tollfree());
print 'ok '.(++$test)." C&W 0500 numbers correctly identified as toll-free\n";
$number = Number::Phone->new('+448000341234');
print 'not ' unless($number->is_tollfree());
print 'ok '.(++$test)." generic toll-free numbers correctly identified\n";

$number = Number::Phone->new('+448450033845');
print 'not ' unless($number->is_specialrate());
print 'ok '.(++$test)." special-rate numbers correctly identified\n";

$number = Number::Phone->new('+449088791234');
print 'not ' unless($number->is_adult() && $number->is_specialrate());
print 'ok '.(++$test)." 0908 'adult' numbers correctly identified\n";
$number = Number::Phone->new('+449090901234');
print 'not ' unless($number->is_adult() && $number->is_specialrate());
print 'ok '.(++$test)." 0909 'adult' numbers correctly identified\n";

$number = Number::Phone->new('+447000012345');
print 'not ' unless($number->is_personal());
print 'ok '.(++$test)." personal numbers correctly identified\n";

$number = Number::Phone->new('+445588301234');
print 'not ' unless($number->is_corporate());
print 'ok '.(++$test)." corporate numbers correctly identified\n";

$number = Number::Phone->new('+448200123456');
print 'not ' unless($number->is_network_service());
print 'ok '.(++$test)." network service numbers correctly identified\n";

$number = Number::Phone->new('+448450033845');
print 'not ' unless($number->operator() eq 'Interweb Design Ltd');
print 'ok '.(++$test)." operators correctly identified\n";

print 'not ' if(defined($number->areaname()));
print 'ok '.(++$test)." good, no area name for non-geographic numbers\n";
$number = Number::Phone->new('+442087712924');
print 'not ' unless($number->areaname() eq 'London');
print 'ok '.(++$test)." London numbers return correct area name\n";

$number = Number::Phone->new('+448457283848'); # "Allocated for Migration only"
print 'not ' unless($number);
print 'ok '.(++$test)." 0845 'Allocated for Migration only' fixed\n";

$number = Number::Phone->new('+448701540154'); # "Allocated for Migration only"
print 'not ' unless($number);
print 'ok '.(++$test)." 0870 'Allocated for Migration only' fixed\n";

$number = Number::Phone->new('+447092306588'); # dodgy spaces were appearing in data
print 'not ' unless($number);
print 'ok '.(++$test)." bad 070 data fixed\n";

$number = Number::Phone->new('+442030791234'); # new London 020 3 numbers
print 'not ' unless($number);
print 'ok '.(++$test)." 0203 numbers are recognised\n";
print 'not ' unless($number->is_allocated() && $number->is_geographic() && $number->is_fixed_line());
print 'ok '.(++$test)." ... and their type looks OK\n";

$number = Number::Phone->new('+442087712924');
print 'not ' unless($number->location()->[0] == 51.38309 && $number->location()->[1] == -0.336079);
print 'ok '.(++$test)." geo numbers have correct location\n";
$number = Number::Phone->new('+447979866975');
print 'not ' if(defined($number->location()));
print 'ok '.(++$test)." non-geo numbers have no location\n";
