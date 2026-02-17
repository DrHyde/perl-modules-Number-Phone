package Number::Phone;

use strict;

use File::ShareDir;
use File::Spec::Functions qw(catfile);
use File::Basename qw(dirname);
use Cwd qw(abs_path);

use Scalar::Util 'blessed';

use Number::Phone::Country;
use Number::Phone::Data;
use Number::Phone::StubCountry;

use Devel::Deprecations::Environmental
    OldPerl => { unsupported_from => '2022-11-08', older_than => '5.10.0' },
    OldPerl => { unsupported_from => '2023-01-08', older_than => '5.12.0' },
    OldPerl => { unsupported_from => '2024-03-09', older_than => '5.14.0' };

# MUST be in format N.NNNN, see https://github.com/DrHyde/perl-modules-Number-Phone/issues/58
our $VERSION = '4.0009';

my $NOSTUBS = 0;
sub import {
  my $class = shift;
  my @params = @_;
  if(grep { /^nostubs$/ } @params) {
    $NOSTUBS++
  }
}

sub _find_data_file {
    my $wanted = shift;

    # giant ball of hate because lib::abs doesn't work on Windows
    my $this_file = __FILE__;
    my $this_dir  = dirname($this_file);

    my @candidate_files = (
         # if this is $devdir/lib ...
         catfile($this_dir, qw(.. .. lib .. share), $wanted),
         # if this is $devdir/blib/lib ...
         catfile($this_dir, qw(.. .. .. blib lib .. .. share), $wanted),
         # if this has been installed
         catfile(File::ShareDir::dist_dir('Number-Phone'), $wanted),
    );
    my $file = (grep { -e $_ } @candidate_files)[0];

    if(!$file) {
        die(
            "Couldn't find data file '$wanted' amongst:\n".
            join('', map { "  $_\n" } @candidate_files)
        );
    }
    return $file;
}

my @is_methods = qw(
    is_valid is_allocated is_in_use
    is_geographic is_fixed_line is_mobile is_pager
    is_tollfree is_specialrate is_adult is_network_service is_personal
    is_corporate is_government is_international
    is_ipphone is_isdn is_drama
);

foreach my $method (
    @is_methods, qw(
        country_code regulator areacode areaname
        subscriber operator operator_ported translates_to
        format location data_source
    )
) {
    no strict 'refs';
    *{__PACKAGE__."::$method"} = sub { undef; }
}

sub type {
    my $self = shift;
    my $rval = [grep { $self->$_() } @is_methods];
    wantarray() ? @{$rval} : $rval;
}

sub country {
    my $class = blessed(shift);
    (my @two_letter_codes) = $class =~ /\b([A-Z]{2})\b/g;
    return $two_letter_codes[-1];
}

sub dial_to {
  my $from = shift;
  my $to   = shift;

  if($from->country_code() != $to->country_code()) {
    return Number::Phone::Country::idd_code($from->country()).
        $to->country_code().
        ($to->isa('Number::Phone::StubCountry')
          ? $to->raw_number()
          : (
              ($to->areacode() ? $to->areacode() : '').
              $to->subscriber()
            )
        );
  }

  # do we know how to do this?
  my $intra_country_dial_to = eval '$from->intra_country_dial_to($to)';
  return undef if($@); # no
  return $intra_country_dial_to if(defined($intra_country_dial_to)); # yes, and here's how

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

sub format_using {
    my $self   = shift;
    my $format = shift;

    return $self->format() if($format eq 'E123');

    eval "use Number::Phone::Formatter::$format";
    die("Couldn't load format '$format': $@\n") if($@);
    return "Number::Phone::Formatter::$format"->format($self->format(), $self);
}

sub format_for_country {
  my $self = shift;
  my $country_code = shift || '';
  $country_code = Number::Phone::Country::country_code($country_code)
    if $country_code && $country_code =~ /[a-z]/i;
  $country_code =~ s/^\+//;
  return $self->format_using('National') if $country_code eq $self->country_code();
  return $self->format_using('NationallyPreferredIntl');
}

sub timezones {
    my $self = shift;

    if (my $stub = Number::Phone::Lib->new($self->format)) {
        return $stub->timezones;
    }

    return undef;
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

MSISDN format is supported.

=head1 INCOMPATIBLE CHANGES

=head2 from version 4.0003 onwards

As of version 4.0003, alphabetic characters and underscores in phone numbers
will cause a warning to be emitted. The first release after August 2026 will
upgrade those to be fatal errors.

=head2 from version 3.9002 onwards

3.9002 is the last version that supported perls with 32-bit integers.

=head2 from version 3.8000 onwards

3.8000 is a bit stricter about numbers and countries not matching in the
constructor. This may affect users who specify places like Guernsey but
provide numbers from Jersey or the Isle of Man, all three of which are separate
jurisdictions squatting on random places all over the UK's number plan.

=head2 from version 3.6000 onwards

As of version 3.6000 the C<areaname> method is documented as taking an optional
language code. As far as I can tell providing this new parameter to the method
as provided by all the subclasses on the CPAN won't do any harm.

=head2 from version 3.4004 onwards

The prefix codes in 3.4003 and earlier were managed by hand and so got out
of date. After that release they are mostly derived from libphonenumber.
libphonenumber's data includes carrier selection codes when they are
mandatory for dialling so those are now included. This sometimes means that
some random carrier has been arbitrarily privileged over others.

=head2 from version 3.4000 to 3.4003

From version 3.4000 to 3.4003 inclusive we accepted any old garbage after
+383 as being valid, as the Kosovo numbering plan had not been published.
Now that that has been published, we use libphonenumber data, and validate
against it.

=head2 until version 3.3000

We used to use KOS for the country code for Kosovo, that has now changed to
XK. See L<Number::Phone::Country>.

=head2 until version 3.0014

Early versions of this module allowed what are now object methods
to also be called as class methods or even as functions. This was a
bad design decision. Use of those calling conventions was deprecated
in version 2.0, released in January 2012, and started to emit
warnings. All code to support those calling conventions has now been removed.

=head1 COMPATIBILITY WITH libphonenumber

libphonenumber is a similar project for other languages, maintained
by Google.

If you pass in a country code for which
no supporting module is available, the constructor will try to use a 'stub'
class under Number::Phone::StubCountry::* that uses data automatically
extracted from Google's libphonenumber project.  libphonenumber doesn't
have enough data to support all the features of Number::Phone.
If you want to disable this, then pass 'nostubs'
when you use the module:

    use Number::Phone qw(nostubs);

Alternatively, if you want to *always* use data derived from libphonenumber,
you should use the L<Number::Phone::Lib> module instead. This is a subclass
of Number::Phone that will use the libphonenumber-derived stub classes even
when extra data is available in, for example, Number::Phone::UK. You might
want to do this for compatibility or performance. Number::Phone::UK is quite
slow, because it uses a huge database for some of its features.

=head1 PERL VERSIONS SUPPORTED

Your perl must support 64 bit ints.

Because they are not supported by some libraries that we depend on, perl
versions below 5.14 are not supported. If you have old versions of those
libraries installed then Number::Phone I<may> still work, but because I can't
automatically test on those older versions any more that is liable to change
without notice.

=cut

sub _new_args {
    my $class = shift;
    my($country, $number) = @_;
    die("Number::Phone->new(): too many params\n") if(exists($_[2]));

    my $original_country;
    $original_country = $country if($country =~ /::/);

    if(!defined($number)) { # one arg
        $number = $country;
    } elsif($country =~ /[a-z]/i) {
        # eg ('UK', '12345')
        #    ('MOCK', ...)
        #    ('InternationalNetworks882', ...)
        # we accept lower-case ISO codes
        $original_country = uc($country) if($country =~ /^[a-z]{2}$/i);
        if($country =~ /^GMSS::[a-zA-Z]+$/) {
            if($number !~ /^\+881/) {
                $number = "+881$number";
            }
        } elsif($country =~ /^InternationalNetworks(88[23])::[a-zA-Z]+$/) {
            my $idd = $1;
            if($number !~ /^\+$idd/) {
                $number = "+$idd$number";
            }
        } elsif(index($number, '+'.Number::Phone::Country::country_code($country)) != 0) {
            $number = '+'.Number::Phone::Country::country_code($country).$number;
        }
    } else { # (+)NNN
        $number = join('', grep { defined } ($country, $number));
    }

    if($number =~ /[^0-9+#*()\[\]{},.<> \t\n\r-]/) {
        warn(__PACKAGE__ . ": ridiculous characters in '$number'\n");
    }
    $number =~ s/[^+0-9]//g;
    $number = "+$number" unless($number =~ /^\+/);

    $country = Number::Phone::Country::phone2country($number) or return;
    if($country eq 'AQ' && $number =~ /^\+882/) {
        $original_country = 'InternationalNetworks882';
    }

    # special cases where you can legitimately ask for a containing country (eg
    # GB) and get back a sub-country (eg GG, which squats upon parts of the GB
    # number plan)
    if(
        ($country eq 'VA'           && $original_country eq 'IT') ||
        ($country =~ /^(IM|GG|JE)$/ && $original_country eq 'GB')
    ) {
        $original_country = $country;
    }

    return ($original_country || $country), $number;
}

sub new {
    my $class = shift;
    my($country, $number) = $class->_new_args(@_);
    return undef unless($country);
    if ($number =~ /^\+1/) {
        $country = "NANP";
    } elsif($country eq 'GB') {
        # for hysterical raisins
        $country = 'UK';
    } elsif($country =~ /^(GG|JE|IM)$/) {
        $country = "UK::$country";
    }
    eval "use Number::Phone::$country";
    if($@ || !"Number::Phone::$country"->isa('Number::Phone')) {
        if($@ =~ /--without_uk/) {
            # a test unexpectedly tried to load Number::Phone::UK, argh!
            die $@
        }
        # undo the above transformations, for stub-land
        if($country eq 'UK') { $country = 'GB' }
        if($country =~ /^UK::(..)/) { $country = $1 }
        return $class->_make_stub_object($number, $country)
    }
    return "Number::Phone::$country"->new($number);
}

sub _make_stub_object {
    my ($class, $number, $country_name) = @_;
    die("no module available for $country_name, and nostubs turned on\n") if($NOSTUBS);

    my $stub_class = "Number::Phone::StubCountry::$country_name";
    eval "use $stub_class";
    if($@ && $number =~ /^\+881/) {
        $stub_class = "Number::Phone::StubCountry::GMSS::$country_name";
        eval "use $stub_class";
    } elsif($@ && $number =~ /^\+882/ && $country_name ne 'AQ') {
        $stub_class = "Number::Phone::StubCountry::InternationalNetworks882::$country_name";
        eval "use $stub_class";
    } elsif($@ && $number =~ /^\+883/) {
        $stub_class = "Number::Phone::StubCountry::InternationalNetworks883::$country_name";
        eval "use $stub_class";
    } elsif($@) {
        my (undef, $country_idd) = Number::Phone::Country::phone2country_and_idd($number);
        # an instance of this class is the ultimate fallback
        (my $local_number = $number) =~ s/(^\+$country_idd|\D)//;
        if($local_number eq '') { return undef; }
        return bless({
            country_code => $country_idd,
            is_valid     => undef,
            number       => $local_number,
        }, 'Number::Phone::StubCountry');
    }

    $stub_class->new($number);
}

=head1 METHODS

All Number::Phone classes can implement the following object methods.

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

=item is_drama

The number is for use in fiction, such as TV and Radio drama programmes.
It will not be allocated for use in real life.

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

This may take an optional language code such as 'de' or 'en'. If
you provide that then you will get back whatever the place name is
in that language, if the data is available. If you don't provide
it then it will first look at your locale settings and try to find
a name in an appropriate language, and if nothing is found fall
back to English.

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

=item timezones

This returns a list-ref of the timezones that could be assoicated with a
geographic number or with the country for non geographic numbers. Returns
undef in the case that possible timezones are unknown.

Data is sourced from Google's libphonenumber project therefore implementation
lies in the stub-countries which return timezones e.g. Europe/London, America/New_York.
Non-stub implementations by default return their stub-country counterpart's
result.

Results are sorted alphabetically.

This method should be considered experimental, and there may be some minor
changes, especially for international "country" codes and non-geographic
numbers.

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

Return a sanely formatted E.123-compliant version of the number, complete with
IDD code, eg for the UK number (0208) 771-2924 it would return +44 20 8771
2924.

The superclass implementation returns undef, which is nonsense, so you
should always implement this.

=item format_using

If you want something different from E.123, then pass this the name of a
L<formatter|Number::Phone::Formatters> to use.

For example, if you want to get "just the digits, ma'am", use the
L<Raw|Number::Phone::Formatter::Raw> formatter thus:

  Number::Phone->new('+44 20 8771 2924')->format_using('Raw');

which will return:

  2087712924

It is a fatal error to specify a non-existent formatter.

=item format_for_country

Given a country code (either two-letter ISO or numeric prefix), return the
number formatted either nationally-formatted, if the number is in the same
country, or as a nationally-preferred international number if not. Internally
this uses the National and NationallyPreferredIntl formatters. Beware of the
potential performance hit!

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

=head2 DATA SOURCES

=over

=item data_source

Class method, return some hopefully useful text about the source of the data
(if any) that drives a country-specific module. The implementation in the base
class returns undef as the base class itself has no data source.

=item libphonenumber_tag

Class method which you should not over-ride, implemented in the base class.
Returns the version of libphonenumber whose metadata was used for this release
of Number::Phone. NB that this is derived from their most recent git tag, so
may occasionally be a little ahead of the most recent libphonenumber release as
the tag gets created before their release is built.

The current version of this is also documented in L<Number::Phone::Data>.

=back

=head2 HOW TO DIAL FROM ONE NUMBER TO ANOTHER

=over

=item dial_to

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
(usually 00), then the destination country's country code, area code
(if the country has such a thing), and subscriber number.

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
Number::Phone::Country. That gives us a two letter country code that
is used to try to load the right module. We then pass the number through to
that module's constructor and return whatever it says (which may be undef
if you pass in an invalid number - see SUBCLASSING below).

The constructor returns undef if it can not figure out what country
you're talking about, or an object based on Google's libphonenumber
data if there's no complete country-specific module available.

It is generally assumed that numbers are complete and unambiguous - ie you
can't normally pass just the local part to the constructor if the number has an
area code. Any subclass's constructor which contravenes this should document
it.

If you call it with two parameters, then the two must match. ie, if you
do this:

    Number::Phone->new("FR", "+441424220001")

you will get C<undef> back because whiel the number is valid, it ain't French.
This usually applies to the case where a single country's number plan contains
other jurisdictions, such as the case of Guernsey, Jersey and the Isle of Man
squatting on the United Kingdom's number plan. For example, this fails, because
the number is from Guernsey, not Jersey:

    Number::Phone->new('JE', '01481256789')

For backward compatibility and convenience, however, if you ask for an object
representing a number in the "host" country but pass a number for the
"sub-country" then you'll get back a valid object representing the sub-country:

    my $gg_number = Number::Phone->new('GB', '01481256789')

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

=head1 UPDATES

I release updates approximately every three months, including new data.

I will also do intercalary releases to fix *serious* bugs in the code
and when *large* data updates (eg when a country's numbering scheme changes)
are brought to my attention.

I will not normally do a release just because a country has added some
new number range. If this irks you then I would welcome a discussion on
how you can best write a patch, with tests, that will reliably incorporate
updated data from libphonenumber. Much of the needed code already exists
in the repository but it is not fit for end-user consumption.

=head1 BUGS/FEEDBACK

Please report bugs by at L<https://github.com/DrHyde/perl-modules-Number-Phone/issues>, including, if possible, a test case.

=head1 MAILING LIST

There is a mailing list for announcements, discussion and help. Please
subscribe at L<https://groups.google.com/g/number-phone>.

=head1 SEE ALSO

L<https://github.com/googlei18n/libphonenumber>, a similar project for Java,
C++ and Javascript. Number::Phone imports its data.

=head1 SOURCE CODE REPOSITORY

L<git://github.com/DrHyde/perl-modules-Number-Phone.git>

=head1 AUTHOR, COPYRIGHT and LICENCE

Copyright 2004 - 2025 David Cantrell E<lt>F<david@cantrell.org.uk>E<gt>

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
