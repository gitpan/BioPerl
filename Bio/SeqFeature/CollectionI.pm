# $Id$
#
# BioPerl module for Bio::SeqFeature::CollectionI
#
# Cared for by Jason Stajich <jason@bioperl.org>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqFeature::CollectionI - An interface for a collection of SeqFeatureI objects. 

=head1 SYNOPSIS


# get a Bio::SeqFeature::CollectionI somehow
# perhaps a Bio::SeqFeature::Collection


    use Bio::SeqFeature::Collection;
    my $collection = new Bio::SeqFeature::Collection;
    $collection->add_features(\@featurelist);


    $collection->features(-attributes => 
			  [ { 'location' => new Bio::Location::Simple
				  (-start=> 1, -end => 300) ,
				  'overlaps' }]);

=head1 DESCRIPTION

This interface describes the basic methods needed for a collection of Sequence Features.  

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to
the Bioperl mailing list.  Your participation is much appreciated.

  bioperl-l@bioperl.org              - General discussion
  http://bioperl.org/MailList.shtml  - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
of the bugs and their resolution. Bug reports can be submitted via
email or the web:

  bioperl-bugs@bioperl.org
  http://bugzilla.bioperl.org/

=head1 AUTHOR - Jason Stajich

Email jason@bioperl.org

Describe contact details here

=head1 CONTRIBUTORS

Additional contributors names and emails here

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::SeqFeature::CollectionI;
use vars qw(@ISA);
use strict;
use Carp;
use Bio::Root::RootI;

@ISA = qw( Bio::Root::RootI );


=head2 add_features

 Title   : add_features
 Usage   : $collection->add_features(\@features);
 Function:
 Returns : number of features added
 Args    : arrayref of Bio::SeqFeatureI objects to index

=cut

sub add_features{
    shift->throw_not_implemented();
}


=head2 features

 Title   : features
 Usage   : my @f = $collection->features(@args);
 Returns : a list of Bio::SeqFeatureI objects
 Args    : see below
 Status  : public

This routine will retrieve features associated with this collection
object.  It can be used to return all features, or a subset based on
their type, location, or attributes.

  -types     List of feature types to return.  Argument is an array
             of Bio::Das::FeatureTypeI objects or a set of strings
             that can be converted into FeatureTypeI objects.

  -callback   A callback to invoke on each feature.  The subroutine
              will be passed to each Bio::SeqFeatureI object in turn.

  -attributes A hash reference containing attributes to match.

The -attributes argument is a hashref containing one or more attributes
to match against:

  -attributes => { Gene => 'abc-1',
                   Note => 'confirmed' }

Attribute matching is simple exact string matching, and multiple
attributes are ANDed together.  See L<Bio::DB::ConstraintsI> for a
more sophisticated take on this.

If one provides a callback, it will be invoked on each feature in
turn.  If the callback returns a false value, iteration will be
interrupted.  When a callback is provided, the method returns undef.

=cut

sub features{
    shift->throw_not_implemented();
}

1;
