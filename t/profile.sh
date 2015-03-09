#!/bin/sh
rm nytprof.out 2>/dev/null
HARNESS_PERL_SWITCHES=-MDevel::NYTProf make test
nytprofhtml --open
