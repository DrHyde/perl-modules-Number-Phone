package Number::Phone::Country;

use strict;

our $VERSION = 1.5;
our $use_uk = 0;

sub import {
    shift;
    my $export = 1;
    foreach my $param (@_) {
        if(lc($param) eq 'noexport') { $export = 0; }
         elsif(lc($param) eq 'uk') { $use_uk = 1; }
    }
    if($export) {
        my $callpkg = caller(1);
        no strict 'refs';
        *{"$callpkg\::phone2country"} = \&{__PACKAGE__."\::phone2country"};
    }
}

my %idd_codes = (
    # 1     => 'NANP',

    20      => 'EG', 212     => 'MA', 213     => 'DZ', 216     => 'TN',
    218     => 'LY', 220     => 'GM', 221     => 'SN', 222     => 'MR',
    223     => 'ML',
    224     => 'GN',
    225     => 'CI', 226     => 'BF', 227     => 'NE', 228     => 'TG',
    229     => 'BJ', 230     => 'MU', 231     => 'LR', 232     => 'SL',
    233     => 'GH', 234     => 'NG', 235     => 'TD', 236     => 'CF',
    237     => 'CM', 238     => 'CV',
    239     => 'ST', 240     => 'GQ', 241     => 'GA',
    242     => 'CG', 243     => 'CD', 244     => 'AO', 245     => 'GW',
    246     => 'IO', 247     => 'AC', 248     => 'SC', 249     => 'SD',
    250     => 'RW', 251     => 'ET', 252     => 'SO', 253     => 'DJ',
    254     => 'KE', 255     => 'TZ', 256     => 'UG', 257     => 'BI',
    258     => 'MZ', 260     => 'ZM', 261     => 'MG',
    2622691 => 'YT',  # \
    26226960 => 'YT', # |
    26226961 => 'YT', # | Mayotte fixed lines
    26226962 => 'YT', # |
    26226963 => 'YT', # |
    26226964 => 'YT', # /
    26263920 => 'YT', # \
    26263921 => 'YT', # |
    26263922 => 'YT', # |
    26263923 => 'YT', # |
    26263924 => 'YT', # | Mayotte GSM
    26263965 => 'YT', # |
    26263966 => 'YT', # |
    26263967 => 'YT', # |
    26263968 => 'YT', # |
    26263969 => 'YT', # /
    262     => 'RE',  # Assume that Reunion is everything else in +262
    263     => 'ZW',
    264     => 'NA', 265     => 'MW', 266     => 'LS', 267     => 'BW',
    268     => 'SZ',
    269     => 'KM',
    27      => 'ZA', 290     => 'SH',
    291     => 'ER',
    297     => 'AW', 298     => 'FO', 299     => 'GL',
    
    30      => 'GR', 31      => 'NL', 32      => 'BE', 33      => 'FR',
    34      => 'ES', 349567  => 'GI', 350     => 'GI', 351     => 'PT',
    352     => 'LU', 353     => 'IE', 35348   => 'GB', 354     => 'IS',
    355     => 'AL', 356     => 'MT', 357     => 'CY', 358     => 'FI',
    359     => 'BG', 36      => 'HU', 370     => 'LT', 371     => 'LV',
    372     => 'EE', 373     => 'MD', 374     => 'AM', 375     => 'BY',
    376     => 'AD', 377     => 'MC', 378     => 'SM', 379     => 'VA',
    380     => 'UA', 381     => 'RS', 382     => 'ME', 385     => 'HR',
    386     => 'SI',
    387     => 'BA',
    389     => 'MK', 39      => 'IT', 3966982 => 'VA',
    40      => 'RO', 41      => 'CH', 420     => 'CZ', 421     => 'SK',
    423     => 'LI',
    43      => 'AT', 44      => 'GB', 45      => 'DK', 46      => 'SE',
    47      => 'NO', 48      => 'PL', 49      => 'DE',
    
    500     => 'FK',
    501     => 'BZ', 502     => 'GT', 503     => 'SV', 504     => 'HN',
    505     => 'NI', 506     => 'CR', 507     => 'PA',
    508     => 'PM', 509     => 'HT',
    51      => 'PE', 52      => 'MX', 53      => 'CU', 54      => 'AR',
    55      => 'BR', 56      => 'CL', 57      => 'CO', 58      => 'VE',
    590     => 'GP', 591     => 'BO', 592     => 'GY', 593     => 'EC',
    594     => 'GF', 595     => 'PY', 596     => 'MQ', 597     => 'SR',
    598     => 'UY', 599     => 'AN',
    
    60      => 'MY',
    61      => 'AU',
    6189162 => 'CC', # Cocos (Keeling) Islands
    6189164 => 'CX', # Christmas Island
    62      => 'ID', 63      => 'PH',
    64      => 'NZ', 65      => 'SG', 66      => 'TH', 670     => 'TL',
    67210   => 'AQ', # Davis station    \
    67211   => 'AQ', # Mawson           | Australian Antarctic bases
    67212   => 'AQ', # Casey            |
    67213   => 'AQ', # Macquarie Island /
    6723    => 'NF', # Norfolk Island
    673     => 'BN', 674     => 'NR', 675     => 'PG', 676     => 'TO',
    677     => 'SB', 678     => 'VU', 679     => 'FJ', 680     => 'PW',
    681     => 'WF', 682     => 'CK',
    683     => 'NU', 685     => 'WS', 686     => 'KI', 687     => 'NC',
    688     => 'TV',
    689     => 'PF', 690     => 'TK', 691     => 'FM', 692     => 'MH',
    
    # 7     => 'RU & KZ',
    
    81      => 'JP', 82      => 'KR', 84      => 'VN', 850     => 'KP',
    852     => 'HK', 853     => 'MO', 855     => 'KH', 856     => 'LA',
    86      => 'CN',
    880     => 'BD',
    886     => 'TW',
    
    90      => 'TR', 91      => 'IN', 92      => 'PK', 93      => 'AF',
    94      => 'LK', 95      => 'MM', 960     => 'MV', 961     => 'LB',
    962     => 'JO', 963     => 'SY', 964     => 'IQ', 965     => 'KW',
    966     => 'SA', 967     => 'YE', 968     => 'OM', 970     => 'PS',
    971     => 'AE',
    972     => 'IL', 973     => 'BH', 974     => 'QA', 975     => 'BT',
    976     => 'MN', 977     => 'NP',
    98      => 'IR',
    992     => 'TJ',
    993     => 'TM', 994     => 'AZ', 995     => 'GE',
    996     => 'KG', 998     => 'UZ',

    3883    => 'ETNS', # http://wtng.info/wtng-reg.html#Europewide
    800     => 'InternationalFreephone',
    808     => 'SharedCostServices',
    870     => 'Inmarsat',
    871     => 'Inmarsat',
    872     => 'Inmarsat',
    873     => 'Inmarsat',
    874     => 'Inmarsat',
    878     => 'UniversalPersonalTelecoms',
    8812    => 'Ellipso',    # \
    8813    => 'Ellipso',    # |
    8816    => 'Iridium',    # | Sat-phones
    8817    => 'Iridium',    # |
    8818    => 'Globalstar', # |
    8819    => 'Globalstar', # /
    882     => 'InternationalNetworks',
    979     => 'InternationalPremiumRate',
    991     => 'ITPCS',
);

sub phone2country {
    my ($phone) = @_;
    return (phone2country_and_idd($phone))[0];
}

sub phone2country_and_idd {
    my ($phone) = @_;
    $phone =~ s/[^\d+]//g;
    $phone = '+1'.$phone unless(substr($phone, 0, 1) =~ /[1+]/);
    $phone =~ s/\D//g;

    # deal with NANP insanity

    if($phone =~ m!^1(\d{3})\d{7}$!) {

        # see http://www.cnac.ca/mapcodes.htm
        if($1 =~ m!^(
            204|226|250|289|
            306|
            403|416|418|438|450|
            506|514|519|
            604|613|647|
            705|709|778|780|
            807|819|867|
            902|905
        )$!x) {
            return ('CA', 1);
        }
        # see http://www.nanpa.com/number_resource_info/area_code_maps.html
        elsif($1 =~ m!^(
            201|202|203|205|206|207|208|209|
            210|212|213|214|215|216|217|218|219|
            224|225|227|228|229|
            231|234|239|
            240|248|
            251|252|253|254|256|
            260|262|267|269|270|276|278|281|283|
            301|302|303|304|305|307|308|309|
            310|312|313|314|315|316|317|318|319|
            320|321|323|325|
            330|331|334|336|337|339|
            341|347|
            351|352|
            360|361|369|
            380|385|386|
            401|402|404|405|406|407|408|409|
            410|412|413|414|415|417|419|
            423|424|425|
            430|432|434|435|
            440|442|443|445|
            464|469|
            470|475|478|479|
            480|484|
            501|502|503|504|505|507|508|509|
            510|512|513|515|516|517|518|
            520|
            530|
            540|541|
            551|557|559|
            561|562|563|564|567|
            570|571|573|574|575|
            580|585|586|
            601|602|603|605|606|607|608|609|
            610|612|614|615|616|617|618|619|
            620|623|626|627|628|
            630|631|636|
            641|646|
            650|651|657|659|
            660|661|662|667|669|
            678|679|
            682|689|
            701|702|703|704|706|707|708|
            712|713|714|715|716|717|718|719|
            720|724|727|
            731|732|734|737|
            740|747|
            752|754|757|
            760|762|763|764|765|769|
            770|772|773|774|775|
            781|785|786|
            801|802|803|804|805|806|808|
            810|812|813|814|815|816|817|818|
            828|
            830|831|832|835|
            843|845|847|848|
            850|856|857|858|859|
            860|862|863|864|865|
            870|872|878|
            901|903|904|906|907|908|909|
            910|912|913|914|915|916|917|918|919|
            920|925|928|
            931|935|936|937|
            940|941|947|949|
            951|952|954|956|959|
            970|971|972|973|975|978|979|
            980|984|985|989
        )$!x) {
            return ('US', 1);
        }

        # see http://wtng.info/wtng-cod.html#WZ1
        elsif($1 eq '242') { return ('BS', 1); }
        elsif($1 eq '246') { return ('BB', 1); }
        elsif($1 eq '264') { return ('AI', 1); }
        elsif($1 eq '268') { return ('AG', 1); }
        elsif($1 eq '284') { return ('VG', 1); }
        elsif($1 eq '340') { return ('VI', 1); }
        elsif($1 eq '345') { return ('KY', 1); }
        elsif($1 eq '441') { return ('BM', 1); }
        elsif($1 eq '473') { return ('GD', 1); }
        elsif($1 eq '649') { return ('TC', 1); }
        elsif($1 eq '664') { return ('MS', 1); }
        elsif($1 eq '670') { return ('MP', 1); }
        elsif($1 eq '671') { return ('GU', 1); }
        elsif($1 eq '684') { return ('AS', 1); }
        elsif($1 eq '758') { return ('LC', 1); }
        elsif($1 eq '767') { return ('DM', 1); }
        elsif($1 eq '784') { return ('VC', 1); }
        elsif($1 eq '787') { return ('PR', 1); }
        elsif($1 eq '809') { return ('DO', 1); }
        elsif($1 eq '829') { return ('DO', 1); } # overlay
        elsif($1 eq '868') { return ('TT', 1); }
        elsif($1 eq '869') { return ('KN', 1); }
        elsif($1 eq '876') { return ('JM', 1); }
        elsif($1 eq '939') { return ('PR', 1); }

        else { return ('NANP', 1); }
    }

    # following are from http://www.itu.int/itudoc/itu-t/number/k/kaz/75917.html
    # and http://wtng.info/ccod-7.html
    # see also http://wtng.info/wtng-kk.html#Kazakstan
    elsif($phone =~ /^7/) {
        return ('KZ', 7) if($phone =~ /^7(
            300|
            310|311|312|313|314|315|316|317|318|
            320|321|322|323|324|325|326|327|328|329|
            333|336|
            570|571|573|574|
            700
        )/x);
        return ('RU', 7);
    }

    else {
        my @retards = map { substr($phone, 0, $_) } reverse 1..length($phone);
        foreach my $idd (@retards) {
            if(exists $idd_codes{$idd}) {
                my $country = $idd_codes{$idd};
                if($country eq 'GB' && $use_uk) { $country = 'UK'; }
                return ($country, $idd);
            }
        }
    }
    return;
}

1;

=head1 NAME

Number::Phone::Country - Lookup country of phone number

=head1 SYNOPSIS

  use Number::Phone::Country;

  #returns 'CA' for Canada
  my $iso_country_code = phone2country("1 (604) 111-1111");

or

  use Number::Phone::Country qw(noexport uk);

  my $iso_country_code = Number::Phone::Country::phone2country(...);

or

  my ($iso_country_code, $idd) = Number::Phone::Country::phone2country_and_idd(...);

=head1 DESCRIPTION

This module lookups up the country based on a telephone number.
It uses the International Direct Dialing (IDD) prefix, and
lookups North American numbers using the Area Code, in accordance
with the North America Numbering Plan (NANP).

Note that by default, phone2country is exported into your namespace.  This
is deprecated and may be removed in a future version.  You can turn that
off by passing the 'noexport' constant when you use the module.

Also be aware that the ISO code for the United Kingdom is GB, not UK.  If
you would prefer UK, pass the 'uk' constant.

=head1 SEE ALSO

L<Parse::PhoneNumber>

=head1 BUGS

It has not been possible to maintain complete backwards compatibility with
the original 0.01 release.  To fix a
bug, while still retaining the ability to look up plain un-adorned NANP
numbers without the +1 prefix, all non-NANP numbers *must* have their
leading + sign.

Another incompatibility - it was previously assumed that any number not
assigned to some other country was in the US.  This was incorrect for (eg)
800 numbers.  These are now identified as being generic NANP numbers.

Will go out of date every time the NANP has one of its code splits/overlays.
So that's about once a month then.  I'll do my best to keep it up to date.

=head1 WARNING

The Yugoslavs keep changing their minds about what country they want to be
and what their ISO 3166 code and IDD prefix should be.  YU? CS? RS? ME?
God knows.

=head1 AUTHOR

now maintained by David Cantrell E<lt>david@cantrell.org.ukE<gt>

originally by TJ Mather, E<lt>tjmather@maxmind.comE<gt>

Thanks to Shraga Bor-Sood for the updates in version 1.4.

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by MaxMind LLC

Copyright 2004 - 2007 David Cantrell

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
