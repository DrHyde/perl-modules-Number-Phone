package Number::Phone::Country;

use strict;
use Number::Phone::Country::Data;

# *_codes are global so we can mock in some tests
use vars qw($VERSION %idd_codes %prefix_codes);
$VERSION = 1.94;
my $use_uk = 0;

sub import {
    shift;
    my $export = 1;
    foreach my $param (@_) {
        if(lc($param) eq 'noexport') { $export = 0; }
         elsif(lc($param) eq 'uk') { $use_uk = 1; }
         else { warn("Unknown param to ".__PACKAGE__." '$param' at ".join(' line ', (caller())[1,2])."\n"); }
    }
    if($export) {
        my $callpkg = caller(1);
        no strict 'refs';
        warn("Exporting from Number::Phone::Country is deprecated at ".join(' line ', (caller())[1,2])."\n");
        *{"$callpkg\::phone2country"} = \&{__PACKAGE__."\::phone2country"};
    }
}

sub phone2country {
    my ($phone) = @_;
    return (phone2country_and_idd($phone))[0];
}

our %NANP_areas = (
    CA => do {
        # see http://www.cnac.ca/co_codes/co_code_status.htm
        # checked on 2018-03-25
        # next check due 2018-09-25 (semi-annually)
        my $canada = join('|', qw(
            204 226 236 249 250 289
            306 343 365 367
            403 416 418 431 437 438 450
            506 514 519 548 579 581 587
            604 613 639 647
            705 709 778 780 782
            807 819 825 867 873 879
            902 905
        ));
        # handful of non-geographic country-specific codes ...
        # see https://en.wikipedia.org/wiki/Area_code_600
        # checked on 2018-03-25
        # next check due 2018-09-25 (semi-annually)
        $canada = join('|', $canada, 600, 622, 633, 644, 655, 677, 688);
    },
    US => do {
        # see https://www.allareacodes.com/area_code_listings_by_state.htm
        # checked on 2018-03-25
        # next check due 2018-09-25 (semi-annually)
        my $usa = join('|', qw(
            205 251 256 334 938 907 480 520 602 623 928 479 501 870 209 213 310 323 408 415 424 442 510 530 559 562 619 626 628 650 657 661 669 707 714 747 760 805 818 831 858 909 916 925 949 951 303 719 720 970 203 475 860 959 302 239 305 321 352 386 407 561 727 754 772 786 813 850 863 904 941 954 229 404 470 478 678 706 762 770 912 808 208 217 224 309 312 331 618 630 708 773 779 815 847 872 219 260 317 463 574 765 812 930 319 515 563 641 712 316 620 785 913 270 364 502 606 859 225 318 337 504 985 207 240 301 410 443 667 339 351 413 508 617 774 781 857 978 231 248 269 313 517 586 616 734 810 906 947 989 218 320 507 612 651 763 952 228 601 662 769 314 417 573 636 660 816 406 308 402 531 702 725 775 603 201 551 609 732 848 856 862 908 973 505 575 212 315 332 347 516 518 585 607 631 646 680 716 718 845 914 917 929 934 252 336 704 743 828 910 919 980 984 701 216 220 234 330 380 419 440 513 567 614 740 937 405 539 580 918 458 503 541 971 215 267 272 412 484 570 610 717 724 814 878 401 803 843 854 864 605 423 615 629 731 865 901 931 210 214 254 281 325 346 361 409 430 432 469 512 682 713 737 806 817 830 832 903 915 936 940 956 972 979 385 435 801 802 276 434 540 571 703 757 804 206 253 360 425 509 202 304 681 262 414 534 608 715 920 307
        ));
        # handful of non-geographic country-specific codes ...
        # see https://en.wikipedia.org/wiki/Area_code_710
        # checked on 2018-03-25
        # next check due 2018-09-25 (semi-annually)
        $usa    = join('|', $usa, 710);
    },
    # see https://en.wikipedia.org/wiki/North_American_Numbering_Plan#NANP_countries_and_territories
    # checked on 2018-03-23
    # next check due 2019-03-01 (annually)
    AS => '684',         # American Samoa
    AI => '264',         # Anguilla
    AG => '268',         # Antigua and Barbude
    BS => '242',         # Bahamas
    BB => '246',         # Barbados
    BM => '441',         # Bermuda
    VG => '284',         # British Virgin Islands
    KY => '345',         # Cayman Islands
    DM => '767',         # Dominica
    DO => '809|829|849', # Dominican Republic
    GD => '473',         # Grenada
    GU => '671',         # Guam
    JM => '876',         # Jamaica
    MS => '664',         # Montserrat
    MP => '670',         # Northern Mariana Islands
    PR => '787|939',     # Puerto Rico
    KN => '869',         # Saint Kitts and Nevis
    LC => '758',         # Saint Lucia
    VC => '784',         # Saint Vincent and the Grenadines
    SX => '721',         # Sint Maarten
    TT => '868',         # Trinidad and Tobago
    TC => '649',         # Turks and Caicos Islands
    VI => '340',         # US Virgin Islands
);

# private sub, returns list of NANP areas for the given ISO country code
sub _NANP_area_codes {
    # uncoverable subroutine - only used in build scripts
    # uncoverable statement
    return split('\|', $NANP_areas{shift()});
}

sub phone2country_and_idd {
    my ($phone) = @_;
    $phone =~ s/[^\+?\d+]//g;
    $phone = '+1'.$phone unless(substr($phone, 0, 1) =~ /[1+]/);
    $phone =~ s/\D//g;

    # deal with NANP insanity
    if($phone =~ m!^1(\d{3})\d{7}$!) {
        my $area = $1;
        foreach my $country (keys %NANP_areas) {
            if($area =~ /^($NANP_areas{$country})$/x) {
                return ($country, 1);
            }
        }
        return ('NANP', 1);
    } else {
        my @prefixes = map { substr($phone, 0, $_) } reverse 1..length($phone);
        foreach my $idd (@prefixes) {
            if(exists $idd_codes{$idd}) {
                my $country = $idd_codes{$idd};
                if(ref($country) eq 'ARRAY'){
                    foreach my $country_code (@$country) {
                        my $class = "Number\::Phone\::StubCountry\::" . $country_code;
                        eval "require $class";
                        if ($@) {
                            my $error = $@;
                        } elsif($class->new('+' . $phone)) {
                            return (
                                (($country_code eq 'GB' && $use_uk) ? 'UK' : $country_code),
                                $idd
                            );
                        }
                    }
                    $country = @$country[0];
                }

                return ($country, $idd);
            }
        }
    }
    return;
}

sub country_code {
    my $country = uc shift;

    my $data = $prefix_codes{$country} or return;

    return $$data[0];
}

sub idd_code {
    my $country = uc shift;

    my $data = $prefix_codes{$country} or return;

    return $$data[1];
}

sub ndd_code {
    my $country = uc shift;

    my $data = $prefix_codes{$country} or return;

    return $$data[2];
}

1;

=head1 NAME

Number::Phone::Country - Lookup country of phone number

=head1 SYNOPSIS

  use Number::Phone::Country;

  #returns 'CA' for Canada
  my $iso_country_code = phone2country("1 (604) 111-1111");

or

  use Number::Phone::Country qw(noexport uk);

  my $iso_country_code = Number::Phone::Country::phone2country(...);

or

  my ($iso_country_code, $idd) = Number::Phone::Country::phone2country_and_idd(...);

=head1 DESCRIPTION

This module looks up up the country based on a telephone number.
It uses the International Direct Dialing (IDD) prefix, and
lookups North American numbers using the Area Code, in accordance
with the North America Numbering Plan (NANP).  It can also, given a
country, tell you the country code, and the prefixes you need to dial
when in that country to call outside your local area or to call another
country.

Note that by default, phone2country is exported into your namespace.  This
is deprecated and may be removed in a future version.  You can turn that
off by passing the 'noexport' constant when you use the module.

Also be aware that the ISO code for the United Kingdom is GB, not UK.  If
you would prefer UK, pass the 'uk' constant.

I have put in number ranges for Kosovo, which does not yet have an ISO country
code.  I have used XK, as that is the de facto standard as used by numerous
international bodies such as the European Commission and the IMF.  I previously
used KOS, as used by the UN Development Programme.  This may change again in
the future.

=head1 FUNCTIONS

The following functions are available:

=over 4

=item country_code($country)

Returns the international dialing prefix for this country - eg, for the UK
it returns 44, and for Canada it returns 1.

=item idd_code($country)

Returns the International Direct Dialing prefix for the given country.
This is the prefix needed to make a call B<from a country> to another
country.  This is followed by the country code for the country you are
calling.  For example, when calling another country from the US, you must
dial 011.

=item ndd_code($country)

Returns the National Direct Dialing prefix for the given country.  This is
the prefix used to make a call B<within a country> from one city to
another.  This prefix may not be necessary when calling another city in the
same vicinity.  This is followed by the city or area code for the place you
are calling.  For example, in the US, the NDD prefix is "1", so you must
dial 1 before the area code to place a long distance call within the
country.

=item phone2country($phone)

Returns the ISO country code (or XK for Kosovo) for a phone number.
eg, for +441234567890 it returns 'GB' (or 'UK' if you've told it to).

=item phone2country_and_idd($phone)

Returns a list containing the ISO country code and IDD prefix for the given
phone number.  eg for +441234567890 it returns ('GB', 44).

=back

=head1 SEE ALSO

L<Parse::PhoneNumber>

=head1 BUGS

It has not been possible to maintain complete backwards compatibility with
the original 0.01 release.  To fix a
bug, while still retaining the ability to look up plain un-adorned NANP
numbers without the +1 prefix, all non-NANP numbers *must* have their
leading + sign.

Another incompatibility - it was previously assumed that any number not
assigned to some other country was in the US.  This was incorrect for (eg)
800 numbers.  These are now identified as being generic NANP numbers.

Will go out of date every time the NANP has one of its code splits/overlays.
So that's about once a month then.  I'll do my best to keep it up to date.

=head1 WARNING

The Yugoslavs keep changing their minds about what country they want to be
and what their ISO 3166 code and IDD prefix should be.  YU? CS? RS? ME?
God knows.  And then there's Kosovo ...

=head1 AUTHOR

now maintained by David Cantrell E<lt>david@cantrell.org.ukE<gt>

originally by TJ Mather, E<lt>tjmather@maxmind.comE<gt>

country/IDD/NDD contributions by Michael Schout, E<lt>mschout@gkg.netE<gt>

Thanks to Shraga Bor-Sood for the updates in version 1.4.

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by MaxMind LLC

Copyright 2004 - 2011 David Cantrell

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
