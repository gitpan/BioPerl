#-------------------------------------------------------------------------------
# PACKAGE : Bio::Tools::Blast.pm
# PURPOSE : To encapsulate code for running, parsing, and analyzing BLAST reports.
# AUTHOR  : Steve A. Chervitz (sac@genome.stanford.edu)
# CREATED : March 1996
# REVISION: $Id: Blast.pm,v 1.2.2.4 1999/02/05 19:25:05 sac Exp $
# STATUS  : Alpha
# 
# For the latest version and documentation, visit:
#    http://bio.perl.org/Projects/Blast
#
# To generate documentation, run this module through pod2html
# (preferably from Perl v5.004 or better).
#
# Copyright (c) 1996-98 Steve A. Chervitz. All Rights Reserved.
#           This module is free software; you can redistribute it and/or 
#           modify it under the same terms as Perl itself.
#-------------------------------------------------------------------------------

package Bio::Tools::Blast;

use Bio::Tools::SeqAnal;
use Bio::Root::Global  qw(:std);
require 5.002;
use Carp;

@ISA        = qw( Bio::Tools::SeqAnal Exporter);
@EXPORT     = qw();
@EXPORT_OK  = qw($VERSION $Blast);
%EXPORT_TAGS = ( obj => [qw($Blast)],
		 std => [qw($Blast)]);

use strict;
use vars qw($ID $VERSION $Blast @Blast_programs $Revision);

$ID = 'Bio::Tools::Blast';
$VERSION  = 0.074; 
$Revision = '$Id: Blast.pm,v 1.2.2.4 1999/02/05 19:25:05 sac Exp $';  #'

## Static Blast object. 
$Blast = {};
bless $Blast, $ID;
$Blast->{'_name'} = "Static Blast object";

@Blast_programs  = qw(blastp blastn blastx tblastn tblastx);

use vars qw($RawData $HspString $HitCount $DEFAULT_MATRIX $DEFAULT_SIGNIF);
$RawData             = ''; # Holds a single Blast report.
$HspString           = ''; # Holds data for the alignment section of one hit.
$DEFAULT_MATRIX      = 'BLOSUM62';
$DEFAULT_SIGNIF      = 999;# Value used as significance cutoff if none supplied.
$HitCount            = 0;  # Holds total number of hits (not just significant hits).
my $MAX_HSP_OVERLAP  = 2;  # Used when tiling multiple HSPs.
my $_no_gt           = 0;  # If alignment sections lack a '>'.
my $_verbose         = 0;  # Extra progress output.

## POD Documentation:

=head1 NAME

Bio::Tools::Blast.pm - Bioperl BLAST sequence analysis object

=head1 SYNOPSIS

=head2 Parsing Blast reports

Parse an existing Blast report from file:

    use Bio::Tools::Blast;

    $blastObj = Bio::Tools::Blast->new( -file   => '/tmp/blast.out',
					-parse  => 1,  
					-signif => '1e-10',
					);

Parse an existing Blast report from STDIN:

    $blastObj = Bio::Tools::Blast->new( -parse  => 1,  
					-signif => '1e-10',
					);

Then send a Blast report to your script via STDIN.

Full parameters for parsing Blast reports.

 %blastParam = ( 
		-run             => \%runParam,
		-file            => '',
		-parse           => 1,
		-signif          => 1e-5, 
		-filt_func       => \&my_filter,
		-min_len         => 15, 
		-check_all_hits  => 0,
		-strict          => 0,
		-stats           => 1,
		-best            => 0,
		-stream          => 0,
		-share           => 0,
		-exec_func       => \&process_blast,
		-save_array      => \@blast_objs,  # not used if -exce_func defined.
	       );

See L<parse>() for a description of parameters and see L<USAGE> for
more examples including how to parse streams containing multiple Blast reports 
L<Using the Static $Blast Object>.


=head2 Running Blast reports

Run a new Blast2 at NCBI and then parse it:

    %runParam = ( 
		  -method   => 'remote',
		  -prog     => 'blastp',
		  -database => 'swissprot',
		  -seqs     => [ $seq ],  # Bio::Seq.pm objects.
		  );     
 
    $blastObj = Bio::Tools::Blast->new( -run     => \%runParam,
					-parse   => 1,  
					-signif  => '1e-10',
					-strict  => 1,
					);

Full parameters for running Blasts at NCBI using Webblast.pm:

 %runParam = ( 
	      -method   => 'remote',
	      -prog     => 'blastp',
	      -version  => 2,      # BLAST2
	      -database =>'swissprot',
	      -html     => 0,
	      -seqs     => [ $seqObject ],  # Bio::Seq.pm object(s)
	      -descr    => 250,
	      -align    => 250,
	      -expect   => 10,
	      -gap      => 'on',
	      -matrix   => 'PAM250',
	      -email    => undef,  # don't send report via e-mail if parsing.
	      -filter   => undef,  # use default
	      -gap_c    => undef,  # use default
	      -gap_e    => undef,  # use default
	      -word     => undef,  # use default
	      -min_len  => undef,  # use default
	      );     

See L<run>() and L<USAGE> for more information about running Blasts.


=head2 HTML-formatting Blast reports

Print an HTML-formatted version of a Blast report:

    use Bio::Tools::Blast qw(:obj);

    $Blast->to_html($filename);
    $Blast->to_html(-file   => $filename,
		    -header => "<H1>Blast Results</H1>");
    $Blast->to_html(-file   => $filename,
		    -out    => \@array);  # store output
    $Blast->to_html();  # use STDIN

Results are sent directly to STDOUT unless an C<-out =E<gt> array_ref> parameter 
is supplied. See L<to_html>() for details.


=head1 INSTALLATION

This module is included with the central Bioperl distribution:

   http://bio.perl.org/Core/Latest
   ftp://bio.perl.org/pub/DIST

Follow the installation instructions included in the README file.

=head1 DESCRIPTION

The Bio::Tools::Blast.pm module encapsulates data and methods for running, 
parsing, and analyzing pre-existing BLAST reports. This module defines an application
programming interface (API) for working with Blast reports. A Blast object is constructed
from raw Blast output and encapsulates the Blast results which can then be accessed
via the interface defined by the Blast object.

The ways in which researchers use Blast data are many and varied. This module attempts
to be general and flexible enough to accommodate different uses. The Blast module
API is still at an early stage of evolution and I expect it to continue to evolve as new
uses for Blast data are developed. Your L<FEEDBACK> is welcome.

B<FEATURES:>

=over 2

=item * Supports NCBI Blast1.x, Blast2.x, and WashU-Blast2.x, gapped and ungapped.

Can parse HTML-formatted as well as non-HTML-formatted reports.

=item * Launch new Blast analyses remotely or locally.

Blast objects can be constructed directly from the results of the run. See L<run>(). 

=item * Construct Blast objects from pre-existing files or from a new run.

Build a Blast object from a single file or build multiple Blast objects
from an input stream containing multiple reports. See L<parse>().

=item * Add hypertext links from a BLAST report.

See L<to_html>().

=item * Generate sequence and sequence alignment objects from HSP sequences.

If you have Bio::Seq.pm and Bio::UnivAln.pm installed on your system, they can be used 
for working with high-scoring segment pair (HSP) sequences in the Blast alignment.
(A new version of Bio::Seq.pm is included in the distribution, see L<INSTALLATION>).
For more information about them, see:

    http://bio.perl.org/Projects/Sequence/
    http://bio.perl.org/Projects/SeqAlign/

=back

A variety of different data can be extracted from the Blast report
by querying the Blast.pm object. Some basic examples are given in the
L<USAGE> section. For some working scripts, see the links provided 
in the L<DEMO SCRIPTS> section.

As a part of the incipient Bioperl framework, the Bio::Tools::Blast.pm module inherits from
B<Bio::Tools::SeqAnal.pm>, which provides some generic functionality for biological 
sequence analysis. See the documentation for that module for details (L<Links to related modules>).


=head2 The BLAST Program

BLAST (Basic Local Alignment Search Tool) is a widely used algorithm 
for performing rapid sequence similarity 
searches between a single DNA or protein sequence and a large dataset of sequences.
BLAST analyses are typically performed by dedicated remote servers,
such as the ones at the NCBI. Individual groups may also run the program 
on local machines.

The Blast family includes 5 different programs:

              Query Seq        Database
             ------------     ----------
 blastp  --  protein          protein
 blastn  --  nucleotide       nucleotide 
 blastx  --  nucleotide*      protein
 tblastn --  protein          nucleotide*
 tblastx --  nucleotide*      nucleotide*
 
            * = dynamically translated in all reading frames, both strands

See L<References & Information about the BLAST program>.


=head2 Versions Supported

BLAST reports generated by different application front ends are similar
but not exactly the same. Blast reports are not intended to be exchange formats, 
making parsing software susceptible to obsolescence. This module aims to 
support BLAST reports generated by different implementations:

  Implementation    Latest version tested
  --------------    --------------------
  NCBI Blast1       1.4.11   [24-Nov-97] 
  NCBI Blast2       2.0.8    [Jan-5-1999]
  WashU-BLAST2      2.0a19MP [05-Feb-1998]
  GCG               1.4.8    [1-Feb-95]

Support for both gapped and ungapped versions is included. Currently, there
is no special support for PSI-BLAST.


=head2 References & Information about the BLAST program

B<WEBSITES:>

   http://www.ncbi.nlm.nih.gov/BLAST/                 - Homepage at NCBI
   http://www.ncbi.nlm.nih.gov/BLAST/blast_help.html  - Help manual
   http://blast.wustl.edu/                            - WashU-Blast2


B<PUBLICATIONS:> (with PubMed links)


     Altschul S.F., Gish W., Miller W., Myers E.W., Lipman D.J. (1990).
     "Basic local alignment search tool", J Mol Biol 215: 403-410.

http://www.ncbi.nlm.nih.gov/htbin-post/Entrez/query?uid=2231712&form=6&db=m&Dopt=r

     Altschul, Stephen F., Thomas L. Madden, Alejandro A. Schaffer,
     Jinghui Zhang, Zheng Zhang, Webb Miller, and David J. Lipman (1997).
     "Gapped BLAST and PSI-BLAST: a new generation of protein database 
     search programs", Nucleic Acids Res. 25:3389-3402.

http://www.ncbi.nlm.nih.gov/htbin-post/Entrez/query?uid=9254694&form=6&db=m&Dopt=r

     Karlin, Samuel and Stephen F. Altschul (1990).  Methods  for
     assessing the statistical significance of molecular sequence
     features by using general scoring schemes. Proc. Natl. Acad.
     Sci. USA 87:2264-68.

http://www.ncbi.nlm.nih.gov/htbin-post/Entrez/query?uid=2315319&form=6&db=m&Dopt=b

     Karlin, Samuel and Stephen F. Altschul (1993).  Applications
     and statistics for multiple high-scoring segments in molecu-
     lar sequences. Proc. Natl. Acad. Sci. USA 90:5873-7.

http://www.ncbi.nlm.nih.gov/htbin-post/Entrez/query?uid=8390686&form=6&db=m&Dopt=b




=head1 USAGE

=head2 Creating Blast objects

A Blast object is constructed from the contents of a Blast report using 
a set of named parameters. The report data
can be read in from an existing file specified with the 
C<-file =E<gt> 'filename'> parameter or from a
STDIN stream containing potentially multiple
Blast reports. If the C<-file> parameter does not contain a valid filename, 
STDIN will be used. 

To parse the report, you must include a C<-parse =E<gt> 1> parameter
in addition to any other parsing parameters
See L<parse>() for a full description of parsing parameters.
To run a new report and then parse it, include a C<-run =E<gt> \%runParams> 
parameter containing a reference to a hash
that hold the parameters required by the L<run>() method.
L<_initialize> is called by L<new>() and contains general information 
for creating Blast objects. (The L<new>() method is inherited from
B<Bio::Root::Object.pm>, see L<Links to related modules>).

Pre-existing file are automatically uncompressed/compressed 
to access the data and will be left compressed if they
were originally compressed. Compression/decompression uses the gzip or compress programs 
that are standard on Unix systems and should not require special configuration.
  
Blast objects can be generated either by direct instantiation as in:

 use Bio::Tools::Blast;		 
 $blast = new Bio::Tools::Blast (%parameters);

=head2 Using the Static $Blast Object

 use Bio::Tools::Blast qw(:obj);		 

This exports the static $Blast object into your namespace. "Static"
refers to the fact that it has class scope and there is one of these
created when you use this module. The static $Blast object is
basically an empty object that is provided for convenience and is also
used for various internal chores.

It is exported by this module and can be used for
parsing and running reports as well as HTML-formatting without having
to first create an empty Blast object.

Using the static $Blast object for parsing a STDIN stream of Blast reports:

    use Bio::Tools::Blast qw(:obj);

    sub process_blast {
	$blastObj = shift;
	print $blastObj->table();
	$blastObj->destroy;
    }

    $Blast->parse( -parse     => 1,
		   -stream    => 1,  
		   -signif    => '1e-10',
		   -exec_func => \&process_blast,
		   );

Then pipe a stream of Blast reports into your script via STDIN.
For each Blast report extracted from the input stream, the parser will generate 
a new Blast object and pass it to the function specified by C<-exec_func>.
The L<destroy>() call tells Perl to free the memory associated with the object,
important if you are crunching through many reports. This method is inherited
from B<Bio::Root::Object.pm> (see L<Links to related modules>). See L<parse>() for
a full description of parameters and L<DEMO SCRIPTS> for additional examples.


=head2 Running Blasts

To run a Blast, create a new Blast object with a C<-run =E<gt> \%runParams> parameter.
Remote Blasts are performed by including a  C<-method =E<gt> 'remote'> parameter;
local Blasts are performed by including a  C<-method =E<gt> 'local'> parameter.
See L<Running Blast reports> as well as the L<DEMO SCRIPTS> for examples.

Note that the C<-method =E<gt> [ $seqs ]> parameter must contain a reference to an array
of B<Bio::Seq.pm> objects (L<Links to related modules>). Encapsulating the sequence in 
an object makes sequence information much easier to handle as it can be supplied in 
a variety of formats. Bio::Seq.pm is included with this distribution (L<INSTALLATION>).

Remote Blasts are implemented using the B<Bio::Tools::Blast::Run::Webblast.pm> module.
Local Blasts require that you customize the B<Bio::Tools::Blast::Run::LocalBlast.pm> module.
The version of this module included with this distribution provides the basic framework
for running local Blasts. See L<Links to related modules>.


=head2 Significance screening

A C<-signif> parameter can be used to screen out all
hits with P-values (or Expect values) above a certain cutoff. For example, to exclude all 
hits with Expect values above 1.0e-10: C<-signif =E<gt> 1e-10>. Providing a
C<-signif> cutoff can speed up processing tremendously, since only a small
fraction of the report need be parsed. This is because the C<-signif> value is used 
to screen hits based on the data in the "Description" section of the Blast report:

For NCBI BLAST2 reports:

                                                                     Score     E
  Sequences producing significant alignments:                        (bits)  Value
 
  sp|P31376|YAB1_YEAST  HYPOTHETICAL 74.1 KD PROTEIN IN CYS3-MDM10...   957  0.0


For BLAST1 or WashU-BLAST2 reports:

                                                                       Smallest
                                                                         Sum
                                                                High  Probability
  Sequences producing High-scoring Segment Pairs:              Score  P(N)      N
 
  PDB:3PRK_E Proteinase K complexed with inhibitor ...........   504  1.8e-50   1


Thus, the C<-signif> parameter will screen based on Expect values for BLAST2 reports
and based on P-values for BLAST1/WashU-BLAST2 reports.

To screen based on other criteria, you can supply a C<-filt_func> parameter containing 
a function reference that takes a B<Bio::Tools::Sbjct.pm> object as an argument and
returns a boolean, true if the hit is to be screened out. See example below for
L<Screening hits using arbitrary criteria>.


=head2 Get the best hit.

     $hit = $blastObj->hit;  

A "hit" is contained by a B<Bio::Tools::Blast::Sbjct.pm> object. 
 
 
=head2 Get the P-value or Expect value of the most significant hit.

     $p = $blastObj->lowest_p;      
     $e = $blastObj->lowest_expect; 

Alternatively:

     $p = $blastObj->hit->p;      
     $e = $blastObj->hit->expect; 

Note that P-values are not reported in NCBI Blast2 reports.
 
 
=head2 Iterate through all the hits

     foreach $hit ($blastObj->hits) {
	 printf "%s\t %.1e\t %d\t %.2f\t %d\n", 
	                  $hit->name, $hit->expect, $hit->num_hsps,
                          $hit->frac_identical, $hit->gaps;
     }

Refer to the documentation for B<Bio::Tools::Blast::Sbjct.pm> 
for other ways to work with hit objects (L<Links to related modules>).

=head2 Screening hits using arbitrary criteria

    sub filter { $hit=shift;
		 return ($hit->gaps == 0 and 
			 $hit->frac_conserved > 0.5); }
 
     $blastObj = Bio::Tools::Blast->new( -file      => '/tmp/blast.out',
					 -parse     => 1,  
					 -filt_func => \&filter );

While the Blast object is parsing the report, each hit checked by calling
&filter($hit). All hits that generate false return values from &filter
are screened out and will not be added to the Blast object.
Note that the Blast object will normally stop parsing the report after
the first non-significant hit or the first hit that does not pass the
filter function. To force the Blast object to check all hits,
include a C<-check_all_hits =E<gt> 1>  parameter.
Refer to the documentation for B<Bio::Tools::Blast::Sbjct.pm> 
for other ways to work with hit objects.

=head3 Hit start, end coordinates.

      print $sbjct->start('query');
      print $sbjct->end('sbjct');

In array context, you can get information for both query and sbjct with one call:

      ($qstart, $sstart) = $sbjct->start();
      ($qend, $send)     = $sbjct->end();

For important information regarding coordinate information, see 
the L<HSP start, end, and strand> section below.
Also check out documentation for the start and end methods in B<Bio::Tools::Blast::Sbjct.pm>,
which explains what happens if there is more than one HSP.

=head2 Working with HSPs

=head3 Iterate through all the HSPs of every hit

     foreach $hit ($blastObj->hits) {
	 foreach $hsp ($hit->hsps) {
	 printf "%.1e\t %d\t %.1f\t %.2f\t %.2f\t %d\t %d\n", 
	                  $hsp->expect, $hsp->score, $hsp->bits,
                          $hsp->frac_identical, $hsp->frac_conserved, 
	                  $hsp->gaps('query'), $hsp->gaps('sbjct');
     }

Refer to the documentation for B<Bio::Tools::Blast::HSP.pm> 
for other ways to work with hit objects (L<Links to related modules>).


=head3 Extract HSP sequence data as strings or sequence objects

Get the first HSP of the first hit and the sequences
of the query and sbjct as strings.

      $hsp = $blast_obj->hit->hsp;  
      $query_seq = $hsp->seq_str('query');
      $hsp_seq = $hsp->seq_str('sbjct');

Get the indices of identical and conserved positions in the HSP query seq.

      @query_iden_indices = $hsp->seq_inds('query', 'identical');
      @query_cons_indices = $hsp->seq_inds('query', 'conserved');

Similarly for the sbjct sequence.

      @sbjct_iden_indices = $hsp->seq_inds('sbjct', 'identical');
      @sbjct_cons_indices = $hsp->seq_inds('sbjct', 'conserved');
      	    
      print "Query in Fasta format:\n", $hsp->seq('query')->layout('fasta');
      print "Sbjct in Fasta format:\n", $hsp->seq('sbjct')->layout('fasta');

See the B<Bio::Seq.pm> package for more information about using these sequence objects
(L<Links to related modules>).

=head3 Create sequence alignment objects using HSP sequences

      $aln = $hsp->get_aln;
      print " consensus:\n", $aln->consensus();
      print $hsp->get_aln->layout('fasta');
 
      $ENV{READSEQ_DIR} = '/home/users/sac/bin/solaris';
      $ENV{READSEQ} = 'readseq';
      print $hsp->get_aln->layout('msf');

MSF formated layout requires Don Gilbert's ReadSeq program (not included). 
See the B<Bio::UnivAln.pm> for more information about using these alignment objects 
(L<Links to related modules>)'.

=head3 HSP start, end, and strand.

To facilitate HSP processing, endpoint data for each HSP sequence are 
normalized so that B<start is always less than end>. This affects TBLASTN 
and TBLASTX HSPs on the reverse complement or "Minus" strand.

Some examples of obtaining start, end coordinates for HSP objects:

      print $hsp->start('query');
      print $hsp->end('sbjct');
      ($qstart, $sstart) = $hsp->start();
      ($qend, $send) = $hsp->end();

Strandedness of the HSP can be assessed using the strand() method 
on the HSP object:

      print $hsp->strand('query');
      print $hsp->strand('sbjct');

These will return 'Minus' or 'Plus'.
Or, to get strand information for both query and sbjct with a single call:

      ($qstrand, $sstrand) = $hsp->strand();


=head2 Report Generation

=head3 Generate a tab-delimited table of all results.

     print $blastObj->table;       
     print $blastObj->table(0);   # don't include hit descriptions.
     print $blastObj->table_tiled; 

The L<table>() method returns data for each B<HSP> of each hit listed one per
line. The L<table_tiled>() method returns data for each B<hit, i.e., Sbjct>
listed one per line; data from multiple HSPs are combined after tiling to
reduce overlaps. See B<Bio::Tools::Blast::Sbjct.pm> for more information about
HSP tiling.  These methods generate stereotypical, tab-delimited data for each
hit of the Blast report. The output is suitable for importation into
spreadsheets or database tables. Feel free to roll your own table function if
you need a custom table.

For either table method, descriptions of each hit can be included if a 
single, true argument is supplied (e.g., $blastObj->table(1)). The description 
will be added as the last field. This will significantly increase the size of
the table. Labels for the table columns can be obtained with L<table_labels>()
and L<table_labels_tiled>().

=head3 Print a summary of the Blast report

     $blastObj->display();     
     $blastObj->display(-show=>'hits');

L<display>() prints various statistics extracted from the Blast report
such as database name, database size, matrix used, etc. The C<display(-show=E<gt>'hits')>
call prints a non-tab-delimited table attempting to line the data up into 
more readable columns. The output generated is similar to L<table_tiled>().

=head3 HTML-format an existing report

     use Bio::Tools::Blast qw(:obj);
 
     # Going straight from a non HTML report file to HTML output using 
     # the static $Blast object exported by Bio::Tools::Blast.pm
     $Blast->to_html(-file   => '/usr/people/me/blast.output.txt',
		     -header => qq|<H1>BLASTP Results</H1><A HREF="home.html">Home</A>|
		     );
 
     # You can also use a specific Blast object created previously.
     $blastObj->to_html;

L<to_html>() will send HTML output, line-by-line, directly to STDOUT 
unless an C<-out =E<gt> array_ref> parameter is supplied (e.g., C<-out =E<gt> \@array>),
in which case the HTML will be stored in @array, one line per array element. 
The direct outputting permits faster response time since Blast 
reports can be huge. The -header tag can contain a string containing any HTML
that you want to appear at the top of the Blast report.


=head1 DEMO SCRIPTS

Sample Scripts are available at the following URLs. These scripts are included in the
in the installed 'exxamples/blast/' directory (see L<INSTALLATION>).

=head2 Handy library for working with Bio::Tools::Blast.pm

   http://bio.perl.org/Core/Examples/blast/blast_config.pl

=head2 Parsing Blast reports one at a time.

   http://bio.perl.org/Core/Examples/blast/parse.pl
   http://bio.perl.org/Core/Examples/blast/parse2.pl
   http://bio.perl.org/Core/Examples/blast/parse_positions.pl

=head2 Parsing Blast report streams.

   http://bio.perl.org/Core/Examples/blast/parse_stream.pl
   http://bio.perl.org/Core/Examples/blast/parse_multi.pl

B<Warning:> Parsing streams containing large numbers of Blast reports
(a few thousand or so) using parse_stream.pl or parse_multi.pl
may lead to unacceptable memory usage situations. This 
is somewhat dependent of the size and complexity of the reports. 


=head2 Running Blast analyses one at a time.

   http://bio.perl.org/Core/Examples/blast/run.pl

=head2 Running Blast analyses given a set of sequences.

   http://bio.perl.org/Core/Examples/blast/blast_seq.pl

=head2 HTML-formatting Blast reports.

   http://bio.perl.org/Core/Examples/blast/html.pl



=head1 TECHNICAL DETAILS

=head2 Blast Modes

A BLAST object may be created using one of three different modes as defined
by the B<Bio::Tools::SeqAnal.pm> package (See L<Links to related modules>):

 -- parse    - Load a BLAST report and parse it, storing parsed data in Blast.pm object.
 -- run      - Run the BLAST program to generate a new report. 
 -- read     - Load a BLAST report into the Blast object without parsing.


B<Run mode support has recently been added>. 
The module B<Bio::Tools::Blast::Run::Webblast.pm> is an modularized adaptation 
of the webblast script by Alex Dong Li: 

   http://www.genet.sickkids.on.ca/bioinfo_resources/software.html#webblast

for running remote Blast analyses and saving the results locally.
Run mode can be combined with a parse mode to generate a Blast report and then
build the Blast object from the parsed results of this report 
(see L<run>() and L<SYNOPSIS>).

In read mode, the BLAST report is read in by the Blast object but is not parsed.
This could be used to internalize a Blast report but not parse
it for results (e.g., generating HTML formatted output). 



=head2 Significant Hits

This module permits the screening of hits on the basis of user-specified criteria
for significance. Currently, Blast reports can be screened based on:

   CRITERIA                            PARAMETER       VALUE
   ----------------------------------  ---------      ----------------
  1) the best Expect (or P) value      -signif        float or sci-notation
  2) the length of the query sequence  -min_length    integer
  3) arbitrary criteria                -filt_func     function reference

The parameters are used for construction of the BLAST object
or when running the L<parse>() method on the static $Blast object.
The -SIGNIF value represents the number listed in the description section 
at the top of the Blast report. For Blast2, this is an Expect value, for Blast1
and WashU-Blast2, this is a P-value. 
The idea behind the C<-filt_func> parameter is that the hit has to pass through a
filter to be considered significant. Refer to the documentation for 
B<Bio::Tools::Blast::Sbjct.pm> for ways to work with hit objects.

Using a C<-signif> parameter allows for the following:

=over 2

=item Faster parsing.

Each hit can be screened by examination of the description line alone without 
fully parsing the HSP alignment section.

=item Flexibility.

The C<-signif> tag provides a more semantic-free way to specify the value to be 
used as a basis for screening hits. Thus, C<-signif> can be used for
screening Blast1 or Blast2 reports. It is up to the user to understand whether
C<-signif> represents a P-value or an Expect value.

=back

Any hit not meeting the significance criteria will not be added to the
"hit list" of the BLAST object. Also, a BLAST object without
any hits meeting the significance criteria will throw an exception during object
construction (a fatal event).  


=head2 Statistical Parameters

There are numerous parameters which define the behavior of the BLAST program
and which are useful for interpreting the search results. These parameters 
are extracted from the Blast report:

  filter  --  for masking out low-complexity sequences or short repeats
  matrix  --  name of the substitution scoring matrix (e.g., BLOSUM62)
  E       --  Expect filter (screens out frequent scores)
  S       --  Cutoff score for segment pairs
  W       --  Word length
  T       --  Threshold score for word pairs
  Lambda, --  Karlin-Altschul "sum" statistical parameters dependent on  
   K, H        sequence composition.
  G       --  Gap creation penalty.
  E       --  Gap extension penalty. 

These parameters are not always needed. Extraction may be turned off 
explicitly by including a C<-stats =E<gt> 0> parameter during object construction.              
Support for all statistical parameters is not complete.

For more about the meaning of parameters, check out the NCBI URLs given above.


=head2 Module Organization

The modules that comprise this Bioperl Blast distribution are location in the
Bio:: hierarchy as shown in the diagram below.

                            Bio/
                             |
               +--------------------------+
               |                          |
          Bio::Tools                  Bio::Root
               |                          |
    +----------------------+           Object.pm
    |          |           |
 SeqAnal.pm  Blast.pm    Blast/
                           |
            +---------+---------+------------+
            |         |         |            |
          Sbjct.pm   HSP.pm   HTML.pm       Run/
                                             |
                                       +------------+
                                       |            |
                                  Webblast.pm   LocalBlast.pm 


Bio::Tools::Blast.pm is a concrete class that inherits from B<Bio::Tools::SeqAnal.pm>
and relies on other modules for parsing and managing BLAST data.
Worth mentioning about this hierarchy is the lack of a "Parse.pm" module.
Since parsing is considered central to the purpose of the Bioperl Blast module
(and Bioperl in general), it seems somewhat unnatural to segregate out all
parsing code. This segregation could also lead to inefficiencies and
harder to maintain code. I consider this issue still open for debate.

Bio::Tools::Blast.pm, B<Bio::Tools::Blast::Sbjct.pm>, and B<Bio::Tools::Blast::HSP.pm> are 
mostly dedicated
to parsing and all can be used to instantiate objects.
Blast.pm is the main "command and control" module, inheriting some basic
behaviors from SeqAnal.pm (things that are not specific to Blast I<per se>).

B<Bio::Tools::Blast::HTML.pm> contains functions dedicated to generating HTML-formatted Blast 
reports and does not generate objects.

=head2 Running Blasts: Details

B<Bio::Tools::Blast::Run::Webblast.pm> contains a set of functions for
running Blast analyses at a remote server and also does not instantiate objects.
It uses a helper script called postclient.pl, located in the Run directory.
The proposed LocalBlast.pm module would be used for running Blast reports
on local machines and thus would be customizable for different sites. It would
operate in a parallel fashion to Webblast.pm (i.e., being a collection of 
functions, taking in sequence objects or files, returning result files).

The Run modules are considered experimental. In particular, Webblast.pm catures 
an HTML-formatted version of the Blast report from the NCBI server and strips out the HTML in 
preparation for parsing. A more direct approach would be to capture the Blast results 
directly from the server using an interface to the NCBI toolkit. 
This approach was recently proposed on the Bioperl
mailing list: http://www.uni-bielefeld.de/mailinglists/BCD/vsns-bcd-perl/9805/0000.html


=head1 TODO

=over 4

=item * Develop a functional, prototype Bio::Tools::Blast::Run::LocalBlast.pm module.

=item * Add support for PSI-BLAST

=item * Permit Webblast.pm to handle sequence files 

as well as Bio::Seq.pm objects

=item * Further exploit Bio::UnivAln.pm 

and multiple-sequence alignment programs using HSP sequence data. Some of this may 
best go into a separate, dedicated module or script as opposed to 
burdening Blast.pm, Sbjct.pm, and HSP.pm with additional functionality that is not always
required.

=item * Parse histogram of expectations & retrieve gif image in Blast report (if present).

=item * Add a method to the Blast object for removing HTML from a Blast report.

Use Bio::Tools::Blast::HTML::strip_html().

=item * Access Blast results directly from the NCBI server

using a Perl interface to the NCBI toolkit (when available).

=item * Enhance the test script 

for use with "make test" during installation.

=item * Explore alternatives to autoloading.

=item * Fix memory leak that occurs when parsing Blast streams.

=item * Enhance performance.

=item * Improve documentation.

=back


=head1 VERSION

Bio::Tools::Blast.pm, 0.074


=head1 FEEDBACK

=head2 Mailing Lists 

User feedback is an integral part of the evolution of this and other Bioperl modules.
Send your comments and suggestions preferably to one of the Bioperl mailing lists.
Your participation is much appreciated.

    vsns-bcd-perl@lists.uni-bielefeld.de          - General discussion
    vsns-bcd-perl-guts@lists.uni-bielefeld.de     - Technically-oriented discussion
    http://bio.perl.org/MailList.html             - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track the bugs and 
their resolution. Bug reports can be submitted via email or the web:

    bioperl-bugs@bio.perl.org                   
    http://bio.perl.org/bioperl-bugs/           


=head1 AUTHOR

Steve A. Chervitz, sac@genome.stanford.edu

See the L<FEEDBACK> section for where to send bug reports and comments.

=head1 ACKNOWLEDGEMENTS

This module was developed under the auspices of the Saccharomyces Genome
Database:
    http://genome-www.stanford.edu/Saccharomyces

Other contributors include: Alex Dong Li (webblast), Chris Dagdigian
(Seq.pm), Steve Brenner (Seq.pm), Georg Fuellen (Seq.pm, UnivAln.pm),
and untold others who have offered comments (noted in the
Bio/Tools/Blast/CHANGES file of the distribution).

=head1 COPYRIGHT

Copyright (c) 1996-98 Steve A. Chervitz. All Rights Reserved.
This module is free software; you can redistribute it and/or 
modify it under the same terms as Perl itself.

=head1 SEE ALSO

 Bio::Tools::SeqAnal.pm                  - Sequence analysis object base class.
 Bio::Tools::Blast::Sbjct.pm             - Blast hit object.
 Bio::Tools::Blast::HSP.pm               - Blast HSP object.
 Bio::Tools::Blast::HTML.pm              - Blast HTML-formating utility class.
 Bio::Tools::Blast::Run::Webblast.pm     - Utility module for running Blasts remotely.
 Bio::Tools::Blast::Run::LocalBlast.pm   - Utility module for running Blasts locally.
 Bio::Seq.pm                             - Biosequence object  
 Bio::UnivAln.pm                         - Biosequence alignment object.
 Bio::Root::Object.pm                    - Proposed base class for all Bioperl objects.

=head2 Links to related modules

 Bio::Tools::SeqAnal.pm      
      http://bio.perl.org/Core/POD/Tools/SeqAnal.html

 Bio::Tools::Blast::Sbjct.pm 
      http://bio.perl.org/Core/POD/Tools/Blast/Sbjct.html

 Bio::Tools::Blast::HSP.pm   
      http://bio.perl.org/Core/POD/Tools/Blast/HSP.html

 Bio::Tools::Blast::HTML.pm       
      http://bio.perl.org/Core/POD/Tools/Blast/HTML.html

 Bio::Tools::Blast::Run::Webblast.pm 
      http://bio.perl.org/Core/POD/Tools/Blast/Run/Webblast.html

 Bio::Tools::Blast::Run::LocalBlast.pm 
      http://bio.perl.org/Core/POD/Tools/Blast/Run/LocalBlast.html

 Bio::Seq.pm              
      http://bio.perl.org/Core/POD/Seq.html

 Bio::UnivAln.pm             
      http://bio.perl.org/Projects/SeqAlign/
      Europe:  http://www.techfak.uni-bielefeld.de/bcd/Perl/Bio/#univaln

 Bio::Root::Object.pm        
      http://bio.perl.org/Core/POD/Root/Object.html


 http://bio.perl.org/Projects/modules.html  - Online module documentation
 http://bio.perl.org/Projects/Blast/        - Bioperl Blast Project     
 http://bio.perl.org/                       - Bioperl Project Homepage


L<References & Information about the BLAST program>.

=head1 KNOWN BUGS

There is a memory leak that occurs when parsing parsing streams containing 
large numbers of Blast reports (a few thousand or so).
The severity of the leak is dependent of the size and complexity of the 
Blast reports being parsed. 

=cut



#
##
###
#### END of main POD documentation.
###
##
#


=head1 APPENDIX

Methods beginning with a leading underscore are considered private
and are intended for internal use by this module. They are
B<not> considered part of the public interface and are described here
for documentation purposes only.

=cut


##############################################################################
##                          CONSTRUCTOR                                     ##
##############################################################################

=head2 _initialize

 Usage     : $blastObj->_initialize( %named_parameters )
           : Automatically called by Bio::Root::Object::new()
 Purpose   : Calls superclass constructor and initializes some key Blast data.
 Returns   : n/a
 Argument  : Named Parameters (PARAMETER TAGS CAN BE UPPER OR LOWER CASE).
           : The Blast.pm constructor relies on the SeqAnal.pm constructor
           : to handle the parameters it receives from new().
           : These parameters consist of all parameters necessary for parsing
           : and/or running a Blast report in addition to parameters
           : required by SeqAnal.pm.
           : Briefly, to parse a report include this parameter:
           :       -PARSE => 1
           : To run a report, include this parameter:
           :       -RUN => \%run_params 
           : To run + parse, supply both.
           : Please see the SeqAnal::_initialize() method for details.

See Also   : B<Bio::Tools::SeqAnal::_initialize()>, L<parse>(), L<run>(), L<Links to related modules>

=cut

#---------------
sub _initialize {
#---------------
    my( $self, @param ) = @_;
    
    # When parsing a stream of Blast results, don't call superclass constructor.
    if($Blast->{'_stream'}) {
	eval {
	    $self->_parse_stream_data(@param);
	};
	if($@) {
	    push @{$Blast->{'_errs'}}, $@;
	}

    } else {
	$RawData = '';
	$self->SUPER::_initialize( @param );
    }
    $_verbose = $self->verbose() > 0;
}


#-------------
sub destroy {
#-------------
    my $self=shift; 
    $DEBUG==2 && print STDERR "DESTROYING $self ${\$self->name}";
    if($self->{'_hits'}) {
	foreach($self->hits) { 
	    $_->destroy; 
	    undef $_;
	}
	undef $self->{'_hits'};
        #$self->{'_hits'}->remove_all;  ## When and if this member becomes a vector.
    }

    # Not undef-ing to avoid unnecessary re-allocation.
    $Blast->{'_rawData'} = '';
    $RawData   = '';
    $HspString = '';
    $self->SUPER::destroy;
}

#####################################################################################
##                                  ACCESSORS                                      ##
#####################################################################################

=head2 run

 Usage     : $object->run( %named_parameters )
 Purpose   : Run a local or remote Blast analysis on one or more sequences.
 Returns   : String containing name of Blast output file if a single Blast 
           : is run.
           :  -- OR --
           : List of Blast objects if multiple Blasts are being run as a group.
 Argument  : Named parameters:  (PARAMETER TAGS CAN BE UPPER OR LOWER CASE).
           :    -METHOD  => 'local' or 'remote' (default = remote),
           :    -PARSE   => boolean, (true if the results are to be parsed after the run)
           :    -STRICT  => boolean, the strict mode to use for the resulting Blast objects.
           :  ADDITIONAL PARAMETERS:
           :      See methods _run_remote() and _run_local() for required
           :      parameters necessary for running the blast report.
 Throws    : Exception if no Blast output file was obtained.
 Comments  : This method is called automatically during construction of a 
           : Blast.pm object when run parameters are sent to the constructor:
           :  $blastObj = new Bio::Tools::Blast (-RUN =>\%runParam,
	   :					 %parseParam );
           :
           : The specific run methods (local or remote) called by run() 
           : must return a list containing  the file name(s) with the Blast output. 
           :
           : The run() method can perform single or multiple Blast runs
           : (analogous to the way parse() works) depending on how many 
           : sequences are submitted. However, the running of multiple
           : Blasts is probably better handled at the script level. See notes in
           : the "TODO" section below.
           :
           : As for what to do with the Blast result file, that decision is 
           : left for the user who can direct the Blast object to delete, compress,
           : or leave it alone.
           :
           : This method does not worry about load balancing, which
           : is probably best handled at the server level.
           :
 TODO:     : Support for running+parsing multiple Blast analyses with a 
           : single run() call is incomplete. One can generate multiple 
           : reports by placing more than one sequence object in the -seqs  
           : reference parameter. This saves some overhead in the code 
           : that executes the Blasts since all options are configured once.
           : (This is analogous to parsing using the static $Blast object 
           : see parse() and _parse_stream()).
           :
           : The trouble is that Blast objects for all runs are constructed,
           : parsed (if necessary), and then returned as a group
           : This can require lots of memory when run+parsing many Blasts
           : but should be fine if you just want to run a bunch Blasts.
           :
           : For now, when running+parsing Blasts, stick to running one 
           : Blast at a time, building the Blast object with the results 
           : of that report, and processing as necessary.
           : 
           : Support for running PSI-Blast is not complete.

See Also:  L<_run_remote>(), L<_run_local>(), L<parse>()

=cut

#---------
sub run {
#---------
    my ($self, %param) = @_;
    my($method, $parse, $strict) = 
	$self->_rearrange([qw(METHOD PARSE STRICT)], %param);

    $strict = $self->strict($strict) if $strict;

    my (@files);
    if($method =~ /loc/i) {
	@files = $self->_run_local(%param);
	
    } else {
	@files = $self->_run_remote(%param);
    }
    
    $self->throw("Run Blast failed: no Blast output created.") if !@files;

    if(scalar(@files) == 1) {
	# If there was just one Blast output file, prepare to incorporate it
	# into the current Blast object. run() is called before parse() in the
	# SeqAnal.pm constructor.
	if($files[0] ne 'email') {
	    $self->file($files[0]);
	} else { 
	    # Can't do anything with the report.
	    $self->throw("Blast report to be sent via e-mail.");
	} 

    } else {
	# If there are multiple report files, build individual Blast objects foreach.
	# In this situation, the static $Blast object is being used to run
	# a set of related Blasts, similar to the way parse() can be used.
	# This strategy is not optimal since all reports are generated first
	# before any are parsed. 
	# Untested.

	my(@objs);
	foreach(@files) {
	    push @objs, new Bio::Tools::Blast(-FILE   => $_,
					      -PARSE  => $parse || 0,
					      -STRICT => $strict,
					      );
	}
	return @objs;
    }
}


=head2 _run_remote

 Usage     : n/a; internal method called by run()
           : $object->_run_remote( %named_parameters )
 Purpose   : Run Blast on a remote server.
 Argument  : Named parameters:
           :   See documentation for function &blast_remote in
           :   Bio::Tools::Blast::Run::Webblast.pm for description 
           :   of parameters.
 Comments  : This method requires the Bio::Tools::Blast::Run::Webblast.pm
           : which conforms to this minimal API:
           :    * export a method called &blast_remote that accepts a 
           :      Bio::Tools::Blast.pm object + named parameters
           :      (specified in the Webblast.pm module).
           :    * return a list of names of files containing the raw Blast reports.
           :      (When building a Blast object, this list would contain a 
           :       single file from which the Blast object is to be constructed).

See Also   : L<run>(), L<_run_local>(), B<Bio::Tools::Blast::Run::Webblast.pm::blast_remote()>, L<Links to related modules>

=cut

#----------------
sub _run_remote {
#----------------
    my ($self, %param) = @_;

    require Bio::Tools::Blast::Run::Webblast; 
    import  Bio::Tools::Blast::Run::Webblast qw(&blast_remote);

    &blast_remote($self, %param);
}



=head2 _run_local

 Usage     : n/a; internal method called by run()
           : $object->_run_local(%named_parameters)
 Purpose   : Run Blast on a local machine.
 Argument  : Named parameters:
           :   See documentation for function &blast_local in
           :   Bio::Tools::Blast::Run::LocalBlast.pm for description 
           :   of parameters.
 Comments  : This method requires the Bio::Tools::Blast::Run::LocalBlast.pm
           : module which should be customized for your site. This module would 
           : contain all the commands, paths, environment variables, and other 
           : data necessary to run Blast commands on a local machine, but should
           : not contain any semantics for specific query sequences.
           :
           : LocalBlast.pm should also conform to this minimal API:
           :    * export a method called &blast_local that accepts a 
           :       Bio::Tools::Blast.pm object + named parameters
           :      (specified in the LocalBlast.pm module).
           :    * return a list of names of files containing the raw Blast reports.
           :      (When building a Blast object, this list would contain a 
           :       single file from which the Blast object is to be constructed).

See Also   : L<run>(), L<_run_remote>(), B<Bio::Tools::Blast::Run::LocalBlast::blast_local()>, L<Links to related modules>

=cut

#--------------
sub _run_local {
#--------------
    my ($self, %param) = @_;
    
    require Bio::Tools::Blast::Run::Webblast; 
    import  Bio::Tools::Blast::Run::Webblast qw(&blast_local);

    &blast_local($self, %param);
}


=head2 db_remote

 Usage     : @dbs = $Blast->db_remote( [seq_type] );
 Purpose   : Get a list of available sequence databases for remote Blast analysis.
 Returns   : Array of strings 
 Argument  : seq_type = 'p' or 'n' 
           :  'p' = Gets databases for peptide searches  (default)
           :  'n' = Gets databases for nucleotide searches 
 Throws    : n/a
 Comments  : Peptide databases are a subset of the nucleotide databases.
           : It is convenient to call this method on the static $Blast object
           : as shown in Usage.

See Also   : L<db_local>()

=cut

#----------------
sub db_remote {
#----------------
    my ($self, $type) = @_;
    $type ||= 'p';

    require Bio::Tools::Blast::Run::Webblast; 

    my(@dbs);
    if( $type =~ /^p|amino/i) {
	@dbs = @Bio::Tools::Blast::Run::Webblast::Blast_dbp_remote;
    } else {
	@dbs = @Bio::Tools::Blast::Run::Webblast::Blast_dbn_remote;
    }
    @dbs;
}



=head2 db_local

 Usage     : @dbs = $Blast->db_local( [seq_type] );
 Purpose   : Get a list of available sequence databases for local Blast analysis.
 Returns   : Array of strings 
 Argument  : seq_type = 'p' or 'n'
           :  'p' = Gets databases for peptide searches  (default)
           :  'n' = Gets databases for nucleotide searches 
 Throws    : n/a
 Comments  : Peptide databases are a subset of the nucleotide databases.
           : It is convenient to call this method on the static $Blast object.
             as shown in Usage.

See Also   : L<db_remote>()

=cut

#----------------
sub db_local {
#----------------
    my ($self, $type) = @_;
    $type ||= 'p';

    require Bio::Tools::Blast::Run::LocalBlast; 

    my(@dbs);
    if( $type =~ /^p|amino/i) {
	@dbs = @Bio::Tools::Blast::Run::LocalBlast::Blast_dbp_local;
    } else {
	@dbs = @Bio::Tools::Blast::Run::LocalBlast::Blast_dbn_local;
    }
    @dbs;
}


=head2 parse

 Usage     : $blast_object->parse( %named_parameters )
 Purpose   : Parse a Blast report from a file or STDIN.
           :   * Handles both single files and streams containing multiple reports.
           :   * Relies on a panel of private methods to parse the raw BLAST data.
           :   * Sets the significance cutoff.
           :   * Extracts parameters about the BLAST run.
 Returns   : integer (number of Blast reports parsed)
 Argument  : <named parameters>:  (PARAMETER TAGS CAN BE UPPER OR LOWER CASE).
	   : -FILE       => string (name of file containing raw Blast output. 
           :                         Optional. If a valid file is not supplied, 
	   :		             STDIN will be used).
	   : -SIGNIF     => number (float or scientific notation number to be used
	   :                         as a P- or Expect value cutoff; 
	   :			     default =  $DEFAULT_SIGNIF (999)).
	   : -FILT_FUNC  => func_ref (reference to a function to be used for 
           :                          filtering out hits based on arbitrary criteria. 
           :                          This function should take a
           :                          Bio::Tools::Blast::Sbjct.pm object as its first
           :                          argument and return a boolean value,
	   :                          true if the hit should be filtered out).
           :                          Sample filter function:
           :                          -FILT_FUNC => sub { $hit = shift;
	   :				                  $hit->gaps == 0; },
           : -CHECK_ALL_HITS => boolean (check all hits for significance against
           :                             significance criteria.  Default = false.
	   :			         If false, stops processing hits after the first
           :                             non-significant hit or the first hit that fails
           :                             the filt_func call. This speeds parsing, 
           :                             taking advantage of the fact that the hits 
           :                             are processed in the order they are ranked.)
           : -MIN_LEN     => integer (to be used as a minimum query sequence length
           :                          sequences below this length will not be processed).
           :                          default = no minimum length).
	   : -STATS       => boolean (collect stats for report: matrix, filters, etc.
           :                          default = false).
	   : -BEST        => boolean (only process the best hit of each report; 
           :                          default = false).
	   : -GAPPED      => boolean (gapped can be provided if you know in advance
           :                          that the reports were gapped. Otherwise, it will
	   :			      be determined from the report; default = false).
           : -OVERLAP     => integer (the amount of overlap to permit between 
           :                          adjacent HSPs when tiling HSPs, 
           :                          Default = $MAX_HSP_OVERLAP (2))
           :
           : PARAMETERS USED WHEN PARSING MULTI-REPORT STREAMS:
           : --------------------------------------------------
	   : -STREAM      => boolean (true when parsing a Blast stream containing 
           :                          multiple reports. Default = false).
	   : -SHARE       => boolean (set this to true if all reports in stream
	   :			      share the same stats. Default = true)
           :                          Must be set to false when parsing both Blast1 and
           :                          Blast2 reports in the same run or if you need
           :                          statistical params for each report, Lambda, K, H).
	   : -STRICT      => boolean (use strict mode for all Blast objects created.
           :                          Increases sensitivity to errors. For single
           :                          Blasts, this is parameter is sent to new().)
           : -EXEC_FUNC   => func_ref (reference to a function for processing each
           :                           Blast object after it is parsed. Should accept a
           :                           Blast object as its sole argument. Return value
           :                           is ignored. If an -EXEC_FUNC parameter is supplied, 
           :                           the -SAVE_ARRAY parameter will be ignored.)
           : -SAVE_ARRAY  =>array_ref, (reference to an array for storing all
           :                            Blast objects as they are created. 
           :                            Experimental. Not recommended.)
           :
 Throws    : Exception if BLAST report contains a FATAL: error.
           : Propagates any exception thrown by read().
           : Propagates any exception thrown by called parsing methods.
 Comments  : This method can be called either directly using the static $Blast object
           : or indirectly (by Bio::Tools::SeqAnal.pm) during constuction of an 
           : individual Blast object.
           :
           : When processing single Blast reports, the _parse() method is used.
           : To facilitate processing of sets of Blast reports, the _parse_stream()
           : is used. When parsing streams, the parse() parameters are set once.
           : To parse Blast report streams, supply a -STREAM => 1 parameter
           : and provide a STDIN stream containing the reports. See above for
           : additional special parameters that can be used when parsing streams.
           :
           : HTML-formatted reports can be parsed as well. No special flag is required
           : since it is detected automatically. The presence of HTML-formatting 
           : will result in slower performace, however, since it must be removed
           : prior to parsing. Parsing HTML-formatted reports is highly
           : error prone and is generally not recommended.

See Also   : L<_parse>(), L<_parse_stream>(), L<_set_signif>(), L<overlap>(), B<Bio::Root::Object::read()>, B<Bio::Tools::Blast::HTML.pm::strip_html()>, L<Links to related modules>

=cut

#---------
sub parse {
#---------
# $self might be the static $Blast object.
    my ($self, @param) = @_;

    my($signif, $filt_func, $min_len, $check_all, $overlap, $stats, $gapped, 
       $share, $stream, $strict, $best, $sig_fmt) = 
	$self->_rearrange([qw(SIGNIF FILT_FUNC MIN_LEN CHECK_ALL_HITS 
			      OVERLAP STATS GAPPED SHARE STREAM STRICT 
			      BEST SIGNIF_FMT)], @param);

    ## Default is to share stats.
    $Blast->{'_share'}  = defined($share) ? $share : 1;
    $Blast->{'_stream'} = $stream || 0;  
    $Blast->{'_filt_func'} = $filt_func || 0;  
    $Blast->{'_check_all'} = $check_all || 0; 
    $Blast->{'_signif_fmt'} ||= $sig_fmt || ''; 

    $self->_set_signif($signif, $min_len, $filt_func);
    $self->strict($strict) if $strict;
    $self->best($best) if $best;

    ## If $stats is false, miscellaneous statistical and other parameters
    ## are NOT extracted from the Blast report (e.g., matrix name, filter used, etc.).
    ## This can speed processing when crunching tons of Blast reports.
    ## Default is to NOT get stats.
    $self->{'_get_stats'} = defined($stats) ? $stats : 0;  

    ## If we know in advance whether or not a gapped Blast was performed,
    ## we don't need to parse this info from the report, which can be tricky.
    $self->{'_gapped'} = $gapped || 0;  

    my ($count);
    if($Blast->{'_stream'}) {

	$count = $self->_parse_stream(@param);
	
	## Need special way to handle exceptions within stream.
	if($Blast->{'_errs'}) {
	    my @errs = @{$Blast->{'_errs'}};
	    printf STDERR "\n*** %d BLAST REPORTS HAD FATAL ERRORS:\n", scalar(@errs);
	    foreach(@errs) { print STDERR "$_\n"; }
	    @{$Blast->{'_errs'}} = ();
	}
	
	$count -= 1;
    } else {
	$self->_parse(@param);
	$count = 1;
    }
	
    ## If report has been parsed, there is no need
    ## to save the raw data. If it is needed again, it can be
    ## re-read in from the file (unless STDIN was used...)
    $RawData   = '';  
    $HspString = '';

    $count;
}



=head2 _parse

 Usage     : n/a; internal method used by parse()
           : $blast_object->_parse( %named_parameters)
 Purpose   : For use when parsing a single Blast report, not a stream.

See Also   : L<_parse_stream>(), L<parse>()

=cut

#-----------
sub _parse {
#-----------
    my ($self, @param) = @_;
   
    local($/) = "\n";
    $RawData = $self->read(@param) unless $RawData;

    $_verbose && printf "\nParsing file: %s\n", $self->file || 'STDIN';

    if($RawData =~ /<HTML>|<A HREF/i) {
	require Bio::Tools::Blast::HTML; 
	import Bio::Tools::Blast::HTML qw(&strip_html); 
	&strip_html(\$RawData);
    }
	
    $self->_set_query();  # The name of the sequence will appear in error report.

    $RawData =~ /WARNING: (.+?)\n\n/s and $self->warn("$1") if $self->strict;
    $RawData =~ /FATAL: (.+?)\n\n/s and $self->throw("FATAL BLAST ERROR = $1"); 
    $RawData =~ /No hits? found/i and $self->throw("No hits were found."); 

    ## Test length first since the BLAST report may be screened based on length
    ## of query sequence.
    if(	$self->_set_length()) {

	my $get_stats = $self->_get_stats;
	$self->_set_program;
	$self->_set_parameters($get_stats);  # Always must be called.
	$self->_set_date if $get_stats;
	$self->_set_hits();
	$self->_test_significance();

	$self->{'_numHits'}    = $HitCount;
	$self->{'_numSigHits'} = scalar @{$self->{'_hits'}};
    }
}



=head2 _parse_stream

 Usage     : n/a; for internal use by parse()
           : $blast_object->_parse_stream( %named_parameters)
 Purpose   : For use when parsing an input stream containing multiple Blast reports.
 Comments  :
 
 Blast report data is parsed into Blast objects as it is being read in. 
 This facilitates the processing of multiple reports from a STDIN stream.
 In some situations, you want data from all reports, but in others, 
 you may only want Blast reports with significant hits. This function
 attempts to provide for these needs.
 
 This method is typically used by the static $Blast object to parse a
 set of related Blast reports which share the same parameters (significance 
 cutoff, matrix, filters, creation date, database searched, etc.). 
 To save computational and storage costs, these parameters need not be 
 parsed for all such related reports. They need only be parsed once, for 
 the first report, and stored in the static $Blast object, to which the 
 separate Blast objects have access.
 
 One issue concerns what to do with the parsed data: save it or
 use it? Sometimes you need to process all Blast data as a group
 (eg., sorting). Other times, you can safely process each report
 as it gets parsed and then move on to the next. In this case,
 the Blast object for each report should be destroyed before moving
 on to the next (i.e., call $blast->destroy()). Otherwise, the
 Perl garbage collector will not clear the memory. This becomes a
 concern when crunching through thousands of reports. 

 WARNING:
  USE OF THIS METHOD LEADS TO EXCESSIVE MEMORY USAGE WHEN PROCESSING
  STREAMS CONTAINING LARGE NUMBERS OF BLAST REPORTS (N > 1000),
  DESPITE CALLING destroy() ON THE BLAST OBJECTS PRODUCED FROM THE STREAM.
  The source of this memory leak is being investigated. Until then,
  file-by-file parsing should be used instead of stream parsing
  when dealing with large numbers of Blast reports.
  (Use the strategy of parse_multi.pl instead of parse_stream.pl
   in the DEMO SCRIPTS section).
 
  NOTE: Changes made in the 0.061 release may have solved this memory
        problem. This needs to be verified.

See Also   : L<_get_parse_func>(), L<_parse_stream_data>(), L<DEMO SCRIPTS>

=cut

#------------------
sub _parse_stream {
#------------------
    my ($self, @param) = @_;

    # Obtain a function ref (closure) to be used while reading in the raw data.
    my $funct = $self->_get_parse_func(@param);

    $Blast->{'_blastCount'} = 0;

    $self->read(-REC_SEP  =>"\nQuery= ", 
		-FUNC     => $funct,
		@param);

    return $Blast->{'_blastCount'};
    
}




=head2 _parse_stream_data

 Usage     : n/a; internal method used by _parse_stream()
           : $blast_object->_parse_stream_data()
 Purpose   : Parses a single Blast object within an input stream of Blast reports.
 Comments  : The object passed in to this method will be a new Blast object
           : created by the _get_parse_func() closure.

See Also   : L<_parse_stream>(), L<_get_parse_func>()

=cut

#----------------------
sub _parse_stream_data {
#----------------------
    my ($self) = @_;

    $_verbose && printf "\nParsing Blast report $Blast->{'_blastCount'} from stream data\n";

    $RawData = $Blast->{'_rawData'};
    if($RawData =~ /<HTML>|<A HREF/i) {
	require Bio::Tools::Blast::HTML; 
	import Bio::Tools::Blast::HTML qw(&strip_html); 
	&strip_html(\$RawData);
    }
    $self->_set_query();  # The name of the sequence will appear in error report.
    $RawData =~ /WARNING: (.+?)\n\n/s and $self->warn("$1") if $self->strict;
    $RawData =~ /FATAL: (.+?)\n\n/s and $self->throw("FATAL BLAST ERROR = $1"); 
    $RawData =~ /No hits? found/si and $self->throw("No hits were found."); 
    
#    print "\n=============================================\n";
#    print "PARSING STREAM DATA: $Blast->{'_blastCount'}\n";
#    printf "\nRawData (head  200):\n%s\n", substr($RawData, 0, 200);
#    printf "\nRawData (tail -400):\n%s\n", substr($RawData, -400);
#    print "\n=============================================\n\n";
    
    # PROBLEM: 
    # If parameters are not to be shared between different reports in 
    # the stream, we need a way to get the correct data (program and date)
    # to each Blast object. This problem arises due to the way the stream
    # is split ($/ = "\nQuery= ") which leaves the type of program 
    # (BLASTP etc.) at the bottom of the previous record.
    # Note that sharing is on by default, since it is more typical that 
    # you will be crunching through a set of closely related reports.
    # To not share, provide -SHARE => 0 to parse().

    my $get_stats = $self->_get_stats;

    if($Blast->{'_blastCount'} == 1) {
	# Info before the Query= line in first report.
	# The first chunk will not have any BLAST data.
	# We are always putting this in the BLAST object. 
	$Blast->_set_program();
	$Blast->_set_date() if $get_stats;
	return;
    }

    if($Blast->{'_blastCount'} == 2) {
	# get stats only for the first dataset and store in BLAST object.
	# Some of the stats may not be the same across different Blasts
	# e.g., database, Karlin-ALtschul params. If you need these, then you
	# set -SHARE => 0 in the parse() call.
	$Blast->_set_parameters($get_stats); # Always must set params (esp. gapping) 
	if($get_stats) {
	    $Blast->_set_date() if not $Blast->SUPER::date();
	}

    } else {
	## For all additional reports beyond the first, if '_share' is false,
	## each Blast object will have its own stats.
	## To accomplish this, we need to transfer the data from the end of the 
	## previous report chunk which was stored in the BLAST object. (see below).
	if( not $Blast->{'_share'}) {
	    $self->_set_parameters($get_stats);
	    if( $get_stats) {
		$self->_set_program($Blast->SUPER::program, $Blast->SUPER::program_version);
		$self->_set_date($Blast->SUPER::date);
	    }
#	    printf "\nPROGRAM: %s\nDATABASE: %s\n", $self->program, $self->database;
	}
    }
    
    if($self->_set_length()) {
	$self->_set_hits();
	$self->_test_significance();

	$self->{'_numHits'}    = $HitCount;
	$self->{'_numSigHits'} = scalar @{$self->{'_hits'}};
    }

    ## If we are not sharing stats, reset the program and date from the 
    ## data of the current chunk which actually applies 
    ## to the next chunk given the way we have segmented the reports
    ## on "\nQuery= ".
    if(not $Blast->{'_share'}) {
#	print "\nRESETTING PROGRAM\n";
	$Blast->_set_program();
	$Blast->_set_date() if $get_stats;
#	printf "  PROGRAM (Blast): %s\n",  $Blast->program;
    }
	
    ## If report has been parsed, there is typically no need
    ## to save the raw data. If it is needed again, it can be
    ## re-read in from the file.

    $RawData   = '';  
    $HspString = '';
}



=head2 _get_parse_func

 Usage     : n/a; internal method used by _parse_stream()
           : $func_ref = $blast_object->_get_parse_func()
 Purpose   : Generates a function ref to be used as a closure for parsing raw data
           : as it is being loaded by Bio::Root::Object::read()
 Returns   : Function reference (closure).

See Also   : L<_parse_stream>()

=cut

#-------------------
sub _get_parse_func {
#-------------------
# POSSIBLE STRATEGY: 
#   To save memory, the same Blast object can be re-used instead of
#   creating a new one each time. This could solve the memory leak
#   encountered when processing large Blast streams.
   
    my ($self, @param) = @_;

    my ($save_a, $exec_func) = 
	$self->_rearrange([qw(SAVE_ARRAY EXEC_FUNC)], @param); 

#    $MONITOR && print STDERR "\nParsing Blast stream (5/dot, 250/line)\n";
    my $count = 0;
    my $strict = $self->strict();

    # Some validation:
    if($exec_func and not ref($exec_func) eq 'CODE') {
	$self->throw("The -EXEC_FUNC parameter must be function reference.");

    } elsif($save_a and not ref($save_a) eq 'ARRAY') {
	$self->throw("The -SAVE_ARRAY parameter must supply an array reference".
		     "when not using an -EXEC_FUNC parameter.");
    } elsif(not ($save_a or $exec_func)) {
	$self->throw("No -EXEC_FUNC or -SAVE_ARRAY parameter was specified.",
		     "Need to do something with the Blast objects.");
    }

     return sub {
	my ($data) = @_;
	## $data should contain a complete Blast report in one chunk. 
	## (record separator = "\nQuery= ").

	$Blast->{'_rawData'} = $data;  

	$count = $Blast->{'_blastCount'}++;	

	if($MONITOR && $count) {
	    print STDERR ".", $count % 50 ? '' : "\n";
	}

	# The parameters are not used by the new Blast object.
	# It will obtain its mode and strict data from the
	# static $Blast object. This may change.
	my $blast = new Bio::Tools::Blast(-STRICT => $strict);
	
	## This will wipe out the first blast object, which is okay
	## since it contains only the first header from which we've extracted 
	## relevant info.
	if($Blast->{'_blastCount'} > 1) {
	    if($exec_func) {
		&$exec_func($blast);  # ignoring any return value.
		# Helps reduce memory leak when parsing streams:
		if($Blast->{'_stream'}) {
		    $blast->destroy;
		    undef $blast;
		}
	    } else {
		# We've already verified that if there is no exec_func
		# then there must be a $save_array
		push @$save_a, $blast;
	    }
#	    print STDERR "\nNEW BLAST OBJECT: ${\$blast->name}\n";
	}
	1;
    }
}




=head2 _set_parameters

 Usage     : n/a; internal function. called by parse(), set_parameters()
 Purpose   : Extracts statistical and other parameters from the BLAST report.
           : Sets various key elements such as the program and version,
           : gapping, and the layout for the report (blast1 or blast2).
 Argument  : Boolean (get_stats indicator)
 Throws    : Exception if cannot find the parameters section of report.
           : Warning if cannot determine if gapping was used.
           : Warning if cannot determine the scoring matrix used.
 Comments  : This method must always get called, even if the -STATS
           : parse() parameter is false. The reason is that the layout
           : of the report  and the presence of gapping must always be set.
           : The determination whether to set additional stats is made 
           : by methods called by _set_parameters().

See Also   : L<parse>(), L<set_parameters>(), L<_set_database>(), L<_set_program>()

=cut

#---------------------
sub _set_parameters {
#---------------------
    my ($self, $get_stats) = @_;
    my ($prog);
    $self->_set_database($get_stats);

    if( $RawData =~ /\nCPU time: (.*)/s) {
	# NCBI-Blast2 format (v2.04).
	$self->{'_layout'} = 2;
	$self->_set_blast2_stats($1);
    
    } elsif( $RawData =~ /\nParameters:(.*)/s) {
	# NCBI-Blast1 or WashU-Blast2 format.
	$self->{'_layout'} = 1;
	$self->_set_blast1_stats($1);

    } elsif( $RawData =~ /\n\s+Database:(.*)/s) {
	# NCBI-Blast2 format (v2.05).
	$self->{'_layout'} = 2;
	$self->_set_blast2_stats($1);

    } elsif($prog = $self->program_version()) {
	if($prog =~ /^1|WashU/) {
	    $self->{'_layout'} = 1;
	} else {
	    $self->{'_layout'} = 2;
	}
    } else {
	$self->throw("Can't determine report layout (Blast1 or 2).");
    }
    
    if(!defined($self->{'_gapped'})) {
	if($self->program_version() =~ /^1/) {
	    $self->{'_gapped'} = 0; 
	} else {
	    if($self->strict > 0) {
		$self->warn("Can't determine if gapping was used. Assuming gapped.");
	    }
	    $self->{'_gapped'} = 1; 
	    # Could have serious consequences for parsing of results,
	    # so this may turn into a throw() call.
	}
    }
}




=head2 set_parameters

 Usage     : $blast_obj->set_parameters()
 Purpose   : Extracts statistical and other parameters from the BLAST report.
           : Public interface for _set_parameters(). This provides a 
           : way to set the parameters for a Blast report that 
           : did not have them set when initially parsed.
           : Requires the Blast object to access an associated file.
 Returns   : n/a
 Argument  : n/a
 Throws    : Exceptions propagated from _set_parameters().
 Status    : Experimental
 Comments  : Requires that the report be re-read, therefore, will not work
           : if the report was read via STDIN.

See Also   : L<_set_parameters>(), L<parse>()

=cut

#--------------------
sub set_parameters {
#--------------------
    my $self = shift;

    $self->read() unless $RawData;
    $self->{'_get_stats'} = 1;
    $self->_set_layout();
    $self->_set_parameters(1);
}    



=head2 _set_blast2_stats

 Usage     : n/a; internal function called by _set_parameters()
 Purpose   : Extracts statistical and other parameters from BLAST2 report.
           : Stats collected: database release, gapping,
           : posted date, matrix used, filter used, Karlin-Altschul parameters, 
           : E, S, T, X, W.
 Throws    : Exception if cannot get "Parameters" section of Blast report.

See Also   : L<parse>(), L<_set_parameters>(), L<_set_database>(), B<Bio::Tools::SeqAnal::set_date()>,L<Links to related modules>

=cut

#---------------------'
sub _set_blast2_stats {
#---------------------
    my ($self, $data) = (@_);
    
    if($data =~ /\nGapped/s) {
	$self->{'_gapped'} = 1;
    } else {
 	$self->{'_gapped'} = 0;
    }

    # Other stats are not always essential.
    return unless $self->{'_get_stats'};

    # Blast2 Doesn't report what filter was used in the parameters section.
    # It just gives a warning that *some* filter was used in the header. 
    # You just have to know the defaults (currently: protein = SEG, nucl = DUST).
    if($RawData =~ /\bfiltered\b/si) {
	$self->{'_filter'} = 'DEFAULT FILTER';
    } else {
	$self->{'_filter'} = 'NONE';
    }

    if($data =~ /Gapped\nLambda +K +H\n +(.+?)\n/s) {
	my ($l, $k, $h) = split(/\s+/, $1);
	$self->{'_lambda'} = $l || 'UNKNOWN';
	$self->{'_k'} = $k || 'UNKNOWN';
	$self->{'_h'} = $h || 'UNKNOWN';
    } elsif($data =~ /Lambda +K +H\n +(.+?)\n/s) {
	my ($l, $k, $h) = split(/\s+/, $1);
	$self->{'_lambda'} = $l || 'UNKNOWN';
	$self->{'_k'} = $k || 'UNKNOWN';
	$self->{'_h'} = $h || 'UNKNOWN';
    }
    
    if($data =~ /\nMatrix: +(\w+)\n/s) {
	$self->{'_matrix'} = $1;
    } else {
	$self->{'_matrix'} = $DEFAULT_MATRIX.'?'; 
	if($self->strict > 0) {
	    $self->warn("Can't determine scoring matrix. Assuming $DEFAULT_MATRIX.");
	}
    }

    if($data =~ /\nGap Penalties: Existence: +(\d+), +Extension: (\d+)\n/s) {
	$self->{'_gapCreation'} = $1;
	$self->{'_gapExtension'} = $2;
    }
    if($data =~ /sequences better than (\d+):/s) {
	$self->{'_expect'} = $1;
    }

    if($data =~ /\nT: (\d+)/) { $self->{'_word_size'} = $1; }
    if($data =~ /\nA: (\d+)/) { $self->{'_a'} = $1; }
    if($data =~ /\nS1: (\d+)/) { $self->{'_s'} = $1; }
    if($data =~ /\nS2: (\d+)/) { $self->{'_s'} .= ", $1"; }
    if($data =~ /\nX1: (\d+)/) { $self->{'_x1'} = $1; }
    if($data =~ /\nX2: (\d+)/) { $self->{'_x2'} = $1; }
}



=head2 _set_blast1_stats

 Usage     : n/a; internal function called by _set_parameters()
 Purpose   : Extracts statistical and other parameters from BLAST 1.x style eports.
           : Handles NCBI Blast1 and WashU-Blast2 formats.
           : Stats collected: database release, gapping, 
           : posted date, matrix used, filter used, Karlin-Altschul parameters, 
           : E, S, T, X, W.

See Also   : L<parse>(), L<_set_parameters>(), L<_set_database>(), B<Bio::Tools::SeqAnal::set_date()>,L<Links to related modules>

=cut

#----------------------
sub _set_blast1_stats {
#----------------------
    my ($self, $data) = (@_);
    
    if(!$self->{'_gapped'} and $self->program_version() =~ /^2[\w-.]+WashU/) {
	$self->_set_gapping_wu($data);
    } else {
	$self->{'_gapped'} = 0;
    }

    # Other stats are not always essential.
    return unless $self->{'_get_stats'};

    if($data =~ /filter=(.+?)\n/s) {
	$self->{'_filter'} = $1;
    } elsif($data =~ /filter\n +(.+?)\n/s) {
	$self->{'_filter'} = $1;
    } else {
	$self->{'_filter'} = 'NONE';
    }
    
    if($data =~ /E=(\d+)\n/s) {  $self->{'_expect'} = $1; }

    if($data =~ /M=(\d+)\n/s) {  $self->{'_matrix'} = $1; }

    if($data =~ /Frame  MatID Matrix name .+?\n +(.+?)\n/s) {
	## WU-Blast2.
	my ($fr, $mid, $mat, $lu, $ku, $hu, $lc, $kc, $hc) = split(/\s+/,$1);
	$self->{'_matrix'} = $mat || 'UNKNOWN';
	$self->{'_lambda'} = $lu || 'UNKNOWN';
	$self->{'_k'} = $ku || 'UNKNOWN';
	$self->{'_h'} = $hu || 'UNKNOWN';
	
    } elsif($data =~ /Lambda +K +H\n +(.+?)\n/s) {
	## NCBI-Blast1.
	my ($l, $k, $h) = split(/\s+/, $1);
	$self->{'_lambda'} = $l || 'UNKNOWN';
	$self->{'_k'} = $k || 'UNKNOWN';
	$self->{'_h'} = $h || 'UNKNOWN';
    }

    if($data =~ /E +S +W +T +X.+?\n +(.+?)\n/s) {
	# WashU-Blast2
	my ($fr, $mid, $len, $elen, $e, $s, $w, $t, $x, $e2, $s2) = split(/\s+/,$1);
	$self->{'_expect'} ||= $e || 'UNKNOWN';
	$self->{'_s'} = $s || 'UNKNOWN';
	$self->{'_word_size'} = $w || 'UNKNOWN';
	$self->{'_t'} = $t || 'UNKNOWN';
	$self->{'_x'} = $x || 'UNKNOWN';
    
    } elsif($data =~ /E +S +T1 +T2 +X1 +X2 +W +Gap\n +(.+?)\n/s) {
	## NCBI-Blast1.
	my ($e, $s, $t1, $t2, $x1, $x2, $w, $gap) = split(/\s+/,$1);
	$self->{'_expect'} ||= $e || 'UNKNOWN';
	$self->{'_s'} = $s || 'UNKNOWN';
	$self->{'_word_size'} = $w || 'UNKNOWN';
	$self->{'_t1'} = $t1 || 'UNKNOWN';
	$self->{'_t2'} = $t2 || 'UNKNOWN';
	$self->{'_x1'} = $x1 || 'UNKNOWN';
	$self->{'_x2'} = $x2 || 'UNKNOWN';
	$self->{'_gap'} = $gap || 'UNKNOWN';
    }

    if(!$self->{'_matrix'}) {
	$self->{'_matrix'} = $DEFAULT_MATRIX.'?';
	if($self->strict > 0) {
	    $self->warn("Can't determine scoring matrix. Assuming $DEFAULT_MATRIX.");
	}
    }
}


=head2 _set_gapping_wu

 Usage     : n/a; internal function called by _set_blast1_stats()
 Purpose   : Determine if gapping_wu was on for WashU Blast reports.
 Comments  : In earlier versions, gapping was always specified
           : but in the current version (2.0a19MP), gapping is on by default
           : and there is no positive "gapping" indicator in the Parameters
           : section.

See Also   : L<_set_blast1_stats>()

=cut

#--------------------
sub _set_gapping_wu {
#--------------------
    my ($self, $data) = @_;
    
    if($data =~ /gaps?\n/s) {
	$self->{'_gapped'} = ($data =~ /nogaps?\n/s) ? 0 : 1;
    } else {
	$self->{'_gapped'} = 1;
    }
}


=head2 _set_date

 Usage     : n/a; internal function called by _set_parameters()
 Purpose   : Determine the date on which the Blast analysis was performed.
 Comments  : Date information is not consistently added to Blast output.
           : Uses superclass method set_date() to set date from the file,
           : (if any).

See Also   : L<_set_parameters>(), B<Bio::Tools::SeqAnal::set_date()>,L<Links to related modules>

=cut

#--------------
sub _set_date {
#--------------
    my $self = shift;
    my $date = shift;

    if($date) {
	return $self->set_date($date); 
    }
    ### Network BLAST reports from NCBI are time stamped as follows:
    #Fri Apr 18 15:55:41 EDT 1997, Up 1 day, 19 mins, 1 user, load: 19.54, 19.13, 17.77    
    if($RawData =~ /Start:\s+(.+?)\s+End:/s) {
	## Calling superclass method to set the date.
	## If we can't get date from the report, file date is obtained.
	$self->set_date($1);
    } elsif($RawData =~ /Date:\s+(.*?)\n/s) {
	## E-mailed reports have a Date: field
	$self->set_date($1);
    } elsif( $RawData =~ /done\s+at (.+?)\n/s ) {
	$self->set_date($1);  
    } elsif( $RawData =~ /\n([\w:, ]+), Up \d+/s ) {
	$self->set_date($1); 
    } else {
	## Otherwise, let superclass attempt to get the file creation date.
	$self->set_date();
    }
}



=head2 _set_signif

 Usage     : n/a; called automatically by parse()
           : $blast_obj->($signif, $min_len, $filt_func); 
 Purpose   : Sets significance criteria for the BLAST object.
 Argument  : Obligatory three arguments:
           : $signif = float or sci-notation number or undef
           : $min_len = integer or undef
           : $filt_func = function reference or undef
 Throws    : Exception if significance values appear out of range or invalid.
           : Sets default values (signif = 10; min_length = not set).
           : Exception if $filt_func if defined and is not a func ref.
 Comments  : The significance of a BLAST report can be based on
           : the P (or Expect) value and/or the length of the query sequence.
           : P (or Expect) values GREATER than '_significance' are not significant.
           : Query sequence lengths LESS than '_min_length' are not significant.
           :
           : Hits can also be screened using arbitrary significance criteria 
           : as discussed in the parse() method.
           :
           : If no $signif is defined, the '_significance' level is set to 
           : $Bio::Tools::Blast::DEFAULT_SIGNIF (999).

See Also   : L<_test_significance>(), L<_confirm_significance>(), L<signif>(), L<min_length>(), L<parse>()

=cut

#-----------------
sub _set_signif {
#-----------------
    my( $self, $sig, $len, $func ) = @_;
    
    if(defined $sig) {
	$self->{'_confirm_significance'} = 1;
	if( $sig =~ /[^\d.e-]/ or $sig <= 0) { 
	    $self->throw("Invalid significance value: $sig", 
			 "Must be greater than 0.");
	} 
	$self->{'_significance'} = $sig;
    } else {
	$self->{'_significance'}   = $DEFAULT_SIGNIF;
	$self->{'_is_significant'} = 1;
	$Blast->{'_check_all'}     = 1 if not $Blast->{'_filt_func'}; 
    }

    if(defined $len) {
	$self->{'_confirm_significance'} = 1;
	if($len =~ /\D/ or $len <= 0) {
	    $self->warn("Invalid minimum length value: $len", 
			"Value must be an integer > 0. Value not set.");
	} else {
	    $self->{'_min_length'} = $len;
	} 
    }

    if(defined $func) {
	$self->{'_confirm_significance'} = 1;
	if($func and not ref $func eq 'CODE') {
	    $self->throw("Not a function reference: $func",
			 "The -filt_func parameter must be function reference.");
	}
    }
}



=head2 _test_significance

 Usage     : n/a; called automatically during Blast report parsing.
 Purpose   : Determines if the BLAST report has any significant hits.
 Throws    : Exception if the BLAST report lacks any significant hits.
 Comments  : Strategy: Checks the '_hits' member to see if any significant hits 
           : have been obtained.
           : This method is called ONLY if the client has specified
           : significance criteria AND the significance criteria have
           : not been satisfied.
           : Formerly, the client was expected to check for significance
           : after creating the BLAST object. It is more efficient to
           : throw an exception. That way the client is forced to notice it.

See Also   : L<_set_signif>(), L<is_signif>(), L<signif>(), L<min_length>()

=cut

#-----------------------
sub _test_significance {
#-----------------------
    my $self = shift;
    
    return $self->{'_is_significant'} = 1 if not $self->_confirm_significance;

    return if defined $self->{'_is_significant'};
    
    if( scalar @{$self->{'_hits'}}) {
	$self->{'_is_significant'} = 1;
    } else {
	$self->{'_is_significant'} = 0;  

	if($self->strict) {
	    $self->throw("No significant BLAST hits for ${\$self->name}");
	}
    }
}




=head2 _confirm_significance

 Usage     : n/a; internal method called by _test_significance
 Purpose   : Determine if significance criteria are in place.
 Comments  : Obtains info from the static $Blast object if it has not been set
           : for the current object.

See Also   : L<signif>(), L<min_length>()

=cut

#---------------------------
sub _confirm_significance {
#---------------------------
    my $self = shift;  

#    if(defined($self->{'_confirm_significance'})) {
#	 return $self->{'_confirm_significance'};
#    } else { 
#	 return $Blast->{'_confirm_significance'};
#    }
    $self->{'_confirm_significance'} || $Blast->{'_confirm_significance'};
}


=head2 _set_length

 Usage     : n/a; called automatically during Blast report parsing.
 Purpose   : Sets the length of the query sequence (extracted from report).
 Returns   : integer (length of the query sequence)
 Throws    : Exception if cannot determine the query sequence length from
           :           the BLAST report.
           : Exception if the length is below the min_length cutoff (if any).
 Comments  : The logic here is a bit different from the other _set_XXX()
           : methods since the significance of the BLAST report is assessed 
           : if MIN_LENGTH is set.

See Also   : B<Bio::Tools::SeqAnal::length()>, L<Links to related modules>

=cut

#---------------
sub _set_length {
#---------------
    my $self = shift;

    my ($length);
    if( $RawData =~ m/\n\s+\(([\d|,]+) letters\)/s ) {
	$length = $1;
	$length =~ s/,//g;
#	printf "Length = $length in BLAST for %s\n",$self->name; <STDIN>;
    } else {
	$self->throw("Can't determine sequence length from BLAST report.");
    }

    my($sig_len);
    if( $sig_len = $self->min_length()) {
	if($length < $sig_len) {
	    $self->{'_is_significant'} = 0;
	    if ($self->_confirm_significance) {
		$self->throw("Query sequence too short for ${\$self->name} ($length)",
			     "Significant length is $sig_len");
	    }
	}   
    }

    $self->length($length);  # defined in superclass.
}



=head2 _set_database

 Usage     : n/a; called automatically during Blast report parsing.
 Purpose   : Sets the name of the database used by the BLAST analysis.
           : Extracted from raw BLAST report.
 Throws    : Exception if the name of the database cannot be determined.
 Comments  : The database name is used by methods or related objects
           : for database-specific parsing.

See Also   : L<parse>(), B<Bio::Tools::SeqAnal::database()>,B<Bio::Tools::SeqAnal::_set_db_stats()>,L<Links to related modules>

=cut

#------------------
sub _set_database {
#------------------
    my ($self, $get_stats) = @_;

    my ($name, $date, $lets, $seqs);

    my $strict = $self->strict > 0;

    if($RawData =~ m/Database:\s+(.+?)\n/s ) {
	$name = $1;
    } else {
	$self->throw("Can't determine database type from BLAST report.");
    }

    # Always set the database.
    $self->database($name);

    return unless $get_stats;

    if($RawData =~ m/Posted date: +(.+?)\n/s ) {
	$date = $1;
    } elsif($RawData =~ m/Release date: +(.+?)\n/s ) {
	$date = $1;
    } elsif($strict) {
	$self->warn("Can't determine database release date.");
    }

    if($RawData =~ m/letters in database: +([\d,]+)\n/s ) {
	$lets = $1;
    } elsif($strict) {
	$self->warn("Can't determine number of letters in database.");
    }

    if($RawData =~ m/sequences in database: +([\d,]+)\n/s ) {
	$seqs = $1;
    } elsif($strict) {
	$self->warn("Can't determine number of sequences in database.");
    }

    $self->_set_db_stats( -NAME    => $name,
			  -RELEASE => $date || '',
			  -LETTERS => $lets || '',
			  -SEQS    => $seqs || ''
			  );
}



=head2 _set_program

 Usage     : n/a; called automatically during Blast file parsing.
 Purpose   : Sets the name of the BLAST program used (BLASTP, TBLASTN, etc.)
           : Extracted from the raw BLAST report.
 Returns   : String, name of program
 Throws    : Exception if the program cannot be determined.
 Comments  : The program name is used by related objects (Bio::Tools::Blast::Sbjct.pm
           : and HSP.pm) for program-specific parsing. Itis quite exxential
           : for interpreting interval data within HSP.pm.

See Also   : L<_set_parameters>(), B<Bio::Tools::SeqAnal::program>(), B<Bio::Tools::Blast::HSP::_set_seq()>,L<Links to related modules>

=cut

#-----------------
sub _set_program {
#-----------------
    my $self = shift;
    my @data = @_;

    if(@data) {
	$self->SUPER::program($data[0]);
	$self->SUPER::program_version($data[1]);

    } else {

	my($prog, $vers);
	if($RawData =~ /\n?(<\w+>)?(T?BLAST[NPX])\s+(.*?)\n/s) {
	    $prog = $2;
	    $vers = $3;
	} elsif($Blast->{'_stream'} and not $Blast->{'_share'}) {
	    # When not sharing report data during stream parsing,
	    # the last report will lack program info. Don't worry.
	    # See _parse_stream_data(), towards bottom.
	    return;
	} else {
	    $prog = 'UNKNOWN'; 
	    $vers = 'UNKNOWN';
	    $self->throw("Can't determine program type from BLAST report.",
			 "Checked for: @Blast_programs.");
	    # This has important implications for how to handle interval
	    # information for HSPs. TBLASTN uses nucleotides in query HSP
	    # but amino acids in the sbjct HSP sequence.
	}

	$self->SUPER::program($prog);
	$self->SUPER::program_version($vers);
    }
}


=head2 _set_query

 Usage     : n/a; called automatically during Blast report parsing.
 Purpose   : Set the name of the query and the query description.
           : Extracted from the raw BLAST report.
 Returns   : String containing name of query extracted from report.
 Throws    : Warning if the name of the query cannont be obtained.

See Also   : B<Bio::Tools::SeqAnal::query_desc()>,L<Links to related modules>

=cut

#---------------
sub _set_query {
#---------------
    my $self = shift;
    
    if($RawData =~ m/\nQuery= *(.+?)\n/s or
	($Blast->{'_stream'} and $RawData =~ m/^ *(.+?)\n/)) {
	my $info = $1;
	$info =~ s/TITLE //;
	# Split the query line into two parts.
	# Using \s instead of ' '
	$info =~ /(\S+?)\s(.*)/;
	$self->query_desc($2 || '');
	# set name of Blast object and return.
	$self->name($1 || 'UNKNOWN');
    } else {
	$self->warn("Can't determine query sequence name from BLAST report.");
    }
#    print STDERR "\n  NAME = ${\$self->name}\n";
}



=head2 _set_hits

 Usage     : n/a; called automatically during Blast report parsing.
 Purpose   : Set significant hits for the BLAST report. Hits are encapsulated
           : within Bio::Tools::Blast::Sbjct.pm objects.
 Throws    : If all hits generated exceptions, raise exception
           :   (a fatal event for the Blast object.)
           : If some hits were okay but some were bad, generate a warning
           :   (a few bad applies should not spoil the bunch).
           :   This usually indicates a limiting B-value.
           : When the parsing code fails, it is either all or nothing.
 Comments  : Requires Bio::Tools::Blast::Sbjct.pm.
           : Checks significance level (P or Expect value obtained from the
           : "Description section" of the Blast report) of the hit before creating 
           : new Bio::Sbjct object. 
           : Optionally calls a filter function to screen the hit on arbitrary
           : criteria. If the filter function returns true for a gicen hit,
           : that hit will be skipped.
           : If the Blast object was created with-check_all_hits set to true,
           : all hits will be checked for significance and processed if necessary.
           : If this field is false, the parsing will stop after the first
           : non-significant hit. 
           : See parse() for description of parameters.

See Also   : L<parse>(), L<_set_descriptions>(), L<_parse_hsp_data>(), L<_parse_signif>(), B<Bio::Tools::Blast::Sbjct()>,L<Links to related modules>

=cut

#---------------
sub _set_hits {
#---------------
    my $self    = shift;
    my (@hits, @summary, $count, $sig);
    
    require Bio::Tools::Blast::Sbjct; 

    $self->_set_descriptions(\@summary);
    
    $HitCount = 0;
    my $layout    = $self->_layout;
    my $gapped    = $self->gapped;
    my $best      = $self->best;
    my $prog      = $self->program;
    my $check_all = $Blast->{'_check_all'};
    my $filt_func = $Blast->{'_filt_func'} || 0;
    my $sig_fmt   = $Blast->{'_signif_fmt'};
    my $confirm_significance = $self->_confirm_significance();

    my($line, @errs, @bad_names);

    $self->{'_highestSignif'} = 0;
    $self->{'_lowestSignif'} = $DEFAULT_SIGNIF;
    my $my_signif = $self->signif;

    hit_loop:
    foreach $line (@summary) {
	my @hitData = ();
	push @hitData, $line;
	last hit_loop if not $line or $line =~ / NONE |End of List/;
	next hit_loop if $line =~ /^\.\./;

	## Checking the significance value (P- or Expect value) of the hit
	## in the description line. 
	$sig = _parse_signif( $line, $layout, $gapped );
	$self->{'_highestSignif'} = ($sig > $self->{'_highestSignif'}) 
                                          ? $sig : $self->{'_highestSignif'};

	$self->{'_lowestSignif'} = ($sig < $self->{'_lowestSignif'}) 
                                          ? $sig : $self->{'_lowestSignif'};
	# Significance value assessment.
	$sig > $my_signif and ($check_all ? next hit_loop : last hit_loop); 
	
	$HitCount++;  # total hits (signif and non-signif).

#	debug(1);
	my $hit;  # Must be my'ed within hit_loop or failure in 
                  # _parse_hsp_data() will cause no hits to be saved.
	eval {
	    push @hitData, $self->_parse_hsp_data($line);

	    $hit = new Bio::Tools::Blast::Sbjct (-DATA      =>\@hitData, 
						 -PARENT    =>$self, 
						 -NAME      =>$HitCount, 
						 -RANK      =>$HitCount, 
						 -RANK_BY   =>'order',
						 -LAYOUT    =>$layout, 
						 -GAPPED    =>$gapped, 
						 -PROGRAM   =>$prog, 
						 -SIGNIF_FMT=>$sig_fmt,
						 -OVERLAP   =>$Blast->{'_overlap'} || $MAX_HSP_OVERLAP,
						 );
#	    printf STDERR "NEW HIT: %s, SIGNIFICANCE = %g\n", $hit->name, $hit->expect;  <STDIN>;
	};
	if($@) {
	    # Throwing lots of errors can slow down the code substantially.
	    # Error handling code is not that efficient.
	    push @errs, $@;
	    push @bad_names, "#$HitCount";
	    $hit->destroy if ref $hit;
	    undef $hit;
	    next hit_loop;
	} else {
	    # Test significance using custom function (if supplied)
	    if($filt_func) {
		not &$filt_func($hit) and do{ $hit->destroy;
					      $check_all 
						  ? next hit_loop 
						  : ($HitCount--, last hit_loop)
						  };
	    }
	    push @hits, $hit;
	}
	last if $best;  # stop processing if we only need the best hit.

    }  # end hit_loop

    $DEBUG and print STDERR "\n";

   $self->{'_hits'} = \@hits;
    
    ## Throw or warn about any errors encountered. 

    if(@errs) {
	my ($str);
	# When there are many errors, in most of the cases, they are
	# caused by the same problem. Only need to see full data for
	# the first one.
	if(@errs > 2) {
	    $str = "SHOWING FIRST EXCEPTION ONLY:\n$errs[0]";
	    $self->clear_err();  # clearing the existing set of errors.
	                         # Not necessary, unless the -RECORD_ERR =>1
	                         # constructor option was used for Blast object.
	} else {
	    $str = join("\n",@errs);
	}

	if(not @hits) {
	    $self->throw(sprintf("Failed to create any Sbjct objects for %d potential hit(s).", scalar(@errs)),
			 "\n\nTRAPPED EXCEPTION(S):\n$str\nEND TRAPPED EXCEPTION(S)\n"
			 );
	} else {
	    $self->warn(sprintf("Could not create Sbjct objects for %d Blast hit(s): %s", scalar(@errs), join(', ',@bad_names)), 
			@errs > 2 ? "This may be due to a limiting B value (max alignment listings)." : "",
			"\n\nTRAPPED EXCEPTION(S):\n$str\nEND TRAPPED EXCEPTION(S)\n"
			);
	}
	@errs = ();
    }
}



=head2 _set_descriptions

 Usage     : n/a; called automatically by _set_hits()
 Purpose   : Gets the complete description section of a BLAST report.
           : Utility method for _set_hits()
 Argument  : Array reference to an empty array; will be filled with the descriptions section.
 Throws    : Exception if description data cannot be parsed properly.
 Comments  : Description section contains a single line for each hit listing
           : the seq id, description, score, Expect or P-value, etc.

See Also   : L<_set_hits>()

=cut

#----------------------
sub _set_descriptions {  
#----------------------
    my( $self, $sum_aref ) = @_;
    my $start = 0;
    my $count = 0;
    
    $DEBUG and print STDERR "$ID: Setting description data\n";
    
    ## For efficiency reasons, we want to to avoid using $' and $`.
    ## Therefore using single-line mode pattern matching.
    ##
    ## If the report was saved from a web browser page, there will
    ## be no '>' at the start of each HSP alignment listing.
    ## This has a bearing on further parsing code, hence the $_no_gt 
    ## private variable. 

    my ($descriptionString, $hspString);
    if($RawData =~ /\n>/s ) {
	$_no_gt = 0;
	if($RawData =~ /\nSequences producing.+?\n(.+?)\n(>.+)/s ) {
	    ($descriptionString, $hspString) = ($1, $2);
	}
    } elsif($RawData =~ /\nSequences producing.+?\n(.+?)\n\n(.+)/s ) {
	$_no_gt = 1;
	($descriptionString, $hspString) = ($1, $2);
    } else {
	$self->throw("Can't parse description data.");
    }

    $HspString = $hspString;
    $HspString =~ s/\|/_/g;  # '|' characters cause regexp trouble later.

    $descriptionString =~ s/^\s+|\s+$//sg;

    @{$sum_aref} = split( "\n", $descriptionString);
}




=head2 _parse_hsp_data

 Usage     : n/a; called automatically by _set_hits()
 Purpose   : Extracts HSP data for single hit (Sbjct) from the body 
           : of the raw report.  Utility method for _set_hits().
 Returns   : Array containing the HSP alignment section for a single hit.
 Argument  : String (description line for a Blast hit)
 Throws    : Exception if it cannot locate the HSP alignment section 
           : for the hit.
 Status    : Static

See Also   : L<_set_hits>()

=cut

#--------------------
sub _parse_hsp_data { 
#--------------------

    my( $self, $sumLine ) = @_;
    my $startHSPs = 0;
    my @data      = ();
    my @sumLineData = ();
    my $lineCount = 0;
    my( $separator, $hsps );
    
    local $_ = $sumLine;
    @sumLineData = split();
    
    if($_no_gt) {
	# HSP alignment chunks will not start with '>' if the report
	# was saved from a web browser window.
	$separator = "$sumLineData[0]";
    } else {
	$separator = ">[\\s]*$sumLineData[0]";
#	$separator = ">$sumLineData[0]";
    }
    
    $separator =~ s/\|/_/g; # "|" characters cause problems with the regexp

    ## Using single-line mode pattern matching //s to avoid using $' and $`.
    
    if($HspString =~ /\n?$separator\b(.+?)(\n>|\nParameters:|\nCPU|\n\s+Database:)/s) {
	$hsps = $1;
    } elsif($HspString =~ /\n?$separator\b(.+?)(\n\n\n)/s) {
	# Last ditch attempt to find the alignment chunk.
	$hsps = $1;
    } else {
	$self->throw("Can't parse HSP data for $sumLineData[0].",
		     "Missing HSP data or unrecognized format.");
	## This error is typically caused by a limiting B value
	## (the max number of HSP alignments to slow).
    }

    $hsps =~ s/^\s+|\s+$//sg;
    $hsps =~ s/\n\n/\n/s;  # remove blank lines.
    @data = split("\n", $hsps);
    push @data, 'end';

    return @data;
}


=head2 _parse_signif

 Usage     : &_parse_signif(string, layout, gapped);
 Purpose   : Extracts the P- or Expect value from a single line of a BLAST description section.
 Example   : &_parse_signif("PDB_UNIQUEP:3HSC_  heat-shock cognate ...   799  4.0e-206  2", 1);
           : &_parse_signif("gi|758803  (U23828) peritrophin-95 precurs   38  0.19", 2);
 Argument  : string = line from BLAST description section
           : layout = integer (1 or 2)
           : gapped = boolean (true if gapped Blast).
 Returns   : Float (0.001 or 1e-03)
 Status    : Static

=cut

#------------------
sub _parse_signif {
#------------------
    my ($line, $layout, $gapped) = @_;

    local $_ = $line;
    my @linedat = split();

    # When processing both Blast1 and Blast2 reports 
    # in the same run, offset needs to be configured each time. 
    
    my $offset  = 0; 
    $offset  = 1 if $layout == 1 or not $gapped;

    my $signif = $linedat[ $#linedat - $offset ];

    # fail-safe check
    if(not $signif =~ /[.-]/) {
	$offset = ($offset == 0 ? 1 : 0);
	$signif = $linedat[ $#linedat - $offset ];
    }

    $signif = "1$signif" if $signif =~ /^e/i;
    return $signif;
}


## 
## BEGIN ACCESSOR METHODS THAT INCORPORATE THE STATIC $Blast OBJECT.
##

sub program { 
## Overridden method to incorporate the BLAST object.
    my $self = shift;  
    return $self->SUPER::program(@_) if @_;          # set
    $self->SUPER::program || $Blast->SUPER::program; # get
}

sub date { 
## Overridden method to incorporate the BLAST object.
    my $self = shift;  
    return $self->SUPER::date(@_) if @_;       # set
    $self->SUPER::date || $Blast->SUPER::date; # get
}

sub database { 
## Overridden method to incorporate the BLAST object.
    my $self = shift;  
    return $self->SUPER::database(@_) if @_;           # set
    $self->SUPER::database || $Blast->SUPER::database; # get
}


sub program_version { 
## Overridden method to incorporate the BLAST object.
    my $self = shift;  
    return $self->SUPER::program_version(@_) if @_;                  # set
    $self->SUPER::program_version || $Blast->SUPER::program_version; # get
}


sub best { 
## Overridden method to incorporate the BLAST object.
    my $self = shift;  
    return $self->SUPER::best(@_) if @_;       # set
    $self->SUPER::best || $Blast->SUPER::best; # get
}


=head2 signif

 Usage     : $blast->signif();
 Purpose   : Gets the P or Expect value used as significance screening cutoff.
 Returns   : Scientific notation number with this format: 1.0e-05.
 Argument  : n/a
 Comments  : Screening of significant hits uses the data provided on the
           : description line. For Blast1 and WU-Blast2, this data is P-value.
           : for Blast2 it is an Expect value. 
           :
           : Obtains info from the static $Blast object if it has not been set
           : for the current object.

See Also   : L<_set_signif>(), L<_test_significance>()

=cut

#-----------
sub signif { 
#-----------
    my $self = shift;  
    my $sig = $self->{'_significance'} || $Blast->{'_significance'};
    sprintf "%.1e", $sig;
}



=head2 is_signif

 Usage     : $blast->is_signif();
 Purpose   : Determine if the BLAST report contains significant hits.
 Returns   : Boolean
 Argument  : n/a
 Comments  : BLAST reports without significant hits but with defined
           : significance criteria will throw exceptions during construction.
           : This obviates the need to check significant() for
           : such objects.

See Also   : L<_set_signif>(), L<_test_significance>()

=cut

#------------
sub is_signif { my $self = shift; $self->{'_is_significant'}; }
#------------

# is_signif() doesn't incorporate the static $Blast object but is included
# here to be with the other 'signif' methods.



=head2 signif_fmt

 Usage     : $blast->signif_fmt( [FMT] );
 Purpose   : Allows retrieval of the P/Expect exponent values only
           : or as a two-element list (mantissa, exponent).
 Usage     : $blast_obj->signif_fmt('exp'); 
           : $blast_obj->signif_fmt('parts');
 Returns   : String or '' if not set.
 Argument  : String, FMT = 'exp' (return the exponent only)
           :             = 'parts'(return exponent + mantissa in 2-elem list)
           :              = undefined (return the raw value)
 Comments  : P/Expect values are still stored internally as the full,
           : scientific notation value. 
           : This method uses the static $Blast object since this issue
           : will pertain to all Blast reports within a given set.
           : This setting is propagated to Bio::Tools::Blast::Sbjct.pm.

=cut

#--------------
sub signif_fmt { 
#--------------
    my $self = shift; 
    if(@_) { $Blast->{'_signif_fmt'} = shift; }
    $Blast->{'_signif_fmt'} || '';
}


=head2 min_length

 Usage     : $blast->min_length();
 Purpose   : Gets the query sequence length used as significance screening criteria.
 Returns   : Integer
 Argument  : n/a
 Comments  : Obtains info from the static $Blast object if it has not been set
           : for the current object.

See Also   : L<_set_signif>(), L<_test_significance>(), L<signif>()

=cut

#--------------
sub min_length { 
#--------------
    my $self = shift;  
    $self->{'_min_length'} || $Blast->{'_min_length'};
}




=head2 gapped

 Usage     : $blast->gapped();
 Purpose   : Set/Get boolean indicator for gapped BLAST.
 Returns   : Boolean
 Argument  : n/a
 Comments  : Obtains info from the static $Blast object if it has not been set
           : for the current object.

=cut

#-----------
sub gapped { 
#-----------
    my $self = shift; 
    if(@_) { $self->{'_gapped'} = shift; }
    $self->{'_gapped'} || $Blast->{'_gapped'}; 
}


=head2 _get_stats

 Usage     : n/a; internal method.
 Purpose   : Set/Get indicator for collecting full statistics from report.
 Returns   : Boolean (0 | 1)
 Comments  : Obtains info from the static $Blast object if it has not been set
           : for the current object.

=cut

#---------------
sub _get_stats { 
#---------------
    my $self = shift; 
    if(@_) { $self->{'_get_stats'} = shift; }
    defined $self->{'_get_stats'} ? $self->{'_get_stats'} : $Blast->{'_get_stats'}; 
}



=head2 _layout

 Usage     : n/a; internal method.
 Purpose   : Set/Get indicator for the layout of the report.
 Returns   : Integer (1 | 2)
 Comments  : Blast1 and WashU-Blast2 have a layout = 1.
           : This is intended for internal use by this and closely
           : allied modules like Sbjct.pm and HSP.pm.
           :
           : Obtains info from the static $Blast object if it has not been set
           : for the current object.

=cut

#------------
sub _layout { 
#------------
    my $self = shift; 
    if(@_) { $self->{'_layout'} = shift; }
    $self->{'_layout'} || $Blast->{'_layout'}; 
}



## 
## END ACCESSOR METHODS THAT INCORPORATE THE STATIC $Blast OBJECT.
##



=head2 hits

 Usage     : $blast->hits();
 Purpose   : Get a list containing all BLAST hit (Sbjct) objects.
           : Get the numbers of significant hits.
 Examples  : @hits       = $blast->hits();
           : $num_signif = $blast->hits();
 Returns   : List context : list of Bio::Tools::Blast::Sbjct.pm objects.
           : Scalar context: integer (number of significant hits).
           :                 (Equivalent to num_hits()).
 Argument  : n/a. Relies on wantarray.
 Throws    : n/a.
           : Not throwing exception because the absence of hits may have
           : resulted from stringent significance criteria, not a failure
           : set the hits.

See Also   : L<hit>(), L<num_hits>(), L<is_signif>(), L<_set_signif>()

=cut

#----------
sub hits {
#----------
    my $self = shift;

    return wantarray 
        #  returning list containing all hits or empty list.
	? ($self->{'_is_significant'} ? @{$self->{'_hits'}} : ())
        #  returning number of hits or 0.
        : ($self->{'_is_significant'} ? scalar(@{$self->{'_hits'}}) : 0);
}




=head2 hit

 Example   : $blast_obj->hit( [class] )
 Purpose   : Get a specific hit object.
           : Provides some syntactic sugar for the hits() method.
 Usage     : $hitObj = $blast->hit();
           : $hitObj = $blast->hit('best');
           : $hitObj = $blast->hit('worst');
           : $hitObj = $blast->hit( $name );
 Returns   : Object reference for a Bio::Tools::Blast::Sbjct.pm object.
 Argument  : Class (or no argument).
           :   No argument (default) = highest scoring hit (same as 'best').
           :   'best' or 'first' = highest scoring hit.
           :   'worst' or 'last' = lowest scoring hit.
           :   $name = retrieve a hit by seq id (case-insensitive).
 Throws    : Exception if the Blast object has no significant hits.
           : Exception if a hit cannot be found when supplying a specific
           : hit sequence identifier as an argument.
 Comments  : 'best'  = lowest significance value (P or Expect) among significant hits.
           : 'worst' = highest sigificance value (P or Expect) among significant hits.

See Also   : L<hits>(), L<num_hits>(), L<is_signif>()

=cut

#---------
sub hit {
#---------
    my( $self, $option) = @_;
    $option ||= 'best';
    
    $self->{'_is_significant'} or 
	$self->throw("There were no significant hits.",
		     "Use num_hits(), hits(), is_signif() to check.");

    my @hits = @{$self->{'_hits'}};
    
    return $hits[0]      if $option =~ /best|first|1/i;
    return $hits[$#hits] if $option =~ /worst|last/i;

    # Get hit by name.	    
    foreach ( @hits ) {
	return $_ if $_->name() =~ /$option/i;
    }

    $self->throw("Can't get hit for: $option");
}



=head2 num_hits

 Usage     : $blast->num_hits( ['total'] );
 Purpose   : Get number of significant hits or number of total hits.
 Examples  : $num_signif = $blast-num_hits;
           : $num_total  = $blast->num_hits('total');
 Returns   : Integer
 Argument  : String = 'total' (or no argument).
           :   No argument (Default) = return number of significant hits.
           :   'total' = number of total hits.
 Throws    : n/a.
           : Not throwing exception because the absence of hits may have
           : resulted from stringent significance criteria, not a failure
           : set the hits.

See Also   : L<hits>(), L<hit>(), L<is_signif>(), L<_set_signif>()

=cut

#-------------
sub num_hits {
#-------------
    my( $self, $option) = @_;
    $option ||= '';

    $option =~ /total/i and return $self->{'_numHits'} || 0;

    # Default: returning number of significant hits.
    return 0 if not $self->{'_is_significant'};
    return scalar(@{$self->{'_hits'}});
}



=head2 lowest_p

 Usage     : $blast->lowest_p()
 Purpose   : Get the lowest P-value among all hits in a BLAST report.
           : Syntactic sugar for $blast->hit('best')->p().
 Returns   : Float or scientific notation number.
 Argument  : n/a.
 Throws    : Exception if the Blast report does not report P-values
           : (as is the case for NCBI Blast2).
 Comments  : A value is returned regardless of whether or not there were
           : significant hits ($DEFAULT_SIGNIF, currently  999).

See Also   : L<lowest_expect>(), L<lowest_signif>(), L<highest_p>(), L<signif_fmt>()

=cut

#------------
sub lowest_p {
#------------
    my $self = shift;

    # Layout 2 = NCBI Blast 2.x does not report P-values.
    $self->_layout == 2 and
	$self->throw("Can't get P-value with BLAST2.", 
		     "Use lowest_signif() or lowest_expect()");

    return $self->{'_lowestSignif'};
}



=head2 lowest_expect

 Usage     : $blast->lowest_expect()
 Purpose   : Get the lowest Expect value among all hits in a BLAST report.
           : Syntactic sugar for $blast->hit('best')->expect()
 Returns   : Float or scientific notation number.
 Argument  : n/a.
 Throws    : Exception if there were no significant hits and the report
           : does not have Expect values on the description lines
           : (i.e., Blast1, WashU-Blast2).

See Also   : L<lowest_p>(), L<lowest_signif>(), L<highest_expect>(), L<signif_fmt>()

=cut

#------------------
sub lowest_expect {
#------------------
    my $self = shift;
    
    return $self->{'_lowestSignif'} if $self->_layout == 2;

    if($self->{'_is_significant'}) {
	my $bestHit = $self->{'_hits'}->[0];
	return $bestHit->expect();
    } else {
	$self->throw("Can't get lowest expect value: no significant hits ",
		     "The format of this report requires expect values to be extracted\n".
		     "from the hits themselves.");
    }
}


=head2 highest_p

 Example   : $blast->highest_p( ['overall'])
 Purpose   : Get the highest P-value among all hits in a BLAST report.
           : Syntactic sugar for $blast->hit('worst')->p()
           : Can also get the highest P-value overall (not just among signif hits).
 Usage     : $p_signif = $blast->highest_p();
           : $p_all    = $blast->highest_p('overall');
 Returns   : Float or scientific notation number.
 Argument  : String 'overall' or no argument.
           : No argument = get highest P-value among significant hits.
 Throws    : Exception if object is created from a Blast2 report
           : (which does not report P-values).

See Also   : L<highest_signif>(), L<lowest_p>(), L<_set_signif>(), L<signif_fmt>()

=cut

#---------------
sub highest_p {
#---------------
    my ($self, $overall) = @_;
    
    # Layout 2 = NCBI Blast 2.x does not report P-values.
    $self->_layout == 2 and
	$self->throw("Can't get P-value with BLAST2.", 
		     "Use highest_signif() or highest_expect()");

    return $self->{'_highestSignif'} if $overall;
    $self->hit('worst')->p();
}



=head2 highest_expect

 Usage     : $blast_object->highest_expect( ['overall'])
 Purpose   : Get the highest Expect value among all significant hits in a BLAST report.
           : Syntactic sugar for $blast->hit('worst')->expect()
 Examples  : $e_sig = $blast->highest_expect();
           : $e_all = $blast->highest_expect('overall');
 Returns   : Float or scientific notation number.
 Argument  : String 'overall' or no argument.
           : No argument = get highest Expect-value among significant hits.
 Throws    : Exception if there were no significant hits and the report
           : does not have Expect values on the description lines
           : (i.e., Blast1, WashU-Blast2).

See Also   : L<lowest_expect>(), L<highest_signif>(), L<signif_fmt>()

=cut

#-------------------
sub highest_expect {
#-------------------
    my ($self, $overall) = @_;
    
    return $self->{'_highestSignif'} if $overall and $self->_layout == 2;

    if($self->{'_is_significant'}) {
	return $self->hit('worst')->expect;
    } else {
	$self->throw("Can't get highest expect value: no significant hits ",
		     "The format of this report requires expect values to be extracted\n".
		     "from the hits themselves.");
    }
}




=head2 lowest_signif

 Usage     : $blast_obj->lowest_signif();
           : Syntactic sugar for $blast->hit('best')->signif()
 Purpose   : Get the lowest P or Expect value among all hits
           : in a BLAST report.
           : This method is syntactic sugar for $blast->hit('best')->signif()
           : The value returned is the one which is reported in the decription
           : section of the Blast report.
           : For Blast1 and WU-Blast2, this is a P-value, 
           : for NCBI Blast2, it is an Expect value.
 Example   : $blast->lowest_signif();
 Returns   : Float or scientific notation number.
 Argument  : n/a.
 Throws    : n/a.
 Status    : Deprecated. Use lowest_expect() or lowest_p().
 Comments  : The signif() method provides a way to deal with the fact that
           : Blast1 and Blast2 formats differ in what is reported in the
           : description lines of each hit in the Blast report. The signif()
           : method frees any client code from having to know if this is a P-value
           : or an Expect value, making it easier to write code that can process 
           : both Blast1 and Blast2 reports. This is not necessarily a good thing, since
           : one should always know when one is working with P-values or
           : Expect values (hence the deprecated status).
           : Use of lowest_expect() is recommended since all hits will have an Expect value.

See Also   : L<lowest_p>(), L<lowest_expect>(), L<signif>(), L<signif_fmt>(), L<_set_signif>()

=cut

#------------------
sub lowest_signif {
#------------------
    my ($self) = @_;

    return $self->{'_lowestSignif'};
}



=head2 highest_signif

 Usage     : $blast_obj->highest_signif('overall');
           : Syntactic sugar for $blast->hit('worst')->signif()
 Purpose   : Get the highest P or Expect value among all hits
           : in a BLAST report.
           : The value returned is the one which is reported in the decription
           : section of the Blast report.
           : For Blast1 and WU-Blast2, this is a P-value, 
           : for NCBI Blast2, it is an Expect value.
 Example   : $blast->highest_signif();
 Returns   : Float or scientific notation number.
 Argument  : Optional  string 'overall' to get the highest overall significance value.
 Throws    : n/a.
 Status    : Deprecated. Use highest_expect() or highest_p().
 Comments  : Analogous to lowest_signif(), q.v.

See Also   : L<lowest_signif>(), L<lowest_p>(), L<lowest_expect>(), L<signif>(), L<signif_fmt>(), L<_set_signif>()

=cut

#---------------------
sub highest_signif {
#---------------------
    my ($self, $overall) = @_;
    
    return $self->{'_highestSignif'} if $overall;

    if($self->{'_is_significant'}) {
	return $self->hit('worst')->signif;
    }
}




=head2 matrix

 Usage     : $blast_object->matrix();
 Purpose   : Get the name of the scoring matrix used.
           : This is extracted from the report.
 Argument  : n/a
 Returns   : string or undef if not defined

See Also   : L<set_parameters>()

=cut

#------------
sub matrix { my $self = shift; $self->{'_matrix'} || $Blast->{'_matrix'}; }
#------------


=head2 filter

 Usage     : $blast_object->filter();
 Purpose   : Get the name of the low-complexity sequence filter used.
           : (SEG, SEG+XNU, DUST, NONE).
           : This is extracted from the report.
 Argument  : n/a
 Returns   : string or undef if not defined

See Also   : L<set_parameters>()

=cut

#----------
sub filter { my $self = shift; $self->{'_filter'}  || $Blast->{'_filter'}; }
#----------



=head2 expect

 Usage     : $blast_object->expect();
 Purpose   : Get the expect parameter (E) used for the Blast analysis.
           : This is extracted from the report.
 Argument  : n/a
 Returns   : string or undef if not defined.

See Also   : L<set_parameters>()

=cut

#-----------
sub expect { my $self = shift; $self->{'_expect'} || $Blast->{'_expect'}; }
#-----------



=head2 karlin_altschul

 Usage     : $blast_object->karlin_altschul();
 Purpose   : Get the Karlin_Altschul sum statistics (Lambda, K, H)
           : These are extracted from the report.
 Argument  : n/a
 Returns   : list of three floats (Lambda, K, H)
           : If not defined, returns list of three zeros)

See Also   : L<set_parameters>()

=cut

#---------------------
sub karlin_altschul { 
#---------------------
    my $self = shift; 
    if(defined($self->{'_lambda'})) {
	($self->{'_lambda'}, $self->{'_k'}, $self->{'_h'});
    } elsif(defined($Blast->{'_lambda'})) {
	($Blast->{'_lambda'}, $Blast->{'_k'}, $Blast->{'_h'});
    } else {
	(0, 0, 0);
    }
}



=head2 word_size

 Usage     : $blast_object->word_size();
 Purpose   : Get the word_size used during the Blast analysis.
           : This is extracted from the report.
 Argument  : n/a
 Returns   : integer or undef if not defined.

See Also   : L<set_parameters>()

=cut

#--------------
sub word_size { 
#--------------
    my $self = shift; 
    $self->{'_word_size'} || $Blast->{'_word_size'}; 
}



=head2 s

 Usage     : $blast_object->s();
 Purpose   : Get the s statistic for the Blast analysis.
           : This is extracted from the report.
 Argument  : n/a
 Returns   : integer or undef if not defined.

See Also   : L<set_parameters>()

=cut

#------
sub s { my $self = shift; $self->{'_s'} || $Blast->{'_s'}; }
#------



=head2 gap_creation

 Usage     : $blast_object->gap_creation();
 Purpose   : Get the gap creation penalty used for a gapped Blast analysis.
           : This is extracted from the report.
 Argument  : n/a
 Returns   : integer or undef if not defined.

See Also   : L<gap_extension>()

=cut

#-----------------
sub gap_creation { 
#-----------------
    my $self = shift; 
    $self->{'_gapCreation'} || $Blast->{'_gapCreation'};
}



=head2 gap_extension

 Usage     : $blast_object->gap_extension();
 Purpose   : Get the gap extension penalty used for a gapped Blast analysis.
           : This is extracted from the report.
 Argument  : n/a
 Returns   : integer or undef if not defined.

See Also   : L<gap_extension>()

=cut

#-------------------
sub gap_extension { 
#-------------------
    my $self = shift; 
    $self->{'_gapExtension'} || $Blast->{'_gapExtension'};
}



=head2 ambiguous_aln

 Usage     : $blast_object->ambiguous_aln();
 Purpose   : Test all hits and determine if any have an ambiguous alignment.
 Example   : print "ambiguous" if $blast->ambiguous_aln();
 Returns   : Boolean (true if ANY significant hit has an ambiguous alignment)
 Argument  : n/a
 Throws    : n/a
 Status    : Experimental
 Comments  : An ambiguous BLAST alignment is defined as one where two or more
           : different HSPs have significantly overlapping sequences such
           : that it is not possible to create a unique alignment
           : by simply concatenating HSPs. This may indicate the presence
           : of multiple domains in one sequence relative to another.
           : This method only indicates the presence of ambiguity in at 
           : least one significant hit. To determine the nature of the
           : ambiguity, each hit must be examined.

See Also   : B<Bio::Tools::Blast::Sbjct::ambiguous_aln()>,L<Links to related modules>

=cut

#----------------
sub ambiguous_aln { 
#----------------
    my $self = shift;
    foreach($self->hits()) {
	return 1 if ($_->ambiguous_aln() ne '-');
    }
    0;
}


=head2 overlap

 Usage     : $blast_object->overlap([integer]);
 Purpose   : Set/Get the number of overlapping residues allowed when tiling multiple HSPs.
           : Delegates to Bio::Tools::Blast::Sbjct::overlap().
 Throws    : Exception if there are no significant hits.
 Status    : Experimental

See Also   : B<Bio::Tools::Blast::Sbjct::overlap()>,L<Links to related modules>

=cut

#------------
sub overlap { 
#------------
    my $self = shift; 
    if(not $self->hits) {
	$self->throw("Can't get overlap data without significant hits.");
    }
    $self->hit->overlap();
}


=head2 homol_data

 Usage     : @data = $blast_object->homo_data( %named_params );
 Purpose   : Gets specific similarity data about each significant hit. 
 Returns   : Array of strings:
           : "Homology data" for each HSP is in the format:
           :  "<integer> <start> <stop>"
           : Data for different HSPs are tab-delimited.
 Argument  : named parameters passed along to the hit objects.
 Throws    : n/a
 Status    : Experimental
 Comments  : This is a very experimental method used for obtaining an 
           : indication of:
           :   1) how many HSPs are in a Blast alignment
           :   2) how strong the similarity is between sequences in the HSP
           :   3) the endpoints of the alignment (sequence monomer numbers)

See Also   : B<Bio::Tools::Blast::Sbjct::homol_data()>,L<Links to related modules>

=cut

#----------------
sub homol_data {
#----------------
    
    my ($self, %param) = @_;
    my @hits = $self->hits();
    my @data = ();
    
    ## Note: Homology data can be either for the query sequence or the hit
    ##       (Sbjct) sequence. Default is for sbjct. This is specifyable via
    ##       $param{-SEQ}='sbjct' || 'query'.

    foreach ( @hits ) {
	push @data, $_->homol_data(%param);
    }
    @data;
}




=head1 REPORT GENERATING METHODS


=head2 table

 Usage     : $blast_obj->table( [get_desc]);
 Purpose   : Output data for each HSP of each hit in tab-delimited format.
 Example   : print $blast->table;
           : print $blast->table(0);  
           : # Call table_labels() to print labels.
 Argument  : get_desc = boolean, if false the description of each hit is not included.
           :            Default: true (if not defined, include description column).
 Returns   : String containing tab-delimited set of data for each HSP
           : of each significant hit. Different HSPs are separated by newlines.
           : Left-to-Right order of fields:
           :   QUERY_NAME             # Sequence identifier of the query.
           :   QUERY_LENGTH           # Full length of the query sequence.
           :   SBJCT_NAME             # Sequence identifier of the sbjct ("hit".
           :   SBJCT_LENGTH           # Full length of the sbjct sequence.
           :   EXPECT                 # Expect value for the alignment.
           :   SCORE                  # Blast score for the alignment.
           :   BITS                   # Bit score for the alignment.
           :   NUM_HSPS               # Number of HSPs (not the "N" value).
           :   HSP_FRAC_IDENTICAL     # fraction of identical substitutions.
           :   HSP_FRAC_CONSERVED     # fraction of conserved ("positive") substitutions.
           :   HSP_QUERY_ALN_LENGTH   # Length of the aligned portion of the query sequence.
           :   HSP_SBJCT_ALN_LENGTH   # Length of the aligned portion of the sbjct sequence.
           :   HSP_QUERY_GAPS         # Number of gaps in the aligned query sequence.
           :   HSP_SBJCT_GAPS         # Number of gaps in the aligned sbjct sequence.
           :   HSP_QUERY_START        # Starting coordinate of the query sequence.
           :   HSP_QUERY_END          # Ending coordinate of the query sequence.
           :   HSP_SBJCT_START        # Starting coordinate of the sbjct sequence.
           :   HSP_SBJCT_END          # Ending coordinate of the sbjct sequence.
           :   HSP_QUERY_STRAND       # Strand of the query sequence (TBLASTN/X only)
           :   HSP_SBJCT_STRAND       # Strand of the sbjct sequence (TBLASTN/X only)
           :   HSP_FRAME              # Frame for the sbjct translation (TBLASTN/X only)
           :   SBJCT_DESCRIPTION  (optional)  # Full description of the sbjct sequence from 
           :                                  # the alignment section.
 Throws    : n/a
 Comments  : This method does not collect data based on tiling of the HSPs.
           : The table will contains redundant information since the hit name,
           : id, and other info for the hit are listed for each HSP.
           : If you need more flexibility in the output format than this
           : method provides, design a custom function.

See Also  : L<table_tiled>(), L<table_labels>(), L<_display_hits>()

=cut

#-----------
sub table {
#-----------
    my ($self, $get_desc) = @_;
    my $str = '';

    $get_desc = defined $get_desc ? $get_desc : 1;
#    $str .= $self->_table_labels($get_desc) unless $self->{'_labels'};

    my $sigfmt = $self->signif_fmt();
    $sigfmt eq 'parts' and $sigfmt = 'exp';  # disallow 'parts' format for this table.
    my $sigprint = $sigfmt eq 'exp' ? 'd' : '.1e';

    my ($hit, $hsp);
    foreach $hit($self->hits) {
	foreach $hsp($hit->hsps) {
	    # Note: range() returns a 2-element list.
	    $str .= sprintf "%s\t%d\t%s\t%d\t%$sigprint\t%d\t%d\t%d\t%.2f\t%.2f\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%s\t%s\t%s\t%s\n", 
                   $self->name, $self->length, $hit->name, $hit->length, 
	           $hit->expect($sigfmt), $hit->score, $hit->bits,
 	           $hit->num_hsps, $hsp->frac_identical, $hsp->frac_conserved, 
	           $hsp->length('query'), $hsp->length('sbjct'), 
	           $hsp->gaps('list'),
	           $hsp->range('query'), $hsp->range('sbjct'), 
	           $hsp->strand('query'), $hsp->strand('sbjct'), $hsp->frame,
	           ($get_desc ? $hit->desc  : '');
	}
    }
    $str =~ s/\t\n/\n/gs;
    $str;
}



=head2 table_labels

 Usage     : print $blast_obj->table_labels( [get_desc] );
 Purpose   : Get column labels for table().
 Returns   : String containing column labels. Tab-delimited.
 Argument  : get_desc = boolean, if false the description column is not included.
           : Default: true (if not defined, include description column).
 Throws    : n/a

See Also   : L<table>()

=cut

#----------------
sub table_labels {
#----------------
    my ($self, $get_desc) = @_;
    $get_desc = defined $get_desc ? $get_desc : 1;
    my $descstr = $get_desc ? 'DESC' : '';
    my $descln = $get_desc ? '-----' : '';

    my $str = sprintf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", 
                       'QUERY', 'Q_LEN', 'SBJCT', 'S_LEN', 'EXPCT', 'SCORE', 'BITS', 'HSPS', 
                       'IDEN', 'CONSV', 'Q_ALN', 'S_ALN', 'Q_GAP', 'S_GAP',
                       'Q_BEG', 'Q_END', 'S_BEG', 'S_END', 'Q_STR', 'S_STR', 'FRAM', $descstr;
    $str .= sprintf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", 
                       '-----', '-----', '-----', '-----', '-----', '-----', '-----', '-----', 
                       '-----', '-----', '-----', '-----', '-----', '-----', 
                       '-----', '-----', '-----','-----', '-----', '-----','-----', $descln;

    $self->{'_labels'} = 1;    
    $str =~ s/\t\n/\n/gs;
    $str;
}



=head2 table_tiled

 Purpose   : Get data from tiled HSPs in tab-delimited format.
           : Allows only minimal flexibility in the output format.
           : If you need more flexibility, design a custom function.
 Usage     : $blast_obj->table_tiled( [get_desc]);
 Example   : print $blast->table_tiled;
           : print $blast->table_tiled(0);  
           : # Call table_labels_tiled() if you want labels.
 Argument  : get_desc = boolean, if false the description of each hit is not included.
           :            Default: true (include description).
 Returns   : String containing tab-delimited set of data for each HSP
           : of each significant hit. Multiple hits are separated by newlines.
           : Left-to-Right order of fields:
           :   QUERY_NAME            # Sequence identifier of the query.
           :   QUERY_LENGTH          # Full length of the query sequence.
           :   SBJCT_NAME            # Sequence identifier of the sbjct ("hit".
           :   SBJCT_LENGTH          # Full length of the sbjct sequence.
           :   EXPECT                # Expect value for the alignment.
           :   SCORE                 # Blast score for the alignment.
           :   BITS                  # Bit score for the alignment.
           :   NUM_HSPS              # Number of HSPs (not the "N" value).
           :   FRAC_IDENTICAL*       # fraction of identical substitutions.
           :   FRAC_CONSERVED*       # fraction of conserved ("positive") substitutions .
           :   FRAC_ALN_QUERY*       # fraction of the query sequence that is aligned.
           :   FRAC_ALN_SBJCT*       # fraction of the sbjct sequence that is aligned.
           :   QUERY_ALN_LENGTH*     # Length of the aligned portion of the query sequence.
           :   SBJCT_ALN_LENGTH*     # Length of the aligned portion of the sbjct sequence.
           :   QUERY_GAPS*           # Number of gaps in the aligned query sequence.
           :   SBJCT_GAPS*           # Number of gaps in the aligned sbjct sequence.
           :   QUERY_START*          # Starting coordinate of the query sequence.
           :   QUERY_END*            # Ending coordinate of the query sequence.
           :   SBJCT_START*          # Starting coordinate of the sbjct sequence.
           :   SBJCT_END*            # Ending coordinate of the sbjct sequence.
           :   AMBIGUOUS_ALN         # Ambiguous alignment indicator ('qs', 'q', 's').
           :   SBJCT_DESCRIPTION  (optional)  # Full description of the sbjct sequence from 
           :                                  # the alignment section.
           :
           : * Items marked with a "*" report data summed across all HSPs
           :   after tiling them to avoid counting data from overlapping regions 
           :   multiple times.
 Throws    : n/a
 Comments  : This function relies on tiling of the HSPs since it calls 
           : frac_identical() etc. on the hit as opposed to each HSP individually.

See Also   : L<table>(), L<table_labels_tiled>(), B<Bio::Tools::Blast::Sbjct::"HSP Tiling and Ambiguous Alignments">, L<Links to related modules>

=cut

#----------------
sub table_tiled {
#----------------
    my ($self, $get_desc) = @_;
    my $str = '';

    $get_desc = defined $get_desc ? $get_desc : 1;

    my ($hit);
    my $sigfmt = $self->signif_fmt();
    $sigfmt eq 'parts' and $sigfmt = 'exp';  # disallow 'parts' format for this table.
    my $sigprint = $sigfmt eq 'exp' ? 'd' : '.1e';

    foreach $hit($self->hits) {
	$str .= sprintf "%s\t%d\t%s\t%d\t%$sigprint\t%d\t%d\t%d\t%.2f\t%.2f\t%.2f\t%.2f\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%s\t%s\n", 
	               $self->name, $self->length, $hit->name, $hit->length, 
	               $hit->expect($sigfmt), $hit->score, $hit->bits, 
	               $hit->num_hsps, $hit->frac_identical, $hit->frac_conserved, 
	               $hit->frac_aligned_query, $hit->frac_aligned_hit,
	               $hit->length_aln('query'), $hit->length_aln('sbjct'), 
                       $hit->gaps, $hit->range('query'), $hit->range('sbjct'),
	               $hit->ambiguous_aln, ($get_desc ? $hit->desc : '');
    }
    $str =~ s/\t\n/\n/gs;
    $str;
}


=head2 table_labels_tiled

 Usage     : print $blast_obj->table_labels_tiled( [get_desc] );
 Purpose   : Get column labels for table_tiled().
 Returns   : String containing column labels. Tab-delimited.
 Argument  : get_desc = boolean, if false the description column is not included.
           : Default: true (include description column).
 Throws    : n/a

See Also   : L<table_tiled>()

=cut

#---------------------
sub table_labels_tiled {
#---------------------
    my ($self, $get_desc) = @_;
    my $descstr = $get_desc ? 'DESC' : '';
    my $descln = $get_desc ? '-----' : '';

    my $str = sprintf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", 
                       'QUERY', 'Q_LEN', 'SBJCT', 'S_LEN', 'EXPCT', 'SCORE', 'BITS',
                       'HSPS', 'FR_ID', 'FR_CN', 'FR_ALQ', 'FR_ALS', 'Q_ALN', 
                       'S_ALN', 'Q_GAP', 'S_GAP', 'Q_BEG', 'Q_END', 'S_BEG', 'S_END', 
                       'AMBIG', $descstr;
    $str =~ s/\t\n/\n/;
    $str .= sprintf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", 
                       '-----', '-----', '------', '-----', '-----','-----', '-----',
                       '-----', '-----', '-----', '-----', '-----', '-----',
                       '-----', '-----', '-----','-----','-----', '-----', 
                       '-----','-----', $descln;

    $self->{'_labels_tiled'} = 1;    
    $str =~ s/\t\n/\n/gs;
    $str;
}




=head2 display

 Usage     : $blast_object->display( %named_parameters );
 Purpose   : Display information about Bio::Tools::Blast.pm data members,
           : E.g., parameters of the report, data for each hit., etc.
           : Overrides Bio::Root::Object::display().
 Example   : $object->display(-SHOW=>'stats');
           : $object->display(-SHOW=>'stats,hits');
 Argument  : Named parameters: (TAGS CAN BE UPPER OR LOWER CASE)
           :     -SHOW  => 'file' | 'hits' | 'homol'
           :     -WHERE => filehandle (default = STDOUT)
 Returns   : n/a (print/printf is called)
 Status    : Experimental
 Comments  : For tab-delimited output, see table().

See Also   : L<_display_homol>(), L<_display_hits>(), L<_display_stats>(), L<table>(), B<Bio::Root::Tools::SeqAnal::display()>,L<Links to related modules>, 

=cut

#--------------
sub display {
#--------------
    my( $self, %param ) = @_;
    
    $self->SUPER::display(%param);
    my $OUT = $self->fh();

    $self->show =~ /homol/i and $self->_display_homol($OUT);
    $self->show =~ /hits/i and $self->_display_hits( %param );
    1;
}



=head2 _display_homol

 Usage     : n/a; called automatically by display()
 Purpose   : Print homology data for hits in the BLAST report.
 Example   : n/a
 Argument  : one argument = filehandle object.
 Returns   : printf call.
 Status    : Experimental

See Also   : L<homol_data>(), L<display>()

=cut

#-------------------
sub _display_homol {
#-------------------
    my( $self, $OUT ) = @_;
    
    print $OUT "\nBLAST HOMOLOGY DATA FOR: ${\$self->name()}\n";
    print $OUT '-'x40,"\n";
    
    foreach ( $self->homol_data()) {
	print $OUT "$_\n";
    }
}


=head2 _display_stats

 Usage     : n/a; called automatically by display()
 Purpose   : Display information about the Blast report "meta" data.
           : Overrides Bio::Tools::SeqAnal::_display_stats() calling it first.
 Example   : n/a
 Argument  : one argument = filehandle object.
 Returns   : printf call.
 Status    : Experimental

See Also   : L<display>(), B<Bio::Tools::SeqAnal::_display_stats()>,L<Links to related modules>

=cut

#--------------------
sub _display_stats {
#--------------------
    my( $self, $OUT ) = @_;
    
    $self->SUPER::_display_stats($OUT);
    printf( $OUT "%-15s: %s\n", "GAPPED", $self->gapped ? 'YES' : 'NO');
    printf( $OUT "%-15s: %d\n", "TOTAL HITS", $self->num_hits('total'));
    printf( $OUT "%-15s: %s\n", "CHECKED ALL", $Blast->{'_check_all'} ? 'YES' : 'NO');
    printf( $OUT "%-15s: %s\n", "FILT FUNC", $Blast->{'_filt_func'} ? 'YES' : 'NO');
    if($self->min_length) {
	printf( $OUT "%-15s: Length >= %s\n", "MIN_LENGTH", $self->min_length);
    }

    my $num_hits =  $self->num_hits;
    my $signif_str = ($self->_layout == 1) ? 'P' : 'EXPECT';
    if($num_hits) {
	printf( $OUT "%-15s: %d\n", "SIGNIF HITS", $num_hits);
	# Blast1: signif = P-value, Blast2: signif = Expect value.
	
	printf( $OUT "%-15s: %s ($signif_str-VALUE)\n", "SIGNIF CUTOFF", $self->signif);
	printf( $OUT "%-15s: %s\n", "LOWEST $signif_str", $self->lowest_signif());
	printf( $OUT "%-15s: %s\n", "HIGHEST $signif_str", $self->highest_signif());
    }
    printf( $OUT "%-15s: %s (OVERALL)\n", "HIGHEST $signif_str", $self->highest_signif('overall'));
    

    if($self->_get_stats) {
	my $warn = ($Blast->{'_share'} and $Blast->{'_stream'}) ? '(SHARED STATS)' : '';
	printf( $OUT "%-15s: %s\n", "MATRIX", $self->matrix() || 'UNKNOWN');
	printf( $OUT "%-15s: %s\n", "FILTER", $self->filter() || 'UNKNOWN');
	printf( $OUT "%-15s: %s\n", "EXPECT", $self->expect() || 'UNKNOWN');
	printf( $OUT "%-15s: %.3f, %.3f, %.3f %s\n", "LAMBDA, K, H", $self->karlin_altschul(), $warn);
	printf( $OUT "%-15s: %s\n", "WORD SIZE", $self->word_size() || 'UNKNOWN');
	printf( $OUT "%-15s: %s %s\n", "S", $self->s() || 'UNKNOWN', $warn);
	if($self->gapped) {
	    printf( $OUT "%-15s: %s\n", "GAP CREATION", $self->gap_creation() || 'UNKNOWN');
	    printf( $OUT "%-15s: %s\n", "GAP EXTENSION", $self->gap_extension() || 'UNKNOWN');
	}
    }
    print $OUT "\n";
}


=head2 _display_hits

 Usage     : n/a; called automatically by display()
 Purpose   : Display data for each hit. Not tab-delimited.
 Example   : n/a
 Argument  : one argument = filehandle object.
 Returns   : printf call.
 Status    : Experimental
 Comments  : For tab-delimited output, see table().

See Also   : L<display>(), B<Bio::Tools::Blast::Sbjct::display()>, L<table>(),  L<Links to related modules>

=cut

sub _display_hits {
    
    my( $self, %param ) = @_;
    my $OUT = $self->fh();
    my @hits  = $self->hits();
    
    ## You need a wide screen to see this properly.
    # Header.
    print $OUT "\nBLAST HITS FOR: ${\$self->name()} length = ${\$self->length}\n";
    print "(This table requires a wide display.)\n";
    print $OUT '-'x80,"\n";

    print $self->table_labels_tiled(0);
    print $self->table_tiled(0);

    ## Doing this interactively since there is potentially a lot of data here.
    ## Not quite satisfied with this approach.

    if (not $param{-INTERACTIVE}) {
	return 1;
    } else {
	my ($reply);
	print "\nDISPLAY FULL HSP DATA? (y/n): [n] ";
	chomp( $reply = <STDIN> );
	$reply =~ /^y.*/i;
	
	my $count = 0;
	foreach ( @hits ) {
	    $count++;
	    print $OUT "\n\n",'-'x80,"\n";
	    print $OUT "HSP DATA FOR HIT #$count  (hit <RETURN>)";
		print $OUT "\n",'-'x80;<STDIN>;
	    $param{-SHOW} = 'hsp';
	    $_->display( %param );
	}
    }
    1;
}


=head2 to_html

 Usage     : $blast_object->to_html( [%named_parameters] )
 Purpose   : To produce an HTML-formatted version of a BLAST report
           : for efficient navigation of the report using a web browser.
 Example   : # Using the static Blast object:
           : # Can read from STDIN or from a designated file:
           :   $Blast->to_html($file); 
           :   $Blast->to_html(-FILE=>$file, -HEADER=>$header);
           :   (if no file is supplied, STDIN will be used).
           : # saving HTML to an array:
           :   $Blast->to_html(-FILE=>$file, -OUT =>\@out);
           : # Using a pre-existing blast object (must have been built from
           : # a file, not STDIN:
           :   $blastObj->to_html();  
 Returns   : n/a, either prints report to STDOUT or saves to a supplied array
           : if an '-OUT' parameter is defined (see below).
 Argument  : %named_parameters: (TAGS ARE AND CASE INSENSITIVE).
           :    -FILE   => string containing name of a file to be processed.
           :               If not a valid file or undefined, STDIN will be used.
           :               Can skip the -FILE tag if supplying a filename 
           :               as a single argument.
           :    -HEADER => string 
           :               This should be an HTML-formatted string to be used 
           :               as a header for the page, typically describing query sequence,
           :               database searched, the date of the analysis, and any
           :               additional links. 
           :               If not supplied, no special header is used.
           :               Regardless of whether a header is supplied, the
           :               standard info at the top of the report is highlighted.
           :               This should include the <HEADER></HEADER> section 
           :               of the page as well.
           :
           :    -IN    => array reference containing a raw Blast report.
           :              each line in a separate element in the array. 
           :              If -IN is not supplied, read() is called
           :              and data is then read either from STDIN or a file.
           :
           :    -OUT   => array reference to hold the HTML output.
           :              If not supplied, output is sent to STDOUT.
 Throws    : Exception is propagated from $HTML::get_html_func()
           : and Bio::Root::Object::read().
 Comments  : The code that does the actual work is located in
           :  Bio::Tools::Blast::HTML::get_html_func().
 Bugs      : Some hypertext links to external databases may not be
           : correct. This due in part to the dynamic nature of
           : the web.
           : Hypertext links are not added to hits without database ids.
 TODO      : Possibly create a function to produce fancy default header
           : using data extracted from the report (requires some parsing).
           : For example, it would be nice to always include a date

See Also   : B<Bio::Tools::Blast::HTML::get_html_func()>, B<Bio::Root::Object::read()>, L<Links to related modules>

=cut

#------------
sub to_html {
#------------
    my ($self, @param) = @_;

    # Permits syntax such as: $blast->to_html($filename);
    my ($file, $header_html, $in_aref, $out_aref) = 
	$self->_rearrange([qw(FILE HEADER IN OUT)], @param);

    $self->file($file) if $file;

    $header_html ||= '';  
    (ref($out_aref) eq 'ARRAY') ? push(@$out_aref, $header_html) : print "$header_html\n";

    require Bio::Tools::Blast::HTML; 
    import Bio::Tools::Blast::HTML qw(&get_html_func); 

    my ($func);
    eval{ $func = &get_html_func($out_aref);  };
    if($@) {
	my $err = $@; 
	$self->throw($err);
    }

    eval {
	if(!$header_html) {
	    $out_aref ? push(@$out_aref, "<html><body>\n") : print "<html><body>\n";
	}

	if (ref ($in_aref) =~ /ARRAY/) {
	    # If data is being supplied, process it.
	    foreach(@$in_aref) {
		&$func($_);
	    }
	} else {
	    # Otherwise, read it, processing as we go.
	    
	    if($RawData) {
		# If already loaded, process it.
		foreach(split("\n", $RawData)) {
		    &$func("$_\n");
		}
	    } else {
		$self->read(-FUNC => $func, @param);
	    }
	}    
	$out_aref ? push(@$out_aref, "\n</pre></body></html>") : print "\n</pre></body></html>";
    };

    if($@) {
	# Check for trivial error (report already HTML formatted).
	if($@ =~ /HTML formatted/) {
	    print STDERR "\a\nBlast report appears to be HTML formatted already.\n\n";
	} else {
	    my $err = $@; 
	    $self->throw($err);
	}
    }
}



1;
__END__

#####################################################################################
#                                END OF CLASS                                       #
#####################################################################################

=head1 FOR DEVELOPERS ONLY

=head2 Data Members

Information about the various data members of this module is provided for those 
wishing to modify or understand the code. Two things to bear in mind: 

=over 4

=item 1 Do NOT rely on these in any code outside of this module. 

All data members are prefixed with an underscore to signify that they are private.
Always use accessor methods. If the accessor doesn't exist or is inadequate, 
create or modify an accessor (and let me know, too!). (An exception to this might
be for Sbjct.pm or HSP.pm which are more tightly coupled to Blast.pm and
may access Blast data members directly for efficiency purposes, but probably 
should not).

=item 2 This documentation may be incomplete and out of date.

It is easy for these data member descriptions to become obsolete as 
this module is still evolving. Always double check this info and search 
for members not described here.

=back

An instance of Bio::Tools::Blast.pm is a blessed reference to a hash containing
all or some of the following fields:

 FIELD           VALUE
 --------------------------------------------------------------
 _significance    P-value or Expect value cutoff (depends on Blast version:
	          Blast1/WU-Blast2 = P-value; Blast2 = Expect value).
   	          Values GREATER than this are deemed not significant.

 _significant     Boolean. True if the query has one or more significant hit.

 _min_length      Integer. Query sequences less than this will be skipped.

 _confirm_significance  Boolean. True if client has supplied significance criteria.

 _gapped          Boolean. True if BLAST analysis has gapping turned on.

 _hits            List of Sbjct.pm objects. 

 _numHits         Number of hits obtained from the BLAST report.

 _numSigHits      Number of significant based on Significant data members.

 _highestSignif   Highest P or Expect value overall (not just what is stored in _hits).

 _lowestSignif    Lowest P or Expect value overall (not just what is stored in _hits).


The static $Blast object has a special set of members:

  _rawData  
  _errs
  _share
  _stream
  _get_stats
  _gapped
  _filt_func

 Miscellaneous statistical parameters:
 -------------------------------------
  _filter, _matrix, _word_size, _expect, _gapCreation, _gapExtension, _s,
  _lambda, _k, _h
  

 INHERITED DATA MEMBERS 
 -----------------------
 (See Bio::Tools::SeqAnal.pm for inherited data members.)

=cut

1;
