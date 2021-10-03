use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;
use File::ShareDir::Install;

BEGIN {
    unshift @INC, 'buildtools';
    require Number::Phone::BuildTools;
    Number::Phone::BuildTools->import();
    shift @INC;
}

while(@ARGV) {
    if(shift() eq '--without_uk') {
        $Number::Phone::BuildTools::without_uk++;
    }
}

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
    'ExtUtils::MakeMaker'     => 6.64, # TEST_REQUIRES (CONFIGURE_REQUIRES is in 6.52; BUILD_REQUIRES in 6.56)
    'ExtUtils::Manifest'      => 0,
    'ExtUtils::Install'       => 0,
    'File::ShareDir::Install' => 0.11,
    'Parallel::ForkManager'   => '0.7.6' # return data from child processes
  },

  CONFIGURE_REQUIRES => {
    'ExtUtils::MakeMaker'     => 6.64,
    'ExtUtils::Manifest'      => 0,
    'ExtUtils::Install'       => 0,
    'File::ShareDir::Install' => 0.11
  },
  PREREQ_PM    => {
    'Cwd'                    => 0,
    'DBM::Deep'              => 2.0008,
    'Data::Dumper::Concise'  => 0,
    'Devel::CheckOS'         => '1.83',
    'Digest::MD5'            => 0,
    'File::Basename'         => 0,
    'File::Find::Rule'       => 0,
    'File::ShareDir'         => 1.104,
    'File::Spec'             => 0,
    'I18N::LangTags'         => 0,
    'I18N::LangTags::Detect' => 0,
    'Scalar::Util'           => 1.48,
  },
  TEST_REQUIRES => {
    'Carp'                   => 0,
    'Test::Differences'      => 0.62,
    'Test::More'             => '0.96', # need done_testing (0.88) and subtests (0.95_01)
    'Test::Warnings'         => 0,
    'Devel::Hide'            => 0,
    'if'                     => 0,
  },
  dist => {
    PREOP    => "./build-data.sh --previouslibphonenumbertag",
    # TARFLAGS => "--format ustar -c -v -f",
  },
  realclean => {
    FILES => "cover_db"
  },
  PM => PM_from_manifest()
);

package MY;
use File::ShareDir::Install;
sub postamble {
    my $self = shift;
    my @ret = File::ShareDir::Install::postamble( $self );
    my $ret = join "\n", @ret;
    if($Number::Phone::BuildTools::without_uk) {
        $ret =~ s{
            \\
            \s+
            'share/Number-Phone-UK-Data.db'
            \s+
            '[^']+'
        }{}x
    }
    return $ret;
}


