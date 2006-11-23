# -*-Perl-*- mode (to keep my emacs happy)
# $Id: MultiFile.t,v 1.1 2005/08/28 03:41:56 bosborne Exp $

use strict;

BEGIN {
	eval { require Test; };
	if ( $@ ) {
		use lib 't';
	}
	use Test;
	plan tests => 3;
}

use Bio::SeqIO;
use Bio::SeqIO::MultiFile;

ok(1);

my $verbose = $ENV{'BIOPERLDEBUG'} || 0;

my $mf = Bio::SeqIO::MultiFile->new(-format => 'Fasta' ,
												-verbose => $verbose,
												-files =>
												[ Bio::Root::IO->catfile
												("t","data","multi_1.fa"),
												Bio::Root::IO->catfile
												("t","data","multi_2.fa")]);
ok defined $mf;
my $count = 0;
eval {
	while (my $seq = $mf->next_seq() ) {
		$count++;
		# $temp = $seq->display_id;
	}
};
ok( $count,12 );
