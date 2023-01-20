#!/bin/sh
cover -delete
# HARNESS_PERL_SWITCHES=-MDevel::Cover make test
AUTOMATED_TESTING=1 cover -ignore_re ^buildtools/ -test
