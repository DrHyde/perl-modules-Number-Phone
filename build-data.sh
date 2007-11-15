#!/bin/sh

# THIS SHELL SCRIPT IS NOT INTENDED FOR END USERS OR FOR PEOPLE INSTALLING
# THE MODULES, BUT FOR THE AUTHOR'S USE WHEN UPDATING THE DATA FROM OFCOM'S
# PUBLISHED DATA.

wget http://www.ofcom.org.uk/telecoms/ioi/numbers/numbers_administered/codelist.zip
unzip codelist.zip
perl build-data.realwork
cat Data.pm temp.db > lib/Number/Phone/UK/Data.pm

rm codelist.zip s[0123456789]*.txt sabc.txt Data.pm temp.db

