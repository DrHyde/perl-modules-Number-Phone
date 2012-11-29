package Number::Phone::JP;

sub new { return bless({}, __PACKAGE__); }
sub AUTOLOAD { return undef; }
1;
