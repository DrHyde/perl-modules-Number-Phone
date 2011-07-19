package Number::Phone;

use strict;

use Scalar::Util 'blessed';

use Number::Phone::Country qw(noexport uk);
use Number::Phone::StubCountry;

our $VERSION = 1.8003;

my @is_methods = qw(
    is_valid is_allocated is_in_use
    is_geographic is_fixed_line is_mobile is_pager
    is_tollfree is_specialrate is_adult is_network_service is_personal
    is_corporate is_government is_international
    is_ipphone is_isdn
);

foreach my $method (
    @is_methods, qw(
        country_code regulator areacode areaname
        subscriber operator translates_to
        format location
    )
) {
    no strict 'refs';
    *{__PACKAGE__."::$method"} = sub {
        my $self = shift;
        return undef if(blessed($self) && $self->isa(__PACKAGE__));
        my $pkg = __PACKAGE__;
        $self = shift if(
            $self eq __PACKAGE__ ||
            substr($self, 0, 2 + length(__PACKAGE__)) eq __PACKAGE__.'::'
        );
        $self = __PACKAGE__->new($self)
            unless(blessed($self) && $self->isa(__PACKAGE__));
        return $self->$method() if($self);
        undef;
    }
}

sub type {
    my $parm = shift;
    my $class = __PACKAGE__;

    no strict 'refs';

    unless(blessed($parm) && $parm->isa(__PACKAGE__)) {
        if(
            $parm eq __PACKAGE__ ||
            substr($parm, 0, 2 + length(__PACKAGE__)) eq __PACKAGE__.'::'
        ) {
            $class = $parm;
            $parm = shift;
        }
        $parm = $class->new($parm);
    }

    my $rval = $parm ?
        [grep { $parm->$_() } @is_methods] :
        undef;
    wantarray() ? @{$rval} : $rval;
}

sub country {
    my $self = shift;
    return undef if(!blessed($self));
    (my $country = blessed($self)) =~ s/.*:://;
    return undef unless(length($country) == 2);
    return $country;
}

1;

=head1 NAME

Number::Phone - base class for Number::Phone::* modules

=head1 SYNOPSIS

In a sub-class ...

    package Number::Phone::UK;
    use base 'Number::Phone';

and to magically use the right subclass ...

    use Number::Phone;

    $daves_phone = Number::Phone->new('+442087712924');
    $daves_other_phone = Number::Phone->new('+44 7979 866 975');
    # alternatively      Number::Phone->new('+44', '7979 866 975');
    # or                 Number::Phone->new('UK', '07979 866 975');

    if($daves_phone->is_mobile()) {
        send_rude_SMS();
    }

in the example, the +44 is recognised as the country code for the UK,
so the appropriate country-specific module is loaded if available.

If you pass in a bogus country code not recognised by
Number::Phone::Country, the constructor will return undef.

If you pass in a country code for which
no supporting module is available, the constructor will return a
minimal object that knows its country code and how to format a phone
number, but nothing else.  Note that this is an incompatible change:
previously it would return undef.

=cut

sub new {
    my $class = shift;
    my($country, $number) = @_;

    if(!defined($number)) { # one arg
      $number = $country;
    } elsif($country =~ /[a-z]/i) { # eg 'UK', '12345'
      $number = '+'.
                Number::Phone::Country::country_code($country).
		$number
        unless(index($number, '+'.Number::Phone::Country::country_code($country)) == 0);
    } else { # (+)NNN
      $number = join('', grep { defined } ($country, $number));
    }

    die("Need to specify a number for ".__PACKAGE__."->new()\n")
        unless($number);
    die("Number::Phone->new(): too many params\n")
        if(exists($_[2]));
    $number =~ s/[^+0-9]//g;

    $number = "+$number" unless($number =~ /^\+/);
    $country = Number::Phone::Country::phone2country($number);
    return undef unless($country);
    $country = "NANP" if($number =~ /^\+1/);
    eval "use Number::Phone::$country";
    return $class->_make_stub_object($number) if($@);
    return "Number::Phone::$country"->new($number);
}

sub _make_stub_object {
  my $class = shift;
  my $number = shift;
  my $self = {
    country => 'STUBFORCOUNTRYWITHNOMODULE',
    country_idd_code => ''.Number::Phone::Country::country_code(Number::Phone::Country::phone2country($number)),
    country_code => ''.Number::Phone::Country::phone2country($number),
    number => $number
  };
  # use Data::Dumper; local $Data::Dumper::Indent = 1;
  # print Dumper($self);
  bless($self, 'Number::Phone::StubCountry');
}

=head1 METHODS

All Number::Phone classes should implement the following methods, both
as object methods and as class methods.  Used as class methods they should
take a scalar parameter which they should attempt to parse as a phone
number.  Used as object methods, they should perform their duties on the
phone number that was supplied to the constructor.

Those methods whose names begin C<is_> should return the following
values:

=over 4

=item undef

The truth or falsehood can not be determined;

=item 0 (zero)

False - eg, is_personal() might return 0 for a number that is assigned to
a government department.

=item 1 (one)

True

=back

The C<is_*> methods are:

=over 4

=item is_valid

The number is valid within the national numbering scheme.  It may or may
not yet be allocated, or it may be reserved.  Any number which returns
true for any of the following methods will also be valid.

=item is_allocated

The number has been allocated to a telco for use.  It may or may not yet
be in use or may be reserved.

=item is_in_use

The number has been assigned to a customer or is in use by the telco for
its own purposes.

=item is_geographic

The number refers to a geographic area.

=item is_fixed_line

The number, when in use, can only refer to a fixed line.

=item is_mobile

The number, when in use, can only refer to a mobile phone.

=item is_pager

The number, when in use, can only refer to a pager.

=item is_ipphone

The number, when in use, can only refer to a VoIP service.

=item is_isdn

The number, when in use, can only refer to an ISDN service.

=item is_tollfree

Callers will not be charged for calls to this number under normal circumstances.

=item is_specialrate

The number, when in use, attracts special rates.  For instance, national
dialling at local rates, or premium rates for services.

=item is_adult

The number, when in use, goes to a service of an adult nature, such as porn.

=item is_personal

The number, when in use, goes to an individual person.

=item is_corporate

The number, when in use, goes to a business.

=item is_government

The number, when in use, goes to a government department.  Note that the
emergency services are considered to be a network service so should *not*
return true for this method.

=item is_international

The number is charged like a domestic number (including toll-free or special
rate), but actually terminates in a different country.  This covers the
special dialling arrangements between Spain and Gibraltar, and between the
Republic of Ireland and Northern Ireland, as well as services such as the
various "Country Direct"-a-likes.  See also the C<country()> method.

=item is_network_service

The number is some kind of network service such as the operator, directory
enquiries, emergency services etc

=back

Other methods are as follows.  Some of them may return undef if the result
is unknown or not applicable:

=over 4

=item country_code

The numeric code for this country.  eg, 44 for the UK.  Note that there is
*no* + sign.

=item regulator

Returns some text in an appropriate character set saying who the telecoms
regulator is, with optional details such as their web site or phone number.

=item areacode

Return the area code - if applicable - for the number.  If not applicable,
returns undef.

=item areaname

Return the name for the area code - if applicable.  If not applicable,
returns undef.  For instance, for a number beginning +44 20 it would return
'London'.  Note that this may return data in non-ASCII character sets.

=item location

This returns an approximate geographic location for the number if possible.
Obviously this only applies to fixed lines!  The data returned is, if defined,
a reference to an array containing two elements, latitude and longitude,
in degrees.
North of the equator and East of Greenwich are positive.
You may optionally return a third element indicating how confident you are
of the location.  Specify this as a number in kilometers indicating the radius
of the error circle.

=item subscriber

Return the subscriber part of the number

=item operator

Return the name of the telco operating this number, in an appropriate
character set and with optional details such as their web site or phone
number.

=item type

Return a listref of all the is_... methods above which are true.  Note that
this method should only be implemented in the super-class.  eg, for the
number +44 20 87712924 this might return
C<[qw(valid allocated geographic fixed_line)]>.

=item format

Return a sanely formatted version of the number, complete with IDD code, eg
for the UK number (0208) 771-2924 it would return +44 20 87712924.

=item country

The two letter ISO country code for the country in which the call will
terminate.  This is implemented in the superclass and you will only have
to implement your own version for countries where part of the number
range is overlayed with another country.

Exception: for the UK, return 'uk', not 'gb'.

=item translates_to

If the number forwards to another number (such as a special rate number
forwarding to a geographic number), or is part of a chunk of number-space
mapped onto another chunk of number-space (such as where a country has a
shortcut to (part of) another country's number-space, like how Gibraltar
appears as an area code in Spain's numbering plan as well as having its
own country code), then this method may return an object representing the
target number.  Otherwise it returns undef.

=back

Finally, there is a constructor:

=over 4

=item new

Can be called with either one or two parameters.  The *first* is an optional
country code (see the C<country()> method).  The other is a phone number.
If a country code is specified, and a subclass for that country is available,
the phone number is passed to its constructor unchanged.

If only one parameter is passed, then we try to figure out which is the right
country subclass to use by pre-pending a + sign to the number if
there isn't one, and looking the country up using
Number::Phone::Country.  That gives us a two letter country code that
is used to try to load the right module.

The constructor returns undef if it can not figure out what country
you're talking about, or a minimal object if there's no country-specific
module available.  Note that in the case of there being no country-specific
module available this is an incompatible change: previously it would
return undef.

=back

=head1 SUBCLASSING

Sub-classes should implement methods as above, including a C<new()> constructor.
The constructor should take a single parameter, a phone number, and should
validate that.  If the number is valid (use your C<is_valid()> method!) then
you can return a blessed object.  Otherwise you should return undef.

The constructor *must* be capable of accepting a number with the
+ sign and the country's numeric code attached, but should also accept
numbers in the preferred local format (eg 01234 567890 in the UK, which
is the same number as +44 1234 567890) so that users can go straight
to your class without going through Number::Phone's magic country
detector.

Subclasses' names should be Number::Phone::XX, where XX is the two letter
ISO code for the country, in upper case.  So, for example, France would be
FR and Ireland would be IE.  As usual, the UK is an exception, using UK
instead of the ISO-mandated GB.  NANP countries are also an exception,
going like Number::Phone::NANP::XX.

Note that subclasses no longer need to register themselves with
Number::Phone.  In fact, registration is now *ignored* as the magic
country detector now works properly.

=head1 WARNING

There is an incompatible change in version 1.8.  See the SYNOPSIS and
the documentation for the C<new> method above.

=head1 BUGS/FEEDBACK

Please report bugs by email or using http://rt.cpan.org, including,
if possible, a test case.

I welcome feedback from users.

=head1 LICENCE

You may use, modify and distribute this software under the same terms as
perl itself.

=head1 AUTHOR

David Cantrell E<lt>david@cantrell.org.ukE<gt>

Copyright 2004 - 2011

=cut
