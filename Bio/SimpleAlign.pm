#
# BioPerl module for SimpleAlign
#
# Cared for by Ewan Birney <birney@sanger.ac.uk>
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code
#
#  History:
#	11/3/00 Added threshold feature to consensus and consensus_aa  - PS
#		

=head1 NAME

SimpleAlign - Multiple alignments held as a set of sequences

=head1 SYNOPSIS

    $aln = new Bio::SimpleAlign;

    $aln->read_MSF(\*STDIN);

    $aln->write_fasta(\*STDOUT);

=head1 INSTALLATION

This module is included with the central Bioperl distribution:

   http://bio.perl.org/Core/Latest
   ftp://bio.perl.org/pub/DIST

Follow the installation instructions included in the README file.

=head1 DESCRIPTION

SimpleAlign handles multiple alignments of sequences. It is very permissive
of types (it wont insist on things being all same length etc): really
it is a SequenceSet explicitly held in memory with a whole series of
built in manipulations and especially file format systems for
read/writing alignments.

SimpleAlign basically views an alignment as an immutable block of text.
SimpleAlign *is not* the object to be using if you want to perform complex
alignment alignment manipulations.
These functions are much better done by UnivAln by Georg Fuellen.

However for lightweight display/formatting and minimal manipulation
(e.g. removiung all-gaps columns) - this is the one to use.

Tricky concepts. SimpleAlign expects name,start,end to be 'unique' in
the alignment, and this is the key for the internal hashes.
(name,start,end is abreviated nse in the code). However, in many cases
people don't want the name/start-end to be displayed: either multiple
names in an alignment or names specific to the alignment
(ROA1_HUMAN_1, ROA1_HUMAN_2 etc). These names are called
'displayname', and generally is what is used to print out the
alignment. They default to name/start-end

The SimpleAlign Module came from Ewan Birney's Align module

=head1 PROGRESS

SimpleAlign is being slowly converted to bioperl coding standards,
mainly by Ewan.

=over 3

=item Use Bio::Root::Object - done

=item Use proper exceptions - done

=item Use hashed constructor - not done!

=back

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other Bioperl modules.
Send your comments and suggestions preferably to one of the Bioperl mailing lists.
Your participation is much appreciated.

   bioperl-l@bioperl.org             - General discussion
   http://bioperl.org/MailList.shtml - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track the bugs and
their resolution. Bug reports can be submitted via email or the web:

    bioperl-bugs@bio.perl.org
    http://bio.perl.org/bioperl-bugs/

=head1 AUTHOR

Ewan Birney, birney@sanger.ac.uk

=head1 SEE ALSO

 Bio::LocatableSeq.pm

 http://bio.perl.org/Projects/modules.html  - Online module documentation
 http://bio.perl.org/Projects/SeqAlign/     - Bioperl sequence alignment project
 http://bio.perl.org/                       - Bioperl Project Homepage

=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::SimpleAlign;
use vars qw(@ISA);
use strict;

use Bio::Root::RootI;
use Bio::LocatableSeq;         # uses Seq's as list

@ISA = qw(Bio::Root::RootI);
sub new {
  my($class,@args) = @_;

  my $self = $class->SUPER::new(@args);

  # we need to set up internal hashs first!

  $self->{'seq'} = {};
  $self->{'order'} = {};
  $self->{'start_end_lists'} = {};
  $self->{'dis_name'} = {};
  $self->{'id'} = 'NoName';

  # maybe we should automatically read in from args. Hmmm...

  return $self; # success - we hope!
}

=head2 addSeq

 Title     : addSeq
 Usage     : $myalign->addSeq($newseq);
           :
           :
 Function  : Adds another sequence to the alignment
           : *does not* align it - just adds it to the
           : hashes
           :
 Returns   : nothing
 Argument  :

=cut

sub addSeq {
    my $self = shift;
    my $seq  = shift;
    my $order = shift;
    my ($name,$id,$start,$end);

    if( !ref $seq || ! $seq->isa('Bio::LocatableSeq') ) {
	$self->throw("Unable to process non locatable sequences");
    }

    $id = $seq->id();
    $start = $seq->start();
    $end  = $seq->end();

    if( !defined $order ) {
	$order = keys %{$self->{'seq'}};
    }

    $name = sprintf("%s-%d-%d",$id,$start,$end);

    if( $self->{'seq'}->{$name} ) {
	$self->warn("Replacing one sequence [$name]\n");

    }
    else {
	#print STDERR "Assigning $name to $order\n";

	$self->{'order'}->{$order} = $name;

	if (not exists( $self->{'start_end_lists'}->{$id})) {
	    $self->{'start_end_lists'}->{$id} = [];
	}
	push @{$self->{'start_end_lists'}->{$id}}, $seq;
    }

    $self->{'seq'}->{$name} = $seq;

}

=head2 column_from_residue_number

 Title   : column_from_residue_number
 Usage   : $col = $ali->column_from_residue_number( $seqname, $resnumber)
 Function:
    This function gives the position in the alignment (i.e. column number) of
    the given residue number in the sequence with the given name. For example,
    for the alignment

    Seq1/91-97 AC..DEF.GH
    Seq2/24-30 ACGG.RTY..
    Seq3/43-51 AC.DDEFGHI

    column_from_residue_number( "Seq1", 94 ) returns 5.
    column_from_residue_number( "Seq2", 25 ) returns 2.
    column_from_residue_number( "Seq3", 50 ) returns 9.

    An exception is thrown if the residue number would lie outside the length
    of the aligment (e.g. column_from_residue_number( "Seq2", 22 )

 Returns :
    A column number for the postion in the alignment of the given residue in the given
         sequence (1 = first column)
 Args    :
    A sequence name (not a name/start-end)
    A residue number in the whole sequence (not just that segment of it in the alignment)

=cut

sub column_from_residue_number {
    my ($self, $seqname, $resnumber) = @_;

    foreach my $seq ($self->eachSeqWithId($seqname)) {
	if ($resnumber >= $seq->start() and $resnumber <= $seq->end()) {
	    # we have found the correct sequence
	    my @residues = $seq->ary();
	    my $count = $seq->start();
	    my $i;
	    for ($i=0; $i < @residues; $i++) {
		if ($residues[$i] ne '.' and $residues[$i] ne '-') {
		    $count == $resnumber and last;
		    $count++;
		}		
	    }
	    # $i now holds the index of the column. The actual colimn number is this index + 1
		
	    return $i+1;
	}
    }

    $self->throw("Could not find a sequence segment in $seqname containing residue number $resnumber");

}

=head2 consensus_string

 Title     : consensus_string
 Usage     : $str = $ali->consensus_string($threshold_percent)
 Function  : Makes a consensus
 Returns   :
 Argument  : Optional treshold ranging from 0 to 100.  If consensus residue appears in
		fewer than threshold % of the sequences at a given location
		consensus_string will return a "?" at that location rather than the consensus
		letter. (Default value = 0%)

=cut

sub consensus_string {
    my $self = shift;
    my $threshold = shift;
    my $len;
    my ($out,$count);

    $out = "";

    $len = $self->length_aln();

    foreach $count ( 0 .. $len ) {
	$out .= $self->consensus_aa($count,$threshold);
    }

    return $out;

}

=head2 consensus_aa

 Title     : consensus_aa
 Usage     : $consensus_residue = $ali->consensus_aa($residue_number, $threshold_percent)
 Function  : Makes a consensus
 Returns   :
 Argument  : Optional treshold ranging from 0 to 100.  If consensus residue appears in
		fewer than threshold % of the sequences at the specified location
		consensus_string will return a "?"  rather than the consensus
		letter. (Default value = 0%)

=cut


sub consensus_aa {
    my $self = shift;
    my $point = shift;
    my $threshold_percent = shift || -1 ;
    my ($seq,%hash,$count,$letter,$key);

    foreach $seq ( $self->eachSeq() ) {
	$letter = substr($seq->seq,$point,1);
	($letter =~ /\./) && next;
	# print "Looking at $letter\n";
	$hash{$letter}++;
    }
    my $number_of_sequences = $self->no_sequences();
    my $threshold = $number_of_sequences * $threshold_percent / 100. ;
    $count = -1;
    $letter = '?';

    foreach $key ( keys %hash ) {
	# print "Now at $key $hash{$key}\n";
	if( $hash{$key} > $count && $hash{$key} > $threshold) {
	    $letter = $key;
	    $count = $hash{$key};
	}
    }
    return $letter;
}

=head2 each_alphabetically

 Title     : each_alphabetically
 Usage     : foreach $seq ( $ali->each_alphabetically() )
           :
           :
 Function  : returns an array of sequence object sorted
           : alphabetically by name and then by start point
           :
           : Does not change the order of the alignment
 Returns   :
 Argument  :

=cut

	
sub each_alphabetically {
    my $self = shift;
    my ($seq,$nse,@arr,%hash,$count);

    foreach $seq ( $self->eachSeq() ) {
	$nse = $seq->get_nse("-","-");
	$hash{$nse} = $seq;
    }

    foreach $nse ( sort alpha_startend keys %hash) {
	push(@arr,$hash{$nse});
    }

    return @arr;

}

sub alpha_startend {
    my ($aname,$astart,$bname,$bstart);
    ($aname,$astart) = split (/-/,$a);
    ($bname,$bstart) = split (/-/,$b);

    if( $aname eq $bname ) {
	return $astart <=> $bstart;
    }
    else {
	return $aname cmp $bname;
    }

}


=head2 eachSeq

 Title     : eachSeq
 Usage     : foreach $seq ( $align->eachSeq() )
           :
           :
 Function  : gets an array of Seq objects from the
           : alignment
           :
           :
 Returns   : an array
 Argument  : nothing

=cut

sub eachSeq {
    my $self = shift;
    my (@arr,$order);

    foreach $order ( sort { $a <=> $b } keys %{$self->{'order'}} ) {
	if( exists $self->{'seq'}->{$self->{'order'}->{$order}} ) {
	    push(@arr,$self->{'seq'}->{$self->{'order'}->{$order}});
	}
    }

    return @arr;
}


=head2 eachSeqWithId

 Title     : eachSeqWithId
 Usage     : foreach $seq ( $align->eachSeqWithName() )
           :
           :
 Function  : gets an array of Seq objects from the
           : alignment, the contents being those sequences
           : with the given name (there may be more than one
           :
 Returns   : an array
 Argument  : nothing

=cut

sub eachSeqWithId {
    my $self = shift;
    my $id = shift;

    my (@arr, $seq);

    if (exists($self->{'start_end_lists'}->{$id})) {
	@arr = @{$self->{'start_end_lists'}->{$id}};
    }
    return @arr;

    return @arr;
}

sub get_displayname {
    my $self = shift;
    my $name = shift;

    if( defined $self->{'dis_name'}->{$name} ) {
	return  $self->{'dis_name'}->{$name};
    } else {
	return $name;
    }
}

=head2 id

 Title     : id
 Usage     : $myalign->id("Ig")
 Function  : Gets/sets the id field of the alignment
           :
 Returns   : An id string
 Argument  : An id string (optional)

=cut

sub id {
    my ($self, $name) = @_;

    if (defined( $name )) {
	$self->{'id'} = $name;
    }

    return $self->{'id'};
}

=head2 is_flush

 Title     : is_flush
 Usage     : if( $ali->is_flush() )
           :
           :
 Function  : Tells you whether the alignment
           : is flush, ie all of the same length
           :
           :
 Returns   : 1 or 0
 Argument  :

=cut

sub is_flush {
    my $self = shift;
    my $seq;
    my $length = (-1);
    my $temp;

    foreach $seq ( $self->eachSeq() ) {
	if( $length == (-1) ) {
	    $length = length($seq->seq());
	    next;
	}

	$temp = length($seq->seq());

	if( $temp != $length ) {
	    return 0;
	}
    }

    return 1;
}

=head2 length_aln

 Title     : length_aln()
 Usage     : $len = $ali->length_aln()
           :
           :
 Function  : returns the maximum length of the alignment.
           : To be sure the alignment is a block, use is_flush
           :
           :
 Returns   :
 Argument  :

=cut

sub length_aln {
    my $self = shift;
    my $seq;
    my $length = (-1);
    my ($temp,$len);

    foreach $seq ( $self->eachSeq() ) {
	$temp = length($seq->seq());
	if( $temp > $length ) {
	    $length = $temp;
	}
    }

    return $length;
}

=head2 map_chars

 Title     : map_chars
 Usage     : $ali->map_chars('\.','-')
           :
           :
 Function  : does a s/$arg1/$arg2/ on
           : the sequences. Useful for
           : gap characters
           :
           : Notice that the from (arg1) is interpretted
           : as a regex, so be careful about quoting meta
           : characters (eg $ali->map_chars('.','-') wont
           : do what you want)
 Returns   :
 Argument  :

=cut

sub map_chars {
    my $self = shift;
    my $from = shift;
    my $to   = shift;
    my ($seq,$temp);

    foreach $seq ( $self->eachSeq() ) {
	$temp = $seq->str();
	$temp =~ s/$from/$to/g;
	$seq->setseq($temp);
    }
}

sub maxdisplayname_length {
    my $self = shift;
    my $maxname = (-1);
    my ($seq,$len);

    foreach $seq ( $self->eachSeq() ) {
	$len = length $self->get_displayname($seq->get_nse());

	if( $len > $maxname ) {
	    $maxname = $len;
	}
    }

    return $maxname;
}

sub maxname_length {
    my $self = shift;
    my $maxname = (-1);
    my ($seq,$len);

    foreach $seq ( $self->eachSeq() ) {
	$len = length $seq->id();

	if( $len > $maxname ) {
	    $maxname = $len;
	}
    }

    return $maxname;
}

sub maxnse_length {
    my $self = shift;
    my $maxname = (-1);
    my ($seq,$len);

    foreach $seq ( $self->eachSeq() ) {
	$len = length $seq->get_nse();

	if( $len > $maxname ) {
	    $maxname = $len;
	}
    }

    return $maxname;
}

=head2 no_residues

 Title     : no_residues
 Usage     : $no = $ali->no_residues
           :
           :
 Function  : number of residues in total
           : in the alignment
           :
           :
 Returns   :
 Argument  :

=cut

sub no_residues {
    my $self = shift;
    my $count = 0;

    foreach my $seq ($self->eachSeq) {
	my $str = $seq->seq();

	$count += ($str =~ s/[^A-Za-z]//g);
    }

    return $count;
}

=head2 no_sequences

 Title     : no_sequences
 Usage     : $depth = $ali->no_sequences
           :
           :
 Function  : number of sequence in the
           : sequence alignment
           :
           :
 Returns   :
 Argument  :

=cut

sub no_sequences {
    my $self = shift;

    return scalar($self->eachSeq);
}

=head2 percentage_identity

 Title   : percentage_identity
 Usage   : $id = $align->percentage_identity
 Function:
    The function uses a fast method to calculate the average percentage identity of the alignment
 Returns : The average percentage identity of the alignment
 Args    : None

=cut

sub percentage_identity{
   my ($self,@args) = @_;

   my @alphabet = ('A','B','C','D','E','F','G','H','I','J','K','L','M',
                   'N','O','P','Q','R','S','T','U','V','W','X','Y','Z');

   my ($len, $total, $subtotal, $divisor, $subdivisor, @seqs, @countHashes);

   if (! $self->is_flush()) {
       $self->throw("All sequences in the alignment must be the same length");
   }

   @seqs = $self->eachSeq();
   $len = $self->length_aln();

   # load the each hash with correct keys for existence checks
   for( my $index=0; $index < $len; $index++) {
       foreach my $letter (@alphabet) {
	   $countHashes[$index]->{$letter} = 0;
       }
   }

   foreach my $seq (@seqs)  {
       my @seqChars = $seq->ary();
       for( my $column=0; $column < @seqChars; $column++ ) {
	   my $char = uc($seqChars[$column]);
	   if (exists $countHashes[$column]->{$char}) {
	       $countHashes[$column]->{$char}++;
	   }
       }
   }

   $total = 0;
   $divisor = 0;
   for(my $column =0; $column < $len; $column++) {
       my %hash = %{$countHashes[$column]};
       $subdivisor = 0;
       foreach my $res (keys %hash) {
	   $total += $hash{$res}*($hash{$res} - 1);
	   $subdivisor += $hash{$res};
       }
       $divisor += $subdivisor * ($subdivisor - 1);
   }
   return ($total / $divisor )*100.0;
}

=head2 purge

 Title   : purge
 Usage   : $aln->purge(0.7);
 Function: removes sequences above whatever %id
 Example :
 Returns : An array of the removed sequences
 Arguments

 This function will grind on large alignments. Beware!

 (perhaps not ideally implemented)

=cut

sub purge{
  my ($self,$perc) = @_;
  my (@seqs,$seq,%removed,$i,$j,$count,@one,@two,$seq2,$k,$res,$ratio,@ret);

 # $self->write_Pfam(\*STDOUT);

  @seqs = $self->eachSeq();

  #$self->write_Pfam(\*STDOUT);

#  foreach $seq ( @seqs ) {
#      printf("$seq %s %s\n",$seq->get_nse(),join(' ',$seq->dump()));
#  }

  for($i=0;$i< @seqs;$i++ ) {
      $seq = $seqs[$i];
      #printf "%s\n", $seq->out_fasta();
      #print "\n\nDone\n\n";

      # if it has already been removed, skip

      if( $removed{$seq->get_nse()} == 1 ) {
	  next;
      }

      # if not ... look at the other sequences

      # make the first array once

      @one = $seq->seq();
      for($j=$i+1;$j < @seqs;$j++) {
	  $seq2 = $seqs[$j];
	  if ( $removed{$seq2->get_nse()} == 1 ) {
	      next;
	  }
	  @two = $seq2->seq();
	  $count = 0;
	  $res = 0;
	  for($k=0;$k<@one;$k++) {
	      if( $one[$k] ne '.' && $one[$k] ne '-' && $one[$k] eq $two[$k]) {
		  $count++;
	      }
	      if( $one[$k] ne '.' && $one[$k] ne '-' && $two[$k] ne '.' && $two[$k] ne '-' ) {
		  $res++;
	      }
	  }
	  if( $res == 0 ) {
	      $ratio = 0;
	  } else {
	      $ratio = $count/$res;
	  }

	  if( $ratio > $perc ) {
	      $removed{$seq2->get_nse()} = 1;
	      $self->removeSeq($seq2);
	      push(@ret,$seq2);
	  } else {
	      # could put a comment here!
	  }
      }
  }

  return @ret;
}

=head2 read_fasta

 Title     : read_fasta
 Usage     : $ali->read_fasta(\*INPUT)
           :
           :
 Function  : reads in a fasta formatted
           : file for an alignment
           :
           :
 Returns   :
 Argument  :

=cut

sub read_fasta {
    my $self = shift;
    my $in = shift;
    my $count = 0;
    my ($start,$end,$name,$seqname,$seq,$seqchar,$tempname,%align);

    while( <$in> ) {
	if( /^>(\S+)/ ) {
	    $tempname = $1;
	    if( defined $name ) {
		# put away last name and sequence

		if( $name =~ /(\S+)\/(\d+)-(\d+)/ ) {
		    $seqname = $1;
		    $start = $2;
		    $end = $3;
		} else {
		    $seqname=$name;
		    $start = 1;
		    $end = length($seqchar);
		}
		
		$seq = new Bio::LocatableSeq('-seq'=>$seqchar,
				    '-id'=>$seqname,
				    '-start'=>$start,
				    '-end'=>$end,
				    );

		$self->addSeq($seq);

		$count++;
	    }
	    $name = $tempname;
	    $seqchar  = "";
	    next;
	}
	s/[^A-Za-z\.\-]//g;
	$seqchar .= $_;

    }
    # put away last name and sequence

    if( $name =~ /(\S+)\/(\d+)-(\d+)/ ) {
	$seqname = $1;
	$start = $2;
	$end = $3;
    } else {
	$seqname=$name;
	$start = 1;
	$end = length($seqchar);
    }

    $seq = new Bio::LocatableSeq('-seq'=>$seqchar,
			'-id'=>$seqname,
			'-start'=>$start,
			'-end'=>$end,
			);

    $self->addSeq($seq);

    $count++;

    return $count;
}
	

=head2 read_mase

 Title     : read_mase
 Usage     : $ali->read_mase(\*INPUT)
           :
           :
 Function  : reads mase (seaview)
           : formatted alignments
           :
           :
 Returns   :
 Argument  :

=cut
	
sub read_mase {
    my $self = shift;
    my $in = shift;
    my $name;
    my $start;
    my $end;
    my $seq;
    my $add;
    my $count = 0;
	
	
    while( <$in> ) {
	/^;/ && next;
	if( /^(\S+)\/(\d+)-(\d+)/ ) {
	    $name = $1;
	    $start = $2;
	    $end = $3;
	} else {
	    s/\s//g;
	    $name = $_;
	    $end = -1;
	}

	$seq = "";

	while( <$in> ) {
	    /^;/ && last;
	    s/[^A-Za-z\.\-]//g;
	    $seq .= $_;
	}
	if( $end == -1) {
	    $start = 1;
	    $end = length($seq);
	}

	$add = new Bio::LocatableSeq('-seq'=>$seq,
			    '-id'=>$name,
			    '-start'=>$start,
			    '-end'=>$end,
			    );

	
	$self->addSeq($add);

	$count++;
    }

    return $count;
}

=head2 read_MSF

 Title   : read_MSF
 Usage   : $al->read_MSF(\*STDIN);
 Function: reads MSF formatted files. Tries to read *all* MSF
          It reads all non whitespace characters in the alignment
          area. For MSFs with weird gaps (eg ~~~) map them by using
          $al->map_chars('~','-');
 Example :
 Returns :
 Args    : filehandle

=cut

sub read_MSF{
   my ($self,$fh) = @_;
   my (%hash,$name,$str,@names,$seqname,$start,$end,$count,$seq);

   # read in the name section

   while( <$fh> ) {
       /\/\// && last; # move to alignment section
       /Name:\s+(\S+)/ && do { $name = $1;
			       $hash{$name} = ""; # blank line
			       push(@names,$name); # we need it ordered!
			   };
       # otherwise - skip
   }

   # alignment section

   while( <$fh> ) {
       # following regexp changed to not require initial whitespace, according
       # to a suggestion of Peter Schattner <schattner@alum.mit.edu>
       /^\s*(\S+)\s+(.*)$/ && do {
	   $name = $1;
	   $str = $2;
	   if( ! exists $hash{$name} ) {
	       $self->throw("$name exists as an alignment line but not in the header. Not confident of what is going on!");
	   }
	   $str =~ s/\s//g;
	   $hash{$name} .= $str;
       };
   }

   # now got this as a name - sequence hash. Lets make some sequences!

   $count = 0;

   foreach $name ( @names ) {
       if( $name =~ /(\S+)\/(\d+)-(\d+)/ ) {
	   $seqname = $1;
	   $start = $2;
	   $end = $3;
       } else {
	   $seqname=$name;
	   $start = 1;
	   $str = $hash{$name};
	   $str =~ s/[^A-Za-z]//g;
	   $end = length($str);
       }

       $seq = new Bio::LocatableSeq('-seq'=>$hash{$name},
			   '-id'=>$seqname,
			   '-start'=>$start,
			   '-end'=>$end,
			   );

       $self->addSeq($seq);

       $count++;
   }

   return $count;
}

=head2 read_Pfam

 Title     : read_Pfam
 Usage     : $ali->read_Pfam(\*INPUT)
           :
           :
 Function  : reads a Pfam formatted
           : Alignment (Mul format).
           : - this is the format used by Belvu
           :
 Returns   :
 Argument  :

=cut

sub read_Pfam {
    my $self = shift;
    my $in = shift;
    my $name;
    my $start;
    my $end;
    my $seq;
    my $add;
    my $acc;
    my %names;
    my $count = 0;

    while( <$in> ) {
	chop;
	/^\/\// && last;
	if( !/^(\S+)\/(\d+)-(\d+)\s+(\S+)\s*/ ) {
	    $self->throw("Found a bad line [$_] in the pfam format alignment");
	    next;
	}

	$name = $1;
	$start = $2;
	$end = $3;
	$seq = $4;

	$add = new Bio::LocatableSeq('-seq'=>$seq,
			    '-id'=>$name,
			    '-start'=>$start,
			    '-end'=>$end,
			    );

	$self->addSeq($add);
	
	$count++;
    }

    return $count;
}

	

=head2 read_Pfam_file

 Title     : read_Pfam_file
 Usage     : $ali->read_Pfam_file("thisfile");
           :
 Function  : opens a filename, reads
           : a Pfam (mul) formatted alignment
           :
           :
           :
 Returns   :
 Argument  :

=cut

sub read_Pfam_file {
    my $self = shift;
    my $file = shift;
    my $out;

    if( open(_TEMPFILE,$file) == 0 ) {
	$self->throw("Could not open $file for reading Pfam style alignment");
	return 0;
    }

    $out = read_Pfam($self,\*_TEMPFILE);

    close(_TEMPFILE);

    return $out;
}

=head2 read_Prodom

 Title   : read_Prodom
 Usage   : $ali->read_Prodom( $file )
 Function: Reads in a Prodom format alignment
 Returns :
    Args    : A filehandle glob or ref. to a filehandle object

=cut

sub read_Prodom{
   my $self = shift;
   my $file = shift;

   my ($acc, $fake_id, $start, $end, $seq, $add, %names);

   while (<$file>) {
       if (/^AC\s+(\S+)$/) {
	   $self->id( $1 );
       }
       elsif (/^AL\s+(\S+)\|(\S+)\s+(\d+)\s+(\d+)\s+\S+\s+(\S+)$/){
	   $acc=$1;
	   $fake_id=$2;  # Accessions have _species appended
	   $start=$3;
	   $end=$4;
	   $seq=$5;
	
	   $names{'fake_id'} = $fake_id;

	   $add = new Bio::LocatableSeq('-seq'=>$seq,
			       '-id'=>$acc,
			       '-start'=>$start,
			       '-end'=>$end,
			       );
	
	   $self->addSeq($add);
       }
       elsif (/^CO/) {
	   # the consensus line marks the end of the alignment part of the entry
	   last;
       }
   }
}

=head2 read_selex

 Title     : read_selex
 Usage     : $ali->read_selex(\*INPUT)
           :
           :
 Function  : reads selex (hmmer) format
           : alignments
           :
           :
 Returns   :
 Argument  :

=cut

sub read_selex {
    my $self = shift;
    my $in = shift;
    my ($start,$end,%align,$name,$seqname,$seq,$count,%hash,%c2name, %accession, $no);

    # in selex format, every non-blank line that does not start
    # with '#=' is an alignment segment; the '#=' lines are mark up lines.
    # Of particular interest are the '#=GF <name/st-ed> AC <accession>'
    # lines, which give accession numbers for each segment

    while( <$in> ) {
	/^\#=GS\s+(\S+)\s+AC\s+(\S+)/ && do {
	    $accession{ $1 } = $2;
	    next;
	};

	!/^([^\#]\S+)\s+([A-Za-z\.\-]+)\s*/ && next;
	
	$name = $1;
	$seq = $2;

	if( ! defined $align{$name}  ) {
	    $count++;
	    $c2name{$count} = $name;
	}

	$align{$name} .= $seq;
    }

    # ok... now we can make the sequences

    $count = 0;
    foreach $no ( sort { $a <=> $b } keys %c2name ) {
	$name = $c2name{$no};

	if( $name =~ /(\S+)\/(\d+)-(\d+)/ ) {
	    $seqname = $1;
	    $start = $2;
	    $end = $3;
	} else {
	    $seqname=$name;
	    $start = 1;
	    $end = length($align{$name});
	}

	$seq = new Bio::LocatableSeq('-seq'=>$align{$name},
			    '-id'=>$seqname,
			    '-start'=>$start,
			    '-end'=>$end,
			    '-type'=>'aligned',
				     '-accession_number' => $accession{$name},

			    );

	$self->addSeq($seq);

	$count++;
    }

    return $count;
}

=head2 read_stockholm

 Title     : read_stockholm
 Usage     : $ali->read_stockholm(\*INPUT)
           :
           :
 Function  : reads stockholm  format alignments
           :
           :
 Returns   :
 Argument  :

=cut

sub read_stockholm {
    my $self = shift;
    my $in = shift;
    my ($start,$end,%align,$name,$seqname,$seq,$count,%hash,%c2name, %accession, $no);

    # in stockholm format, every non-blank line that does not start
    # with '#=' is an alignment segment; the '#=' lines are mark up lines.
    # Of particular interest are the '#=GF <name/st-ed> AC <accession>'
    # lines, which give accession numbers for each segment

    while( <$in> ) {
	!/\w+/ && next;

	if (/^\#\s*STOCKHOLM\s+/) {
	    last;
	}
	else {
	    $self->throw("Not Stockholm format: Expecting \"# STOCKHOLM 1.0\"; Found \"$_\"");
	}
    }
	

    return $self->read_selex($in);
}

=head2 removeSeq

 Title     : removeSeq
 Usage     : $aln->removeSeq($seq);
 Function  : removes a single sequence from an alignment

=cut

sub removeSeq {
    my $self = shift;
    my $seq = shift;
    my ($name,$id,$start,$end);

    $id = $seq->id();
    $start = $seq->start();
    $end  = $seq->end();
    $name = sprintf("%s-%d-%d",$id,$start,$end);

    if( !exists $self->{'seq'}->{$name} ) {
	$self->throw("Sequence $name does not exist in the alignment to remove!");
    }

    delete $self->{'seq'}->{$name};

    # we need to remove this seq from the start_end_lists hash

    if (exists $self->{'start_end_lists'}->{$id}) {
	# we need to find the sequence in the array.
	
	my ($i, $found);;
	for ($i=0; $i < @{$self->{'start_end_lists'}->{$id}}; $i++) {
	    if (${$self->{'start_end_lists'}->{$id}}[$i] eq $seq) {
		$found = 1;
		last;
	    }
	}
	if ($found) {
	    splice @{$self->{'start_end_lists'}->{$id}}, $i, 1;
	}
	else {
	    $self->throw("Could not find the sequence to remoce from the start-end list");
	}
    }
    else {
	$self->throw("There is no seq list for the name $id");
    }

    # we can't do anything about the order hash but that is ok
    # because eachSeq will handle it
}

sub set_displayname {
    my $self = shift;
    my $name = shift;
    my $disname = shift;

    # print "Setting $name to $disname\n";
    $self->{'dis_name'}->{$name} = $disname;
}

=head2 set_displayname_count

 Title     : set_displayname_count
 Usage     : $ali->set_displayname_count
           :
           :
 Function  : sets the names to be name_#
           : where # is the number of times this
           : name has been used.
           :
 Returns   :
 Argument  :

=cut

sub set_displayname_count {
    my $self= shift;
    my (@arr,$name,$seq,$count,$temp,$nse);

    foreach $seq ( $self->each_alphabetically() ) {
	$nse = $seq->get_nse();

	#name will be set when this is the second
	#time (or greater) is has been seen

	if( $name eq ($seq->id()) ) {
	    $temp = sprintf("%s_%s",$name,$count);
	    $self->set_displayname($nse,$temp);
	    $count++;
	} else {
	    $count = 1;
	    $name = $seq->id();
	    $temp = sprintf("%s_%s",$name,$count);
	    $self->set_displayname($nse,$temp);
	    $count++;
	}
    }

}

=head2 set_displayname_flat

 Title     : set_displayname_flat
 Usage     : $ali->set_displayname_flat()
           :
           :
 Function  : Makes all the sequences be displayed
           : as just their name, not name/start-end
           :
           :
 Returns   :
 Argument  :

=cut

sub set_displayname_flat {
    my $self = shift;
    my ($nse,$seq);

    foreach $seq ( $self->eachSeq() ) {
	$nse = $seq->get_nse();
	$self->set_displayname($nse,$seq->id());
    }
}

=head2 set_displayname_normal

 Title     : set_displayname_normal
 Usage     : $ali->set_displayname_normal()
           :
           :
 Function  : Makes all the sequences be displayed
           : as name/start-end
           :
           :
 Returns   :
 Argument  :

=cut

sub set_displayname_normal {
    my $self = shift;
    my ($nse,$seq);

    foreach $seq ( $self->eachSeq() ) {
	$nse = $seq->get_nse();
	$self->set_displayname($nse,sprintf("%s/%d-%d",$seq->id(),$seq->start(),$seq->end()));
    }
}


=head2 sort_alphabetically

 Title     : sort_alphabetically
 Usage     : $ali->sort_alphabetically
           :
           :
 Function  : changes the order of the alignemnt
           : to alphabetical on name followed by
           : numerical by number
           :
 Returns   :
 Argument  :

=cut

sub sort_alphabetically {
    my $self = shift;
    my ($seq,$nse,@arr,%hash,$count);

    foreach $seq ( $self->eachSeq() ) {
	$nse = $seq->get_nse("-","-");
	$hash{$nse} = $seq;
    }

    $count = 0;

    %{$self->{'order'}} = (); # reset the hash;

    foreach $nse ( sort alpha_startend keys %hash) {
	$self->{'order'}->{$count} = $nse;

	$count++;
    }

}

=head2 uppercase

 Title     : uppercase()
 Usage     : $ali->uppercase()
           :
           :
 Function  : Sets all the sequences
           : to uppercase
           :
           :
 Returns   :
 Argument  :

=cut

sub uppercase {
    my $self = shift;
    my $seq;
    my $temp;

    foreach $seq ( $self->eachSeq() ) {
      $temp = $seq->seq();
      $temp =~ tr/[a-z]/[A-Z]/;

      $seq->setseq($temp);
    }
}

=head2 write_clustalw

 Title     : write_clustalw
 Usage     : $ali->write_clustalw
           :
           :
 Function  : writes a clustalw formatted
           : (.aln) file
           :
           :
 Returns   :
 Argument  :

=cut

sub write_clustalw {
    my $self = shift;
    my $file = shift;
    my ($count,$length,$seq,@seq,$tempcount);

    print $file "CLUSTAL W(1.4) multiple sequence alignment\n\n\n";

    $length = $self->length_aln();
    $count = $tempcount = 0;
    @seq = $self->eachSeq();

    while( $count < $length ) {
	foreach $seq ( @seq ) {
	    print $file sprintf("%-22s %s\n",$self->get_displayname($seq->get_nse()),substr($seq->seq(),$count,50));
	}
	print $file "\n\n";
	$count += 50;
    }


}

=head2 write_fasta

 Title     : write_fasta
 Usage     : $ali->write_fasta(\*OUTPUT)
           :
           :
 Function  : writes a fasta formatted alignment
           :
 Returns   :
 Argument  : reference-to-glob to file or filehandle object

=cut

sub write_fasta {
    my $self = shift;
    my $file  = shift;
    my ($seq,$rseq,$name,$count,$length,$seqsub);

    foreach $rseq ( $self->eachSeq() ) {
	$name = $self->get_displayname($rseq->get_nse());
	$seq  = $rseq->seq();
	
	print $file ">$name\n";
	
	$count =0;
	$length = length($seq);
	while( ($count * 60 ) < $length ) {
	    $seqsub = substr($seq,$count*60,60);
	    print $file "$seqsub\n";
	    $count++;
	}
    }
}

=head2 write_MSF

 Title     : write_MSF
 Usage     : $ali->write_MSF(\*FH)
           :
           :
 Function  : writes MSF format output
           :
           :
           :
 Returns   :
 Argument  :

=cut

sub write_MSF {
    my $self = shift;
    my $file = shift;
    my $msftag;
    my $type;
    my $count = 0;
    my $maxname;
    my ($length,$date,$name,$seq,$miss,$pad,%hash,@arr,$tempcount,$index);

    $date = localtime(time);
    $msftag = "MSF";
    $type = "P";
    $maxname = $self->maxnse_length();
    $length  = $self->length_aln();
    $name = $self->id();
    if( !defined $name ) {
	$name = "Align";
    }

    print $file sprintf("\n%s   MSF: %d  Type: P  %s  Check: 00 ..\n\n",$name,$self->no_sequences,$date);

    foreach $seq ( $self->eachSeq() ) {
	$name = $self->get_displayname($seq->get_nse());
	$miss = $maxname - length ($name);
	$miss += 2;
	$pad  = " " x $miss;

	print $file sprintf(" Name: %s%sLen:    %d  Check:  %d  Weight:  1.00\n",$name,$pad,length $seq->seq(),$seq->GCG_checksum());
	
	$hash{$name} = $seq->seq();
	push(@arr,$name);
    }

    #
    # ok - heavy handed, but there you go.
    #
    print $file "\n//\n";

    while( $count < $length ) {
	
	# there is another block to go!

	foreach $name  ( @arr ) {
	    print $file sprintf("%20s  ",$name);
	
	    $tempcount = $count;
	    $index = 0;
	    while( ($tempcount + 10 < $length) && ($index < 5)  ) {
		
		print $file sprintf("%s ",substr($hash{$name},$tempcount,10));
				
		$tempcount += 10;
		$index++;
	    }

	    #
	    # ok, could be the very last guy ;)
	    #

	    if( $index < 5) {
		
		#
		# space to print!
		#

		print $file sprintf("%s ",substr($hash{$name},$tempcount));
		$tempcount += 10;
	    }

	    print $file "\n";
	} # end of each sequence

	print $file "\n\n"; # added $file HL 08/08/2000; do we really need
                            # so many newlines?

	$count = $tempcount;
    }				
}

=head2 write_Pfam

 Title     : write_Pfam
 Usage     : $ali->write_Pfam(\*OUTPUT)
           :
           :
 Function  : writes a Pfam/Mul formatted
           : file
           :
           :
 Returns   :
 Argument  :

=cut

sub write_Pfam {
    my $self = shift;
    my $out  = shift;
    my ($namestr,$seq,$add);
    my ($maxn);

    $maxn = $self->maxdisplayname_length();

    foreach $seq ( $self->eachSeq() ) {
	$namestr = $self->get_displayname($seq->get_nse());
	$add = $maxn - length($namestr) + 2;
	$namestr .= " " x $add;
	print $out sprintf("%s  %s\n",$namestr,$seq->seq());
    }
}

=head2 write_selex

 Title     : write_selex
 Usage     : $ali->write_selex(\*OUTPUT)
           :
           :
 Function  : writes a selex (hmmer) formatted alignment
           :
 Returns   :
 Argument  : reference-to-glob to file or filehandle object

=cut

sub write_selex {
    my $self = shift;
    my $out  = shift;
    my $acc  = shift;
    my ($namestr,$seq,$add);
    my ($maxn);

    $maxn = $self->maxdisplayname_length();

    foreach $seq ( $self->eachSeq() ) {
	$namestr = $self->get_displayname($seq->get_nse());
	$add = $maxn - length($namestr) + 2;
	$namestr .= " " x $add;
	print $out sprintf("%s  %s\n",$namestr,$seq->seq());
    }
}

1;

