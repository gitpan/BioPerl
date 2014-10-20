# -*-Perl-*-
## Bioperl Test Harness Script for Modules
## $Id: Annotation.t,v 1.18.4.1 2006/11/30 09:24:00 sendu Exp $

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.t'

use strict;
use vars qw($HAVEGRAPHDIRECTED $DEBUG $NUMTESTS);
$DEBUG = $ENV{'BIOPERLDEBUG'} || 0;

BEGIN { 
    # to handle systems with no installed Test module
    # we include the t dir (where a copy of Test.pm is located)
    # as a fallback
    eval { require Test::More; };
    if( $@ ) { 
	use lib 't/lib';
    }
    use Test::More;
    plan tests => ($NUMTESTS = 101);
	use_ok('Bio::Annotation::Collection');
	use_ok('Bio::Annotation::DBLink');
	use_ok('Bio::Annotation::Comment');
	use_ok('Bio::Annotation::Reference');
	use_ok('Bio::Annotation::SimpleValue');
	use_ok('Bio::Annotation::Target');
	use_ok('Bio::Annotation::AnnotationFactory');
	use_ok('Bio::Annotation::StructuredValue');
	use_ok('Bio::Seq');
	use_ok('Bio::SeqFeature::Generic');
	use_ok('Bio::SimpleAlign');
	use_ok('Bio::Cluster::UniGene');
}

#simple value

my $simple = Bio::Annotation::SimpleValue->new(
						  -tagname => 'colour',
						  -value   => '1'
						 ), ;

isa_ok($simple, 'Bio::AnnotationI');
is $simple, 1;
is $simple->value, 1;
is $simple->tagname, 'colour';

is $simple->value(0), 0;
is $simple->value, 0;
is $simple, 0;

# link

my $link1 = new Bio::Annotation::DBLink(-database => 'TSC',
					-primary_id => 'TSC0000030'
					);
isa_ok($link1,'Bio::AnnotationI');
is $link1->database(), 'TSC';
is $link1->primary_id(), 'TSC0000030';
is $link1->as_text, 'Direct database link to TSC0000030 in database TSC';
my $ac = Bio::Annotation::Collection->new();
isa_ok($ac,'Bio::AnnotationCollectionI');

$ac->add_Annotation('dblink',$link1);
$ac->add_Annotation('dblink',
		    Bio::Annotation::DBLink->new(-database => 'TSC',
						 -primary_id => 'HUM_FABV'));

my $comment = Bio::Annotation::Comment->new( '-text' => 'sometext');
is $comment->text, 'sometext';
is $comment->as_text, 'Comment: sometext';
$ac->add_Annotation('comment', $comment);



my $target = new Bio::Annotation::Target(-target_id  => 'F321966.1',
                                         -start      => 1,
                                         -end        => 200,
                                         -strand     => 1,
					 );
isa_ok($target,'Bio::AnnotationI');
ok $ac->add_Annotation('target', $target);


my $ref = Bio::Annotation::Reference->new( '-authors' => 'author line',
					   '-title'   => 'title line',
					   '-location'=> 'location line',
					   '-start'   => 12);
isa_ok($ref,'Bio::AnnotationI');
is $ref->authors, 'author line';
is $ref->title,  'title line';
is $ref->location, 'location line';
is $ref->start, 12;
is $ref->database, 'MEDLINE';
is $ref->as_text, 'Reference: title line';
$ac->add_Annotation('reference', $ref);


my $n = 0;
foreach my $link ( $ac->get_Annotations('dblink') ) {
    is $link->database, 'TSC';
    is $link->tagname(), 'dblink';
    $n++;
}
is ($n, 2);

$n = 0;
my @keys = $ac->get_all_annotation_keys();
is (scalar(@keys), 4);
foreach my $ann ( $ac->get_Annotations() ) {
    shift(@keys) if ($n > 0) && ($ann->tagname ne $keys[0]);
    is $ann->tagname(), $keys[0];
    $n++;
}
is ($n, 5);

$ac->add_Annotation($link1);

$n = 0;
foreach my $link ( $ac->get_Annotations('dblink') ) {
    is $link->tagname(), 'dblink';
    $n++;
}
is ($n, 3);

# annotation of structured simple values (like swissprot''is GN line)
my $ann = Bio::Annotation::StructuredValue->new();
isa_ok($ann, "Bio::AnnotationI");

$ann->add_value([-1], "val1");
is ($ann->value(), "val1");
$ann->value("compat test");
is ($ann->value(), "compat test");
$ann->add_value([-1], "val2");
is ($ann->value(-joins => [" AND "]), "compat test AND val2");
$ann->add_value([0], "val1");
is ($ann->value(-joins => [" AND "]), "val1 AND val2");
$ann->add_value([-1,-1], "val3", "val4");
$ann->add_value([-1,-1], "val5", "val6");
$ann->add_value([-1,-1], "val7");
ok ($ann->value(-joins => [" AND "]), "val1 AND val2 AND (val3 AND val4) AND (val5 AND val6) AND val7");
ok ($ann->value(-joins => [" AND ", " OR "]), "val1 AND val2 AND (val3 OR val4) AND (val5 OR val6) AND val7");

$n = 1;
foreach ($ann->get_all_values()) {
    is ($_, "val".$n++);
}

# nested collections
my $nested_ac = Bio::Annotation::Collection->new();
$nested_ac->add_Annotation('nested', $ac);

is (scalar($nested_ac->get_Annotations()), 1);
($ac) = $nested_ac->get_Annotations();
isa_ok($ac, "Bio::AnnotationCollectionI");
is (scalar($nested_ac->get_all_Annotations()), 6);
$nested_ac->add_Annotation('gene names', $ann);
is (scalar($nested_ac->get_Annotations()), 2);
is (scalar($nested_ac->get_all_Annotations()), 7);
is (scalar($nested_ac->get_Annotations('dblink')), 0);
my @anns = $nested_ac->get_Annotations('gene names');
isa_ok($anns[0], "Bio::Annotation::StructuredValue");
@anns = map { $_->get_Annotations('dblink');
	  } $nested_ac->get_Annotations('nested');
is (scalar(@anns), 3);
is (scalar($nested_ac->flatten_Annotations()), 2);
is (scalar($nested_ac->get_Annotations()), 7);
is (scalar($nested_ac->get_all_Annotations()), 7);

SKIP: {
	eval {require Graph::Directed; 
	  require Bio::Annotation::OntologyTerm; };
	skip('Graph::Directed not installed cannot test'.
		 ' Bio::Annotation::OntologyTerm module',6) if $@;
	# OntologyTerm annotation
    my $termann = Bio::Annotation::OntologyTerm->new(-label => 'test case',
						     -identifier => 'Ann:00001',
						     -ontology => 'dumpster');
    isa_ok($termann->term,'Bio::Ontology::Term');
    is ($termann->term->name, 'test case');
    is ($termann->term->identifier, 'Ann:00001');
    is ($termann->tagname, 'dumpster');
    is ($termann->ontology->name, 'dumpster');
    is ($termann->as_text, "dumpster|test case|");
}

# AnnotatableI
my $seq = Bio::Seq->new();
isa_ok($seq,"Bio::AnnotatableI");
my $fea = Bio::SeqFeature::Generic->new();
isa_ok($fea, "Bio::AnnotatableI");
my $clu = Bio::Cluster::UniGene->new();
isa_ok($clu, "Bio::AnnotatableI");
my $aln = Bio::SimpleAlign->new();
isa_ok($clu,"Bio::AnnotatableI");

# tests for Bio::Annotation::AnnotationFactory

my $factory = Bio::Annotation::AnnotationFactory->new;
isa_ok($factory, 'Bio::Factory::ObjectFactoryI');

# defaults to SimpleValue
$ann = $factory->create_object(-value => 'peroxisome',
                                  -tagname => 'cellular component');
like(ref $ann, qr(Bio::Annotation::SimpleValue));

$factory->type('Bio::Annotation::OntologyTerm');

$ann = $factory->create_object(-name => 'peroxisome',
			       -tagname => 'cellular component');
ok(defined $ann);
like(ref($ann), qr(Bio::Annotation::OntologyTerm));

SKIP: {
	skip("TODO: Create Annotation::Comment based on parameter only",2);
	ok $ann = $factory->create_object(-text => 'this is a comment');
	like(ref $ann, qr(Bio::Annotation::Comment));
}

ok $factory->type('Bio::Annotation::Comment');
ok $ann = $factory->create_object(-text => 'this is a comment');
like(ref $ann, qr(Bio::Annotation::Comment));


# factory guessing the type: Comment
$factory = new Bio::Annotation::AnnotationFactory();
ok $ann = $factory->create_object(-text => 'this is a comment');
like(ref $ann, qr(Bio::Annotation::Comment));

# factory guessing the type: Target
$factory = new Bio::Annotation::AnnotationFactory();
ok $ann = $factory->create_object(-target_id => 'F1234', -start => 1, -end => 10);
like(ref $ann, qr(Bio::Annotation::Target));

# factory guessing the type: OntologyTerm
$factory = new Bio::Annotation::AnnotationFactory();
ok(defined ($ann = $factory->create_object(-name => 'peroxisome',
					  -tagname => 'cellular component')));
like(ref $ann, qr(Bio::Annotation::OntologyTerm));
