#!/usr/bin/perl -w

my $loaded;

use strict;

use Number::Phone::UK;

BEGIN { $| = 1; print "1..40\n"; }
END { print "not ok 1 load module\n" unless $loaded; }

$loaded=1;
my $test = 0;
print "ok ".(++$test)." load module\n";

my $mobile = '+447979866975';
my $pager  = '+447679866975';
print 'not ' unless(1 == Number::Phone::UK::is_mobile($mobile));
print 'ok '.(++$test)." true N::P::CC::is_method('+CC12345')\n";
print 'not ' unless(1 == Number::Phone::UK->is_mobile($mobile));
print 'ok '.(++$test)." true N::P::CC->is_method('+CC12345')\n";
print 'not ' unless(1 == Number::Phone::UK->new($mobile)->is_mobile());
print 'ok '.(++$test)." true N::P::CC->new('+CC12345')->is_method()\n";
print 'not ' unless(1 == Number::Phone::is_mobile($mobile));
print 'ok '.(++$test)." true N::P::is_method('+CC12345')\n";
print 'not ' unless(1 == Number::Phone->is_mobile($mobile));
print 'ok '.(++$test)." true N::P->is_method('+CC12345')\n";
print 'not ' unless(1 == Number::Phone->new($mobile)->is_mobile());
print 'ok '.(++$test)." true N::P->new('+CC12345')->is_method()\n";

print 'not ' unless(0 == Number::Phone::UK::is_mobile($pager));
print 'ok '.(++$test)." false N::P::CC::is_method('+CC12345')\n";
print 'not ' unless(0 == Number::Phone::UK->is_mobile($pager));
print 'ok '.(++$test)." false N::P::CC->is_method('+CC12345')\n";
print 'not ' unless(0 == Number::Phone::UK->new($pager)->is_mobile());
print 'ok '.(++$test)." false N::P::CC->new('+CC12345')->is_method()\n";
print 'not ' unless(0 == Number::Phone::is_mobile($pager));
print 'ok '.(++$test)." false N::P::is_method('+CC12345')\n";
print 'not ' unless(0 == Number::Phone->is_mobile($pager));
print 'ok '.(++$test)." false N::P->is_method('+CC12345')\n";
print 'not ' unless(0 == Number::Phone->new($pager)->is_mobile());
print 'ok '.(++$test)." false N::P->new('+CC12345')->is_method()\n";

print 'not ' if(defined(Number::Phone::UK->is_government($pager)));
print 'ok '.(++$test)." undef N::P::CC->is_method('+CC12345')\n";
print 'not ' if(defined(Number::Phone::UK->new($pager)->is_government()));
print 'ok '.(++$test)." undef N::P::CC->new('+CC12345')->is_method()\n";
print 'not ' if(defined(Number::Phone::is_government($pager)));
print 'ok '.(++$test)." undef N::P::is_method('+CC12345')\n";
print 'not ' if(defined(Number::Phone->is_government($pager)));
print 'ok '.(++$test)." undef N::P->is_method('+CC12345')\n";
print 'not ' if(defined(Number::Phone->new($pager)->is_government()));
print 'ok '.(++$test)." undef N::P->new('+CC12345')->is_method()\n";

print 'not ' unless(@{Number::Phone::UK->type($mobile)});
print 'ok '.(++$test)." scalar N::P::CC->type('+CC12345')\n";
print 'not ' unless(@{Number::Phone::UK->new($mobile)->type()});
print 'ok '.(++$test)." scalar N::P::CC->new('+CC12345')->type()\n";
print 'not ' unless(@{Number::Phone::type($mobile)});
print 'ok '.(++$test)." scalar N::P::type('+CC12345')\n";
print 'not ' unless(@{Number::Phone->type($mobile)});
print 'ok '.(++$test)." scalar N::P->type('+CC12345')\n";
print 'not ' unless(@{Number::Phone->new($mobile)->type()});
print 'ok '.(++$test)." scalar N::P->new('+CC12345')->type()\n";

print 'not ' unless((Number::Phone::UK->type($mobile))[2]);
print 'ok '.(++$test)." list N::P::CC->type('+CC12345')\n";
print 'not ' unless((Number::Phone::UK->new($mobile)->type())[2]);
print 'ok '.(++$test)." list N::P::CC->new('+CC12345')->type()\n";
print 'not ' unless((Number::Phone::type($mobile)))[2];
print 'ok '.(++$test)." list N::P::type('+CC12345')\n";
print 'not ' unless((Number::Phone->type($mobile)))[2];
print 'ok '.(++$test)." list N::P->type('+CC12345')\n";
print 'not ' unless((Number::Phone->new($mobile)->type()))[2];
print 'ok '.(++$test)." list N::P->new('+CC12345')->type()\n";


$mobile = '07979866975';
$pager  = '07679866975';
print 'not ' unless(1 == Number::Phone::UK::is_mobile($mobile));
print 'ok '.(++$test)." true N::P::CC::is_method('12345')\n";
print 'not ' unless(1 == Number::Phone::UK->is_mobile($mobile));
print 'ok '.(++$test)." true N::P::CC->is_method('12345')\n";
print 'not ' unless(1 == Number::Phone::UK->new($mobile)->is_mobile());
print 'ok '.(++$test)." true N::P::CC->new('12345')->is_method()\n";

print 'not ' unless(0 == Number::Phone::UK::is_mobile($pager));
print 'ok '.(++$test)." false N::P::CC::is_method('12345')\n";
print 'not ' unless(0 == Number::Phone::UK->is_mobile($pager));
print 'ok '.(++$test)." false N::P::CC->is_method('12345')\n";
print 'not ' unless(0 == Number::Phone::UK->new($pager)->is_mobile());
print 'ok '.(++$test)." false N::P::CC->new('12345')->is_method()\n";

print 'not ' if(defined(Number::Phone::UK->is_government($pager)));
print 'ok '.(++$test)." undef N::P::CC->is_method('12345')\n";
print 'not ' if(defined(Number::Phone::UK->new($pager)->is_government()));
print 'ok '.(++$test)." undef N::P::CC->new('12345')->is_method()\n";

print 'not ' unless(@{Number::Phone::UK->type($mobile)});
print 'ok '.(++$test)." scalar N::P::CC->type('12345')\n";
print 'not ' unless(@{Number::Phone::UK->new($mobile)->type()});
print 'ok '.(++$test)." scalar N::P::CC->new('12345')->type()\n";

print 'not ' unless((Number::Phone::UK->type($mobile))[2]);
print 'ok '.(++$test)." list N::P::CC->type('12345')\n";
print 'not ' unless((Number::Phone::UK->new($mobile)->type())[2]);
print 'ok '.(++$test)." list N::P::CC->new('12345')->type()\n";
