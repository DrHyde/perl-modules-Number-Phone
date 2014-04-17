#!/usr/bin/perl -w

use strict;

use lib 't/inc';
use fatalwarnings;

our $CLASS = 'Number::Phone';
eval "use $CLASS";
use Test::More;

use lib 't/lib';

require 'common-stub_and_libphonenumber_tests.pl';

# let's break the UK
{
  # silence stupid warning about prefix_codes being used only once
  no warnings 'once';
  $Number::Phone::Country::idd_codes{'44'} = 'MOCK';
  $Number::Phone::Country::prefix_codes{'MOCK'} = ['44',   '00',  undef];
}

require 'uk_tests.pl';

done_testing;
