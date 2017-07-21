package fatalwarnings;

$SIG{__WARN__} = sub {
    die("warning made fatal: ".join('', @_)."\n")
        unless($_[0] =~ m{Using file .*share/Number-Phone-UK-Data.db});
};

1;
