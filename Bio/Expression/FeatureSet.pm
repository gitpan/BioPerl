# $Id: FeatureSet.pm,v 1.8 2002/12/12 00:20:34 allenday Exp $
# BioPerl module for Bio::Expression::FeatureSet
#
# Copyright Allen Day <allenday@ucla.edu>, Stanley Nelson <snelson@ucla.edu>
# Human Genetics, UCLA Medical School, University of California, Los Angeles

# POD documentation - main docs before the code

=head1 NAME

Bio::Expression::FeatureSet - a set of DNA/RNA features.  ISA
Bio::Expression::FeatureI

=head1 SYNOPSIS

#

=head1 DESCRIPTION

A set of DNA/RNA features.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to one
of the Bioperl mailing lists.  Your participation is much appreciated.

  bioperl-l@bioperl.org            - General discussion
  http://bioperl.org/MailList.shtml - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
 the bugs and their resolution.
 Bug reports can be submitted via email or the web:

  bioperl-bugs@bio.perl.org
  http://bugzilla.bioperl.org/

=head1 AUTHOR

Allen Day E<lt>allenday@ucla.eduE<gt>

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...
package Bio::Expression::FeatureSet;

use strict;

use base qw(Bio::Root::Root Bio::Expression::FeatureI);
use vars qw($DEBUG);

=head2 new

 Title   : new
 Usage   : $featureset = Bio::Expression::FeatureSet->new(%args);
 Function: create a new featureset object
 Returns : a Bio::Expression::FeatureSet object
 Args    : an optional hash of parameters to be used in initialization:
           -id    --  the featureset ID
           -type  --  the featureset type

=cut

sub new {
  my($class,@args) = @_;
  my $self = bless {}, $class;
  $self->_initialize(@args);
  return $self;
}

=head2 _initialize

 Title   : _initialize
 Usage   : $featureset->_initialize(@args);
 Function: initialize the featureset object
 Returns : nothing
 Args    : @args

=cut

sub _initialize{
  my ($self,@args) = @_;
  my %param = @args;

  $self->type($param{-type});
  $self->id($param{-id}    );

  $self->SUPER::_initialize(@args);
  $DEBUG = 1 if( ! defined $DEBUG && $self->verbose > 0);
}

=head2 type

 Title   : type
 Usage   : $featureset->type($optional_arg);
 Function: get/set the type of the featureset
 Comments: this is probably going to be a string like
           "quality control", "mismatch blah blah", etc.
 Returns : the featureset type
 Args    : a new value for the featureset type

=cut

sub type {
  my $self = shift;
  $self->{type} = shift if @_;
  return $self->{type};
}

=head2 id

 Title   : id
 Usage   : $featureset->id($optional_arg);
 Function: get/set the id of the featureset
 Returns : the featureset id
 Args    : a new value for the featureset id

=cut

sub id {
  my $self = shift;
  $self->{id} = shift if @_;
  return $self->{id};
}


=head2 standard_deviation

 Title   : standard_deviation
 Usage   : $featureset->standard_deviation($optional_arg);
 Function: get/set the standard deviation of the featureset value
 Returns : the featureset standard deviation
 Args    : a new value for the featureset standard deviation
 Notes   : this method does no calculation, it merely holds a value

=cut

sub standard_deviation {
  my $self = shift;
  $self->{standard_deviation} = shift if @_;
  return $self->{standard_deviation};
}

=head2 quantitation

 Title   : quantitation
 Usage   : $featureset->quantitation($optional_arg);
 Function: get/set the quantitation of the featureset
 Returns : the featureset's quantitated value
 Args    : a new value for the featureset's quantitated value
 Notes   : this method does no calculation, it merely holds a value

=cut

sub quantitation {
  my $self = shift;
  $self->{quantitation} = shift if @_;
  return $self->{quantitation};
}

=head2 quantitation_units

 Title   : quantitation_units
 Usage   : $featureset->quantitation_units($optional_arg);
 Function: get/set the quantitation units of the featureset
 Returns : the featureset's quantitated value units
 Args    : a new value for the featureset's quantitated value units

=cut

sub quantitation_units {
  my $self = shift;
  $self->{quantitation_units} = shift if @_;
  return $self->{quantitation_units};
}

=head2 presence

 Title   : presence
 Usage   : $featureset->presence($optional_arg);
 Function: get/set the presence call of the featureset
 Returns : the featureset's presence call
 Args    : a new value for the featureset's presence call

=cut

sub presence {
  my $self = shift;
  $self->{presence} = shift if @_;
  return $self->{presence};
}

=head2 add_feature

 Title   : add_feature
 Usage   : $feature_copy = $featureset->add_feature($feature);
 Function: add a feature to the featureset
 Returns : see this_feature()
 Args    : a Bio::Expression::FeatureI compliant object

=cut

sub add_feature {
  my($self,@args) = @_;
  foreach my $feature (@args){
	$self->throw('Features must be Bio::Expression::FeatureI compliant') unless $feature->isa('Bio::Expression::FeatureI');
    push @{$self->{features}}, $feature;
  }

  return $self->{features} ? $self->{features}->[-1] : undef;
}

=head2 this_feature

 Title   : this_feature
 Usage   : $feature = $featureset->this_feature
 Function: access the last feature added to the featureset
 Returns : the last feature added to the featureset
 Args    : none

=cut

sub this_feature {
  my $self = shift;
  return $self->{features} ? $self->{features}->[-1] : undef;
}

=head2 each_feature

 Title   : each_feature
 Usage   : @features = $featureset->each_feature
 Function: returns a list of Bio::Expression::FeatureI compliant
           objects
 Returns : a list of objects
 Args    : none

=cut

sub each_feature {
  my $self = shift;
  return @{$self->{features}};
}

=head2 each_feature_quantitation

 Title   : each_feature_quantitation
 Usage   : @featurequantitions = $featureset->each_feature_quantitation;
 Function: returns an list of quantitations of the features in the featureset
 Returns : a list of numeric values
 Args    : none

=cut

sub each_feature_quantitation {
  my $self = shift;
  my @values = ();
  push @values, $_->value foreach $self->each_feature;
  return @values;
}

=head2 is_qc

 Title   : is_qc
 Usage   : $is_quality_control = $featureset->is_qc
 Function: get/set whether or not the featureset is used for quality control purposes
 Returns : a boolean (equivalent)
 Args    : a new value

=cut

sub is_qc {
  my $self = shift;
  $self->{is_qc} = shift if defined @_;
  return $self->{is_qc};
}

1;
