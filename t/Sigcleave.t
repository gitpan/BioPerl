# -*-Perl-*-
## Bioperl Test Harness Script for various modules
## $Id: Sigcleave.t,v 1.9 2001/01/25 22:13:40 jason Exp $

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
    plan tests => 3;
}
use Bio::Tools::Sigcleave;

my $protein = 'MTMDKSELVQKAKLAEQAERYDDMAAAMKAVTEQGHELSNEERNLLSVAYKNVVGARRSSWRVISSIEQKTERNEKKQQMGKEYREKIEAELQDICNDVLELLDKYLIPNATQPESKVFYLKMKGDYFRYLSEVASGDNKQTTVSNSQQAYQEAFEISKKEMQPTHPIRLGLALNFSVFYYEILNSPEKACSLAKTAFDEAIAELDTLNEESYKDSTLIMQLLRDNLTLWTSENQGDEGDAGEGEN';

# Build object
my $sigcleave_object = new Bio::Tools::Sigcleave(-id         =>'test_sigcleave_seq',
						 -type      =>'amino',
						 -threshold => 0,
						 -seq       =>$protein); 
ok ($sigcleave_object);
# Test raw result accessor
my %results = $sigcleave_object->signals;
ok $results{57}, 0.3, "unable to get raw sigcleave results";

# Test formatted output method
my $formatted_output = $sigcleave_object->pretty_print;
ok ($formatted_output);

##
## More tests
##





