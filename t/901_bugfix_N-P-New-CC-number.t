#!/usr/bin/perl -w

my $loaded;

use strict;

use Number::Phone;

BEGIN { $| = 1; print "1..5\n"; }

my $test = 0;

print 'not ' unless((Number::Phone->new('UK', '07970866975')));
print 'ok '.(++$test)." list N::P->new('CC', '012345')\n";
print 'not ' unless((Number::Phone->new('+44', '7970866975')));
print 'ok '.(++$test)." list N::P->new('+NN', '12345')\n";
print 'not ' unless((Number::Phone->new('+447970866975')));
print 'ok '.(++$test)." list N::P->new('+NN12345')\n";

print 'not ' unless((Number::Phone->new('UK', '7970866975'))); # not strictly correct
print 'ok '.(++$test)." list N::P->new('CC', '12345')\n";
print 'not ' unless((Number::Phone->new('+44', '07970866975'))); # not strictly correct
print 'ok '.(++$test)." list N::P->new('+NN', '012345')\n";
