#!/usr/bin/env perl 

# Example usage of a SearchIO::psiblast parser of traditional format Blast reports.
# This parser represents a new and improved version of Bio/Tools/Blast.pm.
#
# Usage:
#   STDIN:  stream containing one or more BLAST or PSI-BLAST reports.
#   STDOUT: none, but generates an output file "hspwriter.out"
#           containing tab-delimited data on a per-HSP basis.
#   STDERR: Progress info.
#
# In this example, we create a SearchIO parser that screens out hits 
# based on expect (or P) scores and a default HSPTableWriter. This writer
# provides the same functionality as the original Bio::Tools::Blast::table2()
# function (i.e., a tab-delimited summary of each hit per row).
# HSPTableWriter, however, is customizable so you can specify just the columns
# you want to have in the output table.
#
# For more documentation about the writer, including
# a complete list of columns, execute:
#   perldoc Bio::SearchIO::Writer::HSPTableWriter.
#
# For more documentation about working with Blast result objects,
# see docs for these modules:
#   Bio::Search::Result::BlastResult
#   Bio::Search::Hit::BlastHit
#   Bio::Search::HSP::BlastHSP
#
# For more documentation about the PSI-Blast parser, see docs for
#   Bio::SearchIO::psiblast
#
# Author: Steve Chervitz <sac@bioperl.org>
# Revision: $Id: hspwriter.pl,v 1.2 2002/01/11 08:05:42 sac Exp $

use strict;
use lib '../../../';

use Bio::SearchIO;
use Bio::SearchIO::Writer::HSPTableWriter;

# These are the columns that will be in the output table of BLAST results.
my @columns = qw(
		 query_name
		 query_length
                 hit_name
                 hit_length
		 rank
                 expect
                 frac_identical_query
                 length_aln_query
                 gaps_total
                 strand_query
                 strand_hit
		);


print STDERR "\nUsing SearchIO->new()\n";

# Note that all parameters for the $in, $out, and $writer objects are optional.
# Default in = STDIN; Default out = STDOUT; Default writer = all columns 
# In this example, we're reading from STDIN and  writing to a STDOUT
my $in     = Bio::SearchIO->new( -format => 'psiblast' );
my $writer = Bio::SearchIO::Writer::HSPTableWriter->new( -columns => \@columns );
my $out    = Bio::SearchIO->new( -format => 'psiblast', 
				 -writer => $writer,
				 -file   => ">hspwriter.out" );

while ( my $result = $in->next_result() ) {
  printf STDERR "\nReport %d: $result\n", $in->report_count;
  
  if( $result->hits ) {
    $out->write_result($result, ($in->report_count - 1 ? 0 : 1) );
  }
  else {
    print STDERR "Hitless Blast Report: $result ";
    print STDERR ($result->no_hits_found ? "\n" : "(filtered)\n");
  }
  
  ## For a simple progress monitor, uncomment this line:
  #print STDERR "."; print STDERR "\n" if $in->report_count % 50 == 0;
}

printf STDERR "\n%d Blast report(s) processed.\n", $in->report_count;
printf STDERR "Output sent to file: %s\n",  $out->file if $out->file;
