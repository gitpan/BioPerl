#ifndef DYNAMITEgenomicHEADERFILE
#define DYNAMITEgenomicHEADERFILE
#ifdef _cplusplus
extern "C" {
#endif
#include "sequence.h"



struct bp_sw_Genomic {  
    int dynamite_hard_link;  
    Sequence * baseseq;  
    } ;  
/* Genomic defined */ 
#ifndef DYNAMITE_DEFINED_Genomic
typedef struct bp_sw_Genomic bp_sw_Genomic;
#define Genomic bp_sw_Genomic
#define DYNAMITE_DEFINED_Genomic
#endif




    /***************************************************/
    /* Callable functions                              */
    /* These are the functions you are expected to use */
    /***************************************************/



/* Function:  truncate_Genomic(gen,start,stop)
 *
 * Descrip:    Truncates a Genomic sequence. Basically uses
 *             the /magic_trunc_Sequence function (of course!)
 *
 *             It does not alter gen, rather it returns a new
 *             sequence with that truncation
 *
 *
 * Arg:          gen [READ ] Genomic that is truncated [Genomic *]
 * Arg:        start [UNKN ] Undocumented argument [int]
 * Arg:         stop [UNKN ] Undocumented argument [int]
 *
 * Return [UNKN ]  Undocumented return value [Genomic *]
 *
 */
Genomic * bp_sw_truncate_Genomic(Genomic * gen,int start,int stop);
#define truncate_Genomic bp_sw_truncate_Genomic


/* Function:  read_fasta_file_Genomic(filename)
 *
 * Descrip:    Reads a fasta file assumming that it is Genomic. 
 *             Will complain if it is not, and return NULL.
 *
 *
 * Arg:        filename [UNKN ] filename to be opened and read [char *]
 *
 * Return [UNKN ]  Undocumented return value [Genomic *]
 *
 */
Genomic * bp_sw_read_fasta_file_Genomic(char * filename);
#define read_fasta_file_Genomic bp_sw_read_fasta_file_Genomic


/* Function:  read_fasta_Genomic (ifp)
 *
 * Descrip:    Reads a fasta file assumming that it is Genomic. 
 *             Will complain if it is not, and return NULL.
 *
 *
 * Arg:        ifp [UNKN ] file point to be read from [FILE *]
 *
 * Return [UNKN ]  Undocumented return value [Genomic *]
 *
 */
Genomic * bp_sw_read_fasta_Genomic (FILE * ifp);
#define read_fasta_Genomic  bp_sw_read_fasta_Genomic 


/* Function:  read_efetch_Genomic(estr)
 *
 * Descrip:    Reads a efetch specified query
 *             Uses, of course /read_efetch_Sequence
 *
 *
 * Arg:        estr [READ ] efetch string which is read [char *]
 *
 * Return [UNKN ]  Undocumented return value [Genomic *]
 *
 */
Genomic * bp_sw_read_efetch_Genomic(char * estr);
#define read_efetch_Genomic bp_sw_read_efetch_Genomic


/* Function:  read_SRS_Genomic(srsquery)
 *
 * Descrip:    Reads a SRS sequence using srs4 syntax.
 *             Uses, of course, /read_SRS_Sequence
 *
 *
 *
 * Arg:        srsquery [READ ] string query representing SRS name [char *]
 *
 * Return [UNKN ]  Undocumented return value [Genomic *]
 *
 */
Genomic * bp_sw_read_SRS_Genomic(char * srsquery);
#define read_SRS_Genomic bp_sw_read_SRS_Genomic


/* Function:  Genomic_name(gen)
 *
 * Descrip:    Returns the name of the Genomic
 *
 *
 * Arg:        gen [UNKN ] Undocumented argument [Genomic *]
 *
 * Return [UNKN ]  Undocumented return value [char *]
 *
 */
char * bp_sw_Genomic_name(Genomic * gen);
#define Genomic_name bp_sw_Genomic_name


/* Function:  Genomic_length(gen)
 *
 * Descrip:    Returns the length of the Genomic
 *
 *
 * Arg:        gen [UNKN ] Undocumented argument [Genomic *]
 *
 * Return [UNKN ]  Undocumented return value [int]
 *
 */
int bp_sw_Genomic_length(Genomic * gen);
#define Genomic_length bp_sw_Genomic_length


/* Function:  Genomic_seqchar(gen,pos)
 *
 * Descrip:    Returns sequence character at this position.
 *
 *
 * Arg:        gen [UNKN ] Genomic [Genomic *]
 * Arg:        pos [UNKN ] position in Genomic to get char [int]
 *
 * Return [UNKN ]  Undocumented return value [char]
 *
 */
char bp_sw_Genomic_seqchar(Genomic * gen,int pos);
#define Genomic_seqchar bp_sw_Genomic_seqchar


/* Function:  Genomic_from_Sequence(seq)
 *
 * Descrip:    makes a new genomic from a Sequence. It 
 *             owns the Sequence memory, ie will attempt a /free_Sequence
 *             on the structure when /free_Genomic is called
 *
 *             If you want to give this genomic this Sequence and
 *             forget about it, then just hand it this sequence and set
 *             seq to NULL (no need to free it). If you intend to use 
 *             the sequence object elsewhere outside of the Genomic datastructure
 *             then use Genomic_from_Sequence(/hard_link_Sequence(seq))
 *
 *             This is part of a strict typing system, and therefore
 *             is going to convert all non ATGCNs to Ns. You will lose
 *             information here.
 *
 *
 * Arg:        seq [OWNER] Sequence to make genomic from [Sequence *]
 *
 * Return [UNKN ]  Undocumented return value [Genomic *]
 *
 */
Genomic * bp_sw_Genomic_from_Sequence(Sequence * seq);
#define Genomic_from_Sequence bp_sw_Genomic_from_Sequence


/* Function:  hard_link_Genomic(obj)
 *
 * Descrip:    Bumps up the reference count of the object
 *             Meaning that multiple pointers can 'own' it
 *
 *
 * Arg:        obj [UNKN ] Object to be hard linked [Genomic *]
 *
 * Return [UNKN ]  Undocumented return value [Genomic *]
 *
 */
Genomic * bp_sw_hard_link_Genomic(Genomic * obj);
#define hard_link_Genomic bp_sw_hard_link_Genomic


/* Function:  Genomic_alloc(void)
 *
 * Descrip:    Allocates structure: assigns defaults if given 
 *
 *
 *
 * Return [UNKN ]  Undocumented return value [Genomic *]
 *
 */
Genomic * bp_sw_Genomic_alloc(void);
#define Genomic_alloc bp_sw_Genomic_alloc


/* Function:  free_Genomic(obj)
 *
 * Descrip:    Free Function: removes the memory held by obj
 *             Will chain up to owned members and clear all lists
 *
 *
 * Arg:        obj [UNKN ] Object that is free'd [Genomic *]
 *
 * Return [UNKN ]  Undocumented return value [Genomic *]
 *
 */
Genomic * bp_sw_free_Genomic(Genomic * obj);
#define free_Genomic bp_sw_free_Genomic


  /* Unplaced functions */
  /* There has been no indication of the use of these functions */


    /***************************************************/
    /* Internal functions                              */
    /* you are not expected to have to call these      */
    /***************************************************/
boolean bp_sw_replace_baseseq_Genomic(Genomic * obj,Sequence * baseseq);
#define replace_baseseq_Genomic bp_sw_replace_baseseq_Genomic
Sequence * bp_sw_access_baseseq_Genomic(Genomic * obj);
#define access_baseseq_Genomic bp_sw_access_baseseq_Genomic

#ifdef _cplusplus
}
#endif

#endif
