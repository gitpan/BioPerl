# -*-Perl-*- mode (to keep my emacs happy)
# $Id: Unflattener.t,v 1.8.4.2 2006/10/02 23:10:40 sendu Exp $

use strict;
use vars qw($DEBUG $TESTCOUNT);
BEGIN {     
    eval { require Test; };
    if( $@ ) {
	use lib 't';
    }
    use Test;
    $TESTCOUNT = 8;
    plan tests => $TESTCOUNT;
}

use Bio::Seq;
use Bio::SeqIO;
use Bio::Root::IO;
use Bio::SeqFeature::Tools::Unflattener;

ok(1);

my $verbosity = -1;   # Set to -1 for release version, so warnings aren't printed

my ($seq, @sfs);
my $unflattener = Bio::SeqFeature::Tools::Unflattener->new;


if (1) {
    my @path = ("t","data","AE003644_Adh-genomic.gb");
    # allow cmd line override
    if (@ARGV) {
	@path = (shift @ARGV);
    }
    $seq = getseq(@path);
    
    ok ($seq->accession_number, 'AE003644');
    my @topsfs = $seq->get_SeqFeatures;
    if( $verbosity > 0 ) {
	warn sprintf "TOP:%d\n", scalar(@topsfs);
	write_hier(@topsfs);
    }
    
    # UNFLATTEN
    $unflattener->verbose($verbosity);
    @sfs = $unflattener->unflatten_seq(-seq=>$seq,
				       -group_tag=>'locus_tag');
    if( $verbosity > 0 ) {
	warn "\n\nPOST PROCESSING:\n";
	write_hier(@sfs);
	warn sprintf "PROCESSED:%d\n", scalar(@sfs);
    }
    ok(@sfs == 21);
}

# now try again, using a custom subroutine to link together features
$seq = getseq("t","data","AE003644_Adh-genomic.gb");
@sfs = $unflattener->unflatten_seq
    (-seq=>$seq,
     -group_tag=>'locus_tag',
     -resolver_method => 
     sub {
	 my $self = shift;
	 my ($sf, @candidate_container_sfs) = @_;
	 if ($sf->has_tag('note')) {
	     my @notes = $sf->get_tag_values('note');
	     my @trnames = map {/from transcript\s+(.*)/;
				$1} @notes;
	     @trnames = grep {$_} @trnames;
	     my $trname;
	     if (@trnames == 0) {
		 $self->throw("UNRESOLVABLE");
	     }
	     elsif (@trnames == 1) {
		 $trname = $trnames[0];
	     }
	     else {
		 $self->throw("AMBIGUOUS: @trnames");
	     }
	     my @container_sfs =
		 grep {
		     my ($product) =
			 $_->has_tag('product') ?
			 $_->get_tag_values('product') :
			 ('');
		     $product eq $trname;
		 } @candidate_container_sfs;
	     if (@container_sfs == 0) {
		 $self->throw("UNRESOLVABLE");
	     }
	     elsif (@container_sfs == 1) {
		 # we got it!
		 return ($container_sfs[0]=>0);
	     }
	     else {
		 $self->throw("AMBIGUOUS");
	     }
                                         
	 }
     });
$unflattener->feature_from_splitloc(-seq=>$seq);
if( $verbosity > 0 ) {
    warn "\n\nPOST PROCESSING:\n";
    write_hier(@sfs);
    warn sprintf "PROCESSED2:%d\n", scalar(@sfs);
}
ok(@sfs == 21);

# try again; different sequence
# this is an E-Coli seq with no mRNA features;
# we just want to link all features directly with gene

$seq = getseq("t","data","D10483.gbk");

# UNFLATTEN
@sfs = $unflattener->unflatten_seq(-seq=>$seq,
				   -partonomy=>{'*'=>'gene'},
                                );
if( $verbosity > 0 ) {
    warn "\n\nPOST PROCESSING:\n";
    write_hier(@sfs);
    warn sprintf "PROCESSED:%d\n", scalar(@sfs);
}
ok(@sfs == 98);

# this sequence has no locus_tag or or gene tags
$seq = getseq("t","data","AY763288.gb");

# UNFLATTEN
@sfs = $unflattener->unflatten_seq(-seq=>$seq,
				   -use_magic=>1
                                  );
if( $verbosity > 0 ) {
    warn "\n\nPOST PROCESSING:\n";
    write_hier(@sfs);
    warn sprintf "PROCESSED:%d\n", scalar(@sfs);
}
ok(@sfs == 3);


# try again; different sequence - dicistronic gene, mRNA record

$seq = getseq("t","data","X98338_Adh-mRNA.gb");

# UNFLATTEN
@sfs = $unflattener->unflatten_seq(-seq=>$seq,
                                 -partonomy=>{'*'=>'gene'},
                                );
if( $verbosity > 0 ) {                                 
    warn "\n\nPOST PROCESSING:\n";
    write_hier(@sfs);
    warn sprintf "PROCESSED:%d\n", scalar(@sfs);
}
ok(@sfs == 7);

# try again; this sequence has no CDSs but rRNA present

$seq = getseq("t","data","no_cds_example.gb");

# UNFLATTEN
@sfs = $unflattener->unflatten_seq(-seq=>$seq,
                                 use_magic=>1
                                );
if( $verbosity > 0 ) {
    warn "\n\nPOST PROCESSING:\n";
    write_hier(@sfs);
    warn sprintf "PROCESSED:%d\n", scalar(@sfs);
}

my @all_sfs = $seq->get_all_SeqFeatures;

my @exons = grep { $_-> primary_tag eq 'exon' }  @all_sfs ; 

ok(@exons == 2);



sub write_hier {
    my @sfs = @_;
    _write_hier(0, @sfs);
}

sub _write_hier {
    my $indent = shift;
    my @sfs = @_;
    foreach my $sf (@sfs) {
        my $label = '?';
        if ($sf->has_tag('product')) {
            ($label) = $sf->get_tag_values('product');
        }
        warn sprintf "%s%s $label\n", '  ' x $indent, $sf->primary_tag;
        my @sub_sfs = $sf->sub_SeqFeature;
        _write_hier($indent+1, @sub_sfs);
    }
}

sub getseq {
    my @path = @_;
    my $seqio =
      Bio::SeqIO->new('-file'=> Bio::Root::IO->catfile(
                                                       @path
                                                      ), 
                      '-format' => 'GenBank');
    $seqio->verbose($verbosity);

    my $seq = $seqio->next_seq();
    return $seq;
}
