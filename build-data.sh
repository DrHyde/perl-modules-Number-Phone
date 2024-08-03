#!/usr/bin/env bash

# THIS SHELL SCRIPT IS NOT INTENDED FOR END USERS OR FOR PEOPLE INSTALLING
# THE MODULES, BUT FOR THE AUTHOR'S USE WHEN UPDATING THE DATA FROM OFCOM'S
# AND libphonenumber's PUBLISHED DATA.
#
# args:
#   --force
#       force a complete rebuild
#   --libphonenumbertag $tag
#       build using a particular libphonenumber git tag. Implies --force.
#       Use latest in their repo if not specified
#   --previouslibphonenumbertag
#       build using whatever --libphonenumbertag was used last time
#   --quietly
#       suppress output from other scripts
#
# Generally you will develop using --force and/or --libphonenumbertag, but then
# when a dist is built it will be freshened with --previouslibphonenumbertag to
# make sure you get what you expect, even if the libphonenumber gang
# have created a new tag just before you build the dist

LIBPHONENUMBERTAG=unset
FORCE=0
EXITSTATUS=0
BUILD_QUIETLY=0

# some machines have one of 'em, some have t'other
MD5=$(which md5 || which md5sum)

function quietly? {
    if [ "$BUILD_QUIETLY" == "1" ]; then
        "$@" >/dev/null 2>&1
    else
        "$@"
    fi
}

# now get an up-to-date libphonenumber and data-files
(
    (cd libphonenumber || (echo Checking out libphonenumber ...; git clone https://github.com/googlei18n/libphonenumber.git))
    (
        cd libphonenumber
        git checkout -q master
        git pull -q
        touch -t $(git --no-pager log -1 --format=%ad --date=format:%Y%m%d%H%M.%S resources/PhoneNumberMetadata.xml) resources/PhoneNumberMetadata.xml
    )

    # # LFS repo removed from github cos it ran out of space
    # if [ "$CI" != "True" ] && [ "$CI" != "true" ] && [ "$GITHUB_ACTIONS" != "true" ]; then
    #     (cd data-files || (echo Checking out data-files ...; git clone git@github.com:DrHyde/perl-modules-Number-Phone-data-files.git data-files/))
    # fi
    (cd data-files || mkdir data-files) # for devs and CI envs that can't yet check that repo out
    (
        cd data-files
        git checkout -q master
        # git pull -q
    )
)

while [ "$#" != "0" ] ; do
    if [ "$1" == "--libphonenumbertag" ]; then
        shift
        LIBPHONENUMBERTAG=$1
        FORCE=1
    elif [ "$1" == "--previouslibphonenumbertag" ]; then
        LIBPHONENUMBERTAG=$(cat .libphonenumber-tag)
    elif [ "$1" == "--force" ]; then
        FORCE=1
    elif [ "$1" == "--quietly" ]; then
        BUILD_QUIETLY=1
    fi

    shift
done

if [ "$LIBPHONENUMBERTAG" == "unset" ]; then
    LIBPHONENUMBERTAG=$(cd libphonenumber; git tag --sort=creatordate|tail -1)
fi

if [ "$FORCE" == "1" ]; then
    rm share/Number-Phone-UK-Data.db
    rm share/Number-Phone-NANP-Data.db
    rm lib/Number/Phone/NANP/Data.pm
    rm lib/Number/Phone/Data.pm
    rm lib/Number/Phone/Country/Data.pm
    rm lib/Number/Phone/StubCountry/KZ.pm
    rm t/example-phone-numbers.t
fi

# switch to our desired tag, and cache it for a future --previouslibphonenumbertag build
(
    cd libphonenumber
    git checkout -q $LIBPHONENUMBERTAG
    touch -t $(git --no-pager log -1 --format=%ad --date=format:%Y%m%d%H%M.%S resources/PhoneNumberMetadata.xml) resources/PhoneNumberMetadata.xml
)
echo $LIBPHONENUMBERTAG > .libphonenumber-tag

# first get OFCOM data and NANP operator data
# OFCOM data was found at:
#   https://www.ofcom.org.uk/phones-telecoms-and-internet/information-for-industry/numbering/numbering-data
#   (prev at http://static.ofcom.org.uk/static/numbering/)
#   report errors at https://www.ofcom.org.uk/about-ofcom/contact-us/contact-the-webmaster
#   contact@ofcom.org.uk might work too
# NANP data was found at:
#   https://www.nationalnanpa.com/reports/reports_cocodes_assign.html
#   https://www.nationalnanpa.com/reports/reports_cocodes.html
#   http://cnac.ca/co_codes/co_code_status.htm
(
    cd data-files

    wget -l 1 -nd --accept-regex telephone-numbers/.*.xlsx -r https://www.ofcom.org.uk/phones-and-broadband/phone-numbers/numbering-data
    for i in s[35789]* sabcde*; do mv "$i" $(echo "$i"|sed 's/?.*//'); done
    rm s10-type-b2.xlsx* numbering-data robots.txt

    rm AllBlocksAugmentedReport.zip COCodeStatus_ALL.zip COCodeStatus_ALL.csv AllBlocksAugmentedReport.txt
    wget https://www.nationalpooling.com/reports/region/AllBlocksAugmentedReport.zip
    wget https://cnac.ca/data/COCodeStatus_ALL.zip
    unzip -q COCodeStatus_ALL.zip
    unzip -q AllBlocksAugmentedReport.zip
)

# stash the Unix epoch of the OFCOM data
OFCOMDATETIME=$(cd data-files;perl -e 'print +(stat(shift))[9]' $(ls -rt *.xlsx|tail -1))
CADATETIME=$(cd data-files;perl -e 'print +(stat(shift))[9]' COCodeStatus_ALL.csv)
USDATETIME=$(cd data-files;perl -e 'print +(stat(shift))[9]' AllBlocksAugmentedReport.txt)

# whine/quit if any of those are older than three months
CURRENTDATETIME=$(date +%s)
THREEMONTHS=7776000
if [ $(( $CURRENTDATETIME - $OFCOMDATETIME )) -gt $THREEMONTHS -o \
     $(( $CURRENTDATETIME - $CADATETIME    )) -gt $THREEMONTHS -o \
     $(( $CURRENTDATETIME - $USDATETIME    )) -gt $THREEMONTHS    \
   ]; then
    echo Data files are ANCIENT, check that the URLs are correct
    ls -l data-files/*xlsx data-files/COCodeStatus_ALL.csv data-files/AllBlocksAugmentedReport.txt
    exit 1
fi

# if share/Number-Phone-UK-Data.db doesn't exist, or OFCOM's stuff or
# libphonenumber's list of area codes is newer ...
if test ! -e share/Number-Phone-UK-Data.db -o \
  buildtools/Number/Phone/BuildHelpers.pm      -nt share/Number-Phone-UK-Data.db -o \
  libphonenumber/resources/geocoding/en/44.txt -nt share/Number-Phone-UK-Data.db -o \
  data-files/sabcde11_12.xlsx -nt share/Number-Phone-UK-Data.db -o \
  data-files/sabcde13.xlsx    -nt share/Number-Phone-UK-Data.db -o \
  data-files/sabcde14.xlsx    -nt share/Number-Phone-UK-Data.db -o \
  data-files/sabcde15.xlsx    -nt share/Number-Phone-UK-Data.db -o \
  data-files/sabcde16.xlsx    -nt share/Number-Phone-UK-Data.db -o \
  data-files/sabcde17.xlsx    -nt share/Number-Phone-UK-Data.db -o \
  data-files/sabcde18.xlsx    -nt share/Number-Phone-UK-Data.db -o \
  data-files/sabcde19.xlsx    -nt share/Number-Phone-UK-Data.db -o \
  data-files/sabcde2.xlsx     -nt share/Number-Phone-UK-Data.db -o \
  data-files/s3.xlsx          -nt share/Number-Phone-UK-Data.db -o \
  data-files/s5.xlsx          -nt share/Number-Phone-UK-Data.db -o \
  data-files/s7.xlsx          -nt share/Number-Phone-UK-Data.db -o \
  data-files/s8.xlsx          -nt share/Number-Phone-UK-Data.db -o \
  data-files/s9.xlsx          -nt share/Number-Phone-UK-Data.db -o \
  build-data.uk               -nt share/Number-Phone-UK-Data.db;
then
  if [ "$CI" != "True" ] && [ "$CI" != "true" ] && [ "$GITHUB_ACTIONS" != "true" ]; then
    EXITSTATUS=1
  fi
  echo rebuilding share/Number-Phone-UK-Data.db
  if test ! -e share/Number-Phone-UK-Data.db; then
      echo "  because it doesn't exist"
  else
      ls -ltr share/Number-Phone-UK-Data.db buildtools/Number/Phone/BuildHelpers.pm libphonenumber/resources/geocoding/en/44.txt data-files/sabcde* data-files/S?.xlsx build-data.uk | \
          sed 's/^/  /'
  fi

  quietly? perl build-data.uk
else
  echo share/Number-Phone-UK-Data.db is up-to-date
fi

# lib/Number/Phone/Country/Data.pm doesn't exist, or if libphonenumber/resources/PhoneNumberMetadata.xml is newer ...
if test ! -e lib/Number/Phone/Country/Data.pm -o \
  buildtools/Number/Phone/BuildHelpers.pm          -nt lib/Number/Phone/Country/Data.pm -o \
  build-data.country-mapping                       -nt lib/Number/Phone/Country/Data.pm -o \
  libphonenumber/resources/PhoneNumberMetadata.xml -nt lib/Number/Phone/Country/Data.pm;
then
  if [ "$CI" != "True" ] && [ "$CI" != "true" ] && [ "$GITHUB_ACTIONS" != "true" ]; then
    EXITSTATUS=1
  fi
  echo rebuilding lib/Number/Phone/Country/Data.pm
  if test ! -e lib/Number/Phone/Country/Data.pm; then
      echo "  because it doesn't exist"
  else
      ls -ltr lib/Number/Phone/Country/Data.pm buildtools/Number/Phone/BuildHelpers.pm build-data.country-mapping libphonenumber/resources/PhoneNumberMetadata.xml | \
          sed 's/^/  /'
  fi
  quietly? perl build-data.country-mapping
else
  echo lib/Number/Phone/Country/Data.pm is up-to-date
fi

# lib/Number/Phone/NANP/Data.pm doesn't exist, or if libphonenumber/resources/geocoding/en/1.txt or PhoneNumberMetadata.xml is newer ...
if test ! -e lib/Number/Phone/NANP/Data.pm -o \
  ! -e share/Number-Phone-NANP-Data.db -o \
  buildtools/Number/Phone/BuildHelpers.pm          -nt lib/Number/Phone/NANP/Data.pm -o \
  build-data.nanp                                  -nt lib/Number/Phone/NANP/Data.pm -o \
  libphonenumber/resources/geocoding/en/1.txt      -nt lib/Number/Phone/NANP/Data.pm -o \
  libphonenumber/resources/PhoneNumberMetadata.xml -nt lib/Number/Phone/NANP/Data.pm -o \
  data-files/AllBlocksAugmentedReport.zip          -nt share/Number-Phone-NANP-Data.db -o \
  data-files/AllBlocksAugmentedReport.txt          -nt share/Number-Phone-NANP-Data.db -o \
  data-files/COCodeStatus_ALL.zip                  -nt share/Number-Phone-NANP-Data.db -o \
  data-files/COCodeStatus_ALL.csv                  -nt share/Number-Phone-NANP-Data.db;
then
  if [ "$CI" != "True" ] && [ "$CI" != "true" ] && [ "$GITHUB_ACTIONS" != "true" ]; then
    EXITSTATUS=1
  fi
  echo rebuilding lib/Number/Phone/NANP/Data.pm share/Number-Phone-NANP-Data.db
  if test ! -e lib/Number/Phone/NANP/Data.pm -o ! -e share/Number-Phone-NANP-Data.db; then
      echo "  because they don't both exist"
  else
      ls -ltr lib/Number/Phone/NANP/Data.pm share/Number-Phone-NANP-Data.db buildtools/Number/Phone/BuildHelpers.pm build-data.nanp libphonenumber/resources/geocoding/en/1.txt libphonenumber/resources/PhoneNumberMetadata.xml data-files/AllBlocksAugmentedReport.* data-files/COCodeStatus_ALL.* | \
          sed 's/^/  /'
  fi
  quietly? perl build-data.nanp
else
  echo lib/Number/Phone/NANP/Data.pm and share/Number-Phone-NANP-Data.db are up-to-date
fi
# this must be after build-data.nanp has fetched them
NANPDATETIME=$(perl -e 'print +(stat(shift))[9]' $(ls -rt data-files/[0-9][0-9][0-9].xml|tail -1))

# lib/Number/Phone/StubCountry/KZ.pm doesn't exist, or if libphonenumber/resources/PhoneNumberMetadata.xml is newer,
# or if lib/Number/Phone/NANP/Data.pm is newer ...
if test ! -e lib/Number/Phone/StubCountry/KZ.pm -o \
  buildtools/Number/Phone/BuildHelpers.pm          -nt lib/Number/Phone/StubCountry/KZ.pm -o \
  build-data.stubs                                 -nt lib/Number/Phone/StubCountry/KZ.pm -o \
  libphonenumber/resources/geocoding/en/1.txt      -nt lib/Number/Phone/StubCountry/KZ.pm -o \
  libphonenumber/resources/timezones/map_data.txt  -nt lib/Number/Phone/StubCountry/KZ.pm -o \
  libphonenumber/resources/PhoneNumberMetadata.xml -nt lib/Number/Phone/StubCountry/KZ.pm -o \
  lib/Number/Phone/NANP/Data.pm                    -nt lib/Number/Phone/StubCountry/KZ.pm;
then
  if [ "$CI" != "True" ] && [ "$CI" != "true" ] && [ "$GITHUB_ACTIONS" != "true" ]; then
    EXITSTATUS=1
  fi
  echo rebuilding lib/Number/Phone/StubCountry/\*.pm
  if test ! -e lib/Number/Phone/StubCountry/KZ.pm; then
      echo "  because they don't all exist"
  else
      ls -ltr lib/Number/Phone/StubCountry/KZ.pm buildtools/Number/Phone/BuildHelpers.pm build-data.stubs libphonenumber/resources/geocoding/en/1.txt libphonenumber/resources/timezones/map_data.txt libphonenumber/resources/PhoneNumberMetadata.xml lib/Number/Phone/NANP/Data.pm | \
          sed 's/^/  /'
  fi

  quietly? perl build-data.stubs
else
  echo lib/Number/Phone/StubCountry/\*.pm are up-to-date
fi

# t/example-phone-numbers.t doesn't exist, or if libphonenumber/resources/PhoneNumberMetadata.xml is newer
if test ! -e t/example-phone-numbers.t -o \
  buildtools/Number/Phone/BuildHelpers.pm          -nt t/example-phone-numbers.t -o \
  build-tests.pl                                   -nt t/example-phone-numbers.t -o \
  libphonenumber/resources/PhoneNumberMetadata.xml -nt t/example-phone-numbers.t;
then
  if [ "$CI" != "True" ] && [ "$CI" != "true" ] && [ "$GITHUB_ACTIONS" != "true" ]; then
    EXITSTATUS=1
  fi
  echo rebuilding t/example-phone-numbers.t
  if test ! -e t/example-phone-numbers.t; then
      echo "  because it doesn't exist"
  else
      ls -ltr t/example-phone-numbers.t buildtools/Number/Phone/BuildHelpers.pm build-tests.pl libphonenumber/resources/PhoneNumberMetadata.xml | \
          sed 's/^/  /'
  fi

  quietly? perl build-tests.pl
else
  echo t/example-phone-numbers.t is up-to-date
fi

# update Number::Phone::Data with update date/times and libphonenumber tag
OLD_N_P_DATA_MD5=$($MD5 lib/Number/Phone/Data.pm 2>/dev/null)
(
    echo \# automatically generated file, don\'t edit
    echo package Number::Phone::Data\;
    echo \*Number::Phone::libphonenumber_tag = sub { \"$LIBPHONENUMBERTAG\" }\;
    echo \*Number::Phone::UK::data_source = sub { \"OFCOM at \".gmtime\($OFCOMDATETIME\).\" UTC\" }\;
    echo \*Number::Phone::NANP::CA::data_source = sub { \"CNAC at \".gmtime\($CADATETIME\).\" UTC\" }\;
    echo \*Number::Phone::NANP::US::data_source = sub { \"National Pooling Administrator at \".gmtime\($USDATETIME\).\" UTC\" }\;
    echo \*Number::Phone::NANP::data_source = sub { \"localcallingguide.com at \".gmtime\($NANPDATETIME\).\" UTC\" }\;
    echo 1\;
    echo
    echo =head1 NAME
    echo
    echo Number::Phone::Data
    echo
    echo =head1 DATA SOURCES
    echo
    echo Canadian operator data derived from CNAC at $(perl -e "print ''.gmtime($CADATETIME)") UTC
    echo
    echo US operator data derived from National Pooling Administrator at $(perl -e "print ''.gmtime($USDATETIME)") UTC
    echo
    echo Other NANP operator data derived from localcallingguide.com at $(perl -e "print ''.gmtime($NANPDATETIME)") UTC
    echo
    echo UK data derived from OFCOM at $(perl -e "print ''.gmtime($OFCOMDATETIME)") UTC
    echo
    echo Most other data derived from libphonenumber $LIBPHONENUMBERTAG
    echo
    echo =cut
)>lib/Number/Phone/Data.pm
if [ "$OLD_N_P_DATA_MD5" != "$($MD5 lib/Number/Phone/Data.pm)" ] && [ "$CI" != "True" ] && [ "$CI" != "true" ] && [ "$GITHUB_ACTIONS" != "true" ]; then
    EXITSTATUS=1
fi

# finally look for out of date files and yell about them
echo
for file in `grep -ri next.check.due lib build-* t|grep -v build-data.sh|sed 's/:.*//'|sort|uniq`; do
    grep next.check.due $file | perl -Mstrict -Mwarnings -e '
        my $file = "'$file'";
        my $today = join("-",
                        (gmtime())[5] + 1900,
                        sprintf("%02d", (gmtime())[4] + 1),
                        sprintf("%02d", (gmtime())[3])
                    );
        while(my $line = <STDIN>) {
            chomp($line);
            $line =~ s/^\s*#\s+next\s+check\s+due\s+//;
            $line =~ s/ .*$//;
            print "Found a next check due on $line in $file\n"
                if($line lt $today);
        }
    '
done

if [ $EXITSTATUS == 1 ]; then
  if test -e Makefile; then
    echo stuff changed, need to re-run Makefile.PL
    `grep "^PERL " Makefile|awk '{print $3}'|sed 's/"//g'` Makefile.PL
  fi
fi

(
    cd data-files
    if test -e .gitignore; then
        git commit -q $(grep -vf .gitignore <(ls)) -m "data files as at $(date)"
        # git push -q
        git gc -q
    fi
)

exit $EXITSTATUS
