#
# BioPerl module for Bio::Index::Abstract
#
# Cared for by Ewan Birney <birney@sanger.ac.uk>
#          and James Gilbert <jgrg@sanger.ac.uk>
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Index::Abstract - Abstract interface for indexing a flat file

=head1 SYNOPSIS

You should not be using this module directly

=head1 USING DB_FILE

To use DB_File and not SDBM for this index, pass the value:

    -dbm_package => 'DB_File'

to new (see below).

=head1 DESCRIPTION

This object provides the basic mechanism to associate positions
in files with names. The position and filenames are stored in DBM
which can then be accessed later on. It is the equivalent of flat
file indexing (eg, SRS or efetch).

This object is the guts to the mechanism, which will be used by the
specific objects inheriting from it.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to one
of the Bioperl mailing lists.  Your participation is much appreciated.

  bioperl-l@bioperl.org             - General discussion
  bioperl-guts-l@bioperl.org        - Automated bug and CVS messages
  http://bioperl.org/MailList.shtml - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
the bugs and their resolution.  Bug reports can be submitted via
email or the web:

  bioperl-bugs@bio.perl.org
  http://bio.perl.org/bioperl-bugs/

=head1 AUTHOR - Ewan Birney, James Gilbert

Email - birney@sanger.ac.uk, jgrg@sanger.ac.uk

=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal
methods are usually preceded with an "_" (underscore).

=cut

# Let the code begin...

package Bio::Index::Abstract;

use strict;
use Fcntl qw( O_RDWR O_CREAT O_RDONLY );
use vars qw( $TYPE_AND_VERSION_KEY
             @ISA $USE_DBM_TYPE $DB_HASH );

# Object preamble - inheriets from Bio::Root::Object

use Bio::Root::Object;
use Symbol();

@ISA = qw(Bio::Root::Object);

# new() is inherited from Bio::Root::Object

=head2 new

  Usage   : $index = Bio::Index::Abstract->new(
                -filename    => $dbm_file,
                -write_flag  => 0,  
                -dbm_package => 'DB_File',
                -verbose     => 0);
  Function: Returns a new index object.  If filename is
            specified, then open_dbm() is immediately called. 
            Bio::Index::Abstract->new() will usually be called
            directly only when opening an existing index.
  Returns : A new index object
  Args    : -filename    The name of the dbm index file.
            -write_flag  TRUE if write access to the dbm file is
                         needed.
            -dbm_package The Perl dbm module to use for the
                         index.
            -verbose     Print debugging output to STDERR if
                         TRUE.

=cut

sub _initialize {
    my($self, @args) = @_;
    
    my( $filename, $write_flag, $dbm_package, $verbose ) =
        $self->_rearrange(['FILENAME','WRITE_FLAG','DBM_PACKAGE','VERBOSE'], @args);
    
    # Store any parameters passed
    $self->filename($filename)       if $filename;
    $self->write_flag($write_flag)   if $write_flag;
    $self->dbm_package($dbm_package) if $dbm_package;
    $self->verbose($verbose);

    $self->{'_filehandle'} = []; # Array in which to cache SeqIO objects
    $self->{'_DB'}         = {}; # Gets tied to the DBM file
    
    # Open database
    $self->open_dbm() if $filename;
}

=pod

=head2 filename

 Title   : filename
 Usage   : $value = $self->filename();
           $self->filename($value);
 Function: Gets or sets the name of the dbm index file.
 Returns : The current value of filename
 Args    : Value of filename if setting, or none if
           getting the value.

=head2 write_flag

 Title   : write_flag
 Usage   : $value = $self->write_flag();
           $self->write_flag($value);
 Function: Gets or sets the value of write_flag, which
           is wether the dbm file should be opened with
           write access.
 Returns : The current value of write_flag (default 0)
 Args    : Value of write_flag if setting, or none if
           getting the value.

=head2 dbm_package

 Usage   : $value = $self->dbm_package();
           $self->dbm_package($value);
           
 Function: Gets or sets the name of the Perl dbm module used. 
           If the value is unset, then it returns the value of
           the package variable $USE_DBM_TYPE or if that is
           unset, then it chooses the best available dbm type,
           choosing 'DB_File' in preference to 'SDBM_File'. 
           Bio::Abstract::Index may work with other dbm file
           types.

 Returns : The current value of dbm_package
 Args    : Value of dbm_package if setting, or none if
           getting the value.

=cut

sub dbm_package {
    my( $self, $value ) = @_;
    
    if ($value) {
        $self->{'_dbm_package'} = $value;
    }
    elsif (! $self->{'_dbm_package'}) {
        if ($USE_DBM_TYPE) {
            $self->{'_dbm_package'} = $USE_DBM_TYPE;
        } else {
            my( $type );
            # DB_File isn't available on all systems
            eval {
                require DB_File;
                DB_File->import('$DB_HASH');
            };
            if ($@) {
                require SDBM_File;
                $type = 'SDBM_File';
            } else {
                $type = 'DB_File';
            }
            $USE_DBM_TYPE = $self->{'_dbm_package'} = $type;
        }
    }
    return $self->{'_dbm_package'};
}

# Generate accessor methods for simple object fields
BEGIN {
    foreach my $func (qw(filename write_flag)) {
        no strict 'refs';
        my $field = "_$func";
        
        *$func = sub {
            my( $self, $value ) = @_;
            
            if (defined $value) {
                $self->{$field} = $value;
            }
            return $self->{$field};
        }
    }
}

=head2 db

  Title   : db
  Usage   : $index->db
  Function: Returns a ref to the hash which is tied to the dbm
            file.  Used internally when adding and retrieving
            data from the database.
  Example : $db = $index->db();
            $db->{ $some_key } = $data
            $data = $index->db->{ $some_key };
  Returns : ref to HASH
  Args    : NONE

=cut

sub db {
    return $_[0]->{'_DB'};
}

=head2 get_stream

 Title   : get_stream
 Usage   : $stream = $index->get_stream( $id );
 Function: Returns a file handle with the file pointer
           at the approprite place

           This provides for a way to get the actual
           file contents and not an object 

           WARNING: you must parse the record deliminter
           *yourself*. Abstract wont do this for you 
           So this code
 
           $fh = $index->get_stream($myid);
           while( <$fh> ) {
              # do something
           }
           will parse the entire file if you don't put in
           a last statement in, like

           while( <$fh> ) {
              /^\/\// && last; # end of record
              # do something
           }

 Returns : A filehandle object
 Args    : string represents the accession number
 Notes   : This method should not be used without forethought 

=cut

#'

sub get_stream {
   my ($self,$id) = @_;

   my ($desc,$acc,$out);
   my $db = $self->db();

   if (my $rec = $db->{ $id }) {
       my( @record );
       
       my ($file, $begin, $end) = $self->unpack_record( $rec );
        
       # Get the (possibly cached) filehandle
       my $fh = $self->_file_handle( $file );
       
       # move to start
       seek($fh, $begin, 0);
       
       return $fh;
   }
   else {
       $self->throw("Unable to find a record for $id in the flat file index");
   }
}

=head2 open_dbm

  Usage   : $index->open_dbm()
  
  Function: Opens the dbm file associated with the index
            object.  Write access is only given if explicitly
            asked for by calling new(-write => 1) or having set
            the write_flag(1) on the index object.  The type of
            dbm file opened is that returned by dbm_package(). 
            The name of the file to be is opened is obtained by
            calling the filename() method.

  Example : $index->_open_dbm()
  Returns : 1 on success

=cut

sub open_dbm {
    my( $self ) = @_;
    
    my $filename = $self->filename()
        or $self->throw("filename() not set");

    my $db = $self->db();
    
    # Close the dbm file if already open (maybe we're getting
    # or dropping write access
    if (ref($db) ne 'HASH') {
        untie($db);
    }
    
    # What kind of DBM file are we going to open?
    my $dbm_type = $self->dbm_package;
    
    # Choose mode for opening dbm file (read/write+create or read-only).
    my $mode_flags = $self->write_flag ? O_RDWR|O_CREAT : O_RDONLY;
    
    # Open the dbm file
    if ($dbm_type eq 'DB_File') {
        tie( %$db, $dbm_type, $filename, $mode_flags, 0644, $DB_HASH )
            or $self->throw("Can't open '$dbm_type' dbm file '$filename' : $!");
    } else {
        tie( %$db, $dbm_type, $filename, $mode_flags, 0644 )
            or $self->throw("Can't open '$dbm_type' dbm file '$filename' : $!");
    }

    # The following methods access data in the dbm file:

    # Now, if we're a Bio::Index::Abstract caterpillar, then we
    # transform ourselves into a Bio::Index::<something> butterfly!
    if( ref($self) eq "Bio::Index::Abstract" ) { 
	my $pkg = $self->_code_base();
	bless $self, $pkg;
    }

    # Check or set this is the right kind and version of index
    $self->_type_and_version();
    
    # Check files haven't changed size since they were indexed
    $self->_check_file_sizes();

    return 1;
}

=head2 _version

  Title   : _version
  Usage   : $type = $index->_version()
  Function: Returns a string which identifes the version of an
            index module.  Used to permanently identify an index
            file as having been created by a particular version
            of the index module.  Must be provided by the sub class
  Example : 
  Returns : 
  Args    : none

=cut

sub _version {
    my $self = shift;
    
    $self->throw("In Bio::Index::Abstract, no _version method in sub class");
}

=head2 _code_base

 Title   : _code_base
 Usage   : $code = $db->_code_base();
 Function:
 Example :
 Returns : Code package to be used with this 
 Args    :

=cut

sub _code_base {
   my ($self) = @_;
   my $code_key    = '__TYPE_AND_VERSION';
   my $record;

   $record = $self->db->{$code_key};

   my($code,$version) = $self->unpack_record($record);
   if( wantarray ) {
       return ($code,$version);
   } else {
       return $code;
   }
}

=head2 _type_and_version

  Title   : _type_and_version
  Usage   : Called by _initalize
  Function: Checks that the index opened is made by the same index
            module and version of that module that made it.  If the
            index is empty, then it adds the information to the
            database.
  Example : 
  Returns : 1 or exception
  Args    : none

=cut

sub _type_and_version {
    my $self    = shift;
    my $key     = '__TYPE_AND_VERSION';
    my $version = $self->_version();
    my $type    = ref $self;
    
    # Run check or add type and version key if missing
    if (my $rec = $self->db->{ $key }) {
        my( $db_type, $db_version ) = $self->unpack_record($rec);
        $self->throw("This index file is from version [$db_version] - You need to rebuild it to use module version [$version]")
            unless $db_version == $version;
        $self->throw("This index file is type [$db_type] - Can't access it with module for [$type]")
            unless $db_type eq $type;
    } else {
        $self->add_record( $key, $type, $version )
            or $self->throw("Can't add Type and Version record");
    }
    return 1;
}

=head2 

  Title   : allow_relative_paths
  Usage   : $index->allow_relative_paths()
  Function: Allow files being indexed to have
            non-absolute paths
  Example : $index->allow_relative_paths(1)
  Returns : TRUE or FALSE
  Args    : TRUE or FALSE

=cut

sub allow_relative_paths {
    my( $self, $arg ) = @_;
    
    if (defined $arg) {
        $self->{'_allow_relative_paths'} = $arg;
    }
    return $self->{'_allow_relative_paths'};
}

=head2 

  Title   : _check_file_sizes
  Usage   : $index->_check_file_sizes()
  Function: Verifies that the files listed in the database
            are the same size as when the database was built,
            or throws an exception.  Called by the _initialize()
            function.
  Example : 
  Returns : 1 or exception
  Args    : 

=cut

sub _check_file_sizes {
    my $self = shift;
    my $num  = $self->_file_count() || 0;
    
    for (my $i = 0; $i < $num; $i++) {
        my( $file, $stored_size ) = $self->unpack_record( $self->db->{"__FILE_$i"} );
        my $size = -s $file;
        unless ($size == $stored_size) {
            $self->throw("file $i [ $file ] has changed size $stored_size -> $size. This probably means you need to rebuild the index.");
        }
    }
    return 1;
}

=head2 make_index

  Title   : make_index
  Usage   : $index->make_index( FILE_LIST )
  Function: Takes a list of file names, checks that they are
            all fully qualified, and then calls _filename() on
            each.  It supplies _filename() with the name of the
            file, and an integer which is stored with each record
            created by _filename().  Can be called multiple times,
            and can be used to add to an existing index file.
  Example : $index->make_index( '/home/seqs1', '/home/seqs2', '/nfs/pub/big_db' );
  Returns : Number of files indexed
  Args    : LIST OF FILES

=cut

sub make_index {
    my($self, @files) = @_;
    my $count = 0;

    # blow up if write flag is not set. EB fix

    if( !defined $self->write_flag ) {
	$self->throw("Attempting to make an index on a read-only database. What about a WRITE flag on opening the index?");
    }

    $self->throw("No files to index provided") unless @files;
    foreach my $file (@files) {
        # We're really fussy/lazy, expecting all file names to be
        # fully qualified unless allow_relative_paths is set.
        unless ($self->allow_relative_paths) {
            $self->throw("File name not fully qualified : '$file'")
                unless $file =~ m|^/|;
        }
        $self->throw("File does not exist: $file") unless -e $file;
    }

    # Add each file to the index
    FILE :
    foreach my $file (@files) {

        my $i; # index for this file
    
        # Get new index for this file and increment file count
        if ( defined(my $count = $self->_file_count) ) {
            $i = $count;
        } else {
            $i = 0; $self->_file_count(0);
        }

	# see whether this file has been already indexed
	my ($record,$number,$size);

	if( ($record = $self->db->{"__FILENAME_$file"}) ) {
	    ($number,$size) = $self->unpack_record($record);

	    # if it is the same size - fine. Otherwise die 
	    if( -s $file == $size ) {
		warn "File $file already indexed. Skipping...\n";
		next FILE;
	    } else {
		$self->throw("In index, $file has changed size ($size). Indicates that the index is out of date");
	    }
	}

	# index this file
	warn "Indexing file $file\n" if $self->verbose;

	# this is supplied by the subclass and does the serious work
        $self->_index_file( $file, $i ); # Specific method for each type of index

        # Save file name and size for this index
        $self->add_record("__FILE_$i", $file, -s $file)
            or $self->throw("Can't add data to file: $file");
        $self->add_record("__FILENAME_$file", $i, -s $file)
            or $self->throw("Can't add data to file: $file");

        # increment file lines
	$i++; $self->_file_count($i);
	my $temp;
	$temp = $self->_file_count();
	

    }
    return $count;
}

=head2 _filename

  Title   : _filename
  Usage   : $index->_filename( FILE INT )
  Function: Indexes the file
  Example : 
  Returns : 
  Args    : 

=cut

sub _index_file {
    my $self = shift;
    
    my $pkg = ref($self);
    $self->throw("Error: '$pkg' does not provide the _index_file() method");
}

=head2 _file_handle

  Title   : _file_handle
  Usage   : $fh = $index->_file_handle( INT )
  Function: Returns an open filehandle for the file
            index INT.  On opening a new filehandle it
            caches it in the @{$index->_filehandle} array.
            If the requested filehandle is already open,
            it simply returns it from the array.
  Example : $fist_file_indexed = $index->_file_handle( 0 );
  Returns : ref to a filehandle
  Args    : INT

=cut

sub _file_handle {
    my( $self, $i ) = @_;
    
    unless ($self->{'_filehandle'}[$i]) {
        my $fh = Symbol::gensym();
        my @rec = $self->unpack_record($self->db->{"__FILE_$i"})
            or $self->throw("Can't get filename for index : $i");
        my $file = $rec[0];
        open $fh, $file or $self->throw("Can't read file '$file' : $!");
        $self->{'_filehandle'}[$i] = $fh; # Cache filehandle
    }
    return $self->{'_filehandle'}[$i];
}

=head2 _file_count

  Title   : _file_count
  Usage   : $index->_file_count( INT )
  Function: Used by the index building sub in a sub class to
            track the number of files indexed.  Sets or gets
            the number of files indexed when called with or
            without an argument.
  Example : 
  Returns : INT
  Args    : INT

=cut

sub _file_count {
    my $self = shift;
    if (@_) {
        $self->db->{'__FILE_COUNT'} = shift;
    }
    return $self->db->{'__FILE_COUNT'};
}

=head2 add_record

  Title   : add_record
  Usage   : $index->add_record( $id, @stuff );
  Function: Calls pack_record on @stuff, and adds the result
            of pack_record to the index database under key $id.
            If $id is a reference to an array, then a new entry
            is added under a key corresponding to each element
            of the array.
  Example : $index->add_record( $id, $fileNumber, $begin, $end )
  Returns : TRUE on success or FALSE on failure
  Args    : ID LIST

=cut

sub add_record {
    my( $self, $id, @rec ) = @_;

    print STDERR "Adding key $id\n" if $self->verbose;
    $self->db->{$id} = $self->pack_record( @rec );
    return 1;
}

=head2 pack_record

  Title   : pack_record
  Usage   : $packed_string = $index->pack_record( LIST )
  Function: Packs an array of scalars into a single string
            joined by ASCII 034 (which is unlikely to be used
            in any of the strings), and returns it. 
  Example : $packed_string = $index->pack_record( $fileNumber, $begin, $end )
  Returns : STRING or undef
  Args    : LIST

=cut

sub pack_record {
    my( $self, @args ) = @_;
    return join "\034", @args;
}

=head2 unpack_record

  Title   : unpack_record
  Usage   : $index->unpack_record( STRING )
  Function: Splits the sting provided into an array,
            splitting on ASCII 034.
  Example : ( $fileNumber, $begin, $end ) = $index->unpack_record( $self->db->{$id} )
  Returns : A 3 element ARRAY
  Args    : STRING containing ASCII 034

=cut

sub unpack_record {
    my( $self, @args ) = @_;
    return split /\034/, $args[0];
}

=head2 verbose

 Title   : verbose
 Usage   : $obj->verbose($newval)
 Function: sets whether a report to STDERR should be issued or not
           for each sequence indexed. Helps track errors
 Example : 
 Returns : value of verbose
 Args    : newvalue (optional)

=cut

sub verbose {
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'_verbose'} = $value;
    }
    return $obj->{'_verbose'};

}

=head2 DESTROY

 Title   : DESTROY
 Usage   : Called automatically when index goes out of scope
 Function: Closes connection to database and handles to
           sequence files
 Returns : NEVER
 Args    : NONE

=cut

sub DESTROY {
    my $self = shift;
    
    untie %{$self->db};
}

1;

