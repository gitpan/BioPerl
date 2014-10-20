# -*-Perl-*-
## Bioperl Test Harness Script for Modules
##
# CVS Version
# $Id: SimilarityPair.t,v 1.3 2001/02/26 20:45:37 lapp Exp $


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

    plan tests => 5;
}
use Bio::Seq;
use Bio::SeqFeature::SimilarityPair;
use Bio::Tools::Blast;
use Bio::SeqIO;
use Bio::Root::IO;

# test SimilarityPair

my $seq = (new Bio::SeqIO('-format' => 'fasta',
			  '-file' => Bio::Root::IO->catfile("t","AAC12660.fa")))->next_seq();
ok defined( $seq) && $seq->isa('Bio::SeqI');
my $blast = new Bio::Tools::Blast('-file'=>Bio::Root::IO->catfile("t","blast.report"), '-parse'=>1);
ok defined ($blast) && $blast->isa('Bio::Tools::Blast');
my $hit = $blast->hit;
ok defined ($hit) && $hit->isa('Bio::Tools::Blast::Sbjct'), 1, ' hit is ' . ref($hit);
my $sim_pair = Bio::SeqFeature::SimilarityPair->from_searchResult($hit);
ok defined($sim_pair) && $sim_pair->isa('Bio::SeqFeatureI');
$seq->add_SeqFeature($sim_pair);
ok $seq->all_SeqFeatures() == 1;
