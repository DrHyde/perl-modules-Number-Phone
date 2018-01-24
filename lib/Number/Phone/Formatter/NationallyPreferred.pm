package Number::Phone::Formatter::NationallyPreferred;

use strict;
use warnings;
use Scalar::Util qw(reftype);

sub _regex_variable {
    my ($var, $qr, $subs) = @_;
    $subs =~ s/"/\\"/;
    $subs = "\"$subs\"";
    $var =~ s/$qr/$subs/xee;
    return $var;
}

sub format {
    my ($class, $number, $object) = @_;

    # Only care about the ones that will have the formatters stored
    return $number unless reftype $object eq 'HASH';

    # Don't care about passed in $number in that case
    $number = $object->{number};
    foreach my $formatter (@{$object->{formatters}}) {
        my ($leading_digits, $pattern) = map { $formatter->{$_} } qw(leading_digits pattern);
        if ((!$leading_digits || $number =~ /^($leading_digits)/x) && $number =~ /^$pattern$/x) {
            my $format = $formatter->{intl_format} || $formatter->{format};
            $number = _regex_variable($number, qr/^$pattern$/, $format);
            return '+' . $object->country_code() . ' ' . $number;
        }
    }
    return '+' . $object->country_code() . ' ' . $number;
}

1;

=head1 NAME

Number::Phone::Formatter::NationallyPreferred - formatter for nationally-preferred international phone number

=head1 DESCRIPTION

A formatter to output the international number in its nationally preferred format.

=head1 METHOD

=head2 format

This is the only method. It takes an E.123 international format string and a Number::Phone object,
and outputs the nationally-preferred international phone number if data is available (generally this
means if you're using L<Number::Phone::Lib> or a stub derived from libphoennumber). If no data is available
then it returns the E.123 formatted data.

  +1 212 334 0611 -> +1 212-334-0611

=head1 AUTHOR, COPYRIGHT and LICENCE

Copyright 2018 Matthew Somerville E<lt>F<matthew-github@dracos.co.uk>E<gt>

This software is free-as-in-speech software, and may be used,
distributed, and modified under the terms of either the GNU
General Public Licence version 2 or the Artistic Licence.  It's
up to you which one you use.  The full text of the licences can
be found in the files GPL2.txt and ARTISTIC.txt, respectively.

=cut
