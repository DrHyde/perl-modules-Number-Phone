use 5.006;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Number::Phone',
  VERSION_FROM => 'lib/Number/Phone.pm',
  PREREQ_PM    => {
    'Scalar::Util'  => 0,
    'Test::More'    => 0,
    'Digest::MD5'   => 0
  },
  dist => {
    PREOP => "./build-data.sh"
  }
);
