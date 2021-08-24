use strict;
use warnings;

use Test::More;
use Test::Differences;

use Number::Phone;
use Number::Phone::Lib;

# https://github.com/DrHyde/perl-modules-Number-Phone/issues/101
foreach my $CC (qw(GB GG IM JE)) {
    ok(!defined(Number::Phone->new($CC, '256789')), "->new('$CC', '256789') fails (too short)");

    my $nplib = Number::Phone::Lib->new($CC, '256789');
    if($CC eq 'JE' || $CC eq 'GG') {
        ok(
            $nplib->isa("Number::Phone::StubCountry::$CC"),
            "::Lib->new('$CC', '256789') - valid local number in $CC"
        );
    } else {
        ok(
            !defined($nplib),
            "::Lib->new('$CC', '256789') -  invalid or ambiguous"
        );
    }
}

done_testing();
