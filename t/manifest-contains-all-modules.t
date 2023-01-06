use strict;
use warnings;

use File::Find::Rule;

use Test::More;
use Test::Differences;

# This is a sanity-check to make sure that MANIFEST is up-to-date, as it is
# used by Makefile.PL to generate the list of files to install (see the PM
# section in Makefile.PL)

open(my $manifest_fh, '<', 'MANIFEST') || die("Couldn't open MANIFEST: $!\n");
my @manifest = sort grep { /^lib.*\.pm$/ } map { chomp; $_ } <$manifest_fh>;
my @files = sort File::Find::Rule->file()->name('*.pm')->in('lib');

eq_or_diff(
    \@manifest,
    \@files,
    "MANIFEST and lib/**/*.pm match",
    { filename_a => 'MANIFEST', filename_b => 'lib/**/*.pm' }
);

ok(!-f 'Number/Phone/StubCountry/001.pm', "There's no stub for country 001");

done_testing();
