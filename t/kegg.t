# -*-Perl-*- mode (to keep my emacs happy)
# $Id: kegg.t,v 1.2 2005/11/12 23:15:49 bosborne Exp $

use strict;

BEGIN {
	eval { require Test; };
	if ( $@ ) {
		use lib 't';
	}
	use Test;
	plan tests => 13;
}

use Bio::SeqIO;

ok(1);

my $verbose = $ENV{'BIOPERLDEBUG'} || 0;

my $io = Bio::SeqIO->new(-format => 'kegg',
								 -verbose => $verbose,
								 -file => Bio::Root::IO->catfile
								 ("t","data","AHCYL1.kegg"));
ok($io);
my $kegg = $io->next_seq();
ok($kegg);
ok($kegg->accession, '10768');
ok($kegg->display_id, 'AHCYL1');
ok($kegg->alphabet, 'dna');
ok($kegg->seq,'atgtcgatgcctgacgcgatgccgctgcccggggtcggggaggagctgaagcaggccaaggagatcgaggacgccgagaagtactccttcatggccaccgtcaccaaggcgcccaagaagcaaatccagtttgctgatgacatgcaggagttcaccaaattccccaccaaaactggccgaagatctttgtctcgctcgatctcacagtcctccactgacagctacagttcagctgcatcctacacagatagctctgatgatgaggtttctccccgagagaagcagcaaaccaactccaagggcagcagcaatttctgtgtgaagaacatcaagcaggcagaatttggacgccgggagattgagattgcagagcaagacatgtctgctctgatttcactcaggaaacgtgctcagggggagaagcccttggctggtgctaaaatagtgggctgtacacacatcacagcccagacagcggtgttgattgagacactctgtgccctgggggctcagtgccgctggtctgcttgtaacatctactcaactcagaatgaagtagctgcagcactggctgaggctggagttgcagtgttcgcttggaagggcgagtcagaagatgacttctggtggtgtattgaccgctgtgtgaacatggatgggtggcaggccaacatgatcctggatgatgggggagacttaacccactgggtttataagaagtatccaaacgtgtttaagaagatccgaggcattgtggaagagagcgtgactggtgttcacaggctgtatcagctctccaaagctgggaagctctgtgttccggccatgaacgtcaatgattctgttaccaaacagaagtttgataacttgtactgctgccgagaatccattttggatggcctgaagaggaccacagatgtgatgtttggtgggaaacaagtggtggtgtgtggctatggtgaggtaggcaagggctgctgtgctgctctcaaagctcttggagcaattgtctacattaccgaaatcgaccccatctgtgctctgcaggcctgcatggatgggttcagggtggtaaagctaaatgaagtcatccggcaagtcgatgtcgtaataacttgcacaggaaataagaatgtagtgacacgggagcacttggatcgcatgaaaaacagttgtatcgtatgcaatatgggccactccaacacagaaatcgatgtgaccagcctccgcactccggagctgacgtgggagcgagtacgttctcaggtggaccatgtcatctggccagatggcaaacgagttgtcctcctggcagagggtcgtctactcaatttgagctgctccacagttcccacctttgttctgtccatcacagccacaacacaggctttggcactgatagaactctataatgcacccgaggggcgatacaagcaggatgtgtacttgcttcctaagaaaatggatgaatacgttgccagcttgcatctgccatcatttgatgcccaccttacagagctgacagatgaccaagcaaaatatctgggactcaacaaaaatgggccattcaaacctaattattacagatactaa');
ok($kegg->translate->seq);

ok(($kegg->annotation->get_Annotations('description'))[0]->text,
   'S-adenosylhomocysteine hydrolase-like 1 [EC:3.3.1.1]');

ok(($kegg->annotation->get_Annotations('pathway'))[0]->text,
   'Metabolism; Amino Acid Metabolism; Methionine metabolism');

ok( (grep {$_->database eq 'KO'}
     $kegg->annotation->get_Annotations('dblink'))[0]->comment, 
    'adenosylhomocysteinase' );

ok( (grep {$_->database eq 'PATH'} 
     $kegg->annotation->get_Annotations('dblink'))[0]->primary_id,
    'hsa00271' );

ok( ($kegg->annotation->get_Annotations('aa_seq'))[0]->text,
'MSMPDAMPLPGVGEELKQAKEIEDAEKYSFMATVTKAPKKQIQFADDMQEFTKFPTKTGRRSLSRSISQSSTDSYSSAASYTDSSDDEVSPREKQQTNSKGSSNFCVKNIKQAEFGRREIEIAEQDMSALISLRKRAQGEKPLAGAKIVGCTHITAQTAVLIETLCALGAQCRWSACNIYSTQNEVAAALAEAGVAVFAWKGESEDDFWWCIDRCVNMDGWQANMILDDGGDLTHWVYKKYPNVFKKIRGIVEESVTGVHRLYQLSKAGKLCVPAMNVNDSVTKQKFDNLYCCRESILDGLKRTTDVMFGGKQVVVCGYGEVGKGCCAALKALGAIVYITEIDPICALQACMDGFRVVKLNEVIRQVDVVITCTGNKNVVTREHLDRMKNSCIVCNMGHSNTEIDVTSLRTPELTWERVRSQVDHVIWPDGKRVVLLAEGRLLNLSCSTVPTFVLSITATTQALALIELYNAPEGRYKQDVYLLPKKMDEYVASLHLPSFDAHLTELTDDQAKYLGLNKNGPFKPNYYRY');
