![Written in perl](https://img.shields.io/badge/perl-%2339457E.svg?&logo=perl&logoColor=white)
 ![On the CPAN](https://img.shields.io/cpan/v/Number-Phone)
 ![Linux build status](https://img.shields.io/travis/com/DrHyde/perl-modules-Number-Phone?label=Linux)
 ![FreeBSD build status](https://img.shields.io/cirrus/github/DrHyde/perl-modules-Number-Phone?task=FreeBSD)
 ![MacOS build status](https://img.shields.io/cirrus/github/DrHyde/perl-modules-Number-Phone?task=MacOS)
 ![Windows build status](https://img.shields.io/appveyor/build/DrHyde/perl-modules-Number-Phone?label=Windows)
 ![Test coverage](https://img.shields.io/coveralls/github/DrHyde/perl-modules-Number-Phone/master?label=Coverage)
 ![Github issues](https://img.shields.io/github/issues/DrHyde/perl-modules-Number-Phone?label=Issues)

# Description

This is a large suite of perl modules for parsing and dealing with phone
numbers. For most countries it provides functionality broadly similar to
Google's libphonenumber.

For some NANP countries (mostly north America and the Caribbean; all those
countries in the +1 country code) some extra information is available, in
particular numbers in ranges like such as +1 800 are not just assumed to be
US numbers like what libphonenumber does, and information may be available
on which telco a number is assigned to.

For the UK (and its nearby dependencies) even more is available, including
an approximate location for many geographic numbers, and detection of
fake numbers assigned for use in drama.

# Installation as a user

If you just want to use the code, then install from the CPAN in the usual fashion:

    cpanm Number::Phone

or

    cpan Number::Phone

If you are short on disk space then you might want to consider installing
it without the extra information for the UK. You will still get support for
everything libphonenumber can do, but will save about 100MB of disk space.
Installation like this is a bit more involved:

    cpanm --look Number::Phone

that will download and unpack the most recent version, and open a shell in
the directory into which it was unpacked. Then:

    cpanm --installdeps .
    perl Makefile.PL --without_uk
    make test
    make install
    exit

# Installation as a developer

If you want to work on the code then you will need to run the build script after checking the code out of git:

    ./build-data.sh

That script will need several extra dependencies that aren't listed in `Makefile.PL`. You can see them in the various CI tools' configuration files, such as `.appveyor.yml`. Once you've successfully built the data files (and some code modules that are auto-generated) you can run the tests to see if everything is OK:

    perl Makefile.PL
    make
    make test

Note that you may get test failures if real-world data has changed in such a way as to contradict existing tests.

# Structure

Number::Phone is a base class for parsing and dealing with phone numbers, and the entry point for using all the other modules.

Number::Phone::UK inherits methods from it, over-riding some with UK-specific implementations. The intention is that other people will write other country-specific classes exposing the same API. There are [several](https://metacpan.org/release/Number-Phone-FR) [examples](https://metacpan.org/release/Number-Phone-RO) on the CPAN.

Number::Phone::NANP implements functionality common to all NANP countries (those with international dialling code +1), and Number::Phone::NANP::XX implement some minor details for each individual country in that region.

Number::Phone::StubCountry::* are automatically generated from Google's libphonenumber project's data. They do not support all the features of Number::Phone, but will support many use-cases and should "fail gracefully" if you try to use unsupported features. They will be used if a more fully-featured module is not available. For example if you want Number::Phone to work with a French number it would use Number::Phone::StubCountry::FR unless the third-party Number::Phone::FR is installed.

Number::Phone::Country is a useful module which is used by the NANP modules. It was originally written by T. J. Mather but is now maintained by me.

There are a few Data.pm files at various places in the hierarchy. They either contain data or contain code for accessing data stored in other files.

Finally, Number::Phone::Lib will *only* use N::P::StubCountry::* modules, it won't use any more capable third-party modules. This may be preferred for speed or memory usage, and is a bit more compatible with libphonenumber's view of things.

You should not edit any file that exists but which git doesn't know about, there's a lot of auto-generated stuff here.

# Data sources

The build script uses data from [OFCOM](http://www.ofcom.org.uk/), [CNAC](http://www.cnac.ca/), the US's [National Pooling Administrator](https://www.nationalpooling.com), [localcallingguide.com](https://localcallingguide.com/), and [Google's libphonenumber](http://code.google.com/p/libphonenumber/).

There is also data derived manually from all of the above, and from [the ITU](http://www.itu.int/itu-t/inr/nnp/), [World Telephone Numbering Guide](http://wtng.info/) (treat this with caution, it seems to be no longer maintained), and [Wikipedia](https://en.wikipedia.org/).

Most of those disclaim any responsibility for errors in the data.  I disclaim
all responsibility for errors too, even if my code makes your PBX melt into
a puddle of purple goo.
