use 5.006;
use ExtUtils::MakeMaker;
WriteMakefile(
                NAME         => 'Number::Phone',
                VERSION_FROM => 'lib/Number/Phone.pm',
                PREREQ_PM    => {
                        'Scalar::Util'  => 0,
                        'Test::More'    => 0,
                        # commented out cos 1.0 is incompatible
                        # 'DBM::Deep'        => 0.97, # need to pass DATA filehandle
                }
             );
