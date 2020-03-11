package Number::Phone::UK::Data;

use warnings;
use strict;

use Number::Phone;

our $VERSION = "2.0001";

use DBM::Deep;
use File::ShareDir;

my $file = Number::Phone::_find_data_file('Number-Phone-UK-Data.db');

my $slurped = 0;
my $db;
my $pid = -1;

sub db {
    return $db if($slurped);
    if(!$db || $pid != $$) {
        # we want to re-open the DB if we've forked, because of
        # https://github.com/DrHyde/perl-modules-Number-Phone/issues/72
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
    } else {
        return { map {
            $_ => _slurp($db->{$_})
        } keys(%{$db}) };
    }
}

1;
