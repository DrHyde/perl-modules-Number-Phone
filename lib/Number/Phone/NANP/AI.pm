package Number::Phone::NANP::AI;

use strict;

use base 'Number::Phone::NANP';

our $VERSION = 1.1;

my $cache = {};

# NB this module doesn't register itself, the NANP module should be
# used and will load this one as necessary

=head1 NAME

Number::Phone::NANP::AI - AI-specific methods for Number::Phone

=head1 DESCRIPTION

This class implements AI-specific methods for Number::Phone.  It is
a subclass of Number::Phone::NANP, which is in turn a subclass of
Number::Phone.  Number::Phone::NANP sits in the middle because all
NANP countries can share some significant chunks of code.  You should
never need to C<use> this module directly, as C<Number::Phone::NANP>
will load it automatically when needed.

=head1 SYNOPSIS

    use Number::Phone::NANP;
    
    my $phone_number = Number::Phone->new('+1 264 497 3924');
    # returns a Number::Phone::NANP::AI object
    
=head1 METHODS

The following methods from Number::Phone are overridden:

=over 4

=item regulator

Returns information about the national telecomms regulator.

=cut

sub regulator { 'PUC, http://www.gov.ai/telecommunications/'; }

=back

=head1 BUGS/FEEDBACK

Please report bugs at L<https://github.com/DrHyde/perl-modules-Number-Phone/issues>, including, if possible, a test case.             

I welcome feedback from users.

=head1 LICENCE

You may use, modify and distribute this software under the same terms as
perl itself.

=head1 AUTHOR

David Cantrell E<lt>david@cantrell.org.ukE<gt>

Copyright 2025

=cut

1;
