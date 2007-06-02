package Number::Phone::UK::DBM::Deep;

##
# Number::Phone::UK::DBM::Deep
#
# Description:
#	Multi-level database module for storing hash trees, arrays and simple
#	key/value pairs into FTP-able, cross-platform binary database files.
#
#	Type `perldoc Number::Phone::UK::DBM::Deep` for complete documentation.
#
# Usage Examples:
#	my %db;
#	tie %db, 'Number::Phone::UK::DBM::Deep', 'my_database.db'; # standard tie() method
#	
#	my $db = new Number::Phone::UK::DBM::Deep( 'my_database.db' ); # preferred OO method
#
#	$db->{my_scalar} = 'hello world';
#	$db->{my_hash} = { larry => 'genius', hashes => 'fast' };
#	$db->{my_array} = [ 1, 2, 3, time() ];
#	$db->{my_complex} = [ 'hello', { perl => 'rules' }, 42, 99 ];
#	push @{$db->{my_array}}, 'another value';
#	my @key_list = keys %{$db->{my_hash}};
#	print "This module " . $db->{my_complex}->[1]->{perl} . "!\n";
#
# Copyright:
#	(c) 2002-2006 Joseph Huckaby.  All Rights Reserved.
#	This program is free software; you can redistribute it and/or 
#	modify it under the same terms as Perl itself.
##

use strict;

use Fcntl qw( :DEFAULT :flock :seek );
use Digest::MD5 ();
use Scalar::Util ();

use vars qw( $VERSION );
$VERSION = q(0.983);

##
# Set to 4 and 'N' for 32-bit offset tags (default).  Theoretical limit of 4 GB per file.
#	(Perl must be compiled with largefile support for files > 2 GB)
#
# Set to 8 and 'Q' for 64-bit offsets.  Theoretical limit of 16 XB per file.
#	(Perl must be compiled with largefile and 64-bit long support)
##
#my $LONG_SIZE = 4;
#my $LONG_PACK = 'N';

##
# Set to 4 and 'N' for 32-bit data length prefixes.  Limit of 4 GB for each key/value.
# Upgrading this is possible (see above) but probably not necessary.  If you need
# more than 4 GB for a single key or value, this module is really not for you :-)
##
#my $DATA_LENGTH_SIZE = 4;
#my $DATA_LENGTH_PACK = 'N';
our ($LONG_SIZE, $LONG_PACK, $DATA_LENGTH_SIZE, $DATA_LENGTH_PACK);

##
# Maximum number of buckets per list before another level of indexing is done.
# Increase this value for slightly greater speed, but larger database files.
# DO NOT decrease this value below 16, due to risk of recursive reindex overrun.
##
my $MAX_BUCKETS = 16;

##
# Better not adjust anything below here, unless you're me :-)
##

##
# Setup digest function for keys
##
our ($DIGEST_FUNC, $HASH_SIZE);
#my $DIGEST_FUNC = \&Digest::MD5::md5;

##
# Precalculate index and bucket sizes based on values above.
##
#my $HASH_SIZE = 16;
my ($INDEX_SIZE, $BUCKET_SIZE, $BUCKET_LIST_SIZE);

set_digest();
#set_pack();
#_precalc_sizes();

##
# Setup file and tag signatures.  These should never change.
##
sub SIG_FILE   () { 'DPDB' }
sub SIG_HASH   () { 'H' }
sub SIG_ARRAY  () { 'A' }
sub SIG_NULL   () { 'N' }
sub SIG_DATA   () { 'D' }
sub SIG_INDEX  () { 'I' }
sub SIG_BLIST  () { 'B' }
sub SIG_SIZE   () {  1  }

##
# Setup constants for users to pass to new()
##
sub TYPE_HASH   () { SIG_HASH   }
sub TYPE_ARRAY  () { SIG_ARRAY  }

sub _get_args {
    my $proto = shift;

    my $args;
    if (scalar(@_) > 1) {
        if ( @_ % 2 ) {
            $proto->_throw_error( "Odd number of parameters to " . (caller(1))[2] );
        }
        $args = {@_};
    }
	elsif ( ref $_[0] ) {
        unless ( eval { local $SIG{'__DIE__'}; %{$_[0]} || 1 } ) {
            $proto->_throw_error( "Not a hashref in args to " . (caller(1))[2] );
        }
        $args = $_[0];
    }
	else {
        $args = { file => shift };
    }

    return $args;
}

sub new {
	##
	# Class constructor method for Perl OO interface.
	# Calls tie() and returns blessed reference to tied hash or array,
	# providing a hybrid OO/tie interface.
	##
	my $class = shift;
	my $args = $class->_get_args( @_ );
	
	##
	# Check if we want a tied hash or array.
	##
	my $self;
	if (defined($args->{type}) && $args->{type} eq TYPE_ARRAY) {
        $class = 'Number::Phone::UK::DBM::Deep::Array';
        require Number::Phone::UK::DBM::Deep::Array;
		tie @$self, $class, %$args;
	}
	else {
        $class = 'Number::Phone::UK::DBM::Deep::Hash';
        require Number::Phone::UK::DBM::Deep::Hash;
		tie %$self, $class, %$args;
	}

	return bless $self, $class;
}

sub _init {
    ##
    # Setup $self and bless into this class.
    ##
    my $class = shift;
    my $args = shift;

    # These are the defaults to be optionally overridden below
    my $self = bless {
        type => TYPE_HASH,
        base_offset => length(SIG_FILE),
    }, $class;

    foreach my $param ( keys %$self ) {
        next unless exists $args->{$param};
        $self->{$param} = delete $args->{$param}
    }
    
    # locking implicitly enables autoflush
    if ($args->{locking}) { $args->{autoflush} = 1; }
    
    $self->{root} = exists $args->{root}
        ? $args->{root}
        : Number::Phone::UK::DBM::Deep::_::Root->new( $args );

    if (!defined($self->_fh)) { $self->_open(); }

    return $self;
}

sub TIEHASH {
    shift;
    require Number::Phone::UK::DBM::Deep::Hash;
    return Number::Phone::UK::DBM::Deep::Hash->TIEHASH( @_ );
}

sub TIEARRAY {
    shift;
    require Number::Phone::UK::DBM::Deep::Array;
    return Number::Phone::UK::DBM::Deep::Array->TIEARRAY( @_ );
}

#XXX Unneeded now ...
#sub DESTROY {
#}

sub _open {
	##
	# Open a fh to the database, create if nonexistent.
	# Make sure file signature matches Number::Phone::UK::DBM::Deep spec.
	##
    my $self = $_[0]->_get_self;

    local($/,$\);

	if (defined($self->_fh)) { $self->_close(); }
	
    my $flags = O_RDWR | O_CREAT | O_BINARY;

    my $fh;
    sysopen( $fh, $self->_root->{file}, $flags )
		or $self->_throw_error( "Cannot sysopen file: " . $self->_root->{file} . ": $!" );

    $self->_root->{fh} = $fh;

    if ($self->_root->{autoflush}) {
        my $old = select $fh;
        $|=1;
        select $old;
    }
    
    seek($fh, 0 + $self->_root->{file_offset}, SEEK_SET);

    my $signature;
    my $bytes_read = read( $fh, $signature, length(SIG_FILE));
    
    ##
    # File is empty -- write signature and master index
    ##
    if (!$bytes_read) {
        seek($fh, 0 + $self->_root->{file_offset}, SEEK_SET);
        print( $fh SIG_FILE);
        $self->_create_tag($self->_base_offset, $self->_type, chr(0) x $INDEX_SIZE);

        my $plain_key = "[base]";
        print( $fh pack($DATA_LENGTH_PACK, length($plain_key)) . $plain_key );

        # Flush the filehandle
        my $old_fh = select $fh;
        my $old_af = $|; $| = 1; $| = $old_af;
        select $old_fh;

        my @stats = stat($fh);
        $self->_root->{inode} = $stats[1];
        $self->_root->{end} = $stats[7];

        return 1;
    }
    
    ##
    # Check signature was valid
    ##
    unless ($signature eq SIG_FILE) {
        $self->_close();
        return $self->_throw_error("Signature not found -- file is not a Deep DB");
    }

	my @stats = stat($fh);
	$self->_root->{inode} = $stats[1];
    $self->_root->{end} = $stats[7];
        
    ##
    # Get our type from master index signature
    ##
    my $tag = $self->_load_tag($self->_base_offset);

#XXX We probably also want to store the hash algorithm name and not assume anything
#XXX The cool thing would be to allow a different hashing algorithm at every level

    if (!$tag) {
    	return $self->_throw_error("Corrupted file, no master index record");
    }
    if ($self->{type} ne $tag->{signature}) {
    	return $self->_throw_error("File type mismatch");
    }
    
    return 1;
}

sub _close {
	##
	# Close database fh
	##
    my $self = $_[0]->_get_self;
    close $self->_root->{fh} if $self->_root->{fh};
    $self->_root->{fh} = undef;
}

sub _create_tag {
	##
	# Given offset, signature and content, create tag and write to disk
	##
	my ($self, $offset, $sig, $content) = @_;
	my $size = length($content);

    local($/,$\);
	
    my $fh = $self->_fh;

	seek($fh, $offset + $self->_root->{file_offset}, SEEK_SET);
	print( $fh $sig . pack($DATA_LENGTH_PACK, $size) . $content );
	
	if ($offset == $self->_root->{end}) {
		$self->_root->{end} += SIG_SIZE + $DATA_LENGTH_SIZE + $size;
	}
	
	return {
		signature => $sig,
		size => $size,
		offset => $offset + SIG_SIZE + $DATA_LENGTH_SIZE,
		content => $content
	};
}

sub _load_tag {
	##
	# Given offset, load single tag and return signature, size and data
	##
	my $self = shift;
	my $offset = shift;

    local($/,$\);
	
    my $fh = $self->_fh;

	seek($fh, $offset + $self->_root->{file_offset}, SEEK_SET);
	if (eof $fh) { return undef; }
	
    my $b;
    read( $fh, $b, SIG_SIZE + $DATA_LENGTH_SIZE );
    my ($sig, $size) = unpack( "A $DATA_LENGTH_PACK", $b );
	
	my $buffer;
	read( $fh, $buffer, $size);
	
	return {
		signature => $sig,
		size => $size,
		offset => $offset + SIG_SIZE + $DATA_LENGTH_SIZE,
		content => $buffer
	};
}

sub _index_lookup {
	##
	# Given index tag, lookup single entry in index and return .
	##
	my $self = shift;
	my ($tag, $index) = @_;

	my $location = unpack($LONG_PACK, substr($tag->{content}, $index * $LONG_SIZE, $LONG_SIZE) );
	if (!$location) { return; }
	
	return $self->_load_tag( $location );
}

sub _add_bucket {
	##
	# Adds one key/value pair to bucket list, given offset, MD5 digest of key,
	# plain (undigested) key and value.
	##
	my $self = shift;
	my ($tag, $md5, $plain_key, $value) = @_;
	my $keys = $tag->{content};
	my $location = 0;
	my $result = 2;

    local($/,$\);

    # This verifies that only supported values will be stored.
    {
        my $r = Scalar::Util::reftype( $value );
        last if !defined $r;

        last if $r eq 'HASH';
        last if $r eq 'ARRAY';

        $self->_throw_error(
            "Storage of variables of type '$r' is not supported."
        );
    }

    my $root = $self->_root;

    my $is_dbm_deep = eval { local $SIG{'__DIE__'}; $value->isa( 'Number::Phone::UK::DBM::Deep' ) };
	my $internal_ref = $is_dbm_deep && ($value->_root eq $root);

    my $fh = $self->_fh;

	##
	# Iterate through buckets, seeing if this is a new entry or a replace.
	##
	for (my $i=0; $i<$MAX_BUCKETS; $i++) {
		my $subloc = unpack($LONG_PACK, substr($keys, ($i * $BUCKET_SIZE) + $HASH_SIZE, $LONG_SIZE));
		if (!$subloc) {
			##
			# Found empty bucket (end of list).  Populate and exit loop.
			##
			$result = 2;
			
            $location = $internal_ref
                ? $value->_base_offset
                : $root->{end};
			
			seek($fh, $tag->{offset} + ($i * $BUCKET_SIZE) + $root->{file_offset}, SEEK_SET);
			print( $fh $md5 . pack($LONG_PACK, $location) );
			last;
		}

		my $key = substr($keys, $i * $BUCKET_SIZE, $HASH_SIZE);
		if ($md5 eq $key) {
			##
			# Found existing bucket with same key.  Replace with new value.
			##
			$result = 1;
			
			if ($internal_ref) {
				$location = $value->_base_offset;
				seek($fh, $tag->{offset} + ($i * $BUCKET_SIZE) + $root->{file_offset}, SEEK_SET);
				print( $fh $md5 . pack($LONG_PACK, $location) );
                return $result;
			}

            seek($fh, $subloc + SIG_SIZE + $root->{file_offset}, SEEK_SET);
            my $size;
            read( $fh, $size, $DATA_LENGTH_SIZE); $size = unpack($DATA_LENGTH_PACK, $size);
            
            ##
            # If value is a hash, array, or raw value with equal or less size, we can
            # reuse the same content area of the database.  Otherwise, we have to create
            # a new content area at the EOF.
            ##
            my $actual_length;
            my $r = Scalar::Util::reftype( $value ) || '';
            if ( $r eq 'HASH' || $r eq 'ARRAY' ) {
                $actual_length = $INDEX_SIZE;
                
                # if autobless is enabled, must also take into consideration
                # the class name, as it is stored along with key/value.
                if ( $root->{autobless} ) {
                    my $value_class = Scalar::Util::blessed($value);
                    if ( defined $value_class && !$value->isa('Number::Phone::UK::DBM::Deep') ) {
                        $actual_length += length($value_class);
                    }
                }
            }
            else { $actual_length = length($value); }
            
            if ($actual_length <= ($size || 0)) {
                $location = $subloc;
            }
            else {
                $location = $root->{end};
                seek($fh, $tag->{offset} + ($i * $BUCKET_SIZE) + $HASH_SIZE + $root->{file_offset}, SEEK_SET);
                print( $fh pack($LONG_PACK, $location) );
            }

			last;
		}
	}
	
	##
	# If this is an internal reference, return now.
	# No need to write value or plain key
	##
	if ($internal_ref) {
        return $result;
    }
	
	##
	# If bucket didn't fit into list, split into a new index level
	##
	if (!$location) {
		seek($fh, $tag->{ref_loc} + $root->{file_offset}, SEEK_SET);
		print( $fh pack($LONG_PACK, $root->{end}) );
		
		my $index_tag = $self->_create_tag($root->{end}, SIG_INDEX, chr(0) x $INDEX_SIZE);
		my @offsets = ();
		
		$keys .= $md5 . pack($LONG_PACK, 0);
		
		for (my $i=0; $i<=$MAX_BUCKETS; $i++) {
			my $key = substr($keys, $i * $BUCKET_SIZE, $HASH_SIZE);
			if ($key) {
				my $old_subloc = unpack($LONG_PACK, substr($keys, ($i * $BUCKET_SIZE) + $HASH_SIZE, $LONG_SIZE));
				my $num = ord(substr($key, $tag->{ch} + 1, 1));
				
				if ($offsets[$num]) {
					my $offset = $offsets[$num] + SIG_SIZE + $DATA_LENGTH_SIZE;
					seek($fh, $offset + $root->{file_offset}, SEEK_SET);
					my $subkeys;
					read( $fh, $subkeys, $BUCKET_LIST_SIZE);
					
					for (my $k=0; $k<$MAX_BUCKETS; $k++) {
						my $subloc = unpack($LONG_PACK, substr($subkeys, ($k * $BUCKET_SIZE) + $HASH_SIZE, $LONG_SIZE));
						if (!$subloc) {
							seek($fh, $offset + ($k * $BUCKET_SIZE) + $root->{file_offset}, SEEK_SET);
							print( $fh $key . pack($LONG_PACK, $old_subloc || $root->{end}) );
							last;
						}
					} # k loop
				}
				else {
					$offsets[$num] = $root->{end};
					seek($fh, $index_tag->{offset} + ($num * $LONG_SIZE) + $root->{file_offset}, SEEK_SET);
					print( $fh pack($LONG_PACK, $root->{end}) );
					
					my $blist_tag = $self->_create_tag($root->{end}, SIG_BLIST, chr(0) x $BUCKET_LIST_SIZE);
					
					seek($fh, $blist_tag->{offset} + $root->{file_offset}, SEEK_SET);
					print( $fh $key . pack($LONG_PACK, $old_subloc || $root->{end}) );
				}
			} # key is real
		} # i loop
		
		$location ||= $root->{end};
	} # re-index bucket list
	
	##
	# Seek to content area and store signature, value and plaintext key
	##
	if ($location) {
		my $content_length;
		seek($fh, $location + $root->{file_offset}, SEEK_SET);
		
		##
		# Write signature based on content type, set content length and write actual value.
		##
        my $r = Scalar::Util::reftype($value) || '';
		if ($r eq 'HASH') {
            if ( !$internal_ref && tied %{$value} ) {
                return $self->_throw_error("Cannot store a tied value");
            }
			print( $fh TYPE_HASH );
			print( $fh pack($DATA_LENGTH_PACK, $INDEX_SIZE) . chr(0) x $INDEX_SIZE );
			$content_length = $INDEX_SIZE;
		}
		elsif ($r eq 'ARRAY') {
            if ( !$internal_ref && tied @{$value} ) {
                return $self->_throw_error("Cannot store a tied value");
            }
			print( $fh TYPE_ARRAY );
			print( $fh pack($DATA_LENGTH_PACK, $INDEX_SIZE) . chr(0) x $INDEX_SIZE );
			$content_length = $INDEX_SIZE;
		}
		elsif (!defined($value)) {
			print( $fh SIG_NULL );
			print( $fh pack($DATA_LENGTH_PACK, 0) );
			$content_length = 0;
		}
		else {
			print( $fh SIG_DATA );
			print( $fh pack($DATA_LENGTH_PACK, length($value)) . $value );
			$content_length = length($value);
		}
		
		##
		# Plain key is stored AFTER value, as keys are typically fetched less often.
		##
		print( $fh pack($DATA_LENGTH_PACK, length($plain_key)) . $plain_key );
		
		##
		# If value is blessed, preserve class name
		##
		if ( $root->{autobless} ) {
            my $value_class = Scalar::Util::blessed($value);
            if ( defined $value_class && $value_class ne 'Number::Phone::UK::DBM::Deep' ) {
                ##
                # Blessed ref -- will restore later
                ##
                print( $fh chr(1) );
                print( $fh pack($DATA_LENGTH_PACK, length($value_class)) . $value_class );
                $content_length += 1;
                $content_length += $DATA_LENGTH_SIZE + length($value_class);
            }
            else {
                print( $fh chr(0) );
                $content_length += 1;
            }
        }
            
		##
		# If this is a new content area, advance EOF counter
		##
		if ($location == $root->{end}) {
			$root->{end} += SIG_SIZE;
			$root->{end} += $DATA_LENGTH_SIZE + $content_length;
			$root->{end} += $DATA_LENGTH_SIZE + length($plain_key);
		}
		
		##
		# If content is a hash or array, create new child Number::Phone::UK::DBM::Deep object and
		# pass each key or element to it.
		##
		if ($r eq 'HASH') {
            my %x = %$value;
            tie %$value, 'Number::Phone::UK::DBM::Deep', {
				type => TYPE_HASH,
				base_offset => $location,
				root => $root,
			};
            %$value = %x;
		}
		elsif ($r eq 'ARRAY') {
            my @x = @$value;
            tie @$value, 'Number::Phone::UK::DBM::Deep', {
				type => TYPE_ARRAY,
				base_offset => $location,
				root => $root,
			};
            @$value = @x;
		}
		
		return $result;
	}
	
	return $self->_throw_error("Fatal error: indexing failed -- possibly due to corruption in file");
}

sub _get_bucket_value {
	##
	# Fetch single value given tag and MD5 digested key.
	##
	my $self = shift;
	my ($tag, $md5) = @_;
	my $keys = $tag->{content};

    local($/,$\);

    my $fh = $self->_fh;

	##
	# Iterate through buckets, looking for a key match
	##
    BUCKET:
	for (my $i=0; $i<$MAX_BUCKETS; $i++) {
		my $key = substr($keys, $i * $BUCKET_SIZE, $HASH_SIZE);
		my $subloc = unpack($LONG_PACK, substr($keys, ($i * $BUCKET_SIZE) + $HASH_SIZE, $LONG_SIZE));

		if (!$subloc) {
			##
			# Hit end of list, no match
			##
			return;
		}

        if ( $md5 ne $key ) {
            next BUCKET;
        }

        ##
        # Found match -- seek to offset and read signature
        ##
        my $signature;
        seek($fh, $subloc + $self->_root->{file_offset}, SEEK_SET);
        read( $fh, $signature, SIG_SIZE);
        
        ##
        # If value is a hash or array, return new Number::Phone::UK::DBM::Deep object with correct offset
        ##
        if (($signature eq TYPE_HASH) || ($signature eq TYPE_ARRAY)) {
            my $obj = Number::Phone::UK::DBM::Deep->new(
                type => $signature,
                base_offset => $subloc,
                root => $self->_root
            );
            
            if ($self->_root->{autobless}) {
                ##
                # Skip over value and plain key to see if object needs
                # to be re-blessed
                ##
                seek($fh, $DATA_LENGTH_SIZE + $INDEX_SIZE, SEEK_CUR);
                
                my $size;
                read( $fh, $size, $DATA_LENGTH_SIZE); $size = unpack($DATA_LENGTH_PACK, $size);
                if ($size) { seek($fh, $size, SEEK_CUR); }
                
                my $bless_bit;
                read( $fh, $bless_bit, 1);
                if (ord($bless_bit)) {
                    ##
                    # Yes, object needs to be re-blessed
                    ##
                    my $class_name;
                    read( $fh, $size, $DATA_LENGTH_SIZE); $size = unpack($DATA_LENGTH_PACK, $size);
                    if ($size) { read( $fh, $class_name, $size); }
                    if ($class_name) { $obj = bless( $obj, $class_name ); }
                }
            }
            
            return $obj;
        }
        
        ##
        # Otherwise return actual value
        ##
        elsif ($signature eq SIG_DATA) {
            my $size;
            my $value = '';
            read( $fh, $size, $DATA_LENGTH_SIZE); $size = unpack($DATA_LENGTH_PACK, $size);
            if ($size) { read( $fh, $value, $size); }
            return $value;
        }
        
        ##
        # Key exists, but content is null
        ##
        else { return; }
	} # i loop

	return;
}

sub _delete_bucket {
	##
	# Delete single key/value pair given tag and MD5 digested key.
	##
	my $self = shift;
	my ($tag, $md5) = @_;
	my $keys = $tag->{content};

    local($/,$\);

    my $fh = $self->_fh;
	
	##
	# Iterate through buckets, looking for a key match
	##
    BUCKET:
	for (my $i=0; $i<$MAX_BUCKETS; $i++) {
		my $key = substr($keys, $i * $BUCKET_SIZE, $HASH_SIZE);
		my $subloc = unpack($LONG_PACK, substr($keys, ($i * $BUCKET_SIZE) + $HASH_SIZE, $LONG_SIZE));

		if (!$subloc) {
			##
			# Hit end of list, no match
			##
			return;
		}

        if ( $md5 ne $key ) {
            next BUCKET;
        }

        ##
        # Matched key -- delete bucket and return
        ##
        seek($fh, $tag->{offset} + ($i * $BUCKET_SIZE) + $self->_root->{file_offset}, SEEK_SET);
        print( $fh substr($keys, ($i+1) * $BUCKET_SIZE ) );
        print( $fh chr(0) x $BUCKET_SIZE );
        
        return 1;
	} # i loop

	return;
}

sub _bucket_exists {
	##
	# Check existence of single key given tag and MD5 digested key.
	##
	my $self = shift;
	my ($tag, $md5) = @_;
	my $keys = $tag->{content};
	
	##
	# Iterate through buckets, looking for a key match
	##
    BUCKET:
	for (my $i=0; $i<$MAX_BUCKETS; $i++) {
		my $key = substr($keys, $i * $BUCKET_SIZE, $HASH_SIZE);
		my $subloc = unpack($LONG_PACK, substr($keys, ($i * $BUCKET_SIZE) + $HASH_SIZE, $LONG_SIZE));

		if (!$subloc) {
			##
			# Hit end of list, no match
			##
			return;
		}

        if ( $md5 ne $key ) {
            next BUCKET;
        }

        ##
        # Matched key -- return true
        ##
        return 1;
	} # i loop

	return;
}

sub _find_bucket_list {
	##
	# Locate offset for bucket list, given digested key
	##
	my $self = shift;
	my $md5 = shift;
	
	##
	# Locate offset for bucket list using digest index system
	##
	my $ch = 0;
	my $tag = $self->_load_tag($self->_base_offset);
	if (!$tag) { return; }
	
	while ($tag->{signature} ne SIG_BLIST) {
		$tag = $self->_index_lookup($tag, ord(substr($md5, $ch, 1)));
		if (!$tag) { return; }
		$ch++;
	}
	
	return $tag;
}

sub _traverse_index {
	##
	# Scan index and recursively step into deeper levels, looking for next key.
	##
    my ($self, $offset, $ch, $force_return_next) = @_;
    $force_return_next = undef unless $force_return_next;

    local($/,$\);
	
	my $tag = $self->_load_tag( $offset );

    my $fh = $self->_fh;
	
	if ($tag->{signature} ne SIG_BLIST) {
		my $content = $tag->{content};
		my $start;
		if ($self->{return_next}) { $start = 0; }
		else { $start = ord(substr($self->{prev_md5}, $ch, 1)); }
		
		for (my $index = $start; $index < 256; $index++) {
			my $subloc = unpack($LONG_PACK, substr($content, $index * $LONG_SIZE, $LONG_SIZE) );
			if ($subloc) {
				my $result = $self->_traverse_index( $subloc, $ch + 1, $force_return_next );
				if (defined($result)) { return $result; }
			}
		} # index loop
		
		$self->{return_next} = 1;
	} # tag is an index
	
	elsif ($tag->{signature} eq SIG_BLIST) {
		my $keys = $tag->{content};
		if ($force_return_next) { $self->{return_next} = 1; }
		
		##
		# Iterate through buckets, looking for a key match
		##
		for (my $i=0; $i<$MAX_BUCKETS; $i++) {
			my $key = substr($keys, $i * $BUCKET_SIZE, $HASH_SIZE);
			my $subloc = unpack($LONG_PACK, substr($keys, ($i * $BUCKET_SIZE) + $HASH_SIZE, $LONG_SIZE));
	
			if (!$subloc) {
				##
				# End of bucket list -- return to outer loop
				##
				$self->{return_next} = 1;
				last;
			}
			elsif ($key eq $self->{prev_md5}) {
				##
				# Located previous key -- return next one found
				##
				$self->{return_next} = 1;
				next;
			}
			elsif ($self->{return_next}) {
				##
				# Seek to bucket location and skip over signature
				##
				seek($fh, $subloc + SIG_SIZE + $self->_root->{file_offset}, SEEK_SET);
				
				##
				# Skip over value to get to plain key
				##
				my $size;
				read( $fh, $size, $DATA_LENGTH_SIZE); $size = unpack($DATA_LENGTH_PACK, $size);
				if ($size) { seek($fh, $size, SEEK_CUR); }
				
				##
				# Read in plain key and return as scalar
				##
				my $plain_key;
				read( $fh, $size, $DATA_LENGTH_SIZE); $size = unpack($DATA_LENGTH_PACK, $size);
				if ($size) { read( $fh, $plain_key, $size); }
				
				return $plain_key;
			}
		} # bucket loop
		
		$self->{return_next} = 1;
	} # tag is a bucket list
	
	return;
}

sub _get_next_key {
	##
	# Locate next key, given digested previous one
	##
    my $self = $_[0]->_get_self;
	
	$self->{prev_md5} = $_[1] ? $_[1] : undef;
	$self->{return_next} = 0;
	
	##
	# If the previous key was not specifed, start at the top and
	# return the first one found.
	##
	if (!$self->{prev_md5}) {
		$self->{prev_md5} = chr(0) x $HASH_SIZE;
		$self->{return_next} = 1;
	}
	
	return $self->_traverse_index( $self->_base_offset, 0 );
}

sub lock {
	##
	# If db locking is set, flock() the db file.  If called multiple
	# times before unlock(), then the same number of unlocks() must
	# be called before the lock is released.
	##
    my $self = $_[0]->_get_self;
	my $type = $_[1];
    $type = LOCK_EX unless defined $type;
	
	if (!defined($self->_fh)) { return; }

	if ($self->_root->{locking}) {
		if (!$self->_root->{locked}) {
			flock($self->_fh, $type);
			
			# refresh end counter in case file has changed size
			my @stats = stat($self->_root->{file});
			$self->_root->{end} = $stats[7];
			
			# double-check file inode, in case another process
			# has optimize()d our file while we were waiting.
			if ($stats[1] != $self->_root->{inode}) {
				$self->_open(); # re-open
				flock($self->_fh, $type); # re-lock
				$self->_root->{end} = (stat($self->_fh))[7]; # re-end
			}
		}
		$self->_root->{locked}++;

        return 1;
	}

    return;
}

sub unlock {
	##
	# If db locking is set, unlock the db file.  See note in lock()
	# regarding calling lock() multiple times.
	##
    my $self = $_[0]->_get_self;

	if (!defined($self->_fh)) { return; }
	
	if ($self->_root->{locking} && $self->_root->{locked} > 0) {
		$self->_root->{locked}--;
		if (!$self->_root->{locked}) { flock($self->_fh, LOCK_UN); }

        return 1;
	}

    return;
}

sub _copy_value {
    my $self = shift->_get_self;
    my ($spot, $value) = @_;

    if ( !ref $value ) {
        ${$spot} = $value;
    }
    elsif ( eval { local $SIG{__DIE__}; $value->isa( 'Number::Phone::UK::DBM::Deep' ) } ) {
        my $type = $value->_type;
        ${$spot} = $type eq TYPE_HASH ? {} : [];
        $value->_copy_node( ${$spot} );
    }
    else {
        my $r = Scalar::Util::reftype( $value );
        my $c = Scalar::Util::blessed( $value );
        if ( $r eq 'ARRAY' ) {
            ${$spot} = [ @{$value} ];
        }
        else {
            ${$spot} = { %{$value} };
        }
        ${$spot} = bless ${$spot}, $c
            if defined $c;
    }

    return 1;
}

sub _copy_node {
	##
	# Copy single level of keys or elements to new DB handle.
	# Recurse for nested structures
	##
    my $self = shift->_get_self;
	my ($db_temp) = @_;

	if ($self->_type eq TYPE_HASH) {
		my $key = $self->first_key();
		while ($key) {
			my $value = $self->get($key);
            $self->_copy_value( \$db_temp->{$key}, $value );
			$key = $self->next_key($key);
		}
	}
	else {
		my $length = $self->length();
		for (my $index = 0; $index < $length; $index++) {
			my $value = $self->get($index);
            $self->_copy_value( \$db_temp->[$index], $value );
		}
	}

    return 1;
}

sub export {
	##
	# Recursively export into standard Perl hashes and arrays.
	##
    my $self = $_[0]->_get_self;
	
	my $temp;
	if ($self->_type eq TYPE_HASH) { $temp = {}; }
	elsif ($self->_type eq TYPE_ARRAY) { $temp = []; }
	
	$self->lock();
	$self->_copy_node( $temp );
	$self->unlock();
	
	return $temp;
}

sub import {
	##
	# Recursively import Perl hash/array structure
	##
    #XXX This use of ref() seems to be ok
	if (!ref($_[0])) { return; } # Perl calls import() on use -- ignore
	
    my $self = $_[0]->_get_self;
	my $struct = $_[1];
	
    #XXX This use of ref() seems to be ok
	if (!ref($struct)) {
		##
		# struct is not a reference, so just import based on our type
		##
		shift @_;
		
		if ($self->_type eq TYPE_HASH) { $struct = {@_}; }
		elsif ($self->_type eq TYPE_ARRAY) { $struct = [@_]; }
	}
	
    my $r = Scalar::Util::reftype($struct) || '';
	if ($r eq "HASH" && $self->_type eq TYPE_HASH) {
		foreach my $key (keys %$struct) { $self->put($key, $struct->{$key}); }
	}
	elsif ($r eq "ARRAY" && $self->_type eq TYPE_ARRAY) {
		$self->push( @$struct );
	}
	else {
		return $self->_throw_error("Cannot import: type mismatch");
	}
	
	return 1;
}

sub optimize {
	##
	# Rebuild entire database into new file, then move
	# it back on top of original.
	##
    my $self = $_[0]->_get_self;

#XXX Need to create a new test for this
#	if ($self->_root->{links} > 1) {
#		return $self->_throw_error("Cannot optimize: reference count is greater than 1");
#	}
	
	my $db_temp = Number::Phone::UK::DBM::Deep->new(
		file => $self->_root->{file} . '.tmp',
		type => $self->_type
	);
	if (!$db_temp) {
		return $self->_throw_error("Cannot optimize: failed to open temp file: $!");
	}
	
	$self->lock();
	$self->_copy_node( $db_temp );
	undef $db_temp;
	
	##
	# Attempt to copy user, group and permissions over to new file
	##
	my @stats = stat($self->_fh);
	my $perms = $stats[2] & 07777;
	my $uid = $stats[4];
	my $gid = $stats[5];
	chown( $uid, $gid, $self->_root->{file} . '.tmp' );
	chmod( $perms, $self->_root->{file} . '.tmp' );
	
    # q.v. perlport for more information on this variable
    if ( $^O eq 'MSWin32' || $^O eq 'cygwin' ) {
		##
		# Potential race condition when optmizing on Win32 with locking.
		# The Windows filesystem requires that the filehandle be closed 
		# before it is overwritten with rename().  This could be redone
		# with a soft copy.
		##
		$self->unlock();
		$self->_close();
	}
	
	if (!rename $self->_root->{file} . '.tmp', $self->_root->{file}) {
		unlink $self->_root->{file} . '.tmp';
		$self->unlock();
		return $self->_throw_error("Optimize failed: Cannot copy temp file over original: $!");
	}
	
	$self->unlock();
	$self->_close();
	$self->_open();
	
	return 1;
}

sub clone {
	##
	# Make copy of object and return
	##
    my $self = $_[0]->_get_self;
	
	return Number::Phone::UK::DBM::Deep->new(
		type => $self->_type,
		base_offset => $self->_base_offset,
		root => $self->_root
	);
}

{
    my %is_legal_filter = map {
        $_ => ~~1,
    } qw(
        store_key store_value
        fetch_key fetch_value
    );

    sub set_filter {
        ##
        # Setup filter function for storing or fetching the key or value
        ##
        my $self = $_[0]->_get_self;
        my $type = lc $_[1];
        my $func = $_[2] ? $_[2] : undef;
	
        if ( $is_legal_filter{$type} ) {
            $self->_root->{"filter_$type"} = $func;
            return 1;
        }

        return;
    }
}

##
# Accessor methods
##

sub _root {
	##
	# Get access to the root structure
	##
    my $self = $_[0]->_get_self;
	return $self->{root};
}

sub _fh {
	##
	# Get access to the raw fh
	##
    #XXX It will be useful, though, when we split out HASH and ARRAY
    my $self = $_[0]->_get_self;
	return $self->_root->{fh};
}

sub _type {
	##
	# Get type of current node (TYPE_HASH or TYPE_ARRAY)
	##
    my $self = $_[0]->_get_self;
	return $self->{type};
}

sub _base_offset {
	##
	# Get base_offset of current node (TYPE_HASH or TYPE_ARRAY)
	##
    my $self = $_[0]->_get_self;
	return $self->{base_offset};
}

sub error {
	##
	# Get last error string, or undef if no error
	##
	return $_[0]
        ? ( $_[0]->_get_self->{root}->{error} or undef )
        : $@;
}

##
# Utility methods
##

sub _throw_error {
	##
	# Store error string in self
	##
	my $error_text = $_[1];
	
    if ( Scalar::Util::blessed $_[0] ) {
        my $self = $_[0]->_get_self;
        $self->_root->{error} = $error_text;
	
        unless ($self->_root->{debug}) {
            die "Number::Phone::UK::DBM::Deep: $error_text\n";
        }

        warn "Number::Phone::UK::DBM::Deep: $error_text\n";
        return;
    }
    else {
        die "Number::Phone::UK::DBM::Deep: $error_text\n";
    }
}

sub clear_error {
	##
	# Clear error state
	##
    my $self = $_[0]->_get_self;
	
	undef $self->_root->{error};
}

sub _precalc_sizes {
	##
	# Precalculate index, bucket and bucket list sizes
	##

    #XXX I don't like this ...
    set_pack() unless defined $LONG_SIZE;

	$INDEX_SIZE = 256 * $LONG_SIZE;
	$BUCKET_SIZE = $HASH_SIZE + $LONG_SIZE;
	$BUCKET_LIST_SIZE = $MAX_BUCKETS * $BUCKET_SIZE;
}

sub set_pack {
	##
	# Set pack/unpack modes (see file header for more)
	##
    my ($long_s, $long_p, $data_s, $data_p) = @_;

    $LONG_SIZE = $long_s ? $long_s : 4;
    $LONG_PACK = $long_p ? $long_p : 'N';

    $DATA_LENGTH_SIZE = $data_s ? $data_s : 4;
    $DATA_LENGTH_PACK = $data_p ? $data_p : 'N';

	_precalc_sizes();
}

sub set_digest {
	##
	# Set key digest function (default is MD5)
	##
    my ($digest_func, $hash_size) = @_;

    $DIGEST_FUNC = $digest_func ? $digest_func : \&Digest::MD5::md5;
    $HASH_SIZE = $hash_size ? $hash_size : 16;

	_precalc_sizes();
}

sub _is_writable {
    my $fh = shift;
    (O_WRONLY | O_RDWR) & fcntl( $fh, F_GETFL, my $slush = 0);
}

#sub _is_readable {
#    my $fh = shift;
#    (O_RDONLY | O_RDWR) & fcntl( $fh, F_GETFL, my $slush = 0);
#}

##
# tie() methods (hashes and arrays)
##

sub STORE {
	##
	# Store single hash key/value or array element in database.
	##
    my $self = $_[0]->_get_self;
	my $key = $_[1];

    local($/,$\);

    # User may be storing a hash, in which case we do not want it run 
    # through the filtering system
	my $value = ($self->_root->{filter_store_value} && !ref($_[2]))
        ? $self->_root->{filter_store_value}->($_[2])
        : $_[2];
	
	my $md5 = $DIGEST_FUNC->($key);
	
	##
	# Make sure file is open
	##
	if (!defined($self->_fh) && !$self->_open()) {
		return;
	}

    if ( $^O ne 'MSWin32' && !_is_writable( $self->_fh ) ) {
        $self->_throw_error( 'Cannot write to a readonly filehandle' );
    }
	
	##
	# Request exclusive lock for writing
	##
	$self->lock( LOCK_EX );
	
	my $fh = $self->_fh;
	
	##
	# Locate offset for bucket list using digest index system
	##
	my $tag = $self->_load_tag($self->_base_offset);
	if (!$tag) {
		$tag = $self->_create_tag($self->_base_offset, SIG_INDEX, chr(0) x $INDEX_SIZE);
	}
	
	my $ch = 0;
	while ($tag->{signature} ne SIG_BLIST) {
		my $num = ord(substr($md5, $ch, 1));

        my $ref_loc = $tag->{offset} + ($num * $LONG_SIZE);
		my $new_tag = $self->_index_lookup($tag, $num);

		if (!$new_tag) {
			seek($fh, $ref_loc + $self->_root->{file_offset}, SEEK_SET);
			print( $fh pack($LONG_PACK, $self->_root->{end}) );
			
			$tag = $self->_create_tag($self->_root->{end}, SIG_BLIST, chr(0) x $BUCKET_LIST_SIZE);

			$tag->{ref_loc} = $ref_loc;
			$tag->{ch} = $ch;

			last;
		}
		else {
			$tag = $new_tag;

			$tag->{ref_loc} = $ref_loc;
			$tag->{ch} = $ch;
		}
		$ch++;
	}
	
	##
	# Add key/value to bucket list
	##
	my $result = $self->_add_bucket( $tag, $md5, $key, $value );
	
	$self->unlock();

	return $result;
}

sub FETCH {
	##
	# Fetch single value or element given plain key or array index
	##
    my $self = shift->_get_self;
    my $key = shift;

	##
	# Make sure file is open
	##
	if (!defined($self->_fh)) { $self->_open(); }
	
	my $md5 = $DIGEST_FUNC->($key);

	##
	# Request shared lock for reading
	##
	$self->lock( LOCK_SH );
	
	my $tag = $self->_find_bucket_list( $md5 );
	if (!$tag) {
		$self->unlock();
		return;
	}
	
	##
	# Get value from bucket list
	##
	my $result = $self->_get_bucket_value( $tag, $md5 );
	
	$self->unlock();
	
    #XXX What is ref() checking here?
    #YYY Filters only apply on scalar values, so the ref check is making
    #YYY sure the fetched bucket is a scalar, not a child hash or array.
	return ($result && !ref($result) && $self->_root->{filter_fetch_value})
        ? $self->_root->{filter_fetch_value}->($result)
        : $result;
}

sub DELETE {
	##
	# Delete single key/value pair or element given plain key or array index
	##
    my $self = $_[0]->_get_self;
	my $key = $_[1];
	
	my $md5 = $DIGEST_FUNC->($key);

	##
	# Make sure file is open
	##
	if (!defined($self->_fh)) { $self->_open(); }
	
	##
	# Request exclusive lock for writing
	##
	$self->lock( LOCK_EX );
	
	my $tag = $self->_find_bucket_list( $md5 );
	if (!$tag) {
		$self->unlock();
		return;
	}
	
	##
	# Delete bucket
	##
    my $value = $self->_get_bucket_value( $tag, $md5 );
	if ($value && !ref($value) && $self->_root->{filter_fetch_value}) {
        $value = $self->_root->{filter_fetch_value}->($value);
    }

	my $result = $self->_delete_bucket( $tag, $md5 );
	
	##
	# If this object is an array and the key deleted was on the end of the stack,
	# decrement the length variable.
	##
	
	$self->unlock();
	
	return $value;
}

sub EXISTS {
	##
	# Check if a single key or element exists given plain key or array index
	##
    my $self = $_[0]->_get_self;
	my $key = $_[1];
	
	my $md5 = $DIGEST_FUNC->($key);

	##
	# Make sure file is open
	##
	if (!defined($self->_fh)) { $self->_open(); }
	
	##
	# Request shared lock for reading
	##
	$self->lock( LOCK_SH );
	
	my $tag = $self->_find_bucket_list( $md5 );
	
	##
	# For some reason, the built-in exists() function returns '' for false
	##
	if (!$tag) {
		$self->unlock();
		return '';
	}
	
	##
	# Check if bucket exists and return 1 or ''
	##
	my $result = $self->_bucket_exists( $tag, $md5 ) || '';
	
	$self->unlock();
	
	return $result;
}

sub CLEAR {
	##
	# Clear all keys from hash, or all elements from array.
	##
    my $self = $_[0]->_get_self;

	##
	# Make sure file is open
	##
	if (!defined($self->_fh)) { $self->_open(); }
	
	##
	# Request exclusive lock for writing
	##
	$self->lock( LOCK_EX );
	
    my $fh = $self->_fh;

	seek($fh, $self->_base_offset + $self->_root->{file_offset}, SEEK_SET);
	if (eof $fh) {
		$self->unlock();
		return;
	}
	
	$self->_create_tag($self->_base_offset, $self->_type, chr(0) x $INDEX_SIZE);
	
	$self->unlock();
	
	return 1;
}

##
# Public method aliases
##
sub put { (shift)->STORE( @_ ) }
sub store { (shift)->STORE( @_ ) }
sub get { (shift)->FETCH( @_ ) }
sub fetch { (shift)->FETCH( @_ ) }
sub delete { (shift)->DELETE( @_ ) }
sub exists { (shift)->EXISTS( @_ ) }
sub clear { (shift)->CLEAR( @_ ) }

package Number::Phone::UK::DBM::Deep::_::Root;

sub new {
    my $class = shift;
    my ($args) = @_;

    my $self = bless {
        file => undef,
        fh => undef,
        file_offset => 0,
        end => 0,
        autoflush => undef,
        locking => undef,
        debug => undef,
        filter_store_key => undef,
        filter_store_value => undef,
        filter_fetch_key => undef,
        filter_fetch_value => undef,
        autobless => undef,
        locked => 0,
        %$args,
    }, $class;

    if ( $self->{fh} && !$self->{file_offset} ) {
        $self->{file_offset} = tell( $self->{fh} );
    }

    return $self;
}

sub DESTROY {
    my $self = shift;
    return unless $self;

    close $self->{fh} if $self->{fh};

    return;
}

1;

__END__

=head1 NAME

Number::Phone::UK::DBM::Deep - A pure perl multi-level hash/array DBM

=head1 DESCRIPTION

This is an old version of L<DBM::Deep>.  It is bundled with Number::Phone::UK
module because newer version of DBM::Deep have a different interface.
At some point, Number::Phone::UK's internals will change to become
compatible with the new DBM::Deep, and this module will go away.

Please do not use this module yourself under any circumstances.

=head1 AUTHORS

Joseph Huckaby, L<jhuckaby@cpan.org>

Rob Kinyon, L<rkinyon@cpan.org>

Special thanks to Adam Sah and Rich Gaushell!  You know why :-)

=head1 LICENSE

Copyright (c) 2002-2006 Joseph Huckaby.  All Rights Reserved.
This is free software, you may use it and distribute it under the
same terms as Perl itself.

=cut
