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
#
# Generally you will develop using --force and/or --libphonenumbertag, but then
# when a dist is built it will be freshened with --previouslibphonenumbertag to
# make sure you get what you expect, even if the libphonenumber gang
# have created a new tag just before you build the dist

LIBPHONENUMBERTAG=unset
FORCE=0
EXITSTATUS=0

# now get an up-to-date libphonenumber and data-files
(
    (cd libphonenumber || (echo Checking out libphonenumber ...; git clone https://github.com/googlei18n/libphonenumber.git))
    (
        cd libphonenumber
        git checkout -q master
        git pull -q
    )

    if [ "$CI" != "True" ] && [ "$CI" != "true" ]; then
        (cd data-files || (echo Checking out data-files ...; git clone git@github.com:DrHyde/perl-modules-Number-Phone-data-files.git data-files/))
    fi
    (cd data-files || mkdir data-files) # for CI envs that can't yet check that repo out
    (
        cd data-files
        git checkout -q master
        git pull -q
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
(cd libphonenumber; git checkout -q $LIBPHONENUMBERTAG)
echo $LIBPHONENUMBERTAG > .libphonenumber-tag

# first get OFCOM data and NANP operator data
# NANP data was found at:
#     https://www.nationalnanpa.com/reports/reports_cocodes_assign.html
#     https://www.nationalnanpa.com/reports/reports_cocodes.html
#     http://cnac.ca/co_codes/co_code_status.htm
(
    cd data-files
    for i in \
        http://static.ofcom.org.uk/static/numbering/sabc.txt                        \
        http://static.ofcom.org.uk/static/numbering/sabcde11_12.xlsx                 \
        http://static.ofcom.org.uk/static/numbering/sabcde13.xlsx                    \
        http://static.ofcom.org.uk/static/numbering/sabcde14.xlsx                    \
        http://static.ofcom.org.uk/static/numbering/sabcde15.xlsx                    \
        http://static.ofcom.org.uk/static/numbering/sabcde16.xlsx                    \
        http://static.ofcom.org.uk/static/numbering/sabcde17.xlsx                    \
        http://static.ofcom.org.uk/static/numbering/sabcde18.xlsx                    \
        http://static.ofcom.org.uk/static/numbering/sabcde19.xlsx                    \
        http://static.ofcom.org.uk/static/numbering/sabcde2.xlsx                     \
        http://static.ofcom.org.uk/static/numbering/S3.xlsx                          \
        http://static.ofcom.org.uk/static/numbering/S5.xlsx                          \
        http://static.ofcom.org.uk/static/numbering/S7.xlsx                          \
        http://static.ofcom.org.uk/static/numbering/S8.xlsx                          \
        http://static.ofcom.org.uk/static/numbering/S9.xlsx                          \
        https://www.nationalpooling.com/reports/region/AllBlocksAugmentedReport.zip  \
        https://cnac.ca/data/COCodeStatus_ALL.zip;
    do
        # make sure that there's a file that curl -z can look at
        if test ! -e `basename $i`; then
            touch -t 198001010101 `basename $i`
        fi
        echo Fetching $i
        curl -z `basename $i` -R -O -s -S $i;
        if [ "$?" == "0" ]; then
            echo "  ... OK"
          else
            echo "  ... failed with $?, retry"
            sleep 15
            rm `basename $i`
            curl -R -O -s -S $i;
            if [ "$?" == "0" ]; then
                echo "  ... OK"
              else
                echo "  ... failed with $?, retry again"
                sleep 15
                rm `basename $i`
                curl -R -O -s -S $i;
                if [ "$?" == "0" ]; then
                    echo "  ... OK"
                  else
                    echo " ... failed three times, this time with $?, argh"
                    exit 1;
                fi
            fi
        fi
    done
    rm COCodeStatus_ALL.csv AllBlocksAugmentedReport.txt
    unzip -q COCodeStatus_ALL.zip
    unzip -q AllBlocksAugmentedReport.zip
)

# stash the Unix epoch of the OFCOM data
OFCOMDATETIME=$(cd data-files;perl -e 'print +(stat(shift))[9]' $(ls -rt sabc.txt *.xlsx|tail -1))
CADATETIME=$(cd data-files;perl -e 'print +(stat(shift))[9]' COCodeStatus_ALL.csv)
USDATETIME=$(cd data-files;perl -e 'print +(stat(shift))[9]' AllBlocksAugmentedReport.txt)

# if share/Number-Phone-UK-Data.db doesn't exist, or OFCOM's stuff is newer ...
if test ! -e share/Number-Phone-UK-Data.db -o \
  data-files/sabc.txt         -nt share/Number-Phone-UK-Data.db -o \
  data-files/sabcde11_12.xlsx -nt share/Number-Phone-UK-Data.db -o \
  data-files/sabcde13.xlsx    -nt share/Number-Phone-UK-Data.db -o \
  data-files/sabcde14.xlsx    -nt share/Number-Phone-UK-Data.db -o \
  data-files/sabcde15.xlsx    -nt share/Number-Phone-UK-Data.db -o \
  data-files/sabcde16.xlsx    -nt share/Number-Phone-UK-Data.db -o \
  data-files/sabcde17.xlsx    -nt share/Number-Phone-UK-Data.db -o \
  data-files/sabcde18.xlsx    -nt share/Number-Phone-UK-Data.db -o \
  data-files/sabcde19.xlsx    -nt share/Number-Phone-UK-Data.db -o \
  data-files/sabcde2.xlsx     -nt share/Number-Phone-UK-Data.db -o \
  data-files/S3.xlsx          -nt share/Number-Phone-UK-Data.db -o \
  data-files/S5.xlsx          -nt share/Number-Phone-UK-Data.db -o \
  data-files/S7.xlsx          -nt share/Number-Phone-UK-Data.db -o \
  data-files/S8.xlsx          -nt share/Number-Phone-UK-Data.db -o \
  data-files/S9.xlsx          -nt share/Number-Phone-UK-Data.db -o \
  build-data.uk               -nt share/Number-Phone-UK-Data.db;
then
  if [ "$CI" != "True" ] && [ "$CI" != "true" ]; then
    EXITSTATUS=1
  fi
  echo rebuilding share/Number-Phone-UK-Data.db
  perl build-data.uk
else
  echo share/Number-Phone-UK-Data.db is up-to-date
fi

# lib/Number/Phone/Country/Data.pm doesn't exist, or if libphonenumber/resources/PhoneNumberMetadata.xml is newer ...
if test ! -e lib/Number/Phone/Country/Data.pm -o \
  build-data.country-mapping                       -nt lib/Number/Phone/Country/Data.pm -o \
  libphonenumber/resources/PhoneNumberMetadata.xml -nt lib/Number/Phone/Country/Data.pm;
then
  if [ "$CI" != "True" ] && [ "$CI" != "true" ]; then
    EXITSTATUS=1
  fi
  echo rebuilding lib/Number/Phone/Country/Data.pm
  perl build-data.country-mapping
else
  echo lib/Number/Phone/Country/Data.pm is up-to-date
fi

# lib/Number/Phone/NANP/Data.pm doesn't exist, or if libphonenumber/resources/geocoding/en/1.txt or PhoneNumberMetadata.xml is newer ...
if test ! -e lib/Number/Phone/NANP/Data.pm -o \
  ! -e share/Number-Phone-NANP-Data.db -o \
  build-data.nanp                                  -nt lib/Number/Phone/NANP/Data.pm -o \
  libphonenumber/resources/geocoding/en/1.txt      -nt lib/Number/Phone/NANP/Data.pm -o \
  libphonenumber/resources/PhoneNumberMetadata.xml -nt lib/Number/Phone/NANP/Data.pm -o \
  data-files/AllBlocksAugmentedReport.zip          -nt share/Number-Phone-NANP-Data.db -o \
  data-files/AllBlocksAugmentedReport.txt          -nt share/Number-Phone-NANP-Data.db -o \
  data-files/COCodeStatus_ALL.zip                  -nt share/Number-Phone-NANP-Data.db -o \
  data-files/COCodeStatus_ALL.csv                  -nt share/Number-Phone-NANP-Data.db;
then
  if [ "$CI" != "True" ] && [ "$CI" != "true" ]; then
    EXITSTATUS=1
  fi
  echo rebuilding lib/Number/Phone/NANP/Data.pm
  echo   and share/Number-Phone-NANP-Data.db
  perl build-data.nanp
else
  echo lib/Number/Phone/NANP/Data.pm and share/Number-Phone-NANP-Data.db are up-to-date
fi
# this must be after build-data.nanp has fetched them
NANPDATETIME=$(perl -e 'print +(stat(shift))[9]' $(ls -rt data-files/[0-9][0-9][0-9].xml|tail -1))

# lib/Number/Phone/StubCountry/KZ.pm doesn't exist, or if libphonenumber/resources/PhoneNumberMetadata.xml is newer,
# or if lib/Number/Phone/NANP/Data.pm is newer ...
if test ! -e lib/Number/Phone/StubCountry/KZ.pm -o \
  build-data.stubs                                 -nt lib/Number/Phone/StubCountry/KZ.pm -o \
  libphonenumber/resources/geocoding/en/1.txt      -nt lib/Number/Phone/StubCountry/KZ.pm -o \
  libphonenumber/resources/PhoneNumberMetadata.xml -nt lib/Number/Phone/StubCountry/KZ.pm -o \
  lib/Number/Phone/NANP/Data.pm                    -nt lib/Number/Phone/StubCountry/KZ.pm;
then
  if [ "$CI" != "True" ] && [ "$CI" != "true" ]; then
    EXITSTATUS=1
  fi
  echo rebuilding lib/Number/Phone/StubCountry/\*.pm
  perl build-data.stubs
else
  echo lib/Number/Phone/StubCountry/\*.pm are up-to-date
fi

# t/example-phone-numbers.t doesn't exist, or if libphonenumber/resources/PhoneNumberMetadata.xml is newer
if test ! -e t/example-phone-numbers.t -o \
  build-tests.pl                                   -nt t/example-phone-numbers.t -o \
  libphonenumber/resources/PhoneNumberMetadata.xml -nt t/example-phone-numbers.t;
then
  if [ "$CI" != "True" ] && [ "$CI" != "true" ]; then
    EXITSTATUS=1
  fi
  echo rebuilding t/example-phone-numbers.t
  perl build-tests.pl
else
  echo t/example-phone-numbers.t is up-to-date
fi

# update Number::Phone::Data with update date/times and libphonenumber tag
OLD_N_P_DATA_MD5=$(md5sum lib/Number/Phone/Data.pm 2>/dev/null)
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
if [ "$OLD_N_P_DATA_MD5" != "$(md5sum lib/Number/Phone/Data.pm)" ] && [ "$CI" != "True" ] && [ "$CI" != "true" ]; then
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
            $line =~ s/^\s+#\s+next\s+check\s+due\s+//;
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
        git push -q
        git gc -q
    fi
)

exit $EXITSTATUS
