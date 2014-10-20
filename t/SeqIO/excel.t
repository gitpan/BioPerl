# -*-Perl-*- Test Harness script for Bioperl
# $Id: excel.t 15112 2008-12-08 18:12:38Z sendu $

use strict;

BEGIN {
	use lib '.';
    use Bio::Root::Test;
    
    test_begin(-tests               => 4,
			   -requires_modules    => [],
			   -requires_networking => 0,
			  );
	
	use_ok('Bio::SeqIO::excel');
}

my $verbose = test_debug();

my $format = 'excel';
my $seqio_obj = Bio::SeqIO->new(-file   => test_input_file("test.xls"),
						        -format => $format);

isa_ok($seqio_obj, 'Bio::SeqIO');

my @methods = qw(next_seq write_seq);
foreach my $method (@methods) {
	can_ok($seqio_obj, $method) || 
		diag "$method method not implemented for $format";	
}
