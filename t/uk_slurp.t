#!/usr/bin/perl -w

use strict;
use Number::Phone::UK::Data;
Number::Phone::UK::Data->slurp();

require 't/uk_data.t';
