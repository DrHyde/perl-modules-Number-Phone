package # hah, fooled you PAUSE
    Number::Phone::BuildHelpers;

use strict;
use warnings;

use Exporter qw(import);
our @ISA = qw(Exporter);
our @EXPORT = qw(
    get_final_class_part
    is_dodgy_unknown_country
    known_non_country_codes
    $non_geo_IDD_codes_regex
);

our $non_geo_IDD_codes_regex = qr/^(800|808|870|878|881|882|883|888|979)$/;
# these are territories where libphonenumber has some data, but
# for "ISO" country code "001"
sub is_dodgy_unknown_country {
    my($ISO, $IDD) = @_;

    $ISO !~ /^..$/ && $IDD !~ /$non_geo_IDD_codes_regex/
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
        # NB all the sub-ranges in 881, 882 and 883 except AQ need empty sub-classes in lib/Number/Phone/StubCountry/.../
        # There's also logic for them in Number::Phone->_make_stub_object()
        # and for AQ in Number::Phone->_new_args()
        881    => 'GMSS',                                   # \ Satphones
        8810   => 'GMSS::ICO',                              # |
        8811   => 'GMSS::ICO',                              # |
        # 8812 is vacant (Ellipso never launched)           # |
        # 8813 is vacant (Ellipso never launched)           # |
        # 8814 is spare                                     # |
        # 8815 is spare                                     # |
        8816   => 'GMSS::Iridium',                          # |
        8817   => 'GMSS::Iridium',                          # |
        8818   => 'GMSS::Globalstar',                       # |
        8819   => 'GMSS::Globalstar',                       # /
        882    => 'InternationalNetworks882',               # many allocations not listed as I don't know if they're diallable, see wtng.info
        88213  => 'InternationalNetworks882::Telespazio',   # Sat-phone
        88216  => 'InternationalNetworks882::Thuraya',      # Sat-phone
        88220  => 'InternationalNetworks882::GarudaMobile', # Sat-phone
        88234  => 'AQ',                                     # Antarctica, via Global Networks Switzerland, http://wtng.info/wtng-spe.html#Networks
        883    => 'InternationalNetworks883',
        883130 => 'InternationalNetworks883::Mobistar',
        883140 => 'InternationalNetworks883::MTTGlobalNetworks',
        888    => 'TelecomsForDisasterRelief',
        # 979 is used for testing when we fail to load a module when we
        # know what 'country' it is
        979    => 'InternationalPremiumRate',
        991    => 'ITPCS',
        # 999 deliberately NYI for testing; proposed to be like 888.
    )
}

sub get_final_class_part {
    my($ISO_country_code, $IDD_country_code) = @_;
    return length($ISO_country_code) == 2
      ? $ISO_country_code
      : { known_non_country_codes() }->{$IDD_country_code};
}

1;
