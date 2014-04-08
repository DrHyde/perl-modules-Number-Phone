package Number::Phone;

use strict;

use Scalar::Util 'blessed';

use Number::Phone::Country qw(noexport uk);
use Number::Phone::StubCountry;

our $VERSION = '2.2002';

my $NOSTUBS = 0;
sub import {
  my $class = shift;
  my @params = @_;
  if(grep { /^nostubs$/ } @params) {
    $NOSTUBS++
  }
}


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
        subscriber operator operator_ported translates_to
        format location
    )
) {
    no strict 'refs';
    *{__PACKAGE__."::$method"} = sub {
        my $self = shift;
        warn("DEPRECATION: ".__PACKAGE__."->$method should only be called as an object method\n")
          unless(blessed($self));
        return undef if(blessed($self) && $self->isa(__PACKAGE__));
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
    warn("DEPRECATION: ".__PACKAGE__."->type should only be called as an object method\n")
      unless(blessed($parm));
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
    my $class = blessed(shift);
    return unless $class;
    (my @two_letter_codes) = $class =~ /\b([A-Z]{2})\b/g;
    return $two_letter_codes[-1];
}

sub dial_to {
  my $from = shift;
  my $to   = shift;

  if($from->country_code() != $to->country_code()) {
    return Number::Phone::Country::idd_code($from->country()).
           $to->country_code().
           ($to->areacode() ? $to->areacode() : '').
           $to->subscriber();
  }

  # if we get here it's a domestic call

  # do we know how to do this?
  my $intra_country_dial_to = eval '$from->intra_country_dial_to($to)';
  return undef if($@); # no
  return $intra_country_dial_to if($intra_country_dial_to); # yes, and here's how

  # if we get here, then we can use the default implementation ...

  if(
    defined($from->areacode()) &&
    defined($to->areacode())   &&
    $from->areacode() eq $to->areacode()
  ) { return $to->subscriber(); }

  return Number::Phone::Country::ndd_code($from->country()).
         ($to->areacode() ? $to->areacode() : '').
         $to->subscriber();
}

sub intra_country_dial_to { die("don't know how\n"); }

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
no supporting module is available, the constructor will try to use a 'stub'
class under Number::Phone::StubCountry::* that uses data automatically
extracted from Google's libphonenumber project.  libphonenumber doesn't
have enough data to support all the features of Number::Phone, and this
is an experimental feature.  If you want to disable this, then pass 'nostubs'
when you use the module:

    use Number::Phone qw(nostubs);

=cut

sub _new_args {
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
    $country = Number::Phone::Country::phone2country($number) or return;
    return $country, $number;
}

sub new {
    my $class = shift;
    my($country, $number) = $class->_new_args(@_);
    return undef unless($country);
    if ($number =~ /^\+1/) {
        $country = "NANP";
    } elsif ($country =~ /^(?:GG|JE|IM)$/) {
        $country = 'UK';
    }
    eval "use Number::Phone::$country";
    if($@ || !"Number::Phone::$country"->isa('Number::Phone')) {
        return $class->_make_stub_object($number, $country)
    }
    return "Number::Phone::$country"->new($number);
}

sub _make_stub_object {
 my ($class, $number, $country_name) = @_;
  die("no module available for $country_name, and nostubs turned on\n") if($NOSTUBS);
  my $stub_class = "Number::Phone::StubCountry::$country_name";
  eval "use $stub_class";
  # die("Can't find $stub_class: $@\n") if($@);
  if($@) {
      my (undef, $country_idd) = Number::Phone::Country::phone2country_and_idd($number);
      # an instance of this class is the ultimate fallback
      (my $local_number = $number) =~ s/(^\+$country_idd|\D)//;
      return bless({
          country_code => $country_idd,
          country      => $country_name,
          is_valid     => undef,
          number       => $local_number,
      }, 'Number::Phone::StubCountry');
  }
  $stub_class->new($number);
}

=head1 METHODS

All Number::Phone classes can implement the following methods, as
object methods.  Note that in previous versions these were also required
to work as class methods and could also work as subroutines.  That
was a bad design decision and is deprecated.  Number::Phone will spit
warnings if you try that now, and support will be removed in the future.

The implementations in the parent class all return undef unless otherwise
noted.

Those methods whose names begin C<is_> should return the following
values:

=over

=item undef

The truth or falsehood can not be determined;

=item 0 (zero)

False - eg, is_personal() might return 0 for a number that is assigned to
a government department.

=item 1 (one)

True

=back

=head2 IS_* methods

=over

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

=head2 OTHER NUMBER METADATA METHODS

=over

=item country_code

The numeric code for this country.  eg, 44 for the UK.  Note that there is
*no* + sign.

While the superclass does indeed implement this (returning undef) this is
nonsense in just about all cases, so you should always implement this.

=item regulator

Returns some text in an appropriate character set saying who the telecoms
regulator is, with optional details such as their web site or phone number.

=item areacode

Return the area code - if applicable - for the number.  If not applicable,
the superclass implementation returns undef.

=item areaname

Return the name for the area code - if applicable.  If not applicable,
the superclass definition returns undef.  For instance, for a number
beginning +44 20 it would return
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

The superclass implementation returns undef, which is a reasonable default.

=item subscriber

Return the subscriber part of the number.

While the superclass implementation returns undef, this is nonsense in just
about all cases, so you should always implement this.

=item operator

Return the name of the telco assigned this number, in an appropriate
character set and with optional details such as their web site or phone
number.  Note that this should not take into account number portability.

The superclass implementation returns undef, as this information is not
easily available for most numbering plans.

=item operator_ported

Return the name of the telco to whom this number has been ported.  If it
is known to have not been ported, then return the same as C<operator()>
above.

The superclass implementation returns undef, indicating that you don't
know whether the number has been ported.

=item type

Return a listref of all the is_... methods above which are true.  Note that
this method should only be implemented in the super-class.  eg, for the
number +44 20 87712924 this might return
C<[qw(valid allocated geographic)]>.

=item format

Return a sanely formatted version of the number, complete with IDD code, eg
for the UK number (0208) 771-2924 it would return +44 20 8771 2924.

The superclass implementation returns undef, which is nonsense, so you
should always implement this.

=item country

The two letter ISO country code for the country in which the call will
terminate.  This is implemented in the superclass and you will only have
to implement your own version for countries where part of the number
range is overlayed with another country.

Exception: for the UK, return 'uk', not 'gb'.

Specifically, the superclass implementation looks at the class name and
returns the last two-letter code it finds.  eg ...

  from Number::Phone::UK, it would return UK
  from Number::Phone::UK::IM, it would return IM
  from Number::Phone::NANP::US, it would return US
  from Number::Phone::FR::Full, it would return FR

=item translates_to

If the number forwards to another number (such as a special rate number
forwarding to a geographic number), or is part of a chunk of number-space
mapped onto another chunk of number-space (such as where a country has a
shortcut to (part of) another country's number-space, like how Gibraltar
used to appear as an area code in Spain's numbering plan as well as having its
own country code), then this method may return an object representing the
target number.  Otherwise it returns undef.

The superclass implementation returns undef.

=back

=head2 HOW TO DIAL FROM ONE NUMBER TO ANOTHER

=over

=item dial_to

EXPERIMENTAL METHOD

Takes another Number::Phone object as its only argument and returns a
string showing how to dial from the number represented by the invocant
to that represented by the argument.

Examples:

    Call from +44 20 7210 3613
           to +44 1932 341 111
     You dial 01932341111

    Call from +44 20 7210 3613
           to +44 1932 341 111
     You dial 01932341111

    Call from +44 20 7210 3613
           to +1 202 224 6361
     You dial 0012022246361

    Call from +1 202 224 6361
           to +44 20 7210 3613
     You dial 011442072103613

    Call from +44 7979 866975
           to +44 7979 866976
     You dial 07979 866976

This method is implemented in the superclass, but you may have to
define certain other methods to assist it.  The algorithm is as
follows:

=over

=item international call

Append together the source country's international dialling prefix
(usually 00), then the destination country's code code, area code,
and subscriber number.

=item domestic call, different area code

Call the object's C<intra_country_dial_to()> method.

If it dies, return undef.

If it returns anything other than undef, return that.

If it returns undef, append together the country's out-of-area calling
prefix (usually 0 or 1), the destination area code and subscriber
number.

=item domestic call, same area code

Call the object's C<intra_country_dial_to()> method.

If it dies, return undef.

If it returns anything other than undef, return that.

If it returns undef, return the destination subscriber number.

=back

=item intra_country_dial_to

Takes an object (which should be in the same country as the invocant)
and returns either undef (meaning "use the default behaviour") or a
dialling string.  If it dies this means "I don't know how to dial this
number".

The superclass implementation is to die.

Note that the meaning of undef is a bit different for this method.

Why die by default?  Some countries have weird arrangements for dialling
some numbers domestically. In fact, both the countries I'm most familiar
with do, so I assume that others do too.

=back

=head2 CONSTRUCTOR

=over

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
you're talking about, or an object based on Google's libphonenumber
data if there's no complete country-specific module available.

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

=head1 BUGS/FEEDBACK

Please report bugs by email or using
L<https://github.com/DrHyde/perl-modules-Number-Phone/issues>,
including, if possible, a test case.

I welcome feedback from users.

=head1 SEE ALSO

L<http://code.google.com/p/libphonenumber/>, a similar project for Java,
C++ and Javascript

=head1 SOURCE CODE REPOSITORY

L<git://github.com/DrHyde/perl-modules-Number-Phone.git>

=head1 AUTHOR, COPYRIGHT and LICENCE

Copyright 2004 - 2012 David Cantrell E<lt>F<david@cantrell.org.uk>E<gt>

This software is free-as-in-speech software, and may be used,
distributed, and modified under the terms of either the GNU
General Public Licence version 2 or the Artistic Licence.  It's
up to you which one you use.  The full text of the licences can
be found in the files GPL2.txt and ARTISTIC.txt, respectively.

Some files are under the Apache licence, a copy of which can be found in
the file Apache-2.0.txt.

=head1 CONSPIRACY

This module is also free-as-in-mason software.

=cut
