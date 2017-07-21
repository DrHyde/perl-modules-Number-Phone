package fatalwarnings;

$SIG{__WARN__} = sub {
    die("warning made fatal: ".join('', @_)."\n")
};

1;
