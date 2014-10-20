# -*-Perl-*-
## Bioperl Test Harness Script for Modules
##$Id: SeqUtils.t,v 1.3 2001/01/25 22:13:40 jason Exp $

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
    plan tests => 9;
}

use Bio::PrimarySeq;
use Bio::SeqUtils;
ok 1;

my ($seq, $util, $ascii, $ascii_aa, $ascii3);

#                     !    !          
$ascii =    'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
$ascii_aa = 'ABCDEFGHIXKLMNXPQRSTUVWXYZ';

$ascii3 = 
    'AlaAsxCysAspGluPheGlyHisIleXaaLysLeuMetAsnXaaProGlnArgSerThrSelValTrpXaaTyrGlx';

$seq = Bio::PrimarySeq->new('-seq'=> $ascii,
			       '-moltype'=>'protein', 
			       '-id'=>'test');

# one letter amino acid code to three letter code
ok $util = new Bio::SeqUtils;
ok $util->seq3($seq), $ascii3;

#using anonymous hash
ok (Bio::SeqUtils->seq3($seq), $ascii3); 
ok (Bio::SeqUtils->seq3($seq, undef, ','), 
    'Ala,Asx,Cys,Asp,Glu,Phe,Gly,His,Ile,Xaa,Lys,'.
    'Leu,Met,Asn,Xaa,Pro,Gln,Arg,Ser,Thr,Sel,Val,Trp,Xaa,Tyr,Glx');

$seq->seq('asd-KJJK-');
ok (Bio::SeqUtils->seq3($seq, '-', ':'), 
    'Ala:Ser:Asp:Ter:Lys:Xaa:Xaa:Lys:Ter');

# three letter amino acid code to one letter code
ok (Bio::SeqUtils->seq3in($seq, 'AlaXaaCysAspGlu')), 
ok  $seq->seq, 'AXCDE';
ok (Bio::SeqUtils->seq3in($seq, $ascii3)->seq, $ascii_aa)
#ok ();
