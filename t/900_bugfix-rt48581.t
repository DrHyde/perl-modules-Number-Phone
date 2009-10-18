#!/usr/bin/perl -w

use strict;

use Test::More tests => 3;

use Number::Phone;

my $phone = Number::Phone->new(44, '02087712924');

ok($phone->isa('Number::Phone::UK'), "N::P->new(CC, 'nnnn') returns N::P::CC object");

ok($phone->format() eq "+44 20 87712924", "and it's got the right data");

eval { Number::Phone->new(44, '02087712924', 'apples!') };
ok($@ =~ /too many params/, "dies OK on too many params");
