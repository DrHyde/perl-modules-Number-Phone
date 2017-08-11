package Number::Phone::UK::Data;

use warnings;
use strict;

our $VERSION = "2.0";

use DBM::Deep;
use File::ShareDir;

# giant ball of hate because lib::abs doesn't work on Windows
use File::Spec::Functions qw(catfile);
use File::Basename qw(dirname);
use Cwd qw(abs_path);

my $this_file = abs_path((caller(1))[1]);
my $this_dir  = dirname($this_file);

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

my $slurped = 0;
my $db;
my $pid = -1;

sub db {
    return $db if($slurped);
    if(!$db || $pid != $$) {
	# we want to re-open the DB if we've forked, because of
	# https://github.com/DrHyde/perl-modules-Number-Phone/issues/72
	# Unfortunately that's annoyingly hard to test
	$pid = $$;
        $db = DBM::Deep->new($file);
    }
    return $db
}

sub slurp {
    return if($slurped);
    $db = _slurp(db());
    $slurped++;
}

sub _slurp {
    my $db = shift;
    if(!ref($db)) {
        return $db
    } elsif($db->isa('ARRAY')) {
        return [ map { _slurp($_) } @{$db} ]
    } elsif($db->isa('HASH')) {
        return { map {
            $_ => _slurp($db->{$_})
        } keys(%{$db}) };
    }
}

1;
