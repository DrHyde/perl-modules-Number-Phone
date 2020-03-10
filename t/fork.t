use strict;
use warnings;

use Config;

use Test::More;

my $perl = $Config{perlpath};
my $incpath = (grep { -f "$_/Number/Phone/UK/Data.pm" } @INC)[0];

# this gets an operator to force a seek() on the filehandle
# so we can compare it to what should be a shiny new fh
my $nanp_results = `
    $perl -I$incpath -MNumber::Phone::NANP -e '
        Number::Phone->new("+1 242 225 0000")->operator();
        print tell(Number::Phone::NANP::_datafh)."\n";
        if(!fork()) {
            print tell(Number::Phone::NANP::_datafh)."\n";
        }
    '
`;
my @results = split(/\s+/, $nanp_results);
isnt($results[0], $results[1], "forking gets us a new NANP operators db");

my $uk_results = `
    $perl -I$incpath -MNumber::Phone::UK::Data -e '
        print Number::Phone::UK::Data::db."\n";
        if(!fork()) {
            print Number::Phone::UK::Data::db."\n";
        }
    '
`;
@results = split(/\s+/, $uk_results);
isnt($results[0], $results[1], "forking gets us a new UK db");

SKIP: {
    if(
        $ENV{CI} || !$ENV{AUTOMATED_TESTING}
    ) {
        skip "slurping is too slow so skipping under Devel::Cover and for normal installs, set AUTOMATED_TESTING to run this", 1;
    } 
    diag("NB: this test takes a few minutes and lots of memory");
    my $uk_slurp_results = `
        $perl -I$incpath -MNumber::Phone::UK::Data -e '
            Number::Phone::UK::Data->slurp();
            print Number::Phone::UK::Data::db."\n";
            if(!fork()) {
                print Number::Phone::UK::Data::db."\n";
            }
        '
    `;
    @results = split(/\s+/, $uk_slurp_results);
    is($results[0], $results[1], "forking doesn't get a new UK db if we slurped");

}

done_testing();
