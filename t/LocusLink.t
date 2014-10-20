# -*-Perl-*- mode (to keep my emacs happy)
# $Id: LocusLink.t,v 1.8 2006/06/08 02:11:12 bosborne Exp $

use strict;
use vars qw($DEBUG $NUMTESTS $HAVEGRAPHDIRECTED);
$DEBUG = $ENV{'BIOPERLDEBUG'} || 0;

BEGIN {
	eval { require Test; };
	if( $@ ) {
		use lib 't';
	}
	use Test;
	eval {
		require Graph::Directed; 
		$HAVEGRAPHDIRECTED=1;
	};
	if ($@) {
		$HAVEGRAPHDIRECTED = 0;
		warn "Graph::Directed not installed, skipping tests\n";
	}
	plan tests => ($NUMTESTS = 23);
}

END {
	foreach ( $Test::ntest..$NUMTESTS) {
		skip('Cannot complete LocusLink tests, skipping',1);
	}
	unlink("locuslink-test.out.embl") if -e "locuslink-test.out.embl";
}

exit(0) unless $HAVEGRAPHDIRECTED;

use Bio::SeqIO;
use Bio::Root::IO;
use Bio::SeqFeature::Generic;
use Bio::SeqFeature::AnnotationAdaptor;

ok(1);

my $seqin = Bio::SeqIO->new(-file => Bio::Root::IO->catfile("t","data",
							 "LL-sample.seq"),
			    -format => 'locuslink');
ok $seqin;
my $seqout = Bio::SeqIO->new(-file => ">locuslink-test.out.embl",
			     -format => 'embl');

# process and write to output
my @seqs = ();

while(my $seq = $seqin->next_seq()) {
    push(@seqs, $seq);
    
    # create an artificial feature to stick the annotation on
    my $fea = Bio::SeqFeature::Generic->new(-start => 1, -end => 9999,
					    -strand => 1,
					    -primary => 'annotation');
    my $ac = Bio::SeqFeature::AnnotationAdaptor->new(-feature => $fea);
    foreach my $k ($seq->annotation->get_all_annotation_keys()) {
	foreach my $ann ($seq->annotation->get_Annotations($k)) {
	    next unless $ann->isa("Bio::Annotation::SimpleValue");
	    $ac->add_Annotation($ann);
	}
    }
    $seq->add_SeqFeature($fea);
    $seqout->write_seq($seq);
}

ok (scalar(@seqs), 2);

ok ($seqs[0]->desc,
    "amiloride binding protein 1 (amine oxidase (copper-containing))");
ok ($seqs[0]->accession, "26");
ok ($seqs[0]->display_id, "ABP1");
ok ($seqs[0]->species->binomial, "Homo sapiens");


my @dblinks = $seqs[0]->annotation->get_Annotations('dblink');
my %counts = map { ($_->database(),0) } @dblinks;
foreach (@dblinks) { $counts{$_->database()}++; }

ok ($counts{GenBank}, 11);
ok ($counts{RefSeq}, 4);
ok ($counts{UniGene}, 1);
ok ($counts{Pfam}, 1);
ok ($counts{STS}, 2);
ok ($counts{MIM}, 1);
ok ($counts{PUBMED}, 6);
ok (scalar(@dblinks), 27);

ok ($seqs[1]->desc, "v-abl Abelson murine leukemia viral oncogene homolog 2 (arg, Abelson-related gene)");
ok ($seqs[1]->display_id, "ABL2");

my $ac = $seqs[1]->annotation;
my @keys = $ac->get_all_annotation_keys();
ok (scalar(@keys), 19);

my ($cmt) = $ac->get_Annotations('comment');
ok (length($cmt->text), 403);

my @isoforms = qw(a b);
foreach ($ac->get_Annotations('PRODUCT')) {
    ok ($_->value,
	"v-abl Abelson murine leukemia viral oncogene homolog 2 isoform ".
	shift(@isoforms));
}

my @goann = ();
foreach my $k (@keys) {
    foreach my $ann ($ac->get_Annotations($k)) {
	next unless $ann->isa("Bio::Ontology::TermI");
	push(@goann, $ann);
    }
}
ok (scalar(@goann), 4);
@goann = sort { $a->as_text() cmp $b->as_text() } @goann;
ok ($goann[2]->as_text, "cellular component|cytoplasm|");


