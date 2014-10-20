# This is -*-Perl-*- code
## Bioperl Test Harness Script for Modules
##
# $Id: Biblio_biofetch.t,v 1.3.2.4 2002/06/04 21:46:52 jason Exp $

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.t'

use strict;
use vars qw($NUMTESTS $DEBUG);
$DEBUG=0;
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

    $NUMTESTS = 13;
    plan tests => $NUMTESTS;
    eval { require 'IO/String.pm' };
    if( $@ ) {
	for( $Test::ntest..$NUMTESTS ) {
	    skip("IO::String not installed. This means the Bio::DB::* modules are not usable. Skipping tests",1);
	}
       $error = 1; 
    }
}

if( $error ==  1 ) {
    exit(0);
}

use Bio::Biblio;
ok 1;
use Bio::Biblio::IO;
ok 1;

## End of black magic.
##
## Insert additional test code below but remember to change
## the print "1..x\n" in the BEGIN block to reflect the
## total number of tests that will be run. 

my ($db,$ref,$refio);
# get a single ref

my $verbose = 0;

$ref = $refio = undef;

# check BioFetch access method


eval { 
    ok ($db = new Bio::Biblio (-access => 'biofetch',
				   -verbose=>$verbose));
    ok(defined($ref = $db->get_by_id('20063307')));
    ok $ref->identifier, '20063307';
};

if ($@) {
    print STDERR "Warning: Couldn't connect to BioFetch server with Bio::DB::Medline.pm!\n";
	print STDERR $@ if( $DEBUG );

    foreach ( $Test::ntest..$NUMTESTS) { 
	skip('could not connect to Medline',1);}
}

$ref = $refio = undef;

eval {
    ok defined($db = new Bio::Biblio(-access => 'biofetch',
				     -verbose=>$verbose,
				     -retrievaltype => 'tempfile'
				     )); 


    my $ids = ['20063307', '98276153'];
    ok(defined($refio = $db->get_all($ids)));
    ok($refio->next_bibref->identifier, '20063307');
    ok($refio->next_bibref->identifier, '98276153');
};

if ($@) {    
    if( $DEBUG ) { 
	warn "Batch access test failed.Error: $@\n";
    }
    foreach ( $Test::ntest..$NUMTESTS ) { skip('no network access',1); }
}

eval {
    ok defined($db = new Bio::Biblio(-access => 'biofetch',
				     -verbose=>$verbose
				     )); 

    ok(defined($refio = $db->get_Stream_by_batch(['20063307', '98276153'])));
    ok($refio->next_bibref->identifier, '20063307');
    ok($refio->next_bibref->identifier, '98276153');
};

if ($@) {    
    if( $DEBUG ) { 
	warn "Batch access test failed.Error: $@\n";
    }
    foreach ( $Test::ntest..$NUMTESTS ) { skip('no network access',1); }
}


