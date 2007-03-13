package Number::Phone::UK::DBM::Deep::Hash;

use strict;

use base 'Number::Phone::UK::DBM::Deep';

sub _get_self {
    eval { local $SIG{'__DIE__'}; tied( %{$_[0]} ) } || $_[0]
}

sub TIEHASH {
    ##
    # Tied hash constructor method, called by Perl's tie() function.
    ##
    my $class = shift;
    my $args = $class->_get_args( @_ );
    
    $args->{type} = $class->TYPE_HASH;

    return $class->_init($args);
}

sub FETCH {
    my $self = shift->_get_self;
    my $key = ($self->_root->{filter_store_key})
        ? $self->_root->{filter_store_key}->($_[0])
        : $_[0];

    return $self->SUPER::FETCH( $key );
}

sub STORE {
    my $self = shift->_get_self;
	my $key = ($self->_root->{filter_store_key})
        ? $self->_root->{filter_store_key}->($_[0])
        : $_[0];
    my $value = $_[1];

    return $self->SUPER::STORE( $key, $value );
}

sub EXISTS {
    my $self = shift->_get_self;
	my $key = ($self->_root->{filter_store_key})
        ? $self->_root->{filter_store_key}->($_[0])
        : $_[0];

    return $self->SUPER::EXISTS( $key );
}

sub DELETE {
    my $self = shift->_get_self;
	my $key = ($self->_root->{filter_store_key})
        ? $self->_root->{filter_store_key}->($_[0])
        : $_[0];

    return $self->SUPER::DELETE( $key );
}

sub FIRSTKEY {
	##
	# Locate and return first key (in no particular order)
	##
    my $self = $_[0]->_get_self;

	##
	# Make sure file is open
	##
	if (!defined($self->_fh)) { $self->_open(); }
	
	##
	# Request shared lock for reading
	##
	$self->lock( $self->LOCK_SH );
	
	my $result = $self->_get_next_key();
	
	$self->unlock();
	
	return ($result && $self->_root->{filter_fetch_key})
        ? $self->_root->{filter_fetch_key}->($result)
        : $result;
}

sub NEXTKEY {
	##
	# Return next key (in no particular order), given previous one
	##
    my $self = $_[0]->_get_self;

	my $prev_key = ($self->_root->{filter_store_key})
        ? $self->_root->{filter_store_key}->($_[1])
        : $_[1];

	my $prev_md5 = $Number::Phone::UK::DBM::Deep::DIGEST_FUNC->($prev_key);

	##
	# Make sure file is open
	##
	if (!defined($self->_fh)) { $self->_open(); }
	
	##
	# Request shared lock for reading
	##
	$self->lock( $self->LOCK_SH );
	
	my $result = $self->_get_next_key( $prev_md5 );
	
	$self->unlock();
	
	return ($result && $self->_root->{filter_fetch_key})
        ? $self->_root->{filter_fetch_key}->($result)
        : $result;
}

##
# Public method aliases
##
*first_key = *FIRSTKEY;
*next_key = *NEXTKEY;

1;
__END__
