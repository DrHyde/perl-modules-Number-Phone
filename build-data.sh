#!/bin/bash

# THIS SHELL SCRIPT IS NOT INTENDED FOR END USERS OR FOR PEOPLE INSTALLING
# THE MODULES, BUT FOR THE AUTHOR'S USE WHEN UPDATING THE DATA FROM OFCOM'S
# AND libphonenumber's PUBLISHED DATA.

if [ "$1" == "--force" ]; then
  rm lib/Number/Phone/UK/Data.pm
  rm lib/Number/Phone/NANP/Data.pm
  rm lib/Number/Phone/StubCountry/KZ.pm
fi

EXITSTATUS=0
# first get OFCOM data
# sabc.txt now exists on its own do this is commented out for now
# http://www.ofcom.org.uk/static/numbering/codelist.zip    \
for i in \
    http://www.ofcom.org.uk/static/numbering/sabc.txt        \
    http://www.ofcom.org.uk/static/numbering/sabcde11_12.xls \
    http://www.ofcom.org.uk/static/numbering/sabcde13.xls    \
    http://www.ofcom.org.uk/static/numbering/sabcde14.xls    \
    http://www.ofcom.org.uk/static/numbering/sabcde15.xls    \
    http://www.ofcom.org.uk/static/numbering/sabcde16.xls    \
    http://www.ofcom.org.uk/static/numbering/sabcde17.xls    \
    http://www.ofcom.org.uk/static/numbering/sabcde18.xls    \
    http://www.ofcom.org.uk/static/numbering/sabcde19.xls    \
    http://www.ofcom.org.uk/static/numbering/sabcde2.xls     \
    http://www.ofcom.org.uk/static/numbering/S3.xls          \
    http://www.ofcom.org.uk/static/numbering/S5.xls          \
    http://www.ofcom.org.uk/static/numbering/S7.xls          \
    http://www.ofcom.org.uk/static/numbering/S8.xls          \
    http://www.ofcom.org.uk/static/numbering/S9.xls;
do
    # make sure that there's a file that curl -z can look at
    if test ! -e `basename $i`; then
        touch -t 198001010101 `basename $i`
    fi
    curl -z `basename $i` -R -O -s $i;
done

# unzip -q -o codelist.zip sabc.txt

# if UK/Data.pm doesn't exist, or OFCOM's stuff is newer ...
# codelist.zip      -nt lib/Number/Phone/UK/Data.pm -o \
if test ! -e lib/Number/Phone/UK/Data.pm -o \
  sabc.txt          -nt lib/Number/Phone/UK/Data.pm -o \
  sabcde11_12.xls   -nt lib/Number/Phone/UK/Data.pm -o \
  sabcde13.xls      -nt lib/Number/Phone/UK/Data.pm -o \
  sabcde14.xls      -nt lib/Number/Phone/UK/Data.pm -o \
  sabcde15.xls      -nt lib/Number/Phone/UK/Data.pm -o \
  sabcde16.xls      -nt lib/Number/Phone/UK/Data.pm -o \
  sabcde17.xls      -nt lib/Number/Phone/UK/Data.pm -o \
  sabcde18.xls      -nt lib/Number/Phone/UK/Data.pm -o \
  sabcde19.xls      -nt lib/Number/Phone/UK/Data.pm -o \
  sabcde2.xls       -nt lib/Number/Phone/UK/Data.pm -o \
  S3.xls            -nt lib/Number/Phone/UK/Data.pm -o \
  S5.xls            -nt lib/Number/Phone/UK/Data.pm -o \
  S7.xls            -nt lib/Number/Phone/UK/Data.pm -o \
  S8.xls            -nt lib/Number/Phone/UK/Data.pm -o \
  S9.xls            -nt lib/Number/Phone/UK/Data.pm -o \
  build-data.uk     -nt lib/Number/Phone/UK/Data.pm;
then
  if [ "$TRAVIS" != "true" ]; then
    EXITSTATUS=1
  fi
  echo rebuilding lib/Number/Phone/UK/Data.pm
  perl build-data.uk
else
  echo lib/Number/Phone/UK/Data.pm is up-to-date
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

if [ $EXITSTATUS == 1 ]; then
  if test -e Makefile; then
    echo stuff changed, need to re-run Makefile.PL
    `grep "^PERL " Makefile|awk '{print $3}'|sed 's/"//g'` Makefile.PL
  fi
fi

exit $EXITSTATUS
