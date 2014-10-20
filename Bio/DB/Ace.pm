
#
# BioPerl module for Bio::DB::Ace
#
# Cared for by Ewan Birney <birney@sanger.ac.uk>
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::DB::Ace - Database object interface to ACeDB servers

=head1 SYNOPSIS

    $db = Bio::DB::Ace->new( -server => 'myace.server.com', port => '120000');

    $seq = $db->get_Seq_by_id('MUSIGHBA1'); # Unique ID

    # or ...

    $seq = $db->get_Seq_by_acc('J00522'); # Accession Number

=head1 DESCRIPTION

This provides a standard BioPerl database access to Ace, using Lincoln Steins
excellent AcePerl module. You need to download and install the aceperl module from

  http://stein.cshl.org/AcePerl/

before this interface will work.

This interface is designed at the moment to work through a aceclient/aceserver
type mechanism

=head1 INSTALLING ACEPERL

Download the latest aceperl tar file, gunzip/untar and cd into the directory.
This is a standard CPAN-style directory, so if you go

  Perl Makefile.PL
  make
  <become root>
  make install

Then you will have installed Aceperl. Use the PREFIX mechanism to install elsewhere.

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

package Bio::DB::Ace;
use vars qw($AUTOLOAD @ISA @EXPORT_OK);
use strict;

# Object preamble - inherits from Bio::DB::Abstract

use Bio::DB::BioSeqI;
use Bio::Seq;

BEGIN { 
  eval {
    require Ace;
  };
  if( $@) {
    print STDERR "You have not installed Ace.pm.\n Read the docs in Bio::DB::Ace for more information about how to do this.\n It is very easy\n\nError message $@";
  }
}


@ISA = qw(Bio::DB::BioSeqI Bio::Root::Object Exporter);
@EXPORT_OK = qw();

# new() is inherited from Bio::DB::Abstract

# _initialize is where the heavy stuff will happen when new is called

sub _initialize {
  my($self,@args) = @_;
  my $make = $self->SUPER::_initialize;
  my ($host,$port) = $self->_rearrange([qw(
					 HOST
					 PORT
					 )],
				     @args,
				     );

  if( !$host || !$port ) {
    $self->throw("Must have a host and port for an acedb server to work");
  }

  my $aceobj = Ace->connect(-host => $host,
			    -port => $port) ||
			      $self->throw("Could not make acedb object to $host:$port");

  $self->_aceobj($aceobj);


  return $make; # success - we hope!
}

=head2 get_Seq_by_id

 Title   : get_Seq_by_id
 Usage   : $seq = $db->get_Seq_by_id($uid);
 Function: Gets a Bio::Seq object by its unique identifier/name
 Returns : a Bio::Seq object
 Args    : $id : the id (as a string) of the desired sequence entry

=cut

sub get_Seq_by_id {
  my $self = shift;
  my $id = shift or $self->throw("Must supply an identifier!\n");
  my $ace = $self->_aceobj();
  my ($seq,$dna,$out);

  $seq = $ace->fetch( 'Sequence' , $id);

  # get out the sequence somehow!

  $dna = $seq->asDNA();
  
  $dna =~ s/^>.*\n//;
  $dna =~ s/\n//g;

  $out = Bio::Seq->new( -id => $id, -type => 'Dna', -seq => $dna, -name => "Sequence from Bio::DB::Ace $id");
  return $out;

}

=head2 get_Seq_by_acc

  Title   : get_Seq_by_acc
  Usage   : $seq = $db->get_Seq_by_acc($acc);
  Function: Gets a Bio::Seq object by its accession number
  Returns : a Bio::Seq object
  Args    : $acc : the accession number of the desired sequence entry


=cut

sub get_Seq_by_acc {

  my $self = shift;
  my $acc = shift or $self->throw("Must supply an accesion number!\n");
  
  return $self->get_Seq_by_id($acc);
}

=head2 _aceobj

  Title   : _aceobj
  Usage   : $ace = $db->_aceobj();
  Function: Get/Set on the acedb object 
  Returns : Ace object
  Args    : New value of the ace object

=cut
  
sub _aceobj {
  my ($self,$arg) = @_;

  if( $arg ) {
    $self->{'_aceobj'} = $arg;
  } 

  return $self->{'_aceobj'};
}

1;
