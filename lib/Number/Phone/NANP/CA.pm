package Number::Phone::NANP::CA;

use strict;

use base 'Number::Phone::NANP';

use Number::Phone::Country qw(noexport);

our $VERSION = 1.1001;

my $cache = {};

# NB this module doesn't register itself, the NANP module should be
# used and will load this one as necessary

=head1 NAME

Number::Phone::NANP::CA - CA-specific methods for Number::Phone

=head1 DESCRIPTION

This class implements CA-specific methods for Number::Phone.  It is
a subclass of Number::Phone::NANP, which is in turn a subclass of
Number::Phone.  Number::Phone::NANP sits in the middle because all
NANP countries can share some significant chunks of code.  You should
never need to C<use> this module directly, as C<Number::Phone::NANP>
will load it automatically when needed.

=head1 SYNOPSIS

    use Number::Phone::NANP;
    
    my $phone_number = Number::Phone->new('+1 613 563 7242');
    # returns a Number::Phone::NANP::CA object
    
=head1 METHODS

The following methods from Number::Phone::NANP are overridden:

=over 4

=item data_source

Returns a string telling where and when the data for CA operators was last updated, looking something like:

    "CNAC at Wed Sep 30 10:37:39 2020 UTC"

The current value of this is also documented in L<Number::Phone::Data>.

=item regulator

Returns information about the national telecomms regulator.

=cut

sub regulator { 'CRTC, http://www.crtc.gc.ca/'; }

=back

=head1 BUGS/FEEDBACK

Please report bugs at L<https://github.com/DrHyde/perl-modules-Number-Phone/issues>, including, if possible, a test case.             

I welcome feedback from users.

=head1 LICENCE

You may use, modify and distribute this software under the same terms as
perl itself.

=head1 AUTHOR

David Cantrell E<lt>david@cantrell.org.ukE<gt>

Copyright 2023

=cut

1;
