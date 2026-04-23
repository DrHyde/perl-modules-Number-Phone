cpanm --quiet --notest ExtUtils::MakeMaker Test::Pod Test::Pod::Coverage parent
cpanm --quiet --notest File::ShareDir::Install XML::XPath
cpanm --quiet --notest File::Find::Rule Text::CSV_XS LWP::Protocol::https
perl Makefile.PL
./build-data.sh
make test
make dist
