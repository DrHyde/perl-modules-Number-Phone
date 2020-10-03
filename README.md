<img src="https://img.shields.io/badge/perl-%2339457E.svg?&logo=perl&logoColor=white" alt="Written in perl"> <img src=https://img.shields.io/cpan/v/Number-Phone alt="On the CPAN"> <img src="https://img.shields.io/travis/com/DrHyde/perl-modules-Number-Phone?label=Linux" alt="Linux build status"> <img src="https://img.shields.io/cirrus/github/DrHyde/perl-modules-Number-Phone?task=FreeBSD" alt="FreeBSD build status"> <img src="https://img.shields.io/cirrus/github/DrHyde/perl-modules-Number-Phone?task=MacOS" alt="MacOS build status"> <img src="https://img.shields.io/appveyor/build/DrHyde/perl-modules-Number-Phone?label=Windows" alt="Windows build status"> <img src="https://img.shields.io/coveralls/github/DrHyde/perl-modules-Number-Phone/master?label=Coverage" alt="Test coverage"> <img src="https://img.shields.io/github/issues/DrHyde/perl-modules-Number-Phone?label=Issues" alt="Github issues">

# Description

This is a large suite of perl modules for parsing and dealing with phone numbers.

# Installation as a user

If you just want to use the code, then install from the CPAN in the usual fashion:

    cpanm Number::Phone

or

    cpan Number::Phone

# Installation as a developer

If you want to work on the code then you will need to run the build script after checking the code out of git:

    ./build-data.sh

That script will need several extra dependencies that aren't listed in `Makefile.PL`. You can see them in the various CI tools' configuration files, such as `.appveyor.yml`. Once you've successfully built the data files (and some code modules that are auto-generated) you can run the tests to see if everything is OK:

    perl Makefile.PL
    make
    make test

# Structure

Number::Phone is a base class for parsing and dealing with phone numbers.

Number::Phone::UK inherits methods from it, over-riding some with UK-specific implementations.  The intention is that other people will write other country-specific classes exposing the same API. There are [several](https://metacpan.org/release/Number-Phone-FR) [examples](https://metacpan.org/release/Number-Phone-RO) on the CPAN.

Number::Phone::NANP implements functionality common to all NANP countries (those with international dialling code +1), and Number::Phone::NANP::XX implement some minor details for each individual country in that region.

Number::Phone::StubCountry::* are automatically generated from Google's libphonenumber project's data.  They do not support all the features of Number::Phone, but will support many use-cases and should "fail gracefully" if you try to use unsupported features.

Number::Phone::Country is a useful module which is used by the NANP modules. It was originally written by T. J. Mather but is now maintained by me.

Finally, there are a few Data.pm files at various places in the hierarchy. They either contain data or contain code for accessing data stored in other files.

You should not edit any file that exists but which git doesn't know about, there's a lot of auto-generated stuff here.

# Data sources

The build script uses data from [OFCOM](http://www.ofcom.org.uk/), [CNAC](http://www.cnac.ca/), the US's [National Pooling Administrator](https://www.nationalpooling.com), [localcallingguide.com](https://localcallingguide.com/), and [Google's libphonenumber](http://code.google.com/p/libphonenumber/).

There is also data derived manually from all of the above, and from [the ITU](http://www.itu.int/itu-t/inr/nnp/), [World Telephone Numbering Guide](http://wtng.info/) (treat this with caution, it seems to be no longer maintained), and [Wikipedia](https://en.wikipedia.org/).

Most of those disclaim any responsibility for errors in the data.  I disclaim
all responsibility for errors too, even if my code makes your PBX turn
purple.
