use 5.006;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Number::Phone',
    META_MERGE => {
        license => 'other',
        resource => {
	    repository => 'https://github.com/DrHyde/perl-modules-Number-Phone'
        }
    },
  VERSION_FROM => 'lib/Number/Phone.pm',
  PREREQ_PM    => {
    'Scalar::Util'  => 0,
    'Test::More'    => 0,
    'Digest::MD5'   => 0,
    'DBM::Deep'     => 2.0008,
  },
  dist => {
    PREOP => "./build-data.sh"
  }
);
