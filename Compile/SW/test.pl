#!/usr/local/bin/perl

## Test framework for pSW XS stuff
## $Id: test.pl,v 1.1.1.1 1998/12/11 15:24:25 birney Exp $

## We start with some black magic to print on failure.
BEGIN { $| = 1; print "1..2\n"; }
END {print "not ok 1\n" unless $loaded;}

use bp_sw;

$loaded = 1;
print "ok 1\n";    # 1st test passes.

print "\n2..2\nTesting bp_sw with a protein alignment...\n\n";

&bp_sw::change_max_BaseMatrix_kbytes(20000);
$cm   = &bp_sw::CompMat::read_Blast_file_CompMat("blosum62.bla");
$seq1 = &bp_sw::new_Sequence_from_strings("one","WLGQRNLVSSTGGNLLNVWLKDW");
$seq2 = &bp_sw::new_Sequence_from_strings("two","WMGNRNVVNLLNVWFRDW");

$alb = &bp_sw::Align_Sequences_ProteinSmithWaterman($seq1,$seq2,$cm,-12,-2);

&bp_sw::write_pretty_str_align($alb,$seq1->name,$seq1->seq,$seq2->name,$seq2->seq,15,50,STDERR);

print "ok 2\n"; # Assume 2nd test worked.

## End of black magic.
##
## Insert additional test code below but remember to change
## the print "1..x\n" in the BEGIN block to reflect the
## total number of tests that will be run. 





