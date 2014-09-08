package Number::Phone::Lib;

use strict;
use base 'Number::Phone';

our $VERSION = '1.0';

sub new {
    my $class = shift;
    my($country, $number) = $class->_new_args(@_);
    return undef unless $country;

    # libphonenumber erroneously treats non-geographic numbers such
    # as 1-800 numbers as being in the US
    $country = 'US' if($country eq 'NANP');
    $country = 'GB' if $country eq 'UK';

    return $class->_make_stub_object($number, $country)
}

1;
__END__

=head1 NAME

Number::Phone::Lib - Instantiate Number::Phone::* objects from libphonenumber

=head1 SYNOPSIS

    use Number::Phone::Lib;

    $daves_phone = Number::Phone::Lib->new('+442087712924');
    $daves_other_phone = Number::Phone::Lib->new('+44 7979 866 975');
    # alternatively      Number::Phone::Lib->new('+44', '7979 866 975');
    # or                 Number::Phone::Lib->new('UK', '07979 866 975');

    if ( $daves_phone->is_mobile() ) {
        send_rude_SMS();
    }

This subclass of Number::Phone exclusively uses classes generated from
Google's L<libphonenumber project|https://code.google.com/p/libphonenumber/>.
libphonenumber doesn't have enough data to support all the features of
Number::Phone, but you might want to use its data and no other for a few
reasons:

=over

=item *

Compatibility with libphonenumber's Java, C++, and JavaScript implementations.

=item *

Performance. UK Number parsing and validation by Number::Phone::UK, in particular,
has a substantial overhead thanks to its embedded database. If all you need is
simple validation and/or formatting, all that overhead is unnecessary.

=back

That said, the core Number::Phone UK module
is far more comprehensive.

=head1 LICENCE

You may use, modify and distribute this software under the same terms as
perl itself.

=head1 AUTHORS

=over

=item * David Cantrell E<lt>david@cantrell.org.ukE<gt>


=item * David E. Wheeler E<lt>david@justatheory.comE<gt>

=back

Copyright 2014.

=cut
