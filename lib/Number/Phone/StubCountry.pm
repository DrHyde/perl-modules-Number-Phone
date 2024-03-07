package Number::Phone::StubCountry;

use strict;
use warnings;
use Number::Phone::Country qw(noexport);

use I18N::LangTags::Detect;
use I18N::LangTags;

use base qw(Number::Phone);
our $VERSION = '1.5001';

=head1 NAME

Number::Phone::StubCountry - Base class for auto-generated country files

=cut

sub country_code {
    my $self = shift;

    return $self->{country_code};
}

sub country {
    my $self = shift;
    if(exists($self->{country})) { return $self->{country}; }
    ref($self)=~ /::(\w+?)$/;
    return $self->{country} = $1;
}

sub raw_number {
    my $self = shift;
    $self->{number};
}

sub is_valid {
  my $self = shift;
  if(exists($self->{is_valid})) {
      return $self->{is_valid};
  }
  foreach (map { "is_$_" } qw(specialrate geographic mobile pager tollfree personal ipphone)) {
    return $self->{is_valid} = 1 if($self->$_());
  }
  return $self->{is_valid} = 0;
}

sub is_geographic   { shift()->_validator('geographic'); }
sub is_fixed_line   { shift()->_validator('fixed_line'); }
sub is_mobile       { shift()->_validator('mobile'); }
sub is_pager        { shift()->_validator('pager'); }
sub is_personal     { shift()->_validator('personal_number'); }
sub is_specialrate  { shift()->_validator('specialrate'); }
sub is_tollfree     { shift()->_validator('toll_free'); }
sub is_ipphone      { shift()->_validator('voip'); }

sub _validator {
  my($self, $validator) = @_;
  $validator = $self->{validators}->{$validator};
  return undef unless($validator);
  return $self->raw_number() =~ /^($validator)$/x ? 1 : 0;
}

sub areaname {
    my $self      = shift;
    my @languages = @_;
    if(!@languages) { # nothing specifically asked for? use the locale
        @languages = I18N::LangTags::implicate_supers(I18N::LangTags::Detect::detect());
        if(!grep { $_ eq 'en' } @languages) {
            # and fall back to English
            push @languages, 'en'
        }
    }
    my $number = $self->raw_number();
    LANGUAGE: foreach my $language (@languages) {
        next LANGUAGE unless(exists($self->{areanames}->{$language}));
        my %map = %{$self->{areanames}->{$language}};
        foreach my $prefix (map { substr($number, 0, $_) } reverse(1..length($number))) {
            return $map{$self->country_code().$prefix} if exists($map{$self->country_code().$prefix});
        }
    }
    return undef;
}

sub format {
  my $self = shift;
  my $number = $self->raw_number();
  foreach my $formatter (@{$self->{formatters}}) {
    my($leading_digits, $pattern) = map { $formatter->{$_} } qw(leading_digits pattern);
    if((!$leading_digits || $number =~ /^($leading_digits)/x) && $number =~ /^$pattern$/x) {
      my @bits = $number =~ /^$pattern$/x;
      return join(' ', '+'.$self->country_code(), @bits);
    }
  }
  # if there's no formatters defined ...
  return '+'.$self->country_code().' '.$number;
}

sub timezones {
  my $self = shift;

  # If non-geographic use the country-level timezones
  my $number = $self->is_geographic() ? $self->raw_number() : $self->country_code();

  foreach my $i (reverse (0..length($number))) {
    if (my $timezones = $self->{timezones}->{substr($number, 0, $i)}) {
      my $copy = [@$timezones]; # copy the list-ref to avoid manipulation
      return $copy;
    }
  }

  return undef;
}

1;
