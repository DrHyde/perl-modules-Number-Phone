package fatalwarnings;

$SIG{__WARN__} = sub {
  foreach my $warning (@_) {
    if($warning !~ /^DEPRECATION: Number::Phone.*should only be called as an object method/) {
      die("warning made fatal: $warning\n");
    }
  }
};

1;
