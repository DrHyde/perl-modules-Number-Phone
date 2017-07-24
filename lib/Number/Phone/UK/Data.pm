package Number::Phone::UK::Data;

use warnings;
use strict;

our $VERSION = "2.0";

use DBM::Deep;
use File::ShareDir;

# giant ball of hate because lib::abs doesn't work on Windows
use File::Spec::Functions qw(splitpath catpath catfile);
use Cwd qw(abs_path);

my $this_file = abs_path((caller(1))[1]);
my $this_dir  = catpath((splitpath($this_file))[0,1]);

my @candidate_files = (
     catfile($this_dir, qw(.. .. .. .. lib .. share Number-Phone-UK-Data.db)),            # if this is $devdir/lib ...
     catfile($this_dir, qw(.. .. .. .. .. blib lib .. .. share Number-Phone-UK-Data.db)), # if this is $devdir/blib/lib ...
     catfile(File::ShareDir::dist_dir('Number-Phone'), 'Number-Phone-UK-Data.db'),        # if this has been installed
);

my $file = (grep { -e $_ } @candidate_files)[0];
if(!$file) {
    die(
        "Couldn't find a UK data file amongst:\n".
        join('', map { "  $_\n" } @candidate_files)
    );
}

warn("Using $file\n");
our $db = DBM::Deep->new($file);
1;
