
#
# BioPerl module for Bio::SeqIO::FTHelper
#
# Cared for by Ewan Birney <birney@sanger.ac.uk>
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::FTHelper - Helper class for Embl/Genbank feature tables

=head1 SYNOPSIS

Used by Bio::SeqIO::EMBL to help process the Feature Table

=head1 DESCRIPTION

Represents one particular Feature with the following fields

      key - the key of the feature
      loc - the location string of the feature
      <other fields> - other fields

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this
and other Bioperl modules. Send your comments and suggestions preferably
 to one of the Bioperl mailing lists.
Your participation is much appreciated.

  vsns-bcd-perl@lists.uni-bielefeld.de          - General discussion
  vsns-bcd-perl-guts@lists.uni-bielefeld.de     - Technically-oriented discussion
  http://bio.perl.org/MailList.html             - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
 the bugs and their resolution.
 Bug reports can be submitted via email or the web:

  bioperl-bugs@bio.perl.org
  http://bio.perl.org/bioperl-bugs/

=head1 AUTHOR - Ewan Birney

Email birney@sanger.ac.uk

Describe contact details here

=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::SeqIO::FTHelper;
use vars qw(@ISA);
use strict;

# Object preamble - inheriets from Bio::Root::Object

use Bio::Root::Object;


@ISA = qw(Bio::Root::Object);
# new() is inherited from Bio::Root::Object

# _initialize is where the heavy stuff will happen when new is called

sub _initialize {
  my($self,@args) = @_;

  my $make = $self->SUPER::_initialize;
  $self->{'_field'} = {};
# set stuff in self from @args
  return $make; # success - we hope!
}

=head2 from_SeqFeature

 Title   : from_SeqFeature
 Usage   : @fthelperlist = Bio::SeqIO::FTHelper::from_SeqFeature($sf,$context_annseq);
 Function: constructor of fthelpers from SeqFeatures
         :
         : The additional annseq argument is to allow the building of FTHelper
         : lines relevant to particular sequences (ie, when features are spread over
         : enteries, knowing how to build this)
 Returns : an array of FThelpers
 Args    : seq features


=cut

=head2 _generic_seqfeature

 Title   : _generic_seqfeature
 Usage   : $fthelper->_generic_seqfeature($annseq)
 Function: processes fthelper into a generic seqfeature
 Returns : nothing (places a new seqfeature into annseq)
 Args    : Bio::Seq,Bio::SeqIO::FTHelper


=cut

sub _generic_seqfeature {
   my ($fth,$annseq) = @_;
   my ($sf);

  # print "Converting from", $fth->key, "\n";

   $sf = new Bio::SeqFeature::Generic;
   if( $fth->loc =~ /join/ ) {
       my $strand;
       if ( $fth->loc =~ /complement/ ) {
	   $strand = -1;
       } else {
	   $strand = 1;
       }

       $sf->strand($strand);
       $sf->primary_tag($fth->key . "_span");
       $sf->source_tag('EMBL_GenBank');
       $sf->has_tag("parent",1);
       $sf->_parse->{'parent_homogenous'} = 1;

       # we need to make sub features
       my $loc = $fth->loc;
       while( $loc =~ /\<?(\d+)\.\.\>?(\d+)/g ) {
	   my $start = $1;
	   my $end   = $2;
	   #print "Processing $start-$end\n";
	   my $sub = new Bio::SeqFeature::Generic;
	   $sub->primary_tag($fth->key);
	   $sub->start($start);
	   $sub->end($end);
	   $sub->strand($strand);
	   $sub->source_tag('EMBL_GenBank');
	   $sf->add_sub_SeqFeature($sub,'EXPAND');
       }

   } else {
       my $lst;
       my $len;

       if( $fth->loc =~ /^(\d+)$/ ) {
	   $lst = $len = $1;
       } else {
	   $fth->loc =~ /\<?(\d+)\.\.\>?(\d+)/ || do {
	       $annseq->throw("Weird location line [" . $fth->loc . "] in reading GenBank");
	       last;
	   };
	   $lst = $1;
	   $len = $2;
       }

       $sf->start($lst);
       $sf->end($len);
       $sf->source_tag('EMBL_GenBank');
       $sf->primary_tag($fth->key);
       if( $fth->loc =~ /complement/ ) {
	   $sf->strand(-1);
       } else {
	   $sf->strand(1);
       }
   }

   #print "Adding B4 ", $sf->primary_tag , "\n";

   foreach my $key ( keys %{$fth->field} ){
       foreach my $value ( @{$fth->field->{$key}} ) {
	   $sf->add_tag_value($key,$value);
       }
   }



   $annseq->add_SeqFeature($sf);
}

sub from_SeqFeature {
    my ($sf, $context_annseq) = @_;
    my @ret;
    my $key;

    #
    # If this object knows how to make FThelpers, then let it
    # - this allows us to store *really* weird objects that can write
    # themselves to the EMBL/GenBank...
    #

    if ($sf->can("to_FTHelper")) {
	return $sf->to_FTHelper($context_annseq);
    }

    # build something sensible...
    # if the parent homogenous flag is set, build things from the
    # sub level
    my $loc;
    my $ph_flag;
    if( $sf->can('_parse') ) {
	$ph_flag = $sf->_parse->{'parent_homogenous'} || 0;
    } else {
	$ph_flag = 0;
    }

    if( $ph_flag == 1 ) {
	$key = $sf->primary_tag();
	$key =~ s/_span//g;
	$loc = "join("; 
	my $touch = 0;
	foreach my $sub ( $sf->sub_SeqFeature() ) {
	    if( $touch == 1 ) {
		$loc .= ",";
	    } else {
		$touch = 1;
	    }

	    $loc .= $sub->start() . ".." . $sub->end();
	}
	$loc .= ")";
	if( $sf->strand == -1 ) {
	    $loc = "complement($loc)";
	} 
    } else {
	$loc = $sf->start() . ".." . $sf->end();
	$key = $sf->primary_tag();
        
	if( $sf->strand == -1 ) {
	    $loc = "complement($loc)";
	}
	# going into sub features
	foreach my $sub ( $sf->sub_SeqFeature() ) {
	    my @subfth = &Bio::SeqIO::FTHelper::from_SeqFeature($sub);
	    push(@ret,@subfth);
	}
    }

    my $fth = Bio::SeqIO::FTHelper->new();

    $fth->loc($loc);
    $fth->key($key);
    $fth->field->{'note'} = [];
    #$sf->source_tag && do { push(@{$fth->field->{'note'}},"source=" . $sf->source_tag ); };
    $sf->score && do { push(@{$fth->field->{'note'}},"score=" . $sf->score ); };
    $sf->frame && do { push(@{$fth->field->{'note'}},"frame=" . $sf->frame ); };
    #$sf->strand && do { push(@{$fth->field->{'note'}},"strand=" . $sf->strand ); };

    foreach my $tag ( $sf->all_tags ) {
	if( !defined $fth->field->{$tag} ) {
	    $fth->field->{$tag} = [];
	}
	foreach my $val ( $sf->each_tag_value($tag) ) {
	    push(@{$fth->field->{$tag}},$val);
	}
    }

    push(@ret,$fth);

    unless (@ret) {
	$context_annseq->throw("Problem in processing seqfeature $sf - no fthelpers. Error!");
    }
    foreach my $ft ( @ret ) {
	if( !$ft->isa('Bio::SeqIO::FTHelper') ) {
	    $sf->throw("Problem in processing seqfeature $sf - made a $fth!");
	}
    }

    return @ret;

}

=head2 key

 Title   : key
 Usage   : $obj->key($newval)
 Function: 
 Example : 
 Returns : value of key
 Args    : newvalue (optional)


=cut

sub key{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'key'} = $value;
    }
    return $obj->{'key'};

}

=head2 loc

 Title   : loc
 Usage   : $obj->loc($newval)
 Function: 
 Example : 
 Returns : value of loc
 Args    : newvalue (optional)


=cut

sub loc{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'loc'} = $value;
    }
    return $obj->{'loc'};

}


=head2 field

 Title   : field
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :


=cut

sub field{
   my ($self) = @_;

   return $self->{'_field'};
}

=head2 add_field

 Title   : add_field
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :


=cut

sub add_field{
   my ($self,$key,$val) = @_;

   if( !exists $self->field->{$key} ) {
       $self->field->{$key} = [];
   } 
   push( @{$self->field->{$key}} , $val);
   
}


