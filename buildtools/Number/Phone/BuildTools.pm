package # hah, fooled you PAUSE
    Number::Phone::BuildTools;

use strict;
use warnings;

use Exporter qw(import);
our @ISA = qw(Exporter);
our @EXPORT = qw(PM_from_manifest files_from_manifest modules_from_manifest);
our $without_uk = 0;

sub PM_from_manifest {
    open(my $manifest, 'MANIFEST') || die("Couldn't open MANIFEST\n");
    return {
        map { $_ => "blib/$_" }
        grep {
            /^lib.*\.pm$/ && (
                !$without_uk ||
                $_ !~ /UK/
            )
        }
        map { chomp; $_ } <$manifest>
    };
}

sub files_from_manifest { return sort keys %{PM_from_manifest()}; }

sub modules_from_manifest {
    return map {
        s/(^lib\/|\.pm$)//g;
        s/\//::/g;
        $_
    } files_from_manifest();
}

1;
