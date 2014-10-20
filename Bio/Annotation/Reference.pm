
#
# BioPerl module for Bio::Annotation::Reference
#
# Cared for by Ewan Birney <pfam@sanger.ac.uk>
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Annotation::Reference - Specialised DBLink object for Literature References

=head1 SYNOPSIS

    $reg = Bio::Annotation::Reference->new( -title => 'title line',
					    -location => 'location line',
					    -authors => 'author line',
					    -medline => 998122 );

=head1 DESCRIPTION

Object which presents a literature reference. This is considered to be
a specialised form of database link. The additional methods provided
are all set/get methods to store strings commonly associated with
references, in particular title, location (ie, journal page) and
authors line.

There is no attempt to do anything more than store these things as
strings for processing elsewhere. This is mainly because parsing these
things suck and generally are specific to the specific format one is
using. To provide an easy route to go format --E<gt> object --E<gt> format
without losing data, we keep them as strings. Feel free to post the
list for a better solution, but in general this gets very messy very
fast...

=head1 CONTACT

Describe contact details here

=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...

package Bio::Annotation::Reference;
use vars qw(@ISA);
use strict;

use Bio::Annotation::DBLink;

@ISA = qw(Bio::Annotation::DBLink);

=head2 new

 Title   : new
 Usage   : $ref = Bio::Annotation::Reference->new( -title => 'title line',
						   -authors => 'author line',
						   -location => 'location line',
						   -medline => 9988812);
 Function:
 Example :
 Returns : a new Bio::Annotation::Reference object
 Args    : a hash with optional title, authors, location, medline, start and end
           attributes


=cut

sub new{
    my ($class,@args) = @_;

    my $self = $class->SUPER::new(@args);

    my ($start,$end,$authors,
	$location,$title,$medline) = $self->_rearrange([qw(START
							   END
							   AUTHORS
							   LOCATION
							   TITLE
							   MEDLINE
							   )],@args);

    defined $start    && $self->start($start);
    defined $end      && $self->end($end);
    defined $authors  && $self->authors($authors);
    defined $location && $self->location($location);
    defined $title    && $self->title($title);
    defined $medline  && $self->medline($medline);

    return $self;
}

=head2 start

 Title   : start
 Usage   : $self->start($newval)
 Function: Gives the reference start base
 Example : 
 Returns : value of start
 Args    : newvalue (optional)


=cut

sub start {
    my ($self,$value) = @_;
    if( defined $value) {
	$self->{'start'} = $value;
    }
    return $self->{'start'};

}
=head2 end

 Title   : end
 Usage   : $self->end($newval)
 Function: Gives the reference end base
 Example : 
 Returns : value of end
 Args    : newvalue (optional)


=cut

sub end {
    my ($self,$value) = @_;
    if( defined $value) {
	$self->{'end'} = $value;
    }
    return $self->{'end'};
}

=head2 rp

 Title   : rp
 Usage   : $self->rp($newval)
 Function: Gives the RP line. No attempt is made to parse this line.
 Example : 
 Returns : value of rp
 Args    : newvalue (optional)


=cut

sub rp{
   my ($self,$value) = @_;
   if( defined $value) {
      $self->{'rp'} = $value;
    }
    return $self->{'rp'};

}

=head2 authors

 Title   : authors
 Usage   : $self->authors($newval)
 Function: Gives the author line. No attempt is made to parse the author line
 Example : 
 Returns : value of authors
 Args    : newvalue (optional)


=cut

sub authors{
   my ($self,$value) = @_;
   if( defined $value) {
      $self->{'authors'} = $value;
    }
    return $self->{'authors'};

}

=head2 location

 Title   : location
 Usage   : $self->location($newval)
 Function: Gives the location line. No attempt is made to parse the location line
 Example : 
 Returns : value of location
 Args    : newvalue (optional)


=cut

sub location{
   my ($self,$value) = @_;
   if( defined $value) {
      $self->{'location'} = $value;
    }
    return $self->{'location'};

}

=head2 title

 Title   : title
 Usage   : $self->title($newval)
 Function: Gives the title line (if exists)
 Example : 
 Returns : value of title
 Args    : newvalue (optional)


=cut

sub title{
   my ($self,$value) = @_;
   if( defined $value) {
      $self->{'title'} = $value;
    }
    return $self->{'title'};

}

=head2 medline

 Title   : medline
 Usage   : $self->medline($newval)
 Function: Gives the medline number
 Example : 
 Returns : value of medline
 Args    : newvalue (optional)


=cut

sub medline{
    my ($self,$value) = @_;
    if( defined $value) {
	$self->{'medline'} = $value;
    }
    return $self->{'medline'};
}

=head2 pubmed

 Title   : pubmed
 Usage   : $refobj->pubmed($newval)
 Function: Get/Set the PubMed number, if it is different from the MedLine
           number.
 Example : 
 Returns : value of medline
 Args    : newvalue (optional)


=cut

sub pubmed {
    my ($self,$value) = @_;
    if( defined $value) {
	$self->{'pubmed'} = $value;
    }
    return $self->{'pubmed'};
}

=head2 database

 Title   : database
 Usage   :
 Function: Overrides DBLink database to be hard coded to 'MEDLINE', unless
           the database has been set explicitely before.
 Example :
 Returns : 
 Args    :


=cut

sub database{
   my ($self, @args) = @_;

   return $self->SUPER::database(@args) || 'MEDLINE';
}

=head2 primary_id

 Title   : primary_id
 Usage   :
 Function: Overrides DBLink primary_id to provide medline number
 Example :
 Returns : 
 Args    :


=cut

sub primary_id{
   my ($self, @args) = @_;

   return $self->medline(@args);
}

=head2 optional_id

 Title   : optional_id
 Usage   :
 Function: Overrides DBLink optional_id to provide the PubMed number.
 Example :
 Returns : 
 Args    :


=cut

sub optional_id{
   my ($self, @args) = @_;

   return $self->pubmed(@args);
}


1;


