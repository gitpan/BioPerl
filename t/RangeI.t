# -*-Perl-*-
## Bioperl Test Harness Script for Modules
## $Id: RangeI.t,v 1.4 2001/01/25 22:13:40 jason Exp $

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.t'

use strict;
use vars qw(@funcs);
BEGIN {
    # to handle systems with no installed Test module
    # we include the t dir (where a copy of Test.pm is located)
    # as a fallback
    eval { require Test; };
    if( $@ ) {
	use lib 't';
    }
    use Test;
    @funcs = qw(start end length strand);
    plan tests => 8;
}

use Bio::RangeI;

my $i = 1;
my $func;
while ($func = shift @funcs) {
  $i++;
  if(exists $Bio::RangeI::{$func}) {
    ok(1);
    eval {
      $Bio::RangeI::{$func}->();
    };
    ok( $@ );
  } else {
    ok(0);
  }
}
