#/usr/bin/env perl
#
use strict;
use warnings;

use Test::More;

use Number::Phone;

my $t;

my @drama_numbers = (

	['Leeds' , '+44113 496 0553', '+44113 496 0494'],
	['Sheffield', '+44114 496 0445'],
	['Nottingham', '+44115 496 0881'],
	['Leicester', '+44116 496 0712'],
	['Bristol', '+44117 496 0838'],
	['Reading', '+44118 496 0976'],
	['Birmingham', '+44121 496 0835'],
	['Edinburgh', '+44131 496 0107'],
	['Glasgow', '+44141 496 0297'],
	['Liverpool', '+44151 496 0787'],
	['Mahchester', '+44161 496 0508'],
	['London', '+4420 7946 0364', '+4420 7946 0885'],
	['Tyneside', '+44191 498 0228'],
	['Northern Ireland', '+44289649 6008'],
	['Cardiff', '+4429 2018 0678'],
	['Mobile', '+44 7700 900011', '+44 7700 900471'],
	['Freephone', '+44 8081 570576', '+44 8081 570044'],
	['Premium Rate', '+44 909 879 0845'],
	['UK-Wide', '+44 3069 990965']

);

foreach my $dn (@drama_numbers) {

     my $area = shift @{$dn};

     my $i = 1;
     foreach my $num (@{$dn}) {
          my $phone = Number::Phone->new($num);

          ok($phone->is_drama(), "$area drama number $i ok");
          $t++; $i++;
     }

}



done_testing($t);
