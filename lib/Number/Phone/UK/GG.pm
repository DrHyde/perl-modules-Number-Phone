package Number::Phone::UK::GG;

use strict;

use base 'Number::Phone::UK';

our $VERSION = 1.1;

=head1 NAME

Number::Phone::UK::GG - GG-specific methods for Number::Phone

=head1 DESCRIPTION

This class implements GG-specific methods for Number::Phone.  It is
a subclass of Number::Phone::UK, which is in turn a subclass of
Number::Phone.  Number::Phone::UK sits in the middle because GG is
treated as part of the UK for just about all telephonic purposes.
You should
never need to C<use> this module directly, as C<Number::Phone::UK>
will load it automatically when needed.

=head1 SYNOPSIS

    use Number::Phone::UK
    
    my $phone_number = Number::Phone->new('+44 1481 200000');
    # returns a Number::Phone::UK::GG object
    
=head1 METHODS

The following methods from Number::Phone::UK are overridden:

=over 4

=item regulator

Returns information about the national telecomms regulator.

=cut

sub regulator { return 'Guernsey Competition & Regulatory Authority, https://www.gcra.gg/' }

=back

=head1 BUGS/FEEDBACK

Please report bugs at L<https://github.com/DrHyde/perl-modules-Number-Phone/issues>, including, if possible, a test case.             

I welcome feedback from users.

=head1 LICENCE

You may use, modify and distribute this software under the same terms as
perl itself.

=head1 AUTHOR

David Cantrell E<lt>david@cantrell.org.ukE<gt>

Copyright 2011

=cut

1;
