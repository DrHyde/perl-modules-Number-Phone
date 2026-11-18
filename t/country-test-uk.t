#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

use Number::Phone;
use Number::Phone::Lib;
use Test::More;

END { done_testing(); }

{
    my $np  = Number::Phone::Lib->new('UK', '+238 989 12 34');
    my $int = canonical_format($np);
    is( $int,
        '+442389891234',
        'given "UK" as the country, and a valid UK number that is also a ' .
        'valid international number for another country, N::P::L returns ' .
        'a valid UK object'
    );
}
{
    my $np  = Number::Phone->new('UK', '+238 989 12 34');
    my $int = canonical_format($np);
    is( $int,
        '+442389891234',
        'given "UK" as the country, and a valid UK number that is also a ' .
        'valid international number for another country, N::P returns ' .
        'a valid UK object'
    );
}
{
    my $np  = Number::Phone::Lib->new('UK', '+238 989 12 3');
    my $int = canonical_format($np);
    is( $int,
        undef,
        'given "UK" as the country, and an invalid UK number that is also ' .
        'an invalid international number for another country, N::P::L ' .
        'returns undef'
    );
}
{
    my $np  = Number::Phone->new('UK', '+238 989 12 3');
    my $int = canonical_format($np);
    is( $int,
        undef,
        'given "UK" as the country, and an invalid UK number that is also ' .
        'an invalid international number for another country, N::P ' .
        'returns undef'
    );
}

sub canonical_format {
    my $np = shift;

    return undef if !defined $np;

    my $fmt = $np->format;
    $fmt =~ s/[^0-9+]//g;
    return $fmt;
}
