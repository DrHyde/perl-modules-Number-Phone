package Number::Phone::NANP;

use strict;

use Scalar::Util 'blessed';

use base 'Number::Phone';
use Number::Phone::NANP::Data;

use Number::Phone::Country qw(noexport);

our $VERSION = '1.7001';

my $cache = {};

=head1 NAME

Number::Phone::NANP - NANP-specific methods for Number::Phone

=head1 DESCRIPTION

This is a base class which encapsulates that information about phone
numbers in the North American Numbering Plan (NANP) which are
common to all NANP countries - that is, those whose international
dialling code is +1.

Country-specific modules should inherit from this module and provide
their own versions of methods as necessary.  However, they should not
provide an C<is_valid> method or a constructor.

=head1 SYNOPSIS

This module should not be used directly. It will be loaded as necessary
by Number::Phone:

    use Number::Phone;

    my $phone_number = Number::Phone->new('+1 202 418 1440');
    # $phone_number is now a Number::Phone::NANP::US

    my $other_phone_number = Number::Phone->new('+1 866 623 2282');
    # $phone_number is non-geographic so is a Number::Phone::NANP

=cut

sub new {
    my $class = shift;
    my $number = shift;

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

=item new

The constructor, you should never have to call this yourself. To create an
object the canonical incantation is C<Number::Phone->new('+1 ...')>.

=item operator

For some countries operator data is available.

=item data_source

Returns a string telling where and when the data for operators was last updated, looking something like:

    "localcallingguide.com at Wed Sep 30 10:37:39 2020 UTC"

The current value of this is also documented in L<Number::Phone::Data>.

=cut

# some faffing about to re-open the database if we fork
my $WORDLENGTH;
my $datafh;
my $pid = -1;
sub _datafh {
    if(!$datafh || $pid != $$) {
        my $file = Number::Phone::_find_data_file('Number-Phone-NANP-Data.db');
        open($datafh, '< :raw :bytes', $file) || die("Can't read $file: $!");
        read($datafh, my $header, 8);
        die("$file isn't the right format\n") unless($header eq 'NANPOP'.chr(0).chr(0));
        read($datafh, $WORDLENGTH, 1);
        $WORDLENGTH = ord($WORDLENGTH);
        $pid = $$;
    }
    return $datafh;
}

sub operator {
    my $self = shift;

    # file needs to be open so we have a $WORDLENGTH
    $self->_datafh();

    (my $number = ${$self}) =~ s/\D//g;
    my $ten_thousands = substr($number, 1, 6);

    $ten_thousands -= 200000; # area codes below 200 are invalid
    return $self->_get_data_starting_from_pointer_at_offset($WORDLENGTH * $ten_thousands);
}

sub _get_data_starting_from_pointer_at_offset {
    my($self, $offset) = @_;

    my $pointer = $self->_get_pointer_at_offset($offset);
    return undef unless($pointer);

    my $block_type = $self->_get_block_type_at_offset($pointer);
    $pointer += 1;

    if($block_type == 0) {
        # $pointer points at a string
        return $self->_get_string_at_offset($pointer);
    } elsif($block_type == 1) {
        # $pointer points at a block of pointers
        (my $number = ${$self}) =~ s/\D//g;
        my $thousands = substr($number, 7, 1); # the seventh digit
        return $self->_get_data_starting_from_pointer_at_offset($pointer + $WORDLENGTH * $thousands);
    } else {
        die("Don't know how to handle a block of type $block_type at ".($pointer - 1)."\n");
    }
}

sub _get_block_type_at_offset {
    my($self, $offset) = @_;

    seek($self->_datafh(), $offset, 0);
    read($self->_datafh(), my $block_type, 1);
    return ord($block_type);
}

sub _get_string_at_offset {
    my($self, $offset) = @_;

    seek($self->_datafh(), $offset, 0);
    read($self->_datafh(), my $chars, 1);
    $chars = unpack('C', $chars);
    read($self->_datafh(), my $string, $chars);
    return $string;
}

sub _get_pointer_at_offset {
    my($self, $offset) = @_;

    seek($self->_datafh(), $offset, 0);
    read($self->_datafh(), my $pointer, $WORDLENGTH);
    return unpack('N', $pointer);
}

=item is_valid

The number is valid within the numbering scheme.  It may or may
not yet be allocated, or it may be reserved.

=item is_geographic

NANP-globals like 1-800 aren't geographic, the rest are.

=item is_mobile

NANP-globals like 1-800 aren't mobile. For most others we just don't know because
the data isn't published. libphonenumber has data for *some* countries, so we use
that if we can.

=item is_fixed_line

NANP-globals are fixed lines, for the rest we generally don't know with some
exceptions as per is_mobile above.

=cut

# See Message-ID: <008001c406ba$6bd01820$dad4a645@anhmca.adelphia.net>
# by Doug Ewell on Wed Mar 10 2004 in telnum-l.
#
# NB the EF digits being 11 *is* legal in at least some area codes.
# Obviously you can't dial, eg, 911-1234

sub is_valid {
    my $number = shift;

    # If called as an object method, it *must* be valid otherwise the
    # object would never have been instantiated.
    # If called as a sub, then it's the constructor that's calling.
    return 1 if(blessed($number));

    # otherwise we have to validate

    # if we've seen this number before, use cached result
    return 1 if($cache->{$number}->{is_valid});

    my $parsed_number = $number;
    my %digits;
    $parsed_number =~ s/[^\d+]//g;               # strip non-digits/plusses
    $parsed_number =~ s/^\+1//;                  # remove leading +1

    @digits{qw(A B C D)} = split(//, $parsed_number, 5);

    # this is checked in N::P::C::phone2country_and_idd waaaay before we
    # ever get here. NB leave this here in case a refactor makes that go
    # away. There are tests for this!
    #
    # # and quickly check length
    # if(length($parsed_number) != 10) {
    #     $cache->{$number}->{is_valid} = 0;
    #     return 0;
    # }
    
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

=item is_drama

The number is a '555' number. Numbers with the D, E, and F digits set to 555
are not allocated to real customers, and are intended for use in fiction. eg
212 555 2368 for Ghostbusters.

NB, despite Ghostbusters above, only 555-0100 to 555-0199 are actually reserved.

=cut

sub is_drama {
    my $self = shift;
    if(${$self} =~ /555(\d{4})$/) {
        return ($1 gt '0099' && $1 lt '0200') ? 1 : 0;
    }
    return 0;
}

=item is_government

Area code 710 is reserved for the US Feds, but apparently only one number
in the whole area code works.

=cut

sub is_government {
    my $self = shift;
    if(${$self} =~ /^(\+1)?710/) { return 1; }
     else { return 0; }
}

=item is_tollfree

The number is free to the caller. 800, 844, 855, 866, 877 and 888 "area codes"

=cut

sub is_tollfree {
    my $self = shift;
    if(${$self} =~ /^(\+1)?8[045678]{2}/) { return 1; }
     else { return 0; }
}

=item is_specialrate

The number is charged at a higher rate than normal. The 900 "area code"
and some parts of 242 and 246 (Bahamas and Barbados).

=cut

sub is_specialrate {
    my $self = shift;
    if(${$self} =~ /
        ^(\+1)?
        (
            900 |                          # NANP-global
            242225[0-46-9] |               # BS-specific
            246 ( 292 | 367 | 41[7-9] | 43[01] | 444 | 467 | 736 ) # BB-specific, apparently
        )
    /x) { return 1; }
     else { return 0; }
}

=item is_personal

The number is a "personal" number. The 500, 533, 544, 566 and 577 "area codes".

=cut

sub is_personal {
    my $self = shift;
    if(${$self} =~ /^(\+1)?5[03467]{2}/) { return 1; }
     else { return 0; }
}

sub areaname {
  my $self = shift;
  return Number::Phone::NANP::Data::_areaname('1'.$self->areacode().$self->subscriber());
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
