use strict;
use warnings;

use File::Find::Rule;

use Test::More;
use Test::Differences;

open(my $manifest_fh, '<', 'MANIFEST') || die("Couldn't open MANIFEST: $!\n");
my @manifest = sort grep { /^lib.*\.pm$/ } map { chomp; $_ } <$manifest_fh>;
my @files = sort File::Find::Rule->file()->name('*.pm')->in('lib');

eq_or_diff(
    \@manifest,
    \@files,
    "MANIFEST and lib/**/*.pm match",
    { filename_a => 'MANIFEST', filename_b => 'lib/**/*.pm' }
);

done_testing();
