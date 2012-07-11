package Number::Phone::Country::Data;

$VERSION = '1.0';
%Number::Phone::Country::idd_codes = (
    # 1     => 'NANP',

    # 2* checked against wtng.info 2011-07-08
    20      => 'EG',
    211     => 'SS',
    212     => 'MA',
    2125288 => 'EH', # \ from http://en.wikipedia.org/wiki/List_of_country_calling_codes#At_a_glance
    2125289 => 'EH', # /
    213     => 'DZ', 216     => 'TN',
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
    262269  => 'YT', # Mayotte fixed lines
    262639  => 'YT', # Mayotte GSM
    262     => 'RE', # Assume that Reunion is everything else in +262
    263     => 'ZW',
    264     => 'NA', 265     => 'MW', 266     => 'LS', 267     => 'BW',
    268     => 'SZ',
    269     => 'KM',
    27      => 'ZA', 290     => 'SH',
    291     => 'ER',
    297     => 'AW', 298     => 'FO', 299     => 'GL',
    
    # 3* checked against wtng.info 2011-07-08
    30      => 'GR', 31      => 'NL', 32      => 'BE', 33      => 'FR',
    34      => 'ES', 350     => 'GI', 351     => 'PT',
    352     => 'LU', 353     => 'IE', 35348   => 'GB', 354     => 'IS',
    355     => 'AL', 356     => 'MT', 357     => 'CY', 358     => 'FI',
    359     => 'BG', 36      => 'HU', 370     => 'LT', 371     => 'LV',
    372     => 'EE', 373     => 'MD', 374     => 'AM', 375     => 'BY',
    376     => 'AD', 377     => 'MC',
    37744   => 'KOS', # from http://en.wikipedia.org/wiki/List_of_country_calling_codes#At_a_glance
    37745   => 'KOS',
    38128   => 'KOS',
    38129   => 'KOS',
    38138   => 'KOS',
    38139   => 'KOS',
    38643   => 'KOS',
    38649   => 'KOS',
    378     => 'SM', 379     => 'VA',
    380     => 'UA', 381     => 'RS',
    382     => 'ME', 385     => 'HR',
    386     => 'SI',
    387     => 'BA',
    389     => 'MK', 39      => 'IT', 3966982 => 'VA',

    # 4* checked against wtng.info 2011-07-08
    40      => 'RO', 41      => 'CH', 420     => 'CZ', 421     => 'SK',
    423     => 'LI',
    43      => 'AT', 44      => 'GB',
    45      => 'DK', 46      => 'SE',
    47      => 'NO', 48      => 'PL', 49      => 'DE',
    
    # 5* checked against wtng.info 2011-07-08
    500     => 'FK',
    501     => 'BZ', 502     => 'GT', 503     => 'SV', 504     => 'HN',
    505     => 'NI', 506     => 'CR', 507     => 'PA',
    508     => 'PM', 509     => 'HT',
    51      => 'PE', 52      => 'MX', 53      => 'CU', 54      => 'AR',
    55      => 'BR', 56      => 'CL', 57      => 'CO', 58      => 'VE',
    590     => 'GP', 591     => 'BO', 592     => 'GY', 593     => 'EC',
    594     => 'GF', 595     => 'PY', 596     => 'MQ', 597     => 'SR',
    598     => 'UY',
    599     => 'BQ',
    5999    => 'CW',
    
    # 6* checked against wtng.info 2011-07-08
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
    
    # 7* from http://en.wikipedia.org/wiki/Telephone_numbers_in_Kazakhstan
    # checked 2011-07-08
    76      => 'KZ',
    77      => 'KZ',
    7       => 'RU',
    
    # 8* checked against wtng.info 2011-07-08
    81      => 'JP', 82      => 'KR', 84      => 'VN', 850     => 'KP',
    852     => 'HK', 853     => 'MO', 855     => 'KH', 856     => 'LA',
    86      => 'CN',
    880     => 'BD',
    886     => 'TW',
    
    # 9* checked against wtng.info 2011-07-08
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

    # these checked against wtng.info 2011-07-08
    800     => 'InternationalFreephone',
    808     => 'SharedCostServices',
    870     => 'Inmarsat',
    871     => 'Inmarsat',
    872     => 'Inmarsat',
    873     => 'Inmarsat',
    874     => 'Inmarsat',
    878     => 'UniversalPersonalTelecoms',
    8816    => 'Iridium',    # \ Sat-phones
    8817    => 'Iridium',    # |
    8818    => 'Globalstar', # |
    8819    => 'Globalstar', # /
    882     => 'InternationalNetworks',
    888     => 'TelecomsForDisasterRelief',
    # 979 is used for testing when we fail to load a module when we
    # know what "country" it is
    979     => 'InternationalPremiumRate',
    991     => 'ITPCS',
    # 999 deliberately NYI for testing; proposed to be like 888.
);

# Prefix Codes hash
# ISO code maps to 3 element array containing:
# - Country prefix
# - IDD prefix (for dialling from this country prefix to another)
# - NDD prefix (for dialling from one area of this country to another)
%Number::Phone::Country::prefix_codes = (
    'AD' => ['376',   '00',  undef], # Andorra
    'AE' => ['971',   '00',    '0'], # United Arab Emirates
    'AF' => [ '93',   '00',    '0'], # Afghanistan
    'AG' => [  '1',  '011',    '1'], # Antigua and Barbuda
    'AI' => [  '1',  '011',    '1'], # Anguilla
    'AL' => ['355',   '00',    '0'], # Albania
    'AM' => ['374',   '00',    '8'], # Armenia
    'BQ' => ['599',   '00',    '0'], # Bonaire, Saint Eustatius and Saba (ex-Netherland Antilles)
    'AO' => ['244',   '00',    '0'], # Angola
    'AQ' => ['672',  undef,  undef], # Antarctica
    'AR' => [ '54',   '00',    '0'], # Argentina
    'AS' => [  '1',  '011',    '1'], # American Samoa
    'AT' => [ '43',   '00',    '0'], # Austria
    'AU' => [ '61',   '00',  undef], # Australia
    'AW' => ['297',   '00',  undef], # Aruba
    'AZ' => ['994',   '00',    '8'], # Azerbaijan
    'BA' => ['387',   '00',    '0'], # Bosnia and Herzegovina
    'BB' => [  '1',  '011',    '1'], # Barbados
    'BD' => ['880',   '00',    '0'], # Bangladesh
    'BE' => [ '32',   '00',    '0'], # Belgium
    'BF' => ['226',   '00',  undef], # Burkina Faso
    'BG' => ['359',   '00',    '0'], # Bulgaria
    'BH' => ['973',   '00',  undef], # Bahrain
    'BI' => ['257',   '00',  undef], # Burundi
    'BJ' => ['229',   '00',  undef], # Benin
    'BM' => [  '1',  '011',    '1'], # Bermuda
    'BN' => ['673',   '00',    '0'], # Brunei Darussalam
    'BO' => ['591',   '00',    '0'], # Bolivia
    'BR' => [ '55',   '00',    '0'], # Brazil
    'BS' => [  '1',  '011',    '1'], # Bahamas
    'BT' => ['975',   '00',  undef], # Bhutan
    'BV' => [ '47',   '00',  undef], # Bouvet Island - Norway
    'BW' => ['267',   '00',  undef], # Botswana
    'BY' => ['375',  '810',    '8'], # Belarus (IDD really 8**10)
    'BZ' => ['501',   '00',    '0'], # Belize
    'CA' => [  '1',  '011',    '1'], # Canada
    'CC' => [ '61', '0011',    '0'], # Cocos (Keeling) Islands
    'CD' => ['243',   '00',  undef], # Congo (Dem. Rep. of / Zaire)
    'CF' => ['236',   '00',  undef], # Central African Republic
    'CG' => ['242',   '00',  undef], # Congo
    'CH' => [ '41',   '00',    '0'], # Switzerland
    'CI' => ['225',   '00',    '0'], # Cote D'Ivoire
    'CK' => ['682',   '00',   '00'], # Cook Islands
    'CL' => [ '56',   '00',    '0'], # Chile
    'CM' => ['237',   '00',  undef], # Cameroon
    'CN' => [ '86',   '00',    '0'], # China
    'CO' => [ '57',  '009',   '09'], # Colombia
    'CR' => ['506',   '00',  undef], # Costa Rica
    'CU' => [ '53',  '119',    '0'], # Cuba
    'CV' => ['238',    '0',  undef], # Cape Verde Islands
    'CX' => [ '61', '0011',    '0'], # Christmas Island
    'CY' => ['357',   '00',  undef], # Cyprus
    'CZ' => ['420',   '00',  undef], # Czech Republic
    'DE' => [ '49',   '00',    '0'], # Germany
    'DJ' => ['253',   '00',  undef], # Djibouti
    'DK' => [ '45',   '00',  undef], # Denmark
    'DM' => [  '1',  '011',      1], # Dominica
    'DO' => [  '1',  '011',      1], # Dominican Republic
    'DZ' => ['213',   '00',    '7'], # Algeria
    'EC' => ['593',   '00',    '0'], # Ecuador
    'EE' => ['372',   '00',  undef], # Estonia
    'EG' => [ '20',   '00',    '0'], # Egypt
    'EH' => ['212',   '00',    '0'], # Western Sahara
    'ER' => ['291',   '00',    '0'], # Eritrea
    'ES' => [ '34',   '00',  undef], # Spain
    'ET' => ['251',   '00',    '0'], # Ethiopia
    'FI' => ['358',   '00',    '0'], # Finland
    'FJ' => ['679',   '00',  undef], # Fiji
    'FK' => ['500',   '00',  undef], # Falkland Islands (Malvinas)
    'FM' => ['691',  '011',    '1'], # Micronesia, Federated States of
    'FO' => ['298',   '00',  undef], # Faroe Islands
    'FR' => [ '33',   '00',  undef], # France
    'GA' => ['241',   '00',  undef], # Gabonese Republic
    'GB' => [ '44',   '00',    '0'], # United Kingdom
    'GD' => [  '1',  '011',    '4'], # Grenada
    'GE' => ['995',  '810',    '8'], # Georgia
    'GF' => ['594',   '00',  undef], # French Guiana
    'GH' => ['233',   '00',  undef], # Ghana
    'GI' => ['350',   '00',  undef], # Gibraltar
    'GL' => ['299',   '00',  undef], # Greenland
    'GM' => ['220',   '00',  undef], # Gambia
    'GN' => ['224',   '00',    '0'], # Guinea
    'GP' => ['590',   '00',  undef], # Guadeloupe
    'GQ' => ['240',   '00',  undef], # Equatorial Guinea
    'GR' => [ '30',   '00',  undef], # Greece
    'GS' => ['995',  '810',    '8'], # South Georgia and the South Sandwich Islands (IDD really 8**10)
    'GT' => ['502',   '00',  undef], # Guatemala
    'GU' => [  '1',  '011',    '1'], # Guam
    'GW' => ['245',   '00',  undef], # Guinea-Bissau
    'GY' => ['592',  '001',    '0'], # Guyana
    'HK' => ['852',  '001',  undef], # Hong Kong
    'HM' => ['692',   '00',    '0'], # Heard Island & McDonald Islands
    'HN' => ['504',   '00',    '0'], # Honduras
    'HR' => ['385',   '00',    '0'], # Croatia
    'HT' => ['509',   '00',    '0'], # Haiti
    'HU' => [ '36',   '00',   '06'], # Hungary
    'ID' => [ '62',  '001',    '0'], # Indonesia
    'IE' => ['353',   '00',    '0'], # Ireland
    'IL' => ['972',   '00',    '0'], # Israel
    'IN' => [ '91',   '00',    '0'], # India
    'IO' => ['246',   '00',  undef], # British Indian Ocean Territory
    'IQ' => ['964',   '00',    '0'], # Iraq
    'IR' => [ '98',   '00',    '0'], # Iran, Islamic Republic of
    'IS' => ['354',   '00',    '0'], # Iceland
    'IT' => [ '39',   '00',  undef], # Italy
    'JM' => [  '1',  '011',    '1'], # Jamaica
    'JO' => ['962',   '00',    '0'], # Jordan
    'JP' => [ '81',  '001',    '0'], # Japan
    'KE' => ['254',  '000',    '0'], # Kenya
    'KG' => ['996',   '00',    '0'], # Kyrgyzstan
    'KH' => ['855',  '001',    '0'], # Cambodia
    'KI' => ['686',   '00',    '0'], # Kiribati
    'KM' => ['269',   '00',  undef], # Comoros
    'KN' => [  '1',  '011',    '1'], # Saint Kitts and Nevis
    'KP' => ['850',   '00',    '0'], # Korea, Democratic People's Republic of
    'KR' => [ '82',  '001',    '0'], # Korea (South)
    'KW' => ['965',   '00',    '0'], # Kuwait
    'KY' => [  '1',  '011',    '1'], # Cayman Islands
    'KZ' => [  '7',  '810',    '8'], # Kazakhstan (IDD really 8[pause]10)
    'LA' => ['856',   '00',    '0'], # Laos
    'LB' => ['961',   '00',    '0'], # Lebanon
    'LC' => [  '1',  '011',    '1'], # Saint Lucia
    'LI' => ['423',   '00',  undef], # Liechtenstein
    'LK' => [ '94',   '00',    '0'], # Sri Lanka
    'LR' => ['231',   '00',   '22'], # Liberia
    'LS' => ['266',   '00',    '0'], # Lesotho
    'LT' => ['370',   '00',    '8'], # Lithuania
    'LU' => ['352',   '00',  undef], # Luxembourg
    'LV' => ['371',   '00',    '8'], # Latvia
    'LY' => ['218',   '00',    '0'], # Libyan Arab Jamahiriya
    'MA' => ['212',   '00',  undef], # Morocco
    'MC' => ['377',   '00',    '0'], # Monaco
    'MD' => ['373',   '00',    '0'], # Moldova, Republic of
    'ME' => ['382',   '99',    '0'], # Montenegro
    'MG' => ['261',   '00',    '0'], # Madagascar
    'MH' => ['692',  '011',    '1'], # Marshall Islands
    'MK' => ['389',   '00',    '0'], # Macedonia, the Former Yugoslav Republic of
    'ML' => ['223',   '00',    '0'], # Mali
    'MM' => [ '95',   '00',  undef], # Myanmar
    'MN' => ['976',  '001',    '0'], # Mongolia
    'MO' => ['853',   '00',    '0'], # Macao
    'MP' => [  '1',  '011',    '1'], # Northern Mariana Islands
    'MQ' => ['596',   '00',    '0'], # Martinique
    'MR' => ['222',   '00',    '0'], # Mauritania
    'MS' => [  '1',  '011',    '1'], # Montserrat
    'MT' => ['356',   '00',   '21'], # Malta
    'MU' => ['230',   '00',    '0'], # Mauritius
    'MV' => ['960',   '00',    '0'], # Maldives
    'MW' => ['265',   '00',  undef], # Malawi
    'MX' => [ '52',   '00',   '01'], # Mexico
    'MY' => [ '60',   '00',    '0'], # Malaysia
    'MZ' => ['258',   '00',    '0'], # Mozambique
    'NA' => ['264',   '00',    '0'], # Namibia
    'NC' => ['687',   '00',    '0'], # New Caledonia
    'NE' => ['227',   '00',    '0'], # Niger
    'NF' => ['672',   '00',  undef], # Norfolk Island
    'NG' => ['234',  '009',    '0'], # Nigeria
    'NI' => ['505',   '00',    '0'], # Nicaragua
    'NL' => [ '31',   '00',    '0'], # Netherlands
    'NO' => [ '47',   '00',  undef], # Norway
    'NP' => ['977',   '00',    '0'], # Nepal
    'NR' => ['674',   '00',    '0'], # Nauru
    'NU' => ['683',   '00',    '0'], # Niue
    'NZ' => [ '64',   '00',    '0'], # New Zealand
    'OM' => ['968',   '00',    '0'], # Oman
    'PA' => ['507',   '00',    '0'], # Panama
    'PE' => [ '51',   '00',    '0'], # Peru
    'PF' => ['689',   '00',  undef], # French Polynesia
    'PG' => ['675',   '05',  undef], # Papua New Guinea
    'PH' => [ '63',   '00',    '0'], # Philippines
    'PK' => [ '92',   '00',    '0'], # Pakistan
    'PL' => [ '48',   '00',    '0'], # Poland
    'PM' => ['508',   '00',    '0'], # Saint Pierre and Miquelon
    'PN' => ['872', undef,   undef], # Pitcairn
    'PR' => [  '1',  '011',    '1'], # Puerto Rico
    'PS' => ['970',   '00',    '0'], # Palestinian Territory, Occupied
    'PT' => ['351',   '00',  undef], # Portugal
    'PW' => ['680',  '011',  undef], # Palau
    'PY' => ['595',  '002',    '0'], # Paraguay
    'QA' => ['974',   '00',    '0'], # Qatar
    'RE' => ['262',   '00',    '0'], # Reunion
    'RO' => [ '40',   '00',    '0'], # Romania
    'RS' => ['381',   '99',    '0'], # Serbia
    'RU' => [  '7',  '810',    '8'], # Russia 8**10 NOTE: may change to 00, 0
    'RW' => ['250',   '00',    '0'], # Rwanda
    'SA' => ['966',   '00',    '0'], # Saudi Arabia
    'SB' => ['677',   '00',  undef], # Solomon Islands
    'SC' => ['248',   '00',    '0'], # Seychelles
    'SD' => ['249',   '00',    '0'], # Sudan
    'SE' => [ '46',   '00',    '0'], # Sweden
    'SG' => [ '65',  '001',  undef], # Singapore
    'SH' => ['290',   '00',  undef], # Saint Helena
    'SI' => ['386',   '00',    '0'], # Slovenia
    'SJ' => ['378',   '00',    '0'], # Svalbard and Jan Mayen
    'SK' => ['421',   '00',    '0'], # Slovakia
    'SL' => ['232',   '00',    '0'], # Sierra Leone
    'SM' => ['378',   '00',    '0'], # San Marino
    'SN' => ['221',   '00',    '0'], # Senegal
    'SO' => ['252',   '00',  undef], # Somalia
    'SR' => ['597',   '00',  undef], # Suriname
    'SS' => ['211',   '00',    '0'], # South Sudan
    'ST' => ['239',   '00',    '0'], # Sao Tome and Principe
    'SV' => ['503',   '00',  undef], # El Salvador
    'SY' => ['963',   '00',    '0'], # Syria
    'SZ' => ['268',   '00',  undef], # Swaziland
    'TC' => [  '1',  '011',    '1'], # Turks and Caicos Islands
    'TD' => ['235',   '15',  undef], # Chad
    'TF' => ['596',   '00',    '0'], # French Southern Territories
    'TG' => ['228',   '00',  undef], # Togo
    'TH' => [ '66',  '001',    '0'], # Thailand
    'TJ' => ['992',  '810',    '8'], # Tajikistan (IDD really 8**10)
    'TK' => ['690',   '00',  undef], # Tokelau
    'TL' => ['670',   '00',  undef], # Timor-Leste
    'TM' => ['993',  '810',    '8'], # Turkmenistan (IDD really 8**10)
    'TN' => ['216',   '00',    '0'], # Tunisia
    'TO' => ['676',   '00',  undef], # Tonga Islands
    'TR' => [ '90',   '00',    '0'], # Turkey
    'TT' => [  '1',  '011',    '1'], # Trinidad and Tobago
    'TV' => ['688',   '00',  undef], # Tuvalu
    'TW' => ['886',  '002',  undef], # Taiwan, Province of China
    'TZ' => ['255',  '000',    '0'], # Tanzania, United Republic of
    'UA' => ['380',  '810',    '8'], # Ukraine (IDD really 8**10)
    'UG' => ['256',  '000',    '0'], # Uganda
    'US' => [  '1',  '011',    '1'], # United States
    'UY' => ['598',   '00',    '0'], # Uruguay
    'UZ' => ['998',  '810',    '8'], # Uzbekistan (IDD really 8**10)
    'VA' => ['379',   '00',  undef], # Holy See (Vatican City State)
    'VC' => [  '1',  '011',    '1'], # Saint Vincent and the Grenadines
    'VE' => [ '58',   '00',    '0'], # Venezuela
    'VG' => [  '1',  '011',    '1'], # Virgin Islands, British
    'VI' => [  '1',  '011',    '1'], # Virgin Islands, U.S.
    'VN' => [ '84',   '00',    '0'], # Viet Nam
    'VU' => ['678',   '00',  undef], # Vanuatu
    'WF' => ['681',   '19',  undef], # Wallis and Futuna Islands
    'WS' => ['685',    '0',    '0'], # Samoa (Western)
    'YE' => ['967',   '00',    '0'], # Yemen
    'YT' => ['262',   '00',  undef], # Mayotte
    'ZA' => [ '27',   '09',    '0'], # South Africa
    'ZM' => ['260',   '00',    '0'], # Zambia
    'ZW' => ['263',  '110',    '0'], # Zimbabwe
);
$Number::Phone::Country::prefix_codes{UK} = $Number::Phone::Country::prefix_codes{GB};
