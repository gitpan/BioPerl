## Bioperl Test Harness Script for Modules
## $Id: PrimarySeq.t,v 1.1 2000/02/07 19:38:57 birney Exp $

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
BEGIN { $| = 1; print "1..7\n"; 
	use vars qw($loaded); }
END {print "not ok 1\n" unless $loaded;}

use lib '../';
use Bio::PrimarySeq;

$loaded = 1;
print "ok 1\n";    # 1st test passes.


## End of black magic.
##
## Insert additional test code below but remember to change
## the print "1..x\n" in the BEGIN block to reflect the
## total number of tests that will be run. 


my $seq = Bio::PrimarySeq->new(-seq=>'ACTGTGGCGTCAACT',
			-display_id => 'new-id',
			-moltype => 'dna',
			-accession_number => 'X677667',
                        -desc=>'Sample Bio::Seq object');
print "ok 2\n";  

$seq->accession_number();
$seq->seq();
$seq->display_id();

print "ok 3\n";

$trunc = $seq->trunc(1,4);

print "ok 4\n";

if( $trunc->seq() ne 'ACTG' ) {
   print "not ok 5\n";
   $s = $trunc->seq();
   print STDERR "Expecting ACTG. Got $s\n";
} else {
   print "ok 5\n";
}

$rev = $seq->revcom();

print "ok 6\n";

if( $rev->seq() ne 'AGTTGACGCCACAGT' ) {
   print "not ok 7\n";
} else {
   print "ok 7\n";
}





