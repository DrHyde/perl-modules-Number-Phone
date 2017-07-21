#!/bin/bash

# THIS SHELL SCRIPT IS NOT INTENDED FOR END USERS OR FOR PEOPLE INSTALLING
# THE MODULES, BUT FOR THE AUTHOR'S USE WHEN UPDATING THE DATA FROM OFCOM'S
# AND libphonenumber's PUBLISHED DATA.

if [ "$1" == "--force" ]; then
  rm share/Number-Phone-UK-Data.db
  rm lib/Number/Phone/NANP/Data.pm
  rm lib/Number/Phone/StubCountry/KZ.pm
  rm t/example-phone-numbers.t
fi

EXITSTATUS=0
# first get OFCOM data
for i in \
    http://static.ofcom.org.uk/static/numbering/sabc.txt        \
    http://static.ofcom.org.uk/static/numbering/sabcde11_12.xls \
    http://static.ofcom.org.uk/static/numbering/sabcde13.xls    \
    http://static.ofcom.org.uk/static/numbering/sabcde14.xls    \
    http://static.ofcom.org.uk/static/numbering/sabcde15.xls    \
    http://static.ofcom.org.uk/static/numbering/sabcde16.xls    \
    http://static.ofcom.org.uk/static/numbering/sabcde17.xls    \
    http://static.ofcom.org.uk/static/numbering/sabcde18.xls    \
    http://static.ofcom.org.uk/static/numbering/sabcde19.xls    \
    http://static.ofcom.org.uk/static/numbering/sabcde2.xls     \
    http://static.ofcom.org.uk/static/numbering/S3.xls          \
    http://static.ofcom.org.uk/static/numbering/S5.xls          \
    http://static.ofcom.org.uk/static/numbering/S7.xls          \
    http://static.ofcom.org.uk/static/numbering/S8.xls          \
    http://static.ofcom.org.uk/static/numbering/S9.xls;
do
    # make sure that there's a file that curl -z can look at
    if test ! -e `basename $i`; then
        touch -t 198001010101 `basename $i`
    fi
    curl -z `basename $i` -R -O -s $i;
done

# unzip -q -o codelist.zip sabc.txt

# if share/Number-Phone-UK-Data.db doesn't exist, or OFCOM's stuff is newer ...
if test ! -e share/Number-Phone-UK-Data.db -o \
  sabc.txt          -nt share/Number-Phone-UK-Data.db -o \
  sabcde11_12.xls   -nt share/Number-Phone-UK-Data.db -o \
  sabcde13.xls      -nt share/Number-Phone-UK-Data.db -o \
  sabcde14.xls      -nt share/Number-Phone-UK-Data.db -o \
  sabcde15.xls      -nt share/Number-Phone-UK-Data.db -o \
  sabcde16.xls      -nt share/Number-Phone-UK-Data.db -o \
  sabcde17.xls      -nt share/Number-Phone-UK-Data.db -o \
  sabcde18.xls      -nt share/Number-Phone-UK-Data.db -o \
  sabcde19.xls      -nt share/Number-Phone-UK-Data.db -o \
  sabcde2.xls       -nt share/Number-Phone-UK-Data.db -o \
  S3.xls            -nt share/Number-Phone-UK-Data.db -o \
  S5.xls            -nt share/Number-Phone-UK-Data.db -o \
  S7.xls            -nt share/Number-Phone-UK-Data.db -o \
  S8.xls            -nt share/Number-Phone-UK-Data.db -o \
  S9.xls            -nt share/Number-Phone-UK-Data.db -o \
  build-data.uk     -nt share/Number-Phone-UK-Data.db;
then
  if [ "$TRAVIS" != "true" ]; then
    EXITSTATUS=1
  fi
  echo rebuilding share/Number-Phone-UK-Data.db
  perl build-data.uk
else
  echo share/Number-Phone-UK-Data.db is up-to-date
fi

# now get an up-to-date libphonenumber
(cd libphonenumber && git pull -q) || (echo Checking out libphonenumber ...; git clone https://github.com/googlei18n/libphonenumber.git)

# lib/Number/Phone/NANP/Data.pm doesn't exist, or if libphonenumber/resources/geocoding/en/1.txt or PhoneNumberMetadata.xml is newer ...
if test ! -e lib/Number/Phone/NANP/Data.pm -o \
  build-data.nanp -nt lib/Number/Phone/NANP/Data.pm -o \
  libphonenumber/resources/geocoding/en/1.txt -nt lib/Number/Phone/NANP/Data.pm -o \
  libphonenumber/resources/PhoneNumberMetadata.xml -nt lib/Number/Phone/NANP/Data.pm;
then
  if [ "$TRAVIS" != "true" ]; then
    EXITSTATUS=1
  fi
  echo rebuilding lib/Number/Phone/NANP/Data.pm
  perl build-data.nanp
else
  echo lib/Number/Phone/NANP/Data.pm is up-to-date
fi

# lib/Number/Phone/StubCountry/KZ.pm doesn't exist, or if libphonenumber/resources/PhoneNumberMetadata.xml is newer,
# or if lib/Number/Phone/NANP/Data.pm is newer ...
if test ! -e lib/Number/Phone/StubCountry/KZ.pm -o \
  build-data.stubs -nt lib/Number/Phone/StubCountry/KZ.pm -o \
  libphonenumber/resources/geocoding/en/1.txt -nt lib/Number/Phone/StubCountry/KZ.pm -o \
  libphonenumber/resources/PhoneNumberMetadata.xml -nt lib/Number/Phone/StubCountry/KZ.pm -o \
  lib/Number/Phone/NANP/Data.pm -nt lib/Number/Phone/StubCountry/KZ.pm;
then
  if [ "$TRAVIS" != "true" ]; then
    EXITSTATUS=1
  fi
  echo rebuilding lib/Number/Phone/StubCountry/\*.pm
  perl build-data.stubs
else
  echo lib/Number/Phone/StubCountry/\*.pm are up-to-date
fi

# t/example-phone-numbers.t doesn't exist, or if libphonenumber/resources/PhoneNumberMetadata.xml is newer
if test ! -e t/example-phone-numbers.t -o \
  build-tests.pl -nt t/example-phone-numbers.t -o \
  libphonenumber/resources/PhoneNumberMetadata.xml -nt t/example-phone-numbers.t;
then
  if [ "$TRAVIS" != "true" ]; then
    EXITSTATUS=1
  fi
  echo rebuilding t/example-phone-numbers.t
  perl build-tests.pl
else
  echo t/example-phone-numbers.t is up-to-date
fi

if [ $EXITSTATUS == 1 ]; then
  if test -e Makefile; then
    echo stuff changed, need to re-run Makefile.PL
    `grep "^PERL " Makefile|awk '{print $3}'|sed 's/"//g'` Makefile.PL
  fi
fi

exit $EXITSTATUS
