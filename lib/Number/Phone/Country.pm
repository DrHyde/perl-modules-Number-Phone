package Number::Phone::Country;

use strict;
use Number::Phone::Country::Data;
use Number::Phone::NANP::Data;

# *_codes are global so we can mock in some tests
use vars qw($VERSION %idd_codes %prefix_codes);
$VERSION = 1.7;
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

sub phone2country_and_idd {
    my ($phone) = @_;
    $phone =~ s/[^\+?\d+]//g;
    $phone = '+1'.$phone unless(substr($phone, 0, 1) =~ /[1+]/);
    $phone =~ s/\D//g;

    # deal with NANP insanity
    if($phone =~ /^1(\d{10})$/) {
        return (Number::Phone::NANP::Data::ISO_country_code($1), 1);
    }

    else {
        my @retards = map { substr($phone, 0, $_) } reverse 1..length($phone);
        foreach my $idd (@retards) {
            if(exists $idd_codes{$idd}) {
                my $country = $idd_codes{$idd};
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
