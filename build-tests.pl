#!/usr/bin/env perl

# THIS SCRIPT IS NOT INTENDED FOR END USERS OR FOR PEOPLE INSTALLING
# THE MODULES, BUT FOR THE AUTHOR'S USE WHEN UPDATING THE DATA FROM OFCOM'S
# PUBLISHED DATA.

use strict;
use warnings;
use Data::Dumper; local $Data::Dumper::Indent = 2;
use XML::XPath;

$| = 1;

open(my $testfh, '>', 't/example-phone-numbers.t') ||
    die("Can't write t/example-phone-numbers.t: $!\n");
print $testfh preamble();

my $xml = XML::XPath->new(filename => 'libphonenumber/resources/PhoneNumberMetadata.xml');
my @territories = $xml->find('/phoneNumberMetadata/territories/territory')->get_nodelist();

my @tests = ();

TERRITORY: foreach my $territory (@territories) {
  my $IDD_country_code = ''.$territory->find('@countryCode');
  my $national_code    = ''.($IDD_country_code != 1 ? $territory->find('@nationalPrefix') : '');
  my $ISO_country_code = ''.$territory->find('@id');
  if($ISO_country_code !~ /^..$/) {
    # warn("skipping 'country' $ISO_country_code (+$IDD_country_code)\n");
    next TERRITORY;
  }
  my @example_numbers = $territory->find('*/exampleNumber')->get_nodelist();
  NUMBER: foreach my $example_number (@example_numbers) {
      my $number = $example_number->string_value();
      my $type = ($example_number->find('..')->get_nodelist())[0]->getName();
      if($type =~ /^(voicemail|noInternationalDialling|areaCodeOptional)$/) {
          # warn("skipping type $type for $ISO_country_code (+$IDD_country_code)\n");
          next NUMBER
      }
      my @test_tuples = map {
          ($_->[0] eq 'GB') ? ($_, ['UK', $_->[1]]) : $_
      } (
          [$ISO_country_code, "+$IDD_country_code$number"],
          [$ISO_country_code, "$national_code$number"],
          [                   "+$IDD_country_code$number"]
      );
      TUPLE: foreach my $test_tuple (@test_tuples) {
          my $test_method      =
              $type eq 'uan' ? 'is_specialrate' :
              $type eq 'sharedCost' ? 'is_specialrate' :
              $type eq 'premiumRate' ? 'is_specialrate' :
              $type eq 'voip' ? 'is_ipphone' :
              $type eq 'fixedLine' ? 'is_fixed_line' :
              $type eq 'mobile' ? 'is_mobile' :
              $type eq 'pager' ? 'is_pager' :
              $type eq 'tollFree' ? 'is_tollfree' :
              $type eq 'personalNumber' ? 'is_personal' :
              die("WTF is $type\n");

          if($IDD_country_code == 1 && $test_method =~ /
              is_ipphone |
              is_mobile |
              is_fixed_line |
              is_pager
          /x) {
              if($test_method =~ /is_fixed_line|is_mobile/) {
                  warnonce("checking $ISO_country_code number +$IDD_country_code $number, as is_geographic *or* $test_method\n");
                  $test_method = [$test_method, 'is_geographic'];
              } else {
                 # warn("skipping $ISO_country_code number +$IDD_country_code $number, NANP::* don't fully support $test_method\n");
                 next NUMBER;
             }
          }

          if($IDD_country_code eq '44' && $number =~ /
              ^
              121 234 5678
              |
              1481 256789
              |
              1624 756789
              $
          /x) {
              warn("checking $ISO_country_code number +$IDD_country_code $number, as is_geographic, not is_fixed_line\n");
              $test_method = 'is_geographic';
          }
          if($IDD_country_code eq '672' && $number =~ /^1/) {
              # warn("$ISO_country_code number +$IDD_country_code $number in libphonenumber's example data is dodgy, (conflates NF and AQ)\n");
              next NUMBER;
          }
          if($test_tuple->[0] eq 'VA') {
              warnonce("$ISO_country_code number +$IDD_country_code $number in libphonenumber's example data needs to be treated as IT");
              $test_tuple->[0] = 'IT';
          }
          if($IDD_country_code eq '44' && $number =~ /
              ^
              800   123 4567  |
              5[56] 1234 5678 |
              1481 456789     |
              1624 456789     |
              1534 456789     |
              7797 123456     |
              7624 012345
              $
          /x) {
              # warn("$ISO_country_code number +$IDD_country_code $number in libphonenumber's example data is wrong\n");
              next NUMBER;
          }
          my $constructor_args = [map { "'$_'" } @{$test_tuple}];
          my @classes = $IDD_country_code eq '44' ? qw(Number::Phone Number::Phone::Lib) :
                        $IDD_country_code eq '1'  ? qw(Number::Phone Number::Phone::Lib) :
                                                    qw(Number::Phone::Lib);

          if(!ref($test_method)) { $test_method = [$test_method] }
          my $test_methods     = [map { "'$_'" } @{$test_method}];

          foreach my $class (@classes) {
              push @tests, {
                  class   => $class,
                  args    => $constructor_args,
                  methods => $test_methods
              };
          }
      }
  }
}

print $testfh 'foreach my $test (';
foreach my $test (@tests) {
    print $testfh "{ class => '".$test->{class}."', args => [".join(',',@{$test->{args}})."], methods => [".join(',',@{$test->{methods}})."] },\n";
}
print $testfh ') {
    my($class, $args, $methods) = map { $test->{$_} } qw(class args methods);
    ok(
        # grep is because a number might need to be checked as is_geographic *or* is_fixed_line
        (grep { $class->new(@{$args})->$_() } @{$methods}),
        "$class->new(".join(", ", @{$args}).")->".join(", ", @{$methods})."() does the right thing"
    );
}';

my %warnings = ();
sub warnonce {
    my $warning = shift;
    return if(exists($warnings{$warning}));
    warn($warnings{$warning} = $warning);
}

sub preamble {
    q{
        # automatically generated file, don't edit
        #
        # Copyright 2016 David Cantrell, derived from data from libphonenumber
        # http://code.google.com/p/libphonenumber/
        #
        # Licensed under the Apache License, Version 2.0 (the "License");
        # you may not use this file except in compliance with the License.
        # You may obtain a copy of the License at
        #
        #     http://www.apache.org/licenses/LICENSE-2.0
        #
        # Unless required by applicable law or agreed to in writing, software
        # distributed under the License is distributed on an "AS IS" BASIS,
        # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        # See the License for the specific language governing permissions and
        # limitations under the License.
        
        use strict;
        use warnings;
        use Test::More;
        END { done_testing }

        use Number::Phone;
        use Number::Phone::Lib;
    };
}
