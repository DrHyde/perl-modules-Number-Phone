package Number::Phone::UK::Data;

use warnings;
use strict;

our $VERSION = "2.0";

use DBM::Deep;
use File::ShareDir;
use lib::abs;

my @candidate_files = (
    lib::abs::path('.').'/../../../../lib/../share/Number-Phone-UK-Data.db',            # if this is $devdir/lib/...
    lib::abs::path('.').'/../../../../../blib/lib/../../share/Number-Phone-UK-Data.db', # if this is $devdir/blib/lib/...
    File::ShareDir::dist_dir('Number-Phone').'/Number-Phone-UK-Data.db',                # if this has been installed
);

my $file = (grep { -e $_ } @candidate_files)[0];
if(!$file) {
    die(
        "Couldn't find a UK data file amongst:\n".
        join('', map { "  $_\n" } @candidate_files)
    );
}

our $db = DBM::Deep->new($file);
1;
