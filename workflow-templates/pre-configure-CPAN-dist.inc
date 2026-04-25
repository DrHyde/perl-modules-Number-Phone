cpanm --quiet --notest ExtUtils::MakeMaker Test::Pod Test::Pod::Coverage parent
cpanm --quiet --notest File::ShareDir::Install XML::XPath Data::CompactReadonly File::Find::Rule Text::CSV_XS LWP::Protocol::https
cpanm --quiet --notest --installdeps .
./build-data.sh
