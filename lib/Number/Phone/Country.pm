package Number::Phone::Country;

use strict;
use Number::Phone::Country::Data;
use Number::Phone::NANP::Data;

# *_codes are global so we can mock in some tests
use vars qw($VERSION %idd_codes %prefix_codes);
$VERSION = 1.9;
my $use_uk = 0;

sub import {
    shift;
    my $export = 1;
    foreach my $param (@_) {
        if(lc($param) eq 'noexport') { $export = 0; }
         elsif(lc($param) eq 'uk') { $use_uk = 1; }
    }
    if($export) {
        my $callpkg = caller(1);
        no strict 'refs';
        *{"$callpkg\::phone2country"} = \&{__PACKAGE__."\::phone2country"};
    }
}

sub phone2country {
    my ($phone) = @_;
    return (phone2country_and_idd($phone))[0];
}

our %NANP_areas = (
    CA => do {
        # from http://www.cnac.ca/co_codes/co_code_status.htm, 2014-04-20
        my $canada = join('|', qw(
            204 226 236 249 250 289
            306 343 365
            403 416 418 431 437 438 450
            506 514 519 548 579 581 587
            604 613 639 647
            705 709 778 780 782
            807 819 825 867 873
            902 905
        ));
        # handful of non-geographic country-specific codes ...
        $canada = join('|', $canada, 600, 622, 633, 644, 655, 677, 688);
    },
    US => do {
        # from http://www.nanpa.com/enas/geoAreaCodeAlphabetReport.do, 2014-04-20
        my $usa = join('|', qw(
            907 334 938 256 251 205 870 479 501 520 480 928 602 623 619 562 650 657 661 408 415 424 442 626 559 530 510 323 310 951 949 925 209 213 669 707 714 747 760 805 818 831 858 909 916 303 970 720 719 203 475 860 202 302 407 561 727 754 772 786 813 850 863 904 941 954 305 321 352 386 239 404 229 762 470 678 706 478 770 912 808 712 319 641 563 515 208 708 224 217 618 630 331 312 309 872 847 773 779 815 317 219 812 574 260 765 913 316 785 620 502 859 364 270 606 225 985 504 337 318 857 781 774 978 413 339 351 508 617 240 301 410 667 443 207 248 947 810 989 517 734 313 231 269 586 906 616 763 218 651 612 507 320 952 636 573 314 417 816 660 769 601 228 662 406 252 704 828 910 919 980 984 336 701 308 402 603 732 856 862 908 973 201 609 848 551 575 505 775 702 914 718 929 845 212 315 347 646 585 631 516 518 607 716 917 614 567 513 330 937 740 234 216 440 419 918 405 539 580 971 541 503 458 610 412 215 717 724 814 484 570 878 267 272 401 843 864 803 605 931 615 901 865 423 731 713 737 806 817 512 832 903 915 940 956 972 979 936 281 325 361 682 254 214 210 469 432 430 409 830 385 435 801 434 703 757 571 804 276 540 802 360 253 206 425 509 262 920 534 414 608 715 304 681 307
        ));
        # handful of non-geographic country-specific codes ...
        $usa    = join('|', $usa,    710);
    },
    # see http://wtng.info/wtng-cod.html#WZ1
    # checked 2014-04-21
    PR => '787|939',
    DO => '809|829|849',
    BS => '242',
    BB => '246',
    AI => '264',
    AG => '268',
    VG => '284',
    VI => '340',
    KY => '345',
    BM => '441',
    GD => '473',
    TC => '649',
    MS => '664',
    MP => '670',
    GU => '671',
    AS => '684',
    SX => '721',
    LC => '758',
    DM => '767',
    VC => '784',
    TT => '868',
    KN => '869',
    JM => '876',
);

# private sub, returns list of NANP areas for the given ISO country code
sub _NANP_area_codes {
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
        my @retards = map { substr($phone, 0, $_) } reverse 1..length($phone);
        foreach my $idd (@retards) {
            if(exists $idd_codes{$idd}) {
                my $country = $idd_codes{$idd};
                if(ref($country) eq 'ARRAY'){
                    foreach my $country_code (@$country) {
                        my $class = "Number\::Phone\::StubCountry\::" . $country_code;
                        eval "require $class";
                        if ($@)
                        {
                            my $error = $@;
                        } else {
                            return ($country_code, $idd) if $class->new('+' . $phone);
                        }
                    }
                    $country = @$country[0];
                }

                if($country eq 'GB' && $use_uk) { $country = 'UK'; }
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

I have put in number ranges for Kosovo, which does not yet have an ISO
country code.  I have used KOS, as that is used by the UN Development
Programme.  This may change in the future.

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

Returns the ISO country code (or KOS for Kosovo) for a phone number.
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
