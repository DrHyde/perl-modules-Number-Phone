use strict;
use warnings;

BEGIN {
    unshift @INC, 'buildtools';
    require Number::Phone::BuildTools;
    Number::Phone::BuildTools->import();
    delete $INC{'Number/Phone/BuildTools.pm'};
    shift @INC;
}

use Cwd;

use Test::More;
use Test::Differences;

# This is a sanity-check to make sure that when running under 'make test' in
# the Github workflows that test the normal and --without_uk builds, perl
# only loads Number::Phone::* from blib (and so with/without full-fat UK support)
# and not from lib

use Test::More;
if(!$ENV{BUILD_TEST}) {
    plan skip_all => 'Test only relevant in CI builds set BUILD_TEST to over-ride';
}

foreach my $module (modules_from_manifest()) {
    note("Loading $module\n");
    eval "use $module";
    fail($@) if($@);
}

foreach my $loaded_file (sort grep { $_ =~ m{Number/Phone} } values(%INC)) {
    my $unwanted = getcwd()."/lib";
    ok($loaded_file !~ m{^$unwanted}, "didn't load $loaded_file from \$git_checkout/lib/");
}
    
done_testing();
