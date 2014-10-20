# -*-Perl-*-
## Bioperl Test Harness Script for Modules
##
# $Id: hmmer.t,v 1.12.2.2 2002/06/02 19:32:52 jason Exp $

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
    plan test => 27;
}

use Bio::Tools::HMMER::Domain;
use Bio::Tools::HMMER::Set;
use Bio::Tools::HMMER::Results;
use Bio::Root::IO;

my ($domain,$set,$homol,$rev,$res,$dom,@doms);
$domain = Bio::Tools::HMMER::Domain->new(-verbose=>1);

ok ref($domain), 'Bio::Tools::HMMER::Domain';

$domain->start(50);
$domain->end(200);
$domain->hstart(10);
$domain->hend(100);
$domain->seqbits(50);
$domain->bits(20);
$domain->evalue(0.0001);
$domain->seqname('silly');


# test that we can get out forward and reverse homol_SeqFeatures
$homol = $domain->feature2();
ok $homol->start(), 10;

$rev = $domain;

ok $rev->start(), 50;

$set = Bio::Tools::HMMER::Set->new();
$set->add_Domain($domain);

@doms = $set->each_Domain();
$dom = shift @doms;

ok $dom->start(), 50;

$set->bits(300);
$set->evalue(0.0001);
$set->name('sillyname');
$set->desc('a desc');
$set->accession('fakeaccesssion');
ok $set->bits(), 300;
ok $set->evalue(), 0.0001;
ok $set->name(), 'sillyname';
ok $set->desc, 'a desc';
ok $set->accession, 'fakeaccesssion';

$res = Bio::Tools::HMMER::Results->new( -file => Bio::Root::IO->catfile("t","data","hmmsearch.out") , -type => 'hmmsearch');
my $seen =0;
ok $res->hmmfile, "HMM";
ok $res->seqfile, "HMM.dbtemp.29591";

my $first = 0;
foreach $set ( $res->each_Set) {
    foreach $domain ( $set->each_Domain ) {
    #print STDERR "Got domain ",$domain->seqname," start ",$domain->start," end ",$domain->end,"\n";
    # do nothing for the moment
      $seen = 1;
  }
}
ok $seen, 1;

ok $res->number, 1215, "\nBad number of domains. Expecting 1215. Got" . $res->number;

$res = Bio::Tools::HMMER::Results->new( -file => 
				      Bio::Root::IO->catfile("t","data",
							     "hmmpfam.out") , 
					-type => 'hmmpfam');

ok ($res->number, 2);


# parse HMM 2.2 files

$res = Bio::Tools::HMMER::Results->new( -file => 
				      Bio::Root::IO->catfile("t","data",
							     "L77119.hmmer"),
					-type => 'hmmpfam');
$seen =0;
ok $res->hmmfile, 'Pfam';
ok $res->seqfile, 'L77119.faa';
foreach $set ( $res->each_Set) {
    # only one set anyways

    ok($set->name, 'gi|1522636|gb|AAC37060.1|');
    ok($set->desc, 'M. jannaschii predicted coding region MJECS02 [Methanococcus jannaschii]');
    ok($set->accession, '[none]');
    foreach $domain ( $set->each_Domain ) {
	#print STDERR "Got domain ",$domain->seqname," start ",$domain->start," end ",$domain->end,"\n";
    # do nothing for the moment
	ok($domain->start, 280);
	ok($domain->end, 481);
	ok($domain->bits, -105.2);
	ok($domain->evalue, 0.0022 );
	ok($domain->hmmname, 'Methylase_M');
	
    }
}
ok ($res->number, 1);

# test for bugs #(1189,1034,1172)
$res = Bio::Tools::HMMER::Results->new( -file => Bio::Root::IO->catfile
					("t","data","hmmsearch.out") , 
					-type => 'hmmsearch');
my $res2 = $res->filter_on_cutoff(100,50);
ok($res2);
ok($res2->number, 604);
