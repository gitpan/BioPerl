package Bio::Graphics::Glyph::transcript;
# $Id: transcript.pm,v 1.3.2.9 2002/05/04 20:29:59 lstein Exp $

use strict;
use Bio::Graphics::Glyph::segments;
use vars '@ISA';
@ISA = qw( Bio::Graphics::Glyph::segments);

sub pad_left  {
  my $self = shift;
  my $pad  = $self->SUPER::pad_left;
  return $pad if $self->{level} > 0;
  return $pad unless $self->feature->strand < 0;
  return $self->arrow_length > $pad ? $self->arrow_length : $pad;
}

sub pad_right {
  my $self = shift;
  my $pad  = $self->SUPER::pad_right;
  return $pad if $self->{level} > 0;
  return $pad unless $self->feature->strand > 0;
  return $self->arrow_length > $pad ? $self->arrow_length : $pad;
}

sub draw_component {
  my $self = shift;
  return unless $self->level > 0;
  $self->SUPER::draw_component(@_);
}

sub draw_connectors {
  my $self = shift;
  my $gd = shift;
  my ($left,$top) = @_;
  $self->SUPER::draw_connectors($gd,$left,$top);
  my @parts = $self->parts;

  # H'mmm.  No parts.  Must be in an intron, so draw intron
  # spanning entire range
  if (!@parts) {
    my($x1,$y1,$x2,$y2) = $self->bounds(0,0);
    $self->_connector($gd,$left,$top,$x1,$y1,$x1,$y2,$x2,$y1,$x2,$y2);
    @parts = $self;
  }

  if ($self->feature->strand >= 0) {
    my($x1,$y1,$x2,$y2) = $parts[-1]->bounds(@_);
    my $center = ($y2+$y1)/2;
    $self->arrow($gd,$x2,$x2+$self->arrow_length,$center);
  } else {
    my($x1,$y1,$x2,$y2) = $parts[0]->bounds(@_);
    my $center = ($y2+$y1)/2;
    $self->arrow($gd,$x1,$x1 - $self->arrow_length,$center);
  }
}

sub arrow_length {
  my $self = shift;
  return $self->option('arrow_length') || 8;
}

# override option() for force the "hat" type of connector
sub connector {
  my $self = shift;
  return $self->SUPER::connector(@_) if $self->all_callbacks;
  return 'hat';
}


1;

__END__

=head1 NAME

Bio::Graphics::Glyph::transcript - The "transcript" glyph

=head1 SYNOPSIS

  See L<Bio::Graphics::Panel> and L<Bio::Graphics::Glyph>.

=head1 DESCRIPTION

This glyph is used for drawing transcripts.  It is essentially a
"segments" glyph in which the connecting segments are hats.  The
direction of the transcript is indicated by an arrow attached to the
end of the glyph.

=head2 OPTIONS

The following options are standard among all Glyphs.  See
L<Bio::Graphics::Glyph> for a full explanation.

  Option      Description                      Default
  ------      -----------                      -------

  -fgcolor      Foreground color	       black

  -outlinecolor	Synonym for -fgcolor

  -bgcolor      Background color               turquoise

  -fillcolor    Synonym for -bgcolor

  -linewidth    Line width                     1

  -height       Height of glyph		       10

  -font         Glyph font		       gdSmallFont

  -connector    Connector type                 0 (false)

  -connector_color
                Connector color                black

  -label        Whether to draw a label	       0 (false)

  -description  Whether to draw a description  0 (false)

In addition, the alignment glyph recognizes the following
glyph-specific options:

  Option         Description                  Default
  ------         -----------                  -------

  -arrow_length  Length of the directional   8
                 arrow.

=head1 BUGS

Please report them.

=head1 SEE ALSO

L<Bio::Graphics::Panel>,
L<Bio::Graphics::Track>,
L<Bio::Graphics::Glyph::transcript2>,
L<Bio::Graphics::Glyph::anchored_arrow>,
L<Bio::Graphics::Glyph::arrow>,
L<Bio::Graphics::Glyph::box>,
L<Bio::Graphics::Glyph::primers>,
L<Bio::Graphics::Glyph::segments>,
L<Bio::Graphics::Glyph::toomany>,
L<Bio::Graphics::Glyph::transcript>,

=head1 AUTHOR

Lincoln Stein E<lt>lstein@cshl.orgE<gt>

Copyright (c) 2001 Cold Spring Harbor Laboratory

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  See DISCLAIMER.txt for
disclaimers of warranty.

=cut
