## $Id: pSW.pm,v 1.1.1.1.2.1 1999/01/29 16:34:42 birney Exp $

#
# BioPerl module for Bio::Tools::pSW
#
# Cared for by Ewan Birney <birney@sanger.ac.uk>
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Tools::pSW - DESCRIPTION of Object

=head1 SYNOPSIS

    $factory = new Bio::Tools::pSW( '-matrix' => 'blosum62.bla',
				    '-gap' => 12,
				    '-ext' => 2,
				   );

    #use the factory to make some output

    $factory->align_and_show($seq1,$seq2,STDOUT);

    # make a Bio::SimpleAlign and do something with it

    $aln = $factory->pairwise_alignment($seq1,$seq2);

    $aln->write_MSF(\*STDOUT);

=head1 INSTALLATION

This module is included with the central Bioperl distribution:

   http://bio.perl.org/Core/Latest
   ftp://bio.perl.org/pub/DIST

Follow the installation instructions included in the README file.

=head1 DESCRIPTION

pSW is an Alignment Factory. It builds pairwise alignments using the smith
waterman algorithm. The alignment algorithm is implemented in C and
added in using an XS extension. The XS extension basically comes from the
Wise2 package, but has been slimmed down to only be the alignment part
of that (this is a good thing!). The XS extension comes from the bp_sw
package which is found in Bio/Compile/SW in the bioperl distriubition.
I<Warning> This package will not work if you have not compiled the 
Bio/Compile/SW package.

The mixture of C and Perl is ideal for this sort of 
problem. Here are some plus points for this strategy: 

=over

=item Speed and Memory 

The algorithm is actually implemented in C, which means it is faster than
a pure perl implementation (I have never done one, so I have no idea
how faster) and will use considerably less memory, as it efficiently
assigns memory for the calculation.

=item Algorithm efficiency

The algorithm was written using Dynamite, and so contains an automatic
switch to the linear space divide and conquor method. This means you
could effectively align very large sequences without killing your machine
(it could take a while though!).

=back

=head1 IN_DEVELOPMENT

warning - this module is under active development. Eventually it should
contain the ability to make alignment objects such as Bio::SimpleAlign
or Bio::UnivAlign 

=head1 FEEDBACK

=head2 Mailing Lists 

User feedback is an integral part of the evolution of this and other Bioperl modules.
Send your comments and suggestions preferably to one of the Bioperl mailing lists.
Your participation is much appreciated.

    vsns-bcd-perl@lists.uni-bielefeld.de          - General discussion
    vsns-bcd-perl-guts@lists.uni-bielefeld.de     - Technically-oriented discussion
    http://bio.perl.org/MailList.html             - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track the bugs and 
their resolution. Bug reports can be submitted via email or the web:

    bioperl-bugs@bio.perl.org                   
    http://bio.perl.org/bioperl-bugs/           

=head1 AUTHOR

Ewan Birney, birney@sanger.ac.uk

=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal methods are usually preceded with an underscore "_".

=cut


# Let the code begin...


package Bio::Tools::pSW;
use vars qw($AUTOLOAD @ISA);
use strict;
no strict ( 'refs');

use Bio::Tools::AlignFactory;
use Bio::SimpleAlign;


@ISA = qw(Bio::Tools::AlignFactory Exporter);

BEGIN {
    eval {
	require bp_sw;
    };
    if ( $@ ) {
	print STDERR ("\nThe C-compiled engine for Smith Waterman alignments (bp_sw) has not been installed.\n Please read the installation instructions for bioperl for using the compiled extensions\n\n");
	exit(1);
    }
}


# new() is inherited from Bio::Root::Object

# _initialize is where the heavy stuff will happen when new is called

sub _initialize {
  my($self,@p) = @_;



  my($matrix,$gap,$ext) = $self->_rearrange([qw(MATRIX
						GAP
						EXT
						)],@p);
  
  my $make = $self->SUPER::_initialize(@p);

  #default values - we have to load matrix into memory, so 
  # we need to check it out now
  if( ! defined $matrix || !($matrix =~ /\w/) ) {
      $matrix = 'blosum62.bla';
  }

  $self->matrix($matrix); # will throw exception if it can't load it
  $self->gap(12);
  $self->ext(2);

  #I'm pretty sure I am not doing this right... ho hum...

  if( $gap =~ /\S/ ) {
      $gap =~ /^\d+$/ || $self->throw("Gap penalty must be a number, not [$gap]");
      $self->gap($gap);
  }

  if( $ext =~ /\S/ ) {
      $ext =~ /^\d+$/ || $self->throw("Extension penalty must be a number, not [$ext]");
      $self->gap($gap);
  }

  return $make; # success - we hope!
}


=head2 pairwise_alignment

 Title   : pairwise_alignment
 Usage   : $aln = $factory->pairwise_alignment($seq1,$seq2)
 Function: Makes a SimpleAlign object from two sequences
 Returns : A SimpleAlign object
 Args    :


=cut

sub pairwise_alignment{
    my ($self,$seq1,$seq2) = @_;
    my($t1,$t2,$aln,$out,@str1,@str2,@ostr1,@ostr2,$alc,$tstr,$tid,$start1,$end1,$start2,$end2,$alctemp);

    $self->set_memory_and_report();
    # create engine objects 

    $t1  = &bp_sw::new_Sequence_from_strings($seq1->id(),$seq1->str());
    $t2  = &bp_sw::new_Sequence_from_strings($seq2->id(),$seq2->str());
    $aln = &bp_sw::Align_Sequences_ProteinSmithWaterman($t1,$t2,$self->{'matrix'},-$self->gap,-$self->ext);
    if( ! defined $aln || $aln == 0 ) {
	$self->throw("Unable to build an alignment");
    }


    # free sequence engine objects

    $t1 = $t2 = 0;

    # now we have to get into the AlnBlock structure and
    # figure out what is aligned to what...

    # we are going to need the sequences as arrays for convience

    @str1 = $seq1->seq();
    @str2 = $seq2->seq();

    # get out start points

    # The alignment is in alignment coordinates - ie the first
    # residues starts at -1 and ends at 0. (weird I know).
    # bio-coordinates are +2 from this...

    $start1 = $aln->start()->alu(0)->start +2;
    $start2 = $aln->start()->alu(1)->start +2;

    # step along the linked list of alc units...

    for($alc = $aln->start();$alc->at_end() != 1;$alc = $alc->next()) {
	if( $alc->alu(0)->text_label eq 'SEQUENCE' ) {
	    push(@ostr1,$str1[$alc->alu(0)->start+1]);
	} else {
	    # assumme it is in insert!
	    push(@ostr1,'-');
	}

	if( $alc->alu(1)->text_label eq 'SEQUENCE' ) {
	    push(@ostr2,$str2[$alc->alu(1)->start+1]);
	} else {
	    # assumme it is in insert!
	    push(@ostr2,'-');
	}
	$alctemp = $alc;
    }

    #
    # get out end points
    #

    # end points = real residue end in 'C' coordinates = residue
    # end in biocoordinates. Oh... the wonder of coordinate systems!

    $end1 = $alctemp->alu(0)->end;
    $end2 = $alctemp->alu(1)->end;

    # get rid of the alnblock 
    $alc = 0;
    $aln = 0;

    # new SimpleAlignment
    $out = Bio::SimpleAlign->new(); # new SimpleAlignment

    $tstr = join('',@ostr1);
    $tid = $seq1->id();
    $out->addSeq(Bio::Seq->new( -seq=> $tstr,
			       -start => $start1,
			       -end   => $end1,
			       -id=>$tid ));

    $tstr = join('',@ostr2);
    $tid = $seq2->id();
    $out->addSeq(Bio::Seq->new( -seq=> $tstr,
			       -start => $start2,
			       -end => $end2,
			       -id=> $tid ));

    # give'm back the alignment

    return $out;
}

=head2 align_and_show
 
 Title   : align_and_show
 Usage   : $factory->align_and_show($seq1,$seq2,STDOUT)

=cut

sub align_and_show {
    my($self,$seq1,$seq2,$fh) = @_;
    my($t1,$t2,$aln,$id,$str);

    $self->set_memory_and_report();

    $t1  = &bp_sw::new_Sequence_from_strings($seq1->id(),$seq1->str());

    $t2  = &bp_sw::new_Sequence_from_strings($seq2->id(),$seq2->str());
    $aln = &bp_sw::Align_Sequences_ProteinSmithWaterman($t1,$t2,$self->{'matrix'},-$self->gap,-$self->ext);
    if( ! defined $aln || $aln == 0 ) {
	$self->throw("Unable to build an alignment");
    }

    &bp_sw::write_pretty_seq_align($aln,$t1,$t2,12,50,$fh);

}

=head2 matrix

 Title     : matrix()
 Usage     : $factory->matrix('blosum62.bla');
 Function  : Reads in comparison matrix based on name
           :
 Returns   : 
 Argument  : comparison matrix

=cut

sub matrix {
    my($self,$comp) = @_;
    my $temp;

    if( !defined $comp ) {
	$self->throw("You must have a comparison matrix to set!");
    }

    # talking to the engine here...

    $temp = &bp_sw::CompMat::read_Blast_file_CompMat($comp);

    if( !(defined $temp) || $temp == 0 ) {
	$self->throw("$comp cannot be read as a BLAST comparison matrix file");
    }

    $self->{'matrix'} = $temp;
}



=head2 gap

 Title     : gap
 Usage     : $gap = $factory->gap() #get
           : $factory->gap($value) #set
 Function  : the set get for the gap penalty
 Example   :
 Returns   : gap value 
 Arguments : new value

=cut

sub gap {
    my ($self,$val) = @_;
    

    if( defined $val ) {
	if( $val <= 0 ) {
	    $self->throw("Can't have a gap penalty less than 0");
	}
	$self->{'gap'} = $val;
    }
    return $self->{'gap'};
}


=head2 ext

 Title     : ext
 Usage     : $ext = $factory->ext() #get
           : $factory->ext($value) #set
 Function  : the set get for the ext penalty
 Example   :
 Returns   : ext value 
 Arguments : new value

=cut

sub ext {
    my ($self,$val) = @_;
    
    if( defined $val ) {
	if( $val <= 0 ) {
	    $self->throw("Can't have a gap penalty less than 0");
	}
	$self->{'ext'} = $val;
    }
    return $self->{'ext'};
}

    
