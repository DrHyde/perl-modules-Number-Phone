package Number::Phone::UK;

use strict;

use Scalar::Util 'blessed';
use Number::Phone::UK::Data;

use base 'Number::Phone';

our $VERSION = '1.72';

my $cache = {};

=head1 NAME

Number::Phone::UK - UK-specific methods for Number::Phone

=head1 SYNOPSIS

    use Number::Phone;

    $daves_phone = Number::Phone->new('+44 1234 567890');

=cut

sub new {
    my $class = shift;
    my $number = shift;

    $number = '+44'._clean_number($number);
    if(is_valid($number)) {
        $number =~ s/^0/+44/;
        my $target_class = $class->_get_class(_clean_number($number));
        return undef if($class ne $target_class);
        return bless(\$number, $target_class);
    } else { return undef; }
}

=head1 DATABASE

Number::Phone::UK uses a large database, access via L<Number::Phone::UK::Data>. This
database lives in a file, and normally only the little bits of it that you access will
ever get loaded into memory. This means, however, that creating Number::Phone::UK objects
almost always involves disk access and so is slow compared to data for some other
countries. There are two ways to avoid this slowness.

First, if you don't need all the functionality you can use L<Number::Phone::Lib>.

Second, if you can accept slow startup - eg when your server starts - then you can call
C<< Number::Phone::UK::Data->slurp() >> from your code, which will pull the entire database
into memory. This will take a few minutes, and on a 64-bit machine will consume of the
order of 200MB of memory.

The database uses L<Data::CompactReadonly>. This may have some problems if you connect to it,
C<fork()>, and then try to access the database from multiple processes. We attempt to
work around this by re-connecting to the database after forking. This is, of course,
not a problem if you C<slurp()> the database before forking.

=head1 METHODS

The following methods from Number::Phone are overridden:

=over 4

=item new

The constructor, you should never have to call this yourself. To create an
object the canonical incantation is C<< Number::Phone->new('+44 ...') >>.

=item data_source

Returns a string telling where and when the data that drives this class was last updated, looking something like:

    "OFCOM at Wed Sep 30 10:37:39 2020 UTC"

The current value of this is also documented in L<Number::Phone::Data>.

=item is_valid

The number is valid within the national numbering scheme.  It may or may
not yet be allocated, or it may be reserved.  Any number which returns
true for any of the following methods will also be valid.

=cut

sub _get_class {
  my $class = shift;
  my $number = shift;
  foreach my $prefix (_prefixes($number)) {
    if(exists(Number::Phone::UK::Data::db()->{subclass}->{$prefix})) {
      return $class if(Number::Phone::UK::Data::db()->{subclass}->{$prefix} eq '');

      my $desired_subclass = Number::Phone::UK::Data::db()->{subclass}->{$prefix};
      my $subclass = "Number::Phone::UK::$desired_subclass";
      eval "use $subclass";
      return $subclass;
    }
  }
  return $class;
}

sub _clean_number {
    my $clean = shift;
    $clean =~ s/[^0-9+]//g;               # strip non-digits/plusses
    $clean =~ s/^\+44//;                  # remove leading +44
    $clean =~ s/^0//;                     # kill leading zero
    return $clean;
}

sub _prefixes {
    my $number = shift;
    map { substr($number, 0, $_) } reverse(1..length($number));
}

sub is_valid {
    my $number = shift;

    # If called as an object method, it *must* be valid otherwise the
    # object would never have been instantiated.
    # If called as a subroutine, that's the constructor doing its thang.
    return 1 if(blessed($number));

    # otherwise we have to validate

    # if we've seen this number before, use cached result
    return 1 if($cache->{$number}->{is_valid});

    # assume it's OK unless proven otherwise
    $cache->{$number}->{is_valid} = 1;

    my $cleaned_number = _clean_number($number);

    my @prefixes = _prefixes($cleaned_number);

    # quickly check length
    return $cache->{$number}->{is_valid} = 0 if(length($cleaned_number) < 7 || length($cleaned_number) > 10);

    # 04 and 06 are invalid, only 05[56] are valid
    return $cache->{$number}->{is_valid} = 0 if($cleaned_number =~ /^(4|5[01234789]|6)/);

    # slightly more rigourous length check for some unallocated geographic numbers
    # 07, 02x and 011x are always ten digits
    return $cache->{$number}->{is_valid} = 0 if($cleaned_number =~ /^([27]|11)/ && length($cleaned_number) != 10);

    my $telco;
    my $format;
    foreach my $prefix (@prefixes) {
        if(exists(Number::Phone::UK::Data::db()->{telco}->{$prefix})) {
            $telco = Number::Phone::UK::Data::db()->{telco}->{$prefix};
            last;
        }
    }
    foreach my $prefix (@prefixes) {
        if(exists(Number::Phone::UK::Data::db()->{format}->{$prefix})) {
            $format = Number::Phone::UK::Data::db()->{format}->{$prefix};
            last;
        }
    }

    $cache->{$number}->{is_allocated} = 0;
    $cache->{$number}->{format} = $format;
    if($telco) {
        $cache->{$number}->{is_allocated} = 1;
        $cache->{$number}->{operator} = $telco;
    }

    if($cache->{$number}->{format} && $cache->{$number}->{format} =~ /\+/) {
        my($arealength, $subscriberlength) = split(/\+/, $cache->{$number}->{format});
        # for hateful mixed thing
        my @subscriberlengths = ($subscriberlength =~ m{/}) ? split(/\//, $subscriberlength) : ($subscriberlength);
        $subscriberlength =~ s/^(\d+).*/$1/; # for hateful mixed thing
        $cache->{$number}->{areacode} = substr($cleaned_number, 0, $arealength);
        $cache->{$number}->{subscriber} = substr($cleaned_number, $arealength);
        $cache->{$number}->{areaname} = (
            map {
                Number::Phone::UK::Data::db()->{areanames}->{$_}
            } grep {
                exists(Number::Phone::UK::Data::db()->{areanames}->{$_})
            } @prefixes
        )[0];
        if(!grep { length($cache->{$number}->{subscriber}) == $_ } @subscriberlengths) {
            # number wrong length!
            $cache->{$number} = { is_valid => 0 };
            return 0;
        }
    }

    return $cache->{$number}->{is_valid};
}

# now define the is_* methods that we over-ride
sub is_fixed_line {
  return 0 if(is_mobile(@_));
  return undef;
}

sub is_drama {
    my $self = shift;

    my $num = _clean_number(${$self});

    my @drama_numbers = (
        # Leeds, Sheffield, Nottingham, Leicester, Bristol, Reading
        qr/^11[3-8]4960[0-9]{3}$/,
        # Birmingham, Edinburgh, Glasgow, Liverpool, Manchester
        qr/^1[2-6]14960[0-9]{3}$/,
        # London
        qr/^2079460[0-9]{3}$/,
        # Tyneside/Durham/Sunderland
        qr/^1914980[0-9]{3}$/,
        # Northern Ireland
        qr/^2896496[0-9]{3}$/,
        # Cardiff
        qr/^2920180[0-9]{3}$/,
        # No area
        qr/^1632960[0-9]{3}$/,
        # Mobile
        qr/^7700900[0-9]{3}$/,
        # Freephone
        qr/^8081570[0-9]{3}$/,
        # Premium Rate
        qr/^9098790[0-9]{3}$/,
        # UK Wide
        qr/^3069990[0-9]{3}$/,
    );

    foreach my $d (@drama_numbers) {
        return 1 if ($num =~ $d);
    }

    return 0;
}

foreach my $is (qw(
    geographic network_service tollfree corporate
    personal pager mobile specialrate adult allocated ipphone
)) {
    no strict 'refs';
    *{__PACKAGE__."::is_$is"} = sub {
        my $self = shift;
        if(!exists($cache->{${$self}}->{"is_$is"})) {
          $cache->{${$self}}->{"is_$is"} = 
            grep {
              exists(
                Number::Phone::UK::Data::db()->{
                  { geographic      => 'geo_prefices',
                    network_service => 'network_svc_prefices',
                    tollfree        => 'free_prefices',
                    corporate       => 'corporate_prefices',
                    personal        => 'personal_prefices',
                    pager           => 'pager_prefices',
                    mobile          => 'mobile_prefices',
                    specialrate     => 'special_prefices',
                    adult           => 'adult_prefices',
                    ipphone         => 'ip_prefices'
                  }->{$is}
                }->{$_}
              );
            } _prefixes(_clean_number(${$self}));
        }
        $cache->{${$self}}->{"is_$is"};
    }
}

# define the other methods

foreach my $method (qw(operator areacode areaname subscriber)) {
    no strict 'refs';
    *{__PACKAGE__."::$method"} = sub {
        my $self = shift;
        return $cache->{${$self}}->{$method};
    }
}

=item is_allocated

The number has been allocated to a telco for use.  It may or may not yet
be in use or may be reserved.

=item is_drama

The number is intended for use in fiction. OFCOM has allocated numerous small
ranges for this purpose. These numbers will not be allocated to real customers.
See L<http://stakeholders.ofcom.org.uk/telecoms/numbering/guidance-tele-no/numbers-for-drama>
for the authoritative source.

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

    return undef unless($self->is_geographic());

    my $cleaned_number = _clean_number(${$self});

    my @prefixes = _prefixes($cleaned_number);

    # uncoverable branch true
    if(!$ENV{TESTINGKILLTHEWABBIT}) {
        eval "require Number::Phone::UK::DetailedLocations"; # uncoverable statement
    }
    require Number::Phone::UK::Exchanges if(!$Number::Phone::UK::Exchanges::db);

    foreach(@prefixes) {
        if(exists($Number::Phone::UK::Exchanges::db->{exchg_prefices}->{$_})) {
            return [
                $Number::Phone::UK::Exchanges::db->{exchg_positions}->{$Number::Phone::UK::Exchanges::db->{exchg_prefices}->{$_}}->{lat},
                $Number::Phone::UK::Exchanges::db->{exchg_positions}->{$Number::Phone::UK::Exchanges::db->{exchg_prefices}->{$_}}->{long}
            ];
        }
    }
    # may become coverable if I ever test the location of a number
    # in an areacode that wasn't in the data dump I got years ago
    return undef; # uncoverable statement
}

=item subscriber

Return the subscriber part of the number

=item operator

Return the name of the telco operating this number, in an appropriate
character set and with optional details such as their web site or phone
number.

=item format

Return a sanely formatted version of the number, complete with IDD code, eg
for the UK number (0208) 771-2924 it would return +44 20 8771 2924.

=cut

sub format {
    my $self = shift;
    my $r;

    if($self->areacode()) { # if there's an areacode ...
        $r = '+'.country_code().' '.$self->areacode().' ';
        if(    length($self->subscriber()) == 7) { $r .= substr($self->subscriber(), 0, 3).' '.substr($self->subscriber(), 3) }
         elsif(length($self->subscriber()) == 8) { $r .= substr($self->subscriber(), 0, 4).' '.substr($self->subscriber(), 4) }
         else                                    { $r .= $self->subscriber() }
    } elsif($self->subscriber && $self->subscriber =~ /^7/) { # mobiles/pagers don't have areacodes but should be formatted as if they do
        $r = '+'.country_code().
             ' '.substr($self->subscriber(), 0, 4).
             ' '.substr($self->subscriber(), 4);
    } elsif(!$self->is_allocated() || !$cache->{${self}}->{format}) { # if not allocated or no format
        $r = '+'.country_code().' '.substr(${$self}, 3)
    } elsif($self->subscriber()) { # if there's a subscriber ...
        $r = '+'.country_code().' '.$self->subscriber
    }
    return $r;
}

=item intra_country_dial_to

Within the UK numbering plan you can *always* dial 0xxxx xxxxxx
for intra-country calls. In most places the leading 0$areacode is
optional but in some it is required (see eg
L<https://www.ofcom.org.uk/__data/assets/pdf_file/0017/19160/aberdeen_local_dialling_release.pdf>) and over time this
will apply to more areas.

=cut

sub intra_country_dial_to {
  my $from = shift;
  my $to   = shift;

  die if(!$to->is_allocated());
  return '0'.($to->areacode() ? $to->areacode() : '').$to->subscriber();
}

=item country

If the number is_international, return the two-letter ISO country code.

NYI

=back

=head1 LIMITATIONS/BUGS/FEEDBACK

The results are only as up-to-date as the data included from OFCOM's
official documentation of number range allocations.

No attempt is made to deal with number portability.

Please report bugs at L<https://github.com/DrHyde/perl-modules-Number-Phone/issues>, including, if possible, a test case.             

I welcome feedback from users.

=head1 LICENCE

You may use, modify and distribute this software under the same terms as
perl itself.

=head1 AUTHOR

David Cantrell E<lt>david@cantrell.org.ukE<gt>

Copyright 2024

=cut

1;
