# This is -*-Perl-*- code
## Bioperl Test Harness Script for Modules
##
# $Id: seqread_fail.t,v 1.5 2005/09/17 02:11:21 bosborne Exp $

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.t'

use strict;
#use lib '..','.','./blib/lib';
use vars qw($NUMTESTS $DEBUG);
$DEBUG = $ENV{'BIOPERLDEBUG'} || 0;

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

	eval { require IO::String; 
			 require LWP::UserAgent;
			 require HTTP::Request::Common;
       };
	if( $@ ) {
		print STDERR "IO::String or LWP::UserAgent or HTTP::Request not installed. This means the Bio::DB::* modules are not usable. Skipping tests.\n";
		for( 1..$NUMTESTS ) {
			skip("IO::String, LWP::UserAgent,or HTTP::Request not installed",1);
		}
		$error = 1; 
	}
}

END {
	foreach ( $Test::ntest..$NUMTESTS) {
		skip('Unable to run all of the DB tests',1);
	}
}


if( $error ==  1 ) {
    exit(0);
}


require Bio::DB::GenBank;
require Bio::DB::GenPept;
require Bio::DB::SwissProt;
require Bio::DB::RefSeq;
require Bio::DB::EMBL;
require Bio::DB::BioFetch;

my $verbose = -1;
$verbose = 0 if $DEBUG;

sub fetch {
    my ($id, $class) = @_;
    print "###################### $class  ####################################\n" if $DEBUG;
    my $seq;
    ok defined ( my $gb = new $class('-verbose'=>$verbose,'-delay'=>0) );
    eval { $seq = $gb->get_Seq_by_id($id) };
    if( $@ or not defined$seq ) {
	ok 1;
	return;
    }
    ok 0;
}

my @classes = qw( Bio::DB::BioFetch Bio::DB::GenBank Bio::DB::GenPept
                  Bio::DB::SwissProt Bio::DB::RefSeq Bio::DB::EMBL  );

my $id = 'XXX111';  # nonsense id

for (@classes) {
    fetch ($id, $_);
}

ok 1;
