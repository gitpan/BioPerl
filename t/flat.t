# This is -*-Perl-*- code
## Bioperl Test Harness Script for Modules
##
# $Id: flat.t,v 1.1.2.5 2002/06/07 21:23:06 jason Exp $

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.t'

use strict;
use vars qw($NUMTESTS);

my $error;

BEGIN { 
    # to handle systems with no installed Test module
    # we include the t dir (where a copy of Test.pm is located)
    # as a fallback
    eval { require Test; };
    $error = 0;
    if( $@ ) {
	use lib 't';
    }
    use Test;

    $NUMTESTS = 7;
    plan tests => $NUMTESTS;
    eval { require DB_File; require Bio::DB::Flat; require Bio::Root::IO;};
    if( $@ ) {
	print STDERR "DB_File not loaded. This means flat.t test cannot be executed. Skipping\n";
	foreach ( $Test::ntest..$NUMTESTS ) {
	    skip('DB_File not installed',1);
	}
	$error = 1;
    }
}

if( $error ==  1 ) {
    exit(0);
}
my $testnum;
my $verbose = 0;

## End of black magic.
##
## Insert additional test code below but remember to change
## the print "1..x\n" in the BEGIN block to reflect the
## total number of tests that will be run. 


#First of all we need to create an flat db
use Bio::Root::IO;
use Cwd;
my $cd = cwd();
my $tmpdir = $cd."/t/tmp";
&maketmpdir();
my $db = Bio::DB::Flat->new(-directory  => $tmpdir,
                            -index => 'bdb',
			    -format => 'fasta',
			    -verbose => 1,
                 	    -write_flag => 1
                            );
ok($db);
my $dir = $cd."/t/data/AAC12660.fa";
my $result = $db->build_index(glob($dir));
ok($result);

#Now let's get the sequence out again
my $seq = $db->get_Seq_by_id('AAC12660');
ok($seq);
ok($seq->length,504);
undef $db;
&cleanup();
&maketmpdir();
$db = Bio::DB::Flat->new(-directory  => $tmpdir,
                         -index => 'bdb',
                         -format => 'embl',
                         -verbose => 1,
                         -write_flag => 1
			 );

$dir= $cd."/t/data/factor7.embl";
$result = $db->build_index(glob($dir));
ok($result);
$seq = $db->get_Seq_by_id('HSCFVII');
ok($seq);
ok($seq->length,12850);
undef $db;

#&maketmpdir();
#my $db = Bio::DB::Flat->new(-directory  => $tmpdir,
#                            -index => 'flat',
#                            -format => 'fasta',
#                            -verbose => 1,
#                            -write_flag => 1
#                            );


sub maketmpdir {
    mkdir ($tmpdir,0777);
}
sub cleanup {    
    eval { 
      Bio::Root::IO->rmtree($tmpdir);
    };
} 

END {
    &cleanup();
}
