## Bioperl Test Harness Script for Modules
## $Id: Annotation.t,v 1.1.6.1 2000/04/02 11:07:28 birney Exp $

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
BEGIN { $| = 1; print "1..5\n"; }
END {print "not ok 1\n" unless $loaded;}

use Bio::Annotation;

$loaded = 1;
print "ok 1\n";    # 1st test passes.

## End of black magic.
##
## Insert additional test code below but remember to change
## the print "1..x\n" in the BEGIN block to reflect the
## total number of tests that will be run. 

$annotation = Bio::Annotation->new();
$comment    = Bio::Annotation::Comment->new();
$annotation->add_Comment($comment);
print "ok 2\n";

$dblink     = Bio::Annotation::DBLink->new();
$annotation->add_DBLink($dblink);

print "ok 3\n";
$ref        = Bio::Annotation::Reference->new();
$annotation->add_Reference($ref);
print "ok 4\n";

$annotation->each_Comment();
$annotation->each_DBLink();
$annotation->each_Reference();

print "ok 5\n";
