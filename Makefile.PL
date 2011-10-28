use 5.006;
use ExtUtils::MakeMaker;

-f 'lib/Number/Phone/UK/Data.pm' ||
  system('./build-data.sh');

WriteMakefile(
  NAME         => 'Number::Phone',
  VERSION_FROM => 'lib/Number/Phone.pm',
  PREREQ_PM    => {
    'Scalar::Util'  => 0,
    'Test::More'    => 0,
    'Digest::MD5'   => 0
  }
);
