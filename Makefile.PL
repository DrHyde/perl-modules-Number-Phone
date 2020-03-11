use 5.006;
use ExtUtils::MakeMaker;

use File::ShareDir::Install;

mkdir('share') unless(-d 'share');

install_share 'share';

WriteMakefile(
  NAME         => 'Number::Phone',
    META_MERGE => {
        license => 'open_source',
        resources => {
            repository => 'https://github.com/DrHyde/perl-modules-Number-Phone',
            bugtracker => 'https://github.com/DrHyde/perl-modules-Number-Phone/issues'
        }
    },
  VERSION_FROM => 'lib/Number/Phone.pm',
  BUILD_REQUIRES => {
    'ExtUtils::MakeMaker'     => 6.52,
    'ExtUtils::Manifest'      => 0,
    'ExtUtils::Install'       => 0,
    'File::ShareDir::Install' => 0.11,
    'Parallel::ForkManager'   => '0.7.6' # return data from child processes
  },

  CONFIGURE_REQUIRES => {
    'ExtUtils::MakeMaker'     => 6.52,
    'ExtUtils::Manifest'      => 0,
    'ExtUtils::Install'       => 0,
    'File::ShareDir::Install' => 0.11
  },

  PREREQ_PM    => {
    'Scalar::Util'           => 1.48,
    'Test::More'             => '0.96', # need done_testing (0.88) and subtests (0.95_01)
    'Digest::MD5'            => 0,
    'DBM::Deep'              => 2.0008,
    'Test::utf8'             => 0,
    'File::ShareDir'         => 1.104,
    'File::Spec'             => 0,
    'File::Basename'         => 0,
    'Cwd'                    => 0,
    'I18N::LangTags::Detect' => 0,
    'I18N::LangTags'         => 0,
  },
  dist => {
    PREOP => "./build-data.sh"
  },
  realclean => {
    FILES => "*.xls sabc.txt COCodeStatus_ALL.* AllBlocksAugmentedReport.* cover_db"
  },
);

package MY;
use File::ShareDir::Install qw(postamble);
