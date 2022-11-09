package nptestutils;

use strict;
use warnings;

use Carp;
use Exporter qw(import);
our @EXPORT = qw(building_without_uk);

$SIG{__WARN__} = sub {
    my $warning = join('', @_);
    return if(
        $warning =~ /32 bit integers/ ||
        $warning =~ /Perl too old/ ||
        $warning =~ /^Devel::Hide/ ||
        $warning =~ /^Can't locate.*\(hidden\)/
    );
    confess("warning made fatal: ".join('', @_)."\n")
};

unshift @INC, sub {
    my($this, $wanted_file) = @_;

    # if this is a normal build we don't need to do anything special
    return undef if(!building_without_uk());

    # don't care if asked to load something other than N::P::UK(::*)
    return undef if($wanted_file !~ m{^Number/Phone/UK});

    # but if we're trying to load N::P::UK, and told the build not to,
    # we want to stop it from trying to load a previously installed version.
    # we also want this particular failure mode to get reported by N::P and
    # for it to not fall back to loading a Stub instead. This is to prevent
    # erroneously writing tests in the future that forget about --without_uk.
    die("Number::Phone built --without_uk but tried to load $wanted_file\n");
};

sub building_without_uk { !-e 'blib/lib/Number/Phone/UK.pm' }

1;
