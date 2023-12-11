use strict;
use warnings;
use lib 't/inc';
use nptestutils;

use Config;
use Devel::CheckOS qw(os_is);

use Test::More;

use Number::Phone::NANP;

eval "use Parallel::ForkManager";

SKIP: {
    skip "fork() isn't supported properly on Windows", 3
        if(os_is("MicrosoftWindows"));
    skip "Parallel::ForkManager needed for these tests", 3
        unless($INC{'Parallel/ForkManager.pm'});

    my $forker = Parallel::ForkManager->new(1);
    my $returned_from_child;
    $forker->run_on_finish(sub { $returned_from_child = ${$_[-1]}; });
    
    # this gets an operator to force a seek() on the filehandle
    # so we can compare it to what should be a shiny new fh
    Number::Phone->new("+1 242 225 0000")->operator();
    my $original_tell = tell(Number::Phone::NANP::_datafh);
    $forker->start() || $forker->finish(0, \tell(Number::Phone::NANP::_datafh));
    $forker->wait_all_children();
    isnt($original_tell, $returned_from_child, "forking gets us a new NANP operators db");
    
    SKIP: {
        skip "built --without_uk so not testing that full-fat implementation today", 2
            if(building_without_uk());

        eval 'use Number::Phone::UK::Data';
        die($@) if($@);

        my $original_ukdb = ''.Number::Phone::UK::Data::db();
        $forker->start() || $forker->finish(0, \(''.Number::Phone::UK::Data::db()));
        $forker->wait_all_children();
        isnt($original_ukdb, $returned_from_child, "forking gets us a new UK db");
        
        SKIP: {
            if(!$ENV{AUTOMATED_TESTING}) {
                skip "slurping is too slow so skipping, set AUTOMATED_TESTING to run this", 1;
            } 
            diag("NB: this test takes a few minutes and lots of memory");
            Number::Phone::UK::Data::slurp();
            my $original_slurped_ukdb = ''.Number::Phone::UK::Data::db();
            $forker->start() || $forker->finish(0, \(''.Number::Phone::UK::Data::db()));
            $forker->wait_all_children();
            is($original_slurped_ukdb, $returned_from_child, "forking doesn't get us a new UK db if we slurped");
        }
    }
}

done_testing();
