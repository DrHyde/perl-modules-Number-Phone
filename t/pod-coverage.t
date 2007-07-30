# $Id: pod-coverage.t,v 1.1 2007/07/30 12:49:38 drhyde Exp $
use strict;

$^W=1;

use Test::More;
eval "use Test::Pod::Coverage 1.00";
plan skip_all => "Test::Pod::Coverage 1.00 required for testing POD coverage" if $@;
all_pod_coverage_ok();
