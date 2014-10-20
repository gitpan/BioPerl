# -*-Perl-*-
## Bioperl Test Harness Script for Modules
##
# CVS Version
# $Id: SeqFeature.t,v 1.17.2.1 2001/03/02 18:32:22 jason Exp $


# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.t'

use strict;

BEGIN { 
    # to handle systems with no installed Test module
    # we include the t dir (where a copy of Test.pm is located)
    # as a fallback
    eval { require Test; };
    if( $@ ) {
	use lib 't';
    }
    use Test;

    plan tests => 25;
}

use Bio::Seq;
use Bio::SeqFeature::Generic;
use Bio::SeqFeature::FeaturePair;
use Bio::SeqFeature::SimilarityPair;
use Bio::Tools::Blast;

ok(1);

# predeclare variables for strict
my ($feat,$str,$feat2,$pair,$comp_obj1,$comp_obj2,@sft); 


$feat = new Bio::SeqFeature::Generic ( -start => 40,
				       -end => 80,
				       -strand => 1,
				       -primary => 'exon',
				       -source  => 'internal',
				       -tag => {
					   silly => 20,
					   new => 1
					   }
				       );

ok $feat->start, 40;

ok $feat->end, 80;

ok $feat->primary_tag, 'exon';

ok $feat->source_tag, 'internal';

$str = $feat->gff_string() || ""; # placate -w

# we need to figure out the correct mapping of this stuff
# soon

#if( $str ne "SEQ\tinternal\texon\t40\t80\t1\t.\t." ) {
#    print "not ok 3\n";
#} else {
#    print "ok 3\n";
#}

ok(1);

$pair = new Bio::SeqFeature::FeaturePair();

ok defined $pair;

$feat2 = new Bio::SeqFeature::Generic ( -start => 400,
				       -end => 440,
				       -strand => 1,
				       -primary => 'other',
				       -source  => 'program_a',
				       -tag => {
					   silly => 20,
					   new => 1
					   }
				       );

ok defined $feat2;
$pair->feature1($feat);
$pair->feature2($feat2);

ok $pair->feature1, $feat;
ok $pair->feature2, $feat2;
ok $pair->start, 40;
ok $pair->end, 80;
ok $pair->primary_tag, 'exon';
ok $pair->source_tag, 'internal';
ok $pair->hstart, 400;
ok $pair->hend, 440;
ok $pair->hprimary_tag, 'other' ;
ok $pair->hsource_tag, 'program_a';

$pair->invert;
ok $pair->end, 440;

# Test attaching a SeqFeature::Generic to a Bio::Seq
{
    # Make the parent sequence object
    my $seq = Bio::Seq->new(
        '-seq'          => 'aaaaggggtttt',
        '-display_id'   => 'test',
        '-moltype'      => 'dna',
        );
    
    # Make a SeqFeature
    my $sf1 = Bio::SeqFeature::Generic->new(
        '-start'    => 4,
        '-end'      => 9,
        '-strand'   => 1,
        );
    
    # Add the SeqFeature to the parent
    ok ($seq->add_SeqFeature($sf1));
    
    # Test that it gives the correct sequence
    my $sf_seq1 = $sf1->seq->seq;
    ok $sf_seq1, 'aggggt';
    ok $sf1->end,9;
    ok $sf1->start,4;

    # Make a second seqfeature on the opposite strand
    my $sf2 = Bio::SeqFeature::Generic->new(
        '-start'    => 4,
        '-end'      => 9,
        '-strand'   => -1,
        );
    
    # This time add the PrimarySeq to the seqfeature
    # before adding it to the parent
    ok ($sf2->attach_seq($seq->primary_seq));
    $seq->add_SeqFeature($sf2);
    
    # Test again that we have the correct sequence
    my $sf_seq2 = $sf2->seq->seq;
    ok $sf_seq2, 'acccct';
}
