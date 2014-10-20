## Bioperl Test Harness Script for Modules
## $Id: SimpleAlign.t,v 1.3.12.1 2000/03/31 07:50:02 birney Exp $

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.t'

#-----------------------------------------------------------------------
## perl test harness expects the following output syntax only!
## 1..3
## ok 1  [not ok 1 (if test fails)]
## 2..3
## ok 2  [not ok 2 (if test fails)]
## 3..3
## ok 3  [not ok 3 (if test fails)]
##
## etc. etc. etc. (continue on for each tested function in the .t file)
#-----------------------------------------------------------------------


## We start with some black magic to print on failure.
BEGIN { $| = 1; print "1..7\n"; }
END {print "not ok 1\n" unless $loaded;}

use lib '../';
use Bio::SimpleAlign;

$loaded = 1;
print "ok 1\n";    # 1st test passes.


## End of black magic.
##
## Insert additional test code below but remember to change
## the print "1..x\n" in the BEGIN block to reflect the
## total number of tests that will be run. 

open(FH,"t/test.mase") || die "Could not open test.mase $!";
$aln = Bio::SimpleAlign->new();
$aln->read_mase(\*FH);
close(FH);

if( $aln ) {
	print "ok 2\n";
} else {
	print "not ok 2\n";
}	

open(OUT,">t/out.aln_fasta"); 
$aln->write_fasta(\*OUT);
close(OUT);
print "ok 3\n";


$aln = Bio::SimpleAlign->new();
open(FH,"t/test.pfam");
$aln->read_Pfam(\*FH);
close(FH);

if( $aln ) {
	print "ok 4\n";
} else {
	print "not ok 4\n";
}	

open(OUT,">t/out.pfam"); 
$aln->write_Pfam(\*OUT);
close(OUT);
print "ok 5\n";


$aln = Bio::SimpleAlign->new();
open(IN,"t/out.pfam");
$aln->read_Pfam(\*IN);
close(IN);

if( $aln ) {
	print "ok 6\n";
} else {
	print "not ok 6\n";
}	


open(OUT,">t/out.msf");
$aln->write_MSF(\*OUT);
close(OUT);

print "ok 7\n";


