perl Makefile.PL --without_uk INSTALL_BASE=$HOME/test_install
make test TEST_VERBOSE=1
make install
perl -I$HOME/test_install/lib/perl5 -MData::Dumper::Concise -MNumber::Phone -e 'if(Number::Phone->new("+447979866975")->isa("Number::Phone::StubCountry::GB")) { print "N::P built/installed correctly without N::P::UK\n".Dumper(\%INC); exit(0) } else { print "N::P build/install failed\n"; exit(1) }'
