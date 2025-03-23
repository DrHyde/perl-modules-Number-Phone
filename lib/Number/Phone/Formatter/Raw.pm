package Number::Phone::Formatter::Raw;

use strict;
use warnings;

sub format {
    my $class = shift;
    my $number = shift;
    $number =~ s/.*?\s//;
    $number =~ s/\D//g;
    return $number
}

1;

=head1 NAME

Number::Phone::Formatter::Raw - simple formatter for E.123-formatted phone numbers

=head1 DESCRIPTION

A simple formatter to extract "just the digits, ma'am" from an E.123-formatted phone number.

=head1 METHOD

=head2 format

This is the only method. It takes an E.123 international format string as its only argument, strips off the leading + and country code, and any whitespace, and returns what's left. For example ...

  +44 20 8771 2924 -> 2087712924

  +1 212 334 0611  -> 2123340611

=head1 AUTHOR, COPYRIGHT and LICENCE

Copyright 2025 David Cantrell E<lt>F<david@cantrell.org.uk>E<gt>

This software is free-as-in-speech software, and may be used,
distributed, and modified under the terms of either the GNU
General Public Licence version 2 or the Artistic Licence.  It's
up to you which one you use.  The full text of the licences can
be found in the files GPL2.txt and ARTISTIC.txt, respectively.

=cut
