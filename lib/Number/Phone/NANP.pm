package Number::Phone::NANP;

use strict;

use Scalar::Util 'blessed';

use base 'Number::Phone';
use Number::Phone::NANP::Data;

use Number::Phone::Country qw(noexport);

our $VERSION = 1.4;

my $cache = {};

=head1 NAME

Number::Phone::NANP - NANP-specific methods for Number::Phone

=head1 DESCRIPTION

This is a base class which encapsulates that information about phone
numbers in the North American Numbering Plan (NANP) which are
common to all NANP countries - that is, those whose international
dialling code is +1.  If you are dealing with phone numbers in any of
those countries, you should C<use> this module.  It will then load
the country-specific modules for you as needed.

Country-specific modules should inherit from this module and provide
their own versions of methods as necessary.  However, they should not
provide an C<is_valid> method or a constructor.

=head1 SYNOPSIS

in a program:

    use Number::Phone;

    my $phone_number = Number::Phone->new('+1 202 418 1440');
    # $phone_number is now a Number::Phone::NANP::US

    my $other_phone_number = Number::Phone->new('+1 866 623 2282');
    # $phone_number is non-geographic so is a Number::Phone::NANP

in a subclass:

    package Number::Phone::NANP::CA;
    use base 'Number::Phone::NANP';

=cut

sub new {
    my $class = shift;
    my $number = shift;
    die("No number given to ".__PACKAGE__."->new()\n") unless($number);

    return undef if(!is_valid($number));
    
    # cunningly, N::P::C::p2c supports local NANPish number formats
    # as well as +1XXXXXXXXXX format.  Yay!
    my $country = Number::Phone::Country::phone2country($number);
    
    # try to load country class
    eval "use Number::Phone::NANP::$country;";
    # if we fail, return a generic NANP object, which just happens to
    # also be the right thing to do for pan-NANP numbers like 800
    return bless(\$number, $class) if($@);
    return bless(\$number, $class."::$country");
}

=head1 METHODS

The following methods from Number::Phone are overridden:

=over 4

=item is_valid

The number is valid within the numbering scheme.  It may or may
not yet be allocated, or it may be reserved.

=cut

# See Message-ID: <008001c406ba$6bd01820$dad4a645@anhmca.adelphia.net>
# by Doug Ewell on Wed Mar 10 2004 in telnum-l.

sub is_valid {
    my $number = shift;

    # If called as an object method, it *must* be valid otherwise the
    # object would never have been instantiated.
    # If called as a sub, then it's the constructor that's calling.
    return 1 if(blessed($number) && $number->isa(__PACKAGE__));

    # otherwise we have to validate

    # if we've seen this number before, use cached result
    return 1 if($cache->{$number}->{is_valid});

    my $parsed_number = $number;
    my %digits;
    $parsed_number =~ s/[^\d+]//g;               # strip non-digits/plusses
    $parsed_number =~ s/^\+1//;                  # remove leading +1

    @digits{qw(A B C D)} = split(//, $parsed_number, 5);

    # and quickly check length
    if(length($parsed_number) != 10) {
        $cache->{$number}->{is_valid} = 0;
        return 0;
    }
    
    $cache->{$number}->{is_valid} = (
        $digits{A} >= 2 && $digits{A} <= 9 &&
        $digits{D} >= 2 && $digits{D} <= 9 &&
        $digits{A}.$digits{B} ne '37' &&
        $digits{A}.$digits{B} ne '96' &&
        $digits{B}.$digits{C} ne '11'
    ) ? 1 : 0;

    $cache->{$number}->{areacode}   = substr($parsed_number, 0, 3);
    $cache->{$number}->{subscriber} = substr($parsed_number, 3);
    return $cache->{$number}->{is_valid};
}

# define the other methods

foreach my $method (qw(areacode subscriber)) {
    no strict 'refs';
    *{__PACKAGE__."::$method"} = sub {
        my $self = shift;
        return $cache->{${$self}}->{$method};
    }
}

sub number {
    my $self = shift;

    # skip "+1";
    return substr $$self, 2;
}

sub is_geographic {
    my $self = shift;
    # NANP-globals like 1-800 aren't geographic, the rest are
    return ref($self) eq __PACKAGE__ ? 0 : 1;
}

sub is_mobile {
    my $self = shift;
    # NANP-globals like 1-800 aren't mobile
    if(ref($self) eq __PACKAGE__) { return 0; }
    (my $ISO_country_code = ref($self)) =~ s/.*(..)$/$1/;
    return undef if(!exists($Number::Phone::NANP::Data::mobile_regexes{$ISO_country_code}));
    return ${$self} =~ /^\+1($Number::Phone::NANP::Data::mobile_regexes{$ISO_country_code})$/ ? 1 : 0;
}

sub is_fixed_line {
    my $self = shift;
    # NANP-globals like 1-800 are fixed
    if(ref($self) eq __PACKAGE__) { return 1; }
    (my $ISO_country_code = ref($self)) =~ s/.*(..)$/$1/;
    return undef if(!exists($Number::Phone::NANP::Data::fixed_line_regexes{$ISO_country_code}));
    return ${$self} =~ /^\+1($Number::Phone::NANP::Data::fixed_line_regexes{$ISO_country_code})$/ ? 1 : 0;
}

sub areaname {
  my $self = shift;
  return Number::Phone::NANP::Data::areaname('1'.$self->areacode().$self->subscriber());
}

=item country_code

Returns 1.

=cut

sub country_code { 1; }

=item regulator

Returns informational text relevant to the whole NANP.  Note that when
this method is inherited by a subclass it returns undef meaning "not
known", but returns information about the NANPA when called on an object
of class Number::Phone::NANP.

=cut

sub regulator {
    my $class = shift;
    if(blessed($class) eq __PACKAGE__) {
        return 'NANPA, http://www.nanpa.com/';
    } else {
        return undef;
    }
}

=item areacode

Return the area code for the number.

=item areaname

Return the name for the area code, if applicable, otherwise returns undef.
For instance, for a number beginning with +1 201 200 it would return "Jersey City, NJ".

=item number

Return the raw unformatted phone number.  This is the same as the areacode and
subscriber number joined togehter.

=item subscriber

Return the subscriber part of the number.

=item format

Return a sanely formatted version of the number, complete with IDD code.

=cut

sub format {
    my $self = shift;
    return '+'.country_code().' '.
        $self->areacode().' '.
        substr($self->subscriber(), 0, 3).' '.
        substr($self->subscriber(), 3);
}

=back

=head1 BUGS/FEEDBACK

Please report bugs at L<https://github.com/DrHyde/perl-modules-Number-Phone/issues>, including, if possible, a test case.             

I welcome feedback from users.

=head1 LICENCE

You may use, modify and distribute this software under the same terms as
perl itself.

=head1 AUTHOR

David Cantrell E<lt>david@cantrell.org.ukE<gt>

Copyright 2012

=cut

1;
