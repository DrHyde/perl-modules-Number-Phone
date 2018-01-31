package Number::Phone::Formatter;

use strict;
use warnings;

sub _regex_variable {
    my ($var, $qr, $subs) = @_;
    $subs =~ s/"/\\"/;
    $subs = "\"$subs\"";
    $var =~ s/$qr/$subs/xee;
    return $var;
}

sub _maybe_add_country {
    my ($object, $number, $national) = @_;
    $number = '+' . $object->country_code() . ' ' . $number unless $national;
    return $number;
}

sub _format {
    my ($class, $object, $national) = @_;

    my $number = $object->{number};
    foreach my $formatter (@{$object->{formatters}}) {
        my ($leading_digits, $pattern) = map { $formatter->{$_} } qw(leading_digits pattern);
        if ((!$leading_digits || $number =~ /^($leading_digits)/x) && $number =~ /^$pattern$/x) {
            my $format;
            if ($national && $formatter->{national_rule}) {
                $format = _regex_variable($formatter->{format}, qr/(\$\d)/, $formatter->{national_rule});
            } else {
                $format = $formatter->{intl_format} || $formatter->{format};
            }
            $number = _regex_variable($number, qr/^$pattern$/, $format);
            return _maybe_add_country($object, $number, $national);
        }
    }
    return _maybe_add_country($object, $number, $national);
}

1;

=head1 NAME

Number::Phone::Formatter - base class for other formatters

=head1 DESCRIPTION

A base class containing utility functions used by the formatters.

=head1 AUTHOR, COPYRIGHT and LICENCE

Copyright 2018 Matthew Somerville E<lt>F<matthew-github@dracos.co.uk>E<gt>

This software is free-as-in-speech software, and may be used,
distributed, and modified under the terms of either the GNU
General Public Licence version 2 or the Artistic Licence.  It's
up to you which one you use.  The full text of the licences can
be found in the files GPL2.txt and ARTISTIC.txt, respectively.

=cut
