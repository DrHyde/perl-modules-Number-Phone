package Number::Phone::UK::DBM::Deep::Array;

use strict;

# This is to allow Number::Phone::UK::DBM::Deep::Array to handle negative indices on
# its own. Otherwise, Perl would intercept the call to negative
# indices for us. This was causing bugs for negative index handling.
use vars qw( $NEGATIVE_INDICES );
$NEGATIVE_INDICES = 1;

use base 'Number::Phone::UK::DBM::Deep';

use Scalar::Util ();

sub _get_self {
    eval { local $SIG{'__DIE__'}; tied( @{$_[0]} ) } || $_[0]
}

sub TIEARRAY {
##
# Tied array constructor method, called by Perl's tie() function.
##
    my $class = shift;
    my $args = $class->_get_args( @_ );
	
	$args->{type} = $class->TYPE_ARRAY;
	
	return $class->_init($args);
}

sub FETCH {
    my $self = $_[0]->_get_self;
    my $key = $_[1];

	$self->lock( $self->LOCK_SH );
	
    if ( $key =~ /^-?\d+$/ ) {
        if ( $key < 0 ) {
            $key += $self->FETCHSIZE;
            unless ( $key >= 0 ) {
                $self->unlock;
                return;
            }
        }

        $key = pack($Number::Phone::UK::DBM::Deep::LONG_PACK, $key);
    }

    my $rv = $self->SUPER::FETCH( $key );

    $self->unlock;

    return $rv;
}

sub STORE {
    my $self = shift->_get_self;
    my ($key, $value) = @_;

    $self->lock( $self->LOCK_EX );

    my $orig = $key;

    my $size;
    my $numeric_idx;
    if ( $key =~ /^\-?\d+$/ ) {
        $numeric_idx = 1;
        if ( $key < 0 ) {
            $size = $self->FETCHSIZE;
            $key += $size;
            if ( $key < 0 ) {
                die( "Modification of non-creatable array value attempted, subscript $orig" );
            }
        }

        $key = pack($Number::Phone::UK::DBM::Deep::LONG_PACK, $key);
    }

    my $rv = $self->SUPER::STORE( $key, $value );

    if ( $numeric_idx && $rv == 2 ) {
        $size = $self->FETCHSIZE unless defined $size;
        if ( $orig >= $size ) {
            $self->STORESIZE( $orig + 1 );
        }
    }

    $self->unlock;

    return $rv;
}

sub EXISTS {
    my $self = $_[0]->_get_self;
    my $key = $_[1];

	$self->lock( $self->LOCK_SH );

    if ( $key =~ /^\-?\d+$/ ) {
        if ( $key < 0 ) {
            $key += $self->FETCHSIZE;
            unless ( $key >= 0 ) {
                $self->unlock;
                return;
            }
        }

        $key = pack($Number::Phone::UK::DBM::Deep::LONG_PACK, $key);
    }

    my $rv = $self->SUPER::EXISTS( $key );

    $self->unlock;

    return $rv;
}

sub DELETE {
    my $self = $_[0]->_get_self;
    my $key = $_[1];

    my $unpacked_key = $key;

    $self->lock( $self->LOCK_EX );

    my $size = $self->FETCHSIZE;
    if ( $key =~ /^-?\d+$/ ) {
        if ( $key < 0 ) {
            $key += $size;
            unless ( $key >= 0 ) {
                $self->unlock;
                return;
            }
        }

        $key = pack($Number::Phone::UK::DBM::Deep::LONG_PACK, $key);
    }

    my $rv = $self->SUPER::DELETE( $key );

	if ($rv && $unpacked_key == $size - 1) {
		$self->STORESIZE( $unpacked_key );
	}

    $self->unlock;

    return $rv;
}

sub FETCHSIZE {
	##
	# Return the length of the array
	##
    my $self = shift->_get_self;

    $self->lock( $self->LOCK_SH );

	my $SAVE_FILTER = $self->_root->{filter_fetch_value};
	$self->_root->{filter_fetch_value} = undef;
	
	my $packed_size = $self->FETCH('length');
	
	$self->_root->{filter_fetch_value} = $SAVE_FILTER;
	
    $self->unlock;

	if ($packed_size) {
        return int(unpack($Number::Phone::UK::DBM::Deep::LONG_PACK, $packed_size));
    }

	return 0;
}

sub STORESIZE {
	##
	# Set the length of the array
	##
    my $self = $_[0]->_get_self;
	my $new_length = $_[1];
	
    $self->lock( $self->LOCK_EX );

	my $SAVE_FILTER = $self->_root->{filter_store_value};
	$self->_root->{filter_store_value} = undef;
	
	my $result = $self->STORE('length', pack($Number::Phone::UK::DBM::Deep::LONG_PACK, $new_length));
	
	$self->_root->{filter_store_value} = $SAVE_FILTER;
	
    $self->unlock;

	return $result;
}

sub POP {
	##
	# Remove and return the last element on the array
	##
    my $self = $_[0]->_get_self;

    $self->lock( $self->LOCK_EX );

	my $length = $self->FETCHSIZE();
	
	if ($length) {
		my $content = $self->FETCH( $length - 1 );
		$self->DELETE( $length - 1 );

        $self->unlock;

		return $content;
	}
	else {
        $self->unlock;
		return;
	}
}

sub PUSH {
	##
	# Add new element(s) to the end of the array
	##
    my $self = shift->_get_self;
	
    $self->lock( $self->LOCK_EX );

	my $length = $self->FETCHSIZE();

	while (my $content = shift @_) {
		$self->STORE( $length, $content );
		$length++;
	}

    $self->unlock;

    return $length;
}

sub SHIFT {
	##
	# Remove and return first element on the array.
	# Shift over remaining elements to take up space.
	##
    my $self = $_[0]->_get_self;

    $self->lock( $self->LOCK_EX );

	my $length = $self->FETCHSIZE();
	
	if ($length) {
		my $content = $self->FETCH( 0 );
		
		##
		# Shift elements over and remove last one.
		##
		for (my $i = 0; $i < $length - 1; $i++) {
			$self->STORE( $i, $self->FETCH($i + 1) );
		}
		$self->DELETE( $length - 1 );

        $self->unlock;
		
		return $content;
	}
	else {
        $self->unlock;
		return;
	}
}

sub UNSHIFT {
	##
	# Insert new element(s) at beginning of array.
	# Shift over other elements to make space.
	##
    my $self = shift->_get_self;
	my @new_elements = @_;

    $self->lock( $self->LOCK_EX );

	my $length = $self->FETCHSIZE();
	my $new_size = scalar @new_elements;
	
	if ($length) {
		for (my $i = $length - 1; $i >= 0; $i--) {
			$self->STORE( $i + $new_size, $self->FETCH($i) );
		}
	}
	
	for (my $i = 0; $i < $new_size; $i++) {
		$self->STORE( $i, $new_elements[$i] );
	}

    $self->unlock;

    return $length + $new_size;
}

sub SPLICE {
	##
	# Splices section of array with optional new section.
	# Returns deleted section, or last element deleted in scalar context.
	##
    my $self = shift->_get_self;

    $self->lock( $self->LOCK_EX );

	my $length = $self->FETCHSIZE();
	
	##
	# Calculate offset and length of splice
	##
	my $offset = shift;
    $offset = 0 unless defined $offset;
	if ($offset < 0) { $offset += $length; }
	
	my $splice_length;
	if (scalar @_) { $splice_length = shift; }
	else { $splice_length = $length - $offset; }
	if ($splice_length < 0) { $splice_length += ($length - $offset); }
	
	##
	# Setup array with new elements, and copy out old elements for return
	##
	my @new_elements = @_;
	my $new_size = scalar @new_elements;
	
    my @old_elements = map {
        $self->FETCH( $_ )
    } $offset .. ($offset + $splice_length - 1);
	
	##
	# Adjust array length, and shift elements to accomodate new section.
	##
    if ( $new_size != $splice_length ) {
        if ($new_size > $splice_length) {
            for (my $i = $length - 1; $i >= $offset + $splice_length; $i--) {
                $self->STORE( $i + ($new_size - $splice_length), $self->FETCH($i) );
            }
        }
        else {
            for (my $i = $offset + $splice_length; $i < $length; $i++) {
                $self->STORE( $i + ($new_size - $splice_length), $self->FETCH($i) );
            }
            for (my $i = 0; $i < $splice_length - $new_size; $i++) {
                $self->DELETE( $length - 1 );
                $length--;
            }
        }
	}
	
	##
	# Insert new elements into array
	##
	for (my $i = $offset; $i < $offset + $new_size; $i++) {
		$self->STORE( $i, shift @new_elements );
	}
	
    $self->unlock;

	##
	# Return deleted section, or last element in scalar context.
	##
	return wantarray ? @old_elements : $old_elements[-1];
}

sub EXTEND {
	##
	# Perl will call EXTEND() when the array is likely to grow.
	# We don't care, but include it for compatibility.
	##
}

##
# Public method aliases
##
*length = *FETCHSIZE;
*pop = *POP;
*push = *PUSH;
*shift = *SHIFT;
*unshift = *UNSHIFT;
*splice = *SPLICE;

1;
__END__
