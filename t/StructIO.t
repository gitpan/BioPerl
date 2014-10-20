# -*-Perl-*-
## Bioperl Test Harness Script for Modules
## $Id: StructIO.t,v 1.8.4.2 2006/10/02 23:10:40 sendu Exp $

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
	plan tests => 14;
}

use Bio::Structure::Entry;
use Bio::Structure::IO;
use Bio::Root::IO;
ok(1);
#
# test reading PDB format - single model, single chain
#
my $pdb_file = Bio::Root::IO->catfile("t","data","1BPT.pdb");
my $structin = Bio::Structure::IO->new(-file => $pdb_file, 
													-format => 'pdb');
ok(1);
my $struc = $structin->next_structure;
ok(1);
ok(ref($struc), "Bio::Structure::Entry");

# some basic checks, Structure objects are tested in Structure.t
my ($chain) = $struc->chain;
ok($struc->residue, 97);
my ($atom) = $struc->get_atom_by_serial(367);
ok($atom->id, "NZ");
ok($struc->parent($atom)->id, "LYS-46");
my ($ann) = $struc->annotation->get_Annotations("author");
ok($ann->as_text,
	"Value: D.HOUSSET,A.WLODAWER,F.TAO,J.FUCHS,C.WOODWARD              ");
($ann) = $struc->annotation->get_Annotations("header");
ok($ann->as_text,
	"Value: PROTEINASE INHIBITOR (TRYPSIN)          11-DEC-91   1BPT");
my $pseq = $struc->seqres;
ok($pseq->subseq(1,20), "RPDFCLEPPYTGPCKARIIR");

#
# test reading PDB format - single model, multiple chains
#
$pdb_file = Bio::Root::IO->catfile("t","data","1A3I.pdb");
$structin = Bio::Structure::IO->new(-file => $pdb_file, 
												-format => 'pdb');
$struc = $structin->next_structure;

my ($chaincount,$rescount,$atomcount);
for my $chain ($struc->get_chains) {
	$chaincount++;
   for my $res ($struc->get_residues($chain)) {
		$rescount++;
      for my $atom ($struc->get_atoms($res)) {
			$atomcount++;
		}
   }
}

ok($chaincount, 4);  # 3 polypeptides and a group of hetero-atoms
ok($rescount, 60);   # amino acid residues and solvent molecules
ok($atomcount, 171); # ATOM and HETATM

#
# test reading PDB format - multiple models, single chain
#
$pdb_file = Bio::Root::IO->catfile("t","data","1A11.pdb");

#
# test reading PDB format - chains with ATOMs plus HETATMs
#
$pdb_file = Bio::Root::IO->catfile("t","data","8HVP.pdb");

#
# test writing PDB format
#
my $out_file = Bio::Root::IO->catfile("t","data","temp-pdb1bpt.ent");
my $structout = Bio::Structure::IO->new(-file => ">$out_file", 
                                        -format => 'PDB');
$structout->write_structure($struc);
ok(1);

END {
	unlink $out_file if -e $out_file;
}
