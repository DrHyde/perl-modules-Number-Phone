use strict;
use warnings;
use lib 't/inc';
use nptestutils;

use Number::Phone;
use Number::Phone::Lib;
use Number::Phone::NANP;
use Test::More;

my %tests = (
    '+442087712924' => ['Europe/London'], # Geographic UK number
    '+445511000000' => ['Europe/Guernsey','Europe/Isle_of_Man','Europe/Jersey','Europe/London'], # Non-geographic UK number
    '+12024181440'  => ['America/New_York'], # geographic New York number
    '+18765551234'  => ['America/Jamaica'], # geographic Jamaican number
    '+81335803311'  => ['Asia/Tokyo'], # geographic Japanese number
    '+815012345678' => ['Asia/Tokyo'], # non-geographic Japanese number
    '+18885558888'  => ['America/Adak','America/Anchorage','America/Anguilla','America/Antigua','America/Barbados','America/Boise','America/Cayman','America/Chicago','America/Denver','America/Dominica','America/Edmonton','America/Fort_Nelson','America/Grand_Turk','America/Grenada','America/Halifax','America/Jamaica','America/Juneau','America/Los_Angeles','America/Lower_Princes','America/Montserrat','America/Nassau','America/New_York','America/North_Dakota/Center','America/Phoenix','America/Port_of_Spain','America/Puerto_Rico','America/Regina','America/Santo_Domingo','America/St_Johns','America/St_Kitts','America/St_Lucia','America/St_Thomas','America/St_Vincent','America/Toronto','America/Tortola','America/Vancouver','America/Winnipeg','Atlantic/Bermuda','Pacific/Guam','Pacific/Honolulu','Pacific/Pago_Pago','Pacific/Saipan'], # Non-geographic NANP number.
);

note("timezones()");
while (my ($num, $expect) = each %tests) {
    my $number = Number::Phone::Lib->new($num);
    is_deeply($number->timezones(), $expect, "timezone of $num using libphonenumber");
}

# Non-stubs do not implement timezones() and always should return undef
# even if libnumberphone has data.
is(Number::Phone->new('+18885558888')->timezones(), undef, 'non-stubs return undef');
is(Number::Phone::NANP->new('+12024181440')->timezones(), undef, 'non-no stubs return undef');

done_testing();
