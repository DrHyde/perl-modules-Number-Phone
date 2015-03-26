#!/bin/sh
cover -delete
HARNESS_PERL_SWITCHES=-MDevel::Cover make test
cover -ignore blib/lib/Number/Phone/UK/Data.pm
