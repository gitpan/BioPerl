#ifndef DYNAMITEgenomicdbHEADERFILE
#define DYNAMITEgenomicdbHEADERFILE
#ifdef _cplusplus
extern "C" {
#endif
#include "sequencedb.h"
#include "genomic.h"
#include "hscore.h"
#include "complexsequence.h"
#include "complexevalset.h"

typedef enum GenDBErrorType {
  GENDB_READ_THROUGH = 0,
  GENDB_FAIL_ON_ERROR = 1
} GenDBErrorType;

/* Object GenomicDB
 *
 * Descrip: This object hold a database of
 *        genomic sequences.
 *
 *        You will probably use it in one of
 *        two ways
 *
 *        1 A sequence formatted database, which
 *        is provided by a /SequenceDB object
 *        is used to provide the raw sequences 
 *
 *        2 A single Genomic sequence is used.
 *
 *        In each case this database provides
 *        both the forward and reverse strands
 *        into the system.
 *
 *        Notice that what is exported are
 *        /ComplexSequence objects, not genomic dna,
 *        as this is what is generally needed. 
 *        These are things with splice sites calculated
 *        etc. This is why for initialisation this needs
 *        a /ComplexSequenceEvalSet of the correct type.
 *
 *
 */
struct bp_sw_GenomicDB {  
    int dynamite_hard_link;  
    boolean is_single_seq;   
    boolean done_forward;    
    ComplexSequence * forw;  
    ComplexSequence * rev;   
    SequenceDB * sdb;    
    Sequence * current;  
    ComplexSequenceEvalSet * cses;   
    GenDBErrorType error_handling;   
    Genomic * single;   /*  for single sequence cases, so we can 'index' on it  */ 
    } ;  
/* GenomicDB defined */ 
#ifndef DYNAMITE_DEFINED_GenomicDB
typedef struct bp_sw_GenomicDB bp_sw_GenomicDB;
#define GenomicDB bp_sw_GenomicDB
#define DYNAMITE_DEFINED_GenomicDB
#endif




    /***************************************************/
    /* Callable functions                              */
    /* These are the functions you are expected to use */
    /***************************************************/



/* Function:  show_Hscore_GenomicDB(hs,ofp)
 *
 * Descrip:    shows the Hscore by the GenomicDB information
 *
 *
 *
 * Arg:         hs [UNKN ] High Score structure [Hscore *]
 * Arg:        ofp [UNKN ] output file [FILE *]
 *
 */
void bp_sw_show_Hscore_GenomicDB(Hscore * hs,FILE * ofp);
#define show_Hscore_GenomicDB bp_sw_show_Hscore_GenomicDB


/* Function:  get_Genomic_from_GenomicDB(gendb,de)
 *
 * Descrip:    Gets Genomic sequence out from
 *             the GenomicDB using the information stored in
 *             dataentry
 *
 *
 * Arg:        gendb [UNKN ] Undocumented argument [GenomicDB *]
 * Arg:           de [UNKN ] Undocumented argument [DataEntry *]
 *
 * Return [UNKN ]  Undocumented return value [Genomic *]
 *
 */
Genomic * bp_sw_get_Genomic_from_GenomicDB(GenomicDB * gendb,DataEntry * de);
#define get_Genomic_from_GenomicDB bp_sw_get_Genomic_from_GenomicDB


/* Function:  dataentry_add_GenomicDB(de,cs,gendb)
 *
 * Descrip:    adds information to dataentry from GenomicDB
 *
 *             will eventually add file offset and format information
 *
 *
 * Arg:           de [UNKN ] Undocumented argument [DataEntry *]
 * Arg:           cs [UNKN ] Undocumented argument [ComplexSequence *]
 * Arg:        gendb [UNKN ] Undocumented argument [GenomicDB *]
 *
 * Return [UNKN ]  Undocumented return value [boolean]
 *
 */
boolean bp_sw_dataentry_add_GenomicDB(DataEntry * de,ComplexSequence * cs,GenomicDB * gendb);
#define dataentry_add_GenomicDB bp_sw_dataentry_add_GenomicDB


/* Function:  init_GenomicDB(gendb,return_status)
 *
 * Descrip:    top level function which opens the protein database
 *
 *
 * Arg:                gendb [UNKN ] protein database [GenomicDB *]
 * Arg:        return_status [WRITE] the status of the open from database.h [int *]
 *
 * Return [UNKN ]  Undocumented return value [ComplexSequence *]
 *
 */
ComplexSequence * bp_sw_init_GenomicDB(GenomicDB * gendb,int * return_status);
#define init_GenomicDB bp_sw_init_GenomicDB


/* Function:  reload_GenomicDB(last,gendb,return_status)
 *
 * Descrip:    function which reloads the database
 *
 *
 * Arg:                 last [UNKN ] previous complex sequence, will be freed [ComplexSequence *]
 * Arg:                gendb [UNKN ] Undocumented argument [GenomicDB *]
 * Arg:        return_status [WRITE] return_status of the load [int *]
 *
 * Return [UNKN ]  Undocumented return value [ComplexSequence *]
 *
 */
ComplexSequence * bp_sw_reload_GenomicDB(ComplexSequence * last,GenomicDB * gendb,int * return_status);
#define reload_GenomicDB bp_sw_reload_GenomicDB


/* Function:  close_GenomicDB(cs,gendb)
 *
 * Descrip:    top level function which closes the genomic database
 *
 *
 * Arg:           cs [UNKN ] last complex sequence  [ComplexSequence *]
 * Arg:        gendb [UNKN ] protein database [GenomicDB *]
 *
 * Return [UNKN ]  Undocumented return value [boolean]
 *
 */
boolean bp_sw_close_GenomicDB(ComplexSequence * cs,GenomicDB * gendb) ;
#define close_GenomicDB bp_sw_close_GenomicDB


/* Function:  new_GenomicDB_from_single_seq(seq,cses)
 *
 * Descrip:    To make a new genomic database
 *             from a single Genomic Sequence with a eval system
 *
 *
 * Arg:         seq [UNKN ] sequence which as placed into GenomicDB structure. [Genomic *]
 * Arg:        cses [UNKN ] Undocumented argument [ComplexSequenceEvalSet *]
 *
 * Return [UNKN ]  Undocumented return value [GenomicDB *]
 *
 */
GenomicDB * bp_sw_new_GenomicDB_from_single_seq(Genomic * seq,ComplexSequenceEvalSet * cses);
#define new_GenomicDB_from_single_seq bp_sw_new_GenomicDB_from_single_seq


/* Function:  new_GenomicDB_from_forrev_cseq(cs,cs_rev)
 *
 * Descrip:    To make a new genomic database
 *             from a single ComplexSequence
 *
 *
 * Arg:            cs [UNKN ] complex sequence which is held. [ComplexSequence *]
 * Arg:        cs_rev [UNKN ] Undocumented argument [ComplexSequence *]
 *
 * Return [UNKN ]  Undocumented return value [GenomicDB *]
 *
 */
GenomicDB * bp_sw_new_GenomicDB_from_forrev_cseq(ComplexSequence * cs,ComplexSequence * cs_rev);
#define new_GenomicDB_from_forrev_cseq bp_sw_new_GenomicDB_from_forrev_cseq


/* Function:  new_GenomicDB(seqdb,cses)
 *
 * Descrip:    To make a new genomic database
 *
 *
 * Arg:        seqdb [UNKN ] sequence database [SequenceDB *]
 * Arg:         cses [UNKN ] protein evaluation set [ComplexSequenceEvalSet *]
 *
 * Return [UNKN ]  Undocumented return value [GenomicDB *]
 *
 */
GenomicDB * bp_sw_new_GenomicDB(SequenceDB * seqdb,ComplexSequenceEvalSet * cses);
#define new_GenomicDB bp_sw_new_GenomicDB


/* Function:  hard_link_GenomicDB(obj)
 *
 * Descrip:    Bumps up the reference count of the object
 *             Meaning that multiple pointers can 'own' it
 *
 *
 * Arg:        obj [UNKN ] Object to be hard linked [GenomicDB *]
 *
 * Return [UNKN ]  Undocumented return value [GenomicDB *]
 *
 */
GenomicDB * bp_sw_hard_link_GenomicDB(GenomicDB * obj);
#define hard_link_GenomicDB bp_sw_hard_link_GenomicDB


/* Function:  GenomicDB_alloc(void)
 *
 * Descrip:    Allocates structure: assigns defaults if given 
 *
 *
 *
 * Return [UNKN ]  Undocumented return value [GenomicDB *]
 *
 */
GenomicDB * bp_sw_GenomicDB_alloc(void);
#define GenomicDB_alloc bp_sw_GenomicDB_alloc


/* Function:  free_GenomicDB(obj)
 *
 * Descrip:    Free Function: removes the memory held by obj
 *             Will chain up to owned members and clear all lists
 *
 *
 * Arg:        obj [UNKN ] Object that is free'd [GenomicDB *]
 *
 * Return [UNKN ]  Undocumented return value [GenomicDB *]
 *
 */
GenomicDB * bp_sw_free_GenomicDB(GenomicDB * obj);
#define free_GenomicDB bp_sw_free_GenomicDB


  /* Unplaced functions */
  /* There has been no indication of the use of these functions */


    /***************************************************/
    /* Internal functions                              */
    /* you are not expected to have to call these      */
    /***************************************************/
boolean bp_sw_replace_is_single_seq_GenomicDB(GenomicDB * obj,boolean is_single_seq);
#define replace_is_single_seq_GenomicDB bp_sw_replace_is_single_seq_GenomicDB
ComplexSequence * bp_sw_access_rev_GenomicDB(GenomicDB * obj);
#define access_rev_GenomicDB bp_sw_access_rev_GenomicDB
boolean bp_sw_access_is_single_seq_GenomicDB(GenomicDB * obj);
#define access_is_single_seq_GenomicDB bp_sw_access_is_single_seq_GenomicDB
boolean bp_sw_replace_sdb_GenomicDB(GenomicDB * obj,SequenceDB * sdb);
#define replace_sdb_GenomicDB bp_sw_replace_sdb_GenomicDB
boolean bp_sw_access_done_forward_GenomicDB(GenomicDB * obj);
#define access_done_forward_GenomicDB bp_sw_access_done_forward_GenomicDB
SequenceDB * bp_sw_access_sdb_GenomicDB(GenomicDB * obj);
#define access_sdb_GenomicDB bp_sw_access_sdb_GenomicDB
ComplexSequence * bp_sw_access_forw_GenomicDB(GenomicDB * obj);
#define access_forw_GenomicDB bp_sw_access_forw_GenomicDB
boolean bp_sw_replace_current_GenomicDB(GenomicDB * obj,Sequence * current);
#define replace_current_GenomicDB bp_sw_replace_current_GenomicDB
boolean bp_sw_replace_done_forward_GenomicDB(GenomicDB * obj,boolean done_forward);
#define replace_done_forward_GenomicDB bp_sw_replace_done_forward_GenomicDB
Sequence * bp_sw_access_current_GenomicDB(GenomicDB * obj);
#define access_current_GenomicDB bp_sw_access_current_GenomicDB
boolean bp_sw_replace_rev_GenomicDB(GenomicDB * obj,ComplexSequence * rev);
#define replace_rev_GenomicDB bp_sw_replace_rev_GenomicDB
boolean bp_sw_replace_cses_GenomicDB(GenomicDB * obj,ComplexSequenceEvalSet * cses);
#define replace_cses_GenomicDB bp_sw_replace_cses_GenomicDB
boolean bp_sw_replace_forw_GenomicDB(GenomicDB * obj,ComplexSequence * forw);
#define replace_forw_GenomicDB bp_sw_replace_forw_GenomicDB
ComplexSequenceEvalSet * bp_sw_access_cses_GenomicDB(GenomicDB * obj);
#define access_cses_GenomicDB bp_sw_access_cses_GenomicDB

#ifdef _cplusplus
}
#endif

#endif
