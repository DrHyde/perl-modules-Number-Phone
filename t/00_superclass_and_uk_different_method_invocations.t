#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

use Number::Phone::UK;
use Test::More;

END { done_testing(); }

my $mobile = '+447979866975';
my $pager  = '+447679866975';
ok(1 == Number::Phone::UK::is_mobile($mobile), "true N::P::CC::is_method('+CC12345')");
ok(1 == Number::Phone::UK->is_mobile($mobile), "true N::P::CC->is_method('+CC12345')");
ok(1 == Number::Phone::UK->new($mobile)->is_mobile(), "true N::P::CC->new('+CC12345')->is_method()");
ok(1 == Number::Phone::is_mobile($mobile), "true N::P::is_method('+CC12345')");
ok(1 == Number::Phone->is_mobile($mobile), "true N::P->is_method('+CC12345')");
ok(1 == Number::Phone->new($mobile)->is_mobile(), "true N::P->new('+CC12345')->is_method()");

ok(0 == Number::Phone::UK::is_mobile($pager), "false N::P::CC::is_method('+CC12345')");
ok(0 == Number::Phone::UK->is_mobile($pager), "false N::P::CC->is_method('+CC12345')");
ok(0 == Number::Phone::UK->new($pager)->is_mobile(), "false N::P::CC->new('+CC12345')->is_method()");
ok(0 == Number::Phone::is_mobile($pager), "false N::P::is_method('+CC12345')");
ok(0 == Number::Phone->is_mobile($pager), "false N::P->is_method('+CC12345')");
ok(0 == Number::Phone->new($pager)->is_mobile(), "false N::P->new('+CC12345')->is_method()");

ok(!defined(Number::Phone::UK->is_government($pager)), "undef N::P::CC->is_method('+CC12345')");
ok(!defined(Number::Phone::UK->new($pager)->is_government()), "undef N::P::CC->new('+CC12345')->is_method()");
ok(!defined(Number::Phone::is_government($pager)), "undef N::P::is_method('+CC12345')");
ok(!defined(Number::Phone->is_government($pager)), "undef N::P->is_method('+CC12345')");
ok(!defined(Number::Phone->new($pager)->is_government()), "undef N::P->new('+CC12345')->is_method()");

ok(@{Number::Phone::UK->type($mobile)}, "scalar N::P::CC->type('+CC12345')");
ok(@{Number::Phone::UK->new($mobile)->type()}, "scalar N::P::CC->new('+CC12345')->type()");
ok(@{Number::Phone::type($mobile)}, "scalar N::P::type('+CC12345')");
ok(@{Number::Phone->type($mobile)}, "scalar N::P->type('+CC12345')");
ok(@{Number::Phone->new($mobile)->type()}, "scalar N::P->new('+CC12345')->type()");

ok((Number::Phone::UK->type($mobile))[2], "list N::P::CC->type('+CC12345')");
ok((Number::Phone::UK->new($mobile)->type())[2], "list N::P::CC->new('+CC12345')->type()");

ok((Number::Phone::type($mobile))[2], "list N::P::type('+CC12345')");
ok((Number::Phone->type($mobile))[2], "list N::P->type('+CC12345')");
ok((Number::Phone->new($mobile)->type())[2], "list N::P->new('+CC12345')->type()");

$mobile = '07979866975';
$pager  = '07679866975';
ok(1 == Number::Phone::UK::is_mobile($mobile), "true N::P::CC::is_method('12345')");
ok(1 == Number::Phone::UK->is_mobile($mobile), "true N::P::CC->is_method('12345')");
ok(1 == Number::Phone::UK->new($mobile)->is_mobile(), "true N::P::CC->new('12345')->is_method()");

ok(0 == Number::Phone::UK::is_mobile($pager), "false N::P::CC::is_method('12345')");
ok(0 == Number::Phone::UK->is_mobile($pager), "false N::P::CC->is_method('12345')");
ok(0 == Number::Phone::UK->new($pager)->is_mobile(), "false N::P::CC->new('12345')->is_method()");

ok(!defined(Number::Phone::UK->is_government($pager)), "undef N::P::CC->is_method('12345')");
ok(!defined(Number::Phone::UK->new($pager)->is_government()), "undef N::P::CC->new('12345')->is_method()");

ok(@{Number::Phone::UK->type($mobile)}, "scalar N::P::CC->type('12345')");
ok(@{Number::Phone::UK->new($mobile)->type()}, "scalar N::P::CC->new('12345')->type()");

ok((Number::Phone::UK->type($mobile))[2], "list N::P::CC->type('12345')");
ok((Number::Phone::UK->new($mobile)->type())[2], "list N::P::CC->new('12345')->type()");
