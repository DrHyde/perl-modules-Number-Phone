package Number::Phone::UK;

use strict;

use Scalar::Util 'blessed';
use Number::Phone::UK::Data;

use base 'Number::Phone';

our $VERSION = 1.556;

my $cache = {};

=head1 NAME

Number::Phone::UK - UK-specific methods for Number::Phone

=head1 SYNOPSIS

    use Number::Phone::UK;

    $daves_phone = Number::Phone->new('+44 1234 567890');

=cut

sub new {
    my $class = shift;
    my $number = shift;
    die("No number given to ".__PACKAGE__."->new()\n") unless($number);

    if(is_valid($number)) {
        return bless(\$number, $class);
    } else { return undef; }
}

=head1 METHODS

The following methods from Number::Phone are overridden:

=over 4

=item is_valid

The number is valid within the national numbering scheme.  It may or may
not yet be allocated, or it may be reserved.  Any number which returns
true for any of the following methods will also be valid.

=cut

sub is_valid {
    my $number = shift;

    # if called as an object method, it *must* be valid otherwise the
    # object would never have been instantiated.
    return 1 if(blessed($number) && $number->isa(__PACKAGE__));

    # otherwise we have to validate

    # if we've seen this number before, use cached result
    return 1 if($cache->{$number}->{is_valid});

    my $parsed_number = $number;
    $parsed_number =~ s/[^0-9+]//g;               # strip non-digits/plusses
    $parsed_number =~ s/^\+44//;                  # remove leading +44
    $parsed_number =~ s/^0//;                     # kill leading zero

    # @digits{qw(A B C D E F)} = split(//, $parsed_number, 7);

    my @retards = map { substr($parsed_number, 0, $_) } reverse 1..7;

    # and quickly check length
    $cache->{$number}->{is_valid} = (length($parsed_number) > 6 && length($parsed_number) < 11) ? 1 : 0;
    return 0 unless($cache->{$number}->{is_valid});

    $cache->{$number}->{is_geographic} =
	grep { $Number::Phone::UK::Data::db->{geo_prefices}->{$_} } @retards;
    $cache->{$number}->{is_network_service} =
	grep { $Number::Phone::UK::Data::db->{network_svc_prefices}->{$_} } @retards;
    $cache->{$number}->{is_tollfree} =
	grep { $Number::Phone::UK::Data::db->{free_prefices}->{$_} } @retards;
    $cache->{$number}->{is_corporate} =
	grep { $Number::Phone::UK::Data::db->{corporate_prefices}->{$_} } @retards;
    $cache->{$number}->{is_personal} =
	grep { $Number::Phone::UK::Data::db->{personal_prefices}->{$_} } @retards;
    $cache->{$number}->{is_pager} =
	grep { $Number::Phone::UK::Data::db->{pager_prefices}->{$_} } @retards;
    $cache->{$number}->{is_fixed_line} = 0 if(
      $cache->{$number}->{is_mobile} =
	grep { $Number::Phone::UK::Data::db->{mobile_prefices}->{$_} } @retards
    );

    $cache->{$number}->{is_specialrate} =
	grep { $Number::Phone::UK::Data::db->{special_prefices}->{$_} } @retards;
    $cache->{$number}->{is_adult} =
	grep { $Number::Phone::UK::Data::db->{adult_prefices}->{$_} } @retards;
    $cache->{$number}->{is_ipphone} =
	grep { $Number::Phone::UK::Data::db->{ip_prefices}->{$_} } @retards;
    $cache->{$number}->{is_allocated} = 
	grep { $Number::Phone::UK::Data::db->{telco_and_length}->{$_} } @retards;
    if($cache->{$number}->{is_allocated}) {
        my($telco_and_length) = map { $Number::Phone::UK::Data::db->{telco_and_length}->{$_} } grep { $Number::Phone::UK::Data::db->{telco_and_length}->{$_} } @retards;
	$cache->{$number}->{operator} = $Number::Phone::UK::Data::db->{telco_format}->{$telco_and_length}->{telco};
	$cache->{$number}->{format} = $Number::Phone::UK::Data::db->{telco_format}->{$telco_and_length}->{format};
	if(defined($cache->{$number}->{format}) && $cache->{$number}->{format} =~ /\+/) {
	    my($arealength, $subscriberlength) = split(/\+/, $cache->{$number}->{format});
            # for hateful mixed thing
            my @subscriberlengths = ($subscriberlength =~ m{/}) ? split(/\//, $subscriberlength) : ($subscriberlength);
            $subscriberlength =~ s/^(\d+).*/$1/; # for hateful mixed thing
	    $cache->{$number}->{areacode} = substr($parsed_number, 0, $arealength);
	    $cache->{$number}->{subscriber} = substr($parsed_number, $arealength);
            $cache->{$number}->{areaname} = (
                map {
                    $Number::Phone::UK::Data::db->{areanames}->{$_}
                } grep { $Number::Phone::UK::Data::db->{areanames}->{$_} } @retards
            )[0];
	    if(!grep { length($cache->{$number}->{subscriber}) == $_ } @subscriberlengths) {
	        # number wrong length!
                $cache->{$number} = undef;
		return 0;
	    }
	}
    }
    return $cache->{$number}->{is_valid};
}

# now define the is_* methods that we over-ride

foreach my $is (qw(
    fixed_line geographic network_service tollfree corporate
    personal pager mobile specialrate adult allocated ipphone
)) {
    no strict 'refs';
    *{__PACKAGE__."::is_$is"} = sub {
        my $self = shift;
	$self = shift if($self eq __PACKAGE__);
	$self = __PACKAGE__->new($self)
	    unless(blessed($self) && $self->isa(__PACKAGE__));
	$cache->{${$self}}->{"is_$is"};
    }
}

# define the other methods

foreach my $method (qw(operator areacode areaname subscriber)) {
    no strict 'refs';
    *{__PACKAGE__."::$method"} = sub {
        my $self = shift;
        $self = (blessed($self) && $self->isa(__PACKAGE__)) ?
            $self :
            __PACKAGE__->new($self);
        return $cache->{${$self}}->{$method};
    }
}

=item is_allocated

The number has been allocated to a telco for use.  It may or may not yet
be in use or may be reserved.

=item is_geographic

The number refers to a geographic area.

=item is_fixed_line

The number, when in use, can only refer to a fixed line.

(we can't tell whether a number is a fixed line, but we can tell that
some are *not*).

=item is_mobile

The number, when in use, can only refer to a mobile phone.

=item is_pager

The number, when in use, can only refer to a pager.

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

=item is_ipphone

The number, when in use, is terminated using VoIP.

=item is_network_service

The number is some kind of network service such as a human operator, directory
enquiries, emergency services etc

=item country_code

Returns 44.

=cut

sub country_code { 44; }

=item regulator

Returns informational text.

=cut

sub regulator { 'OFCOM, http://www.ofcom.org.uk/'; }

=item areacode

Return the area code - if applicable - for the number.  If not applicable,
returns undef.

=item areaname

Return the area name - if applicable - for the number, or undef.

=item location

For geographic numbers, this returns the location of the exchange to which
that number is assigned, if available.  Otherwise returns undef.

=cut

sub location {
    my $self = shift;
    $self = (blessed($self) && $self->isa(__PACKAGE__)) ?
        $self :
        __PACKAGE__->new($self);

    return undef unless($self->is_geographic());

    my $parsed_number = ${$self};
    $parsed_number =~ s/[^0-9+]//g;               # strip non-digits/plusses
    $parsed_number =~ s/^\+44//;                  # remove leading +44
    $parsed_number =~ s/^0//;                     # kill leading zero

    my @retards = map { substr($parsed_number, 0, $_) } reverse(1..length($parsed_number));

    eval "require Number::Phone::UK::DetailedLocations" unless($ENV{TESTINGKILLTHEWABBIT});
    require Number::Phone::UK::Exchanges if(!$Number::Phone::UK::Exchanges::db);

    foreach(@retards) {
        if(exists($Number::Phone::UK::Exchanges::db->{exchg_prefices}->{$_})) {
            return [
                $Number::Phone::UK::Exchanges::db->{exchg_positions}->{$Number::Phone::UK::Exchanges::db->{exchg_prefices}->{$_}}->{lat},
                $Number::Phone::UK::Exchanges::db->{exchg_positions}->{$Number::Phone::UK::Exchanges::db->{exchg_prefices}->{$_}}->{long}
            ];
        }
    }

    return undef;
}

=item subscriber

Return the subscriber part of the number

=item operator

Return the name of the telco operating this number, in an appropriate
character set and with optional details such as their web site or phone
number.

=item format

Return a sanely formatted version of the number, complete with IDD code, eg
for the UK number (0208) 771-2924 it would return +44 20 87712924.

=cut

sub format {
    my $self = shift;
    $self = (blessed($self) && $self->isa(__PACKAGE__)) ?
        $self :
        __PACKAGE__->new($self);
    return '+'.country_code().' '.(
	$self->areacode()      ? $self->areacode().' '.$self->subscriber() :
	!$self->is_allocated() ? substr(${$self}, 1 + length(country_code()))
	                       : $self->subscriber()
    );
}

=item country

If the number is_international, return the two-letter ISO country code.

NYI

=back

=head1 LIMITATIONS/BUGS/FEEDBACK

The results are only as up-to-date as the data included from OFCOM's
official documentation of number range allocations.

No attempt is made to deal with number portability.

Please report bugs by email, including, if possible, a test case.             

I welcome feedback from users.

=head1 LICENCE

You may use, modify and distribute this software under the same terms as
perl itself.

=head1 AUTHOR

David Cantrell E<lt>david@cantrell.org.ukE<gt>

Copyright 2004 - 2007

=cut

1;
