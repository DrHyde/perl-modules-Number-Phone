package Number::Phone::StubCountry;

use strict;
use warnings;
use Number::Phone::Country qw(noexport uk);

use base qw(Number::Phone);
our $VERSION = '1.1';

sub country_code {
    my $self = shift;
    
    return exists($self->{country_code})
           ? $self->{country_code}
           : Number::Phone::Country::country_code($self->country());
}

sub country {
    my $self = shift;
    if(exists($self->{country})) { return $self->{country}; }
    if(ref($self) =~ /::(\w\w(\w\w)?)$/) { # extra \w\w is for MOCK during testing
        return $1;
    }
    return undef;
}

sub is_valid {
  my $self = shift;
  if(exists($self->{is_valid})) {
      return $self->{is_valid};
  }
  foreach (map { "is_$_" } qw(special_rate geographic mobile pager tollfree personal ipphone)) {
    return 1 if($self->$_());
  }
  return 0;
}

sub is_geographic   { shift()->_validator('geographic'); }
sub is_fixed_line   { shift()->_validator('fixed_line'); }
sub is_mobile       { shift()->_validator('mobile'); }

sub is_pager        { shift()->_validator('pager'); }
sub is_personal     { shift()->_validator('personal_number'); }
sub is_special_rate { shift()->_validator('special_rate'); }
sub is_tollfree     { shift()->_validator('toll_free'); }
sub is_ipphone      { shift()->_validator('voip'); }

sub _validator {
  my($self, $validator) = @_;
  $validator = $self->{validators}->{$validator};
  return undef unless($validator);
  return $self->{number} =~ /^($validator)$/ ? 1 : 0;
}

sub format {
  my $self = shift;
  my $number = $self->{number};
  foreach my $formatter (@{$self->{formatters}}) {
    my($leading_digits, $pattern) = map { $formatter->{$_} } qw(leading_digits pattern);
    if((!$leading_digits || $number =~ /^($leading_digits)/) && $number =~ /^$pattern$/) {
      my @bits = $number =~ /^$pattern$/;
      return join(' ', '+'.$self->country_code(), @bits);
    }
  }
  return '+'.$self->country_code().' '.$number;
}

1;
