#!/bin/sh

# THIS SHELL SCRIPT IS NOT INTENDED FOR END USERS OR FOR PEOPLE INSTALLING
# THE MODULES, BUT FOR THE AUTHOR'S USE WHEN UPDATING THE DATA FROM OFCOM'S
# AND libphonenumber's PUBLISHED DATA.

# first get OFCOM data and update .../UK/Data.pm
wget http://www.ofcom.org.uk/static/numbering/codelist.zip
unzip codelist.zip
perl build-data.uk
cat Data.pm temp.db > lib/Number/Phone/UK/Data.pm
rm codelist.zip s[0123456789]*.txt sabc.txt Data.pm temp.db

# now get an up-to-date libphonenumber
(cd libphonenumber && svn up) || svn co http://libphonenumber.googlecode.com/svn/trunk libphonenumber
