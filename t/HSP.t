# -*-Perl-*-
## Bioperl Test Harness Script for Modules
## $Id: HSP.t,v 1.4 2001/01/25 22:13:40 jason Exp $

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
    plan tests => 1;
}

use Bio::Tools::Blast::HSP;

ok(1);
