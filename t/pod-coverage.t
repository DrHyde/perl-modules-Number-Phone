use strict;
use warnings;

use lib 't/inc';
use nptestutils;

use Test::More;
eval "use Test::Pod::Coverage 1.08";
plan skip_all => "Test::Pod::Coverage 1.08 required for testing POD coverage" if $@;
foreach my $module (grep { $_ !~ m{\b(UK::Exchanges|Data|StubCountry(::.*)?)$} } all_modules()) {
    pod_coverage_ok($module);
}
done_testing();
