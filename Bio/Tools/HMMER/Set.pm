
#
# BioPerl module for Bio::Tools::HMMER::Set
#
# Cared for by Ewan Birney <birney@sanger.ac.uk>
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Tools::HMMER::Set - Set of identical domains from HMMER matches


=head1 SYNOPSIS

   
    # get a Set object probably from the results object
    print "Bits score over set ",$set->bits," evalue ",$set->evalue,"\n";

    foreach $domain ( $set->each_Domain ) {
	print "Domain start ",$domain->start," end ",$domain->end,"\n";
    }

=head1 DESCRIPTION

Represents a set of HMMER domains hitting one sequence. HMMER reports two
different scores, a per sequence total score (and evalue) and a per
domain score and evalue. This object represents a collection of the same
domain with the sequence bits score and evalue. (these attributes are also
on the per domain scores, which you can get there).

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

=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::Tools::HMMER::Set;
use vars qw(@ISA);
use strict;

# Object preamble - inherits from Bio::Root::Object

use Bio::Root::Object;
use Bio::Tools::HMMER::Domain;

#
# Place functions/variables you want to *export*, ie be visible from the caller package into @EXPORT_OK
#

#
# @ISA has our inheritance.
#

@ISA = ( 'Bio::Root::Object' );

sub _initialize {
    my($self,@args) = @_;
    my $make = $self->SUPER::_initialize(@args);
    $self->{'domains'} = [];
    return $make;
}

=head2 add_Domain

 Title   : add_Domain
 Usage   : $set->add_Domain($domain)
 Function: adds the domain to the list
 Returns : nothing
 Args    : A Bio::Tools::HMMER::Domain object


=cut

sub add_Domain{
   my ($self,$domain) = @_;


   if( ! defined $domain || ! $domain->isa("Bio::Tools::HMMER::Domain") ) {
       $self->throw("[$domain] is not a Bio::Tools::HMMER::Domain. aborting");
   }

   push(@{$self->{'domains'}},$domain);

}

=head2 each_Domain

 Title   : each_Domain
 Usage   : foreach $domain ( $set->each_Domain() ) 
 Function: returns an array of domain objects in this set
 Returns : array
 Args    : none


=cut

sub each_Domain{
   my ($self,@args) = @_;

   return @{$self->{'domains'}};
}

=head2 name

 Title   : name
 Usage   : $obj->name($newval)
 Function: 
 Example : 
 Returns : value of name
 Args    : newvalue (optional)


=cut

sub name{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'name'} = $value;
    }
    return $obj->{'name'};

}
=head2 bits

 Title   : bits
 Usage   : $obj->bits($newval)
 Function: 
 Example : 
 Returns : value of bits
 Args    : newvalue (optional)


=cut

sub bits{
   my ($obj,$value) = @_;

   if( defined $value) {
      $obj->{'bits'} = $value;
    }
    return $obj->{'bits'};

}

=head2 evalue

 Title   : evalue
 Usage   : $obj->evalue($newval)
 Function: 
 Example : 
 Returns : value of evalue
 Args    : newvalue (optional)


=cut

sub evalue{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'evalue'} = $value;
    }
    return $obj->{'evalue'};

}


sub addHMMUnit {
    my $self = shift;
    my $unit = shift;

    $self->warn("Using old addHMMUnit call on Bio::Tools::HMMER::Set. Should replace with add_Domain");
    return $self->add_Domain($unit);
}

sub eachHMMUnit {
    my $self = shift;
    $self->warn("Using old eachHMMUnit call on Bio::Tools::HMMER::Set. Should replace with each_Domain");
    return $self->each_Domain();
}




1;  # says use was ok
__END__

