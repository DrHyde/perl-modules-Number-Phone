package # hah, fooled you PAUSE
    Number::Phone::BuildHelpers;

use strict;
use warnings;

use Exporter qw(import);
our @ISA = qw(Exporter);
our @EXPORT = qw(is_dodgy_unknown_country known_non_country_codes);

# these are territories where libphonenumber has some data, but
# for "ISO" country code "001"
sub is_dodgy_unknown_country {
    my($ISO, $IDD) = @_;

    $ISO !~ /^..$/ # && $IDD !~ /^(800|808|870|878|883|888|979)$/;
}

# see https://en.wikipedia.org/wiki/Global_Mobile_Satellite_System
#     https://en.wikipedia.org/wiki/International_Networks_%28country_code%29
#     wtng.info
# checked on 2022-03-04
# next check due 2024-12-01 (bi-annually)
sub known_non_country_codes {
    (
        800    => 'InternationalFreephone',
        808    => 'SharedCostServices',
        870    => 'Inmarsat',
        878    => 'UniversalPersonalTelecoms',
        881    => 'GMSS',                          # \ Satphones
        8810   => 'ICO',                           # |
        8811   => 'ICO',                           # |
        # 8812 is vacant (Ellipso never launched)  # |
        # 8813 is vacant (Ellipso never launched)  # |
        # 8814 is spare                            # |
        # 8815 is spare                            # |
        8816   => 'Iridium',                       # |
        8817   => 'Iridium',                       # |
        8818   => 'Globalstar',                    # |
        8819   => 'Globalstar',                    # /
        882    => 'InternationalNetworks',         # many allocations not listed as I don't know if they're diallable, see wtng.info
        88213  => 'Telespazio',                    # Sat-phone
        88216  => 'Thuraya',                       # Sat-phone
        88220  => 'GarudaMobile',                  # Sat-phone
        88234  => 'AQ',                            # Antarctica, via Global Networks Switzerland, http://wtng.info/wtng-spe.html#Networks
        883    => 'InternationalNetworks',
        883120 => 'Telenor',
        883130 => 'Mobistar',
        883140 => 'MTTGlobalNetworks',
        888    => 'TelecomsForDisasterRelief',
        # 979 is used for testing when we fail to load a module when we
        # know what 'country' it is
        979    => 'InternationalPremiumRate',
        991    => 'ITPCS',
        # 999 deliberately NYI for testing; proposed to be like 888.
    )
}

1;
