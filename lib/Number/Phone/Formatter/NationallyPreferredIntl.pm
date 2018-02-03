package Number::Phone::Formatter::NationallyPreferredIntl;

use strict;
use warnings;
use parent 'Number::Phone::Formatter';
use Scalar::Util qw(reftype);

our $VERSION = '1.0';

sub format {
    my ($class, $number, $object) = @_;

    $class->_format($object, 0);
}

1;

=head1 NAME

Number::Phone::Formatter::NationallyPreferredIntl - nationally-preferred format for international phone number

=head1 DESCRIPTION

A formatter to output the international number in its nationally preferred format.

=head1 METHOD

=head2 format

This is the only method. It takes an E.123 international format string and a Number::Phone object,
and outputs the nationally-preferred international representation of the  phone number.

  +1 212 334 0611 -> +1 212-334-0611

Note that this uses data derived from libphonenumber, and if your object is
not derived from that it will first create a temporary object. This may
involve a small unexpected performance hit.

=head1 AUTHOR, COPYRIGHT and LICENCE

Copyright 2018 Matthew Somerville E<lt>F<matthew-github@dracos.co.uk>E<gt>

This software is free-as-in-speech software, and may be used,
distributed, and modified under the terms of either the GNU
General Public Licence version 2 or the Artistic Licence.  It's
up to you which one you use.  The full text of the licences can
be found in the files GPL2.txt and ARTISTIC.txt, respectively.

=cut
