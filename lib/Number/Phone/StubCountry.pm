package Number::Phone::StubCountry;

use strict;
use warnings;
use Number::Phone::Country qw(noexport);

use base qw(Number::Phone);
our $VERSION = '1.3';

sub country_code {
    my $self = shift;
    
    return exists($self->{country_code})
           ? $self->{country_code}
           : Number::Phone::Country::country_code($self->country());
}

sub country {
    my $self = shift;
    if(exists($self->{country})) { return $self->{country}; }
    ref($self)=~ /::(\w\w(\w\w)?)$/; # extra \w\w is for MOCK during testing
    return $1;
}

sub is_valid {
  my $self = shift;
  if(exists($self->{is_valid})) {
      return $self->{is_valid};
  }
  foreach (map { "is_$_" } qw(specialrate geographic mobile pager tollfree personal ipphone)) {
    return 1 if($self->$_());
  }
  return 0;
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
  return $self->{number} =~ /^($validator)$/x ? 1 : 0;
}

sub areaname {
    my $self   = shift;
    my $number = $self->{number};
    return unless $self->{areanames};
    my %map = %{$self->{areanames}};
    foreach my $prefix (map { substr($number, 0, $_) } reverse(1..length($number))) {
        return $map{$self->country_code().$prefix} if exists($map{$self->country_code().$prefix});
    }
    return undef;
}

sub format {
  my $self = shift;
  my $number = $self->{number};
  foreach my $formatter (@{$self->{formatters}}) {
    my($leading_digits, $pattern) = map { $formatter->{$_} } qw(leading_digits pattern);
    if((!$leading_digits || $number =~ /^($leading_digits)/x) && $number =~ /^$pattern$/x) {
      my @bits = $number =~ /^$pattern$/x;
      return join(' ', '+'.$self->country_code(), @bits);
    }
  }
  return '+'.$self->country_code().' '.$number;
}

1;
