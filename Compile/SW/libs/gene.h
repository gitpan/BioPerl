#ifndef DYNAMITEgeneHEADERFILE
#define DYNAMITEgeneHEADERFILE
#ifdef _cplusplus
extern "C" {
#endif
#include "dyna.h"

#define GeneLISTLENGTH 16

#ifndef DYNAMITE_DEFINED_GenomicRegion
typedef struct bp_sw_GenomicRegion bp_sw_GenomicRegion;
#define GenomicRegion bp_sw_GenomicRegion
#define DYNAMITE_DEFINED_GenomicRegion
#endif

#ifndef DYNAMITE_DEFINED_Transcript
typedef struct bp_sw_Transcript bp_sw_Transcript;
#define Transcript bp_sw_Transcript
#define DYNAMITE_DEFINED_Transcript
#endif

/* Object Gene
 *
 * Descrip: Gene is the datastructure which represents a single
 *        gene. At the moment this is considered to be a series
 *        of transcripts (the first transcript being "canonical")
 *        which are made from a certain start/stop region in
 *        genomic DNA.
 *
 *        The gene datastructure does not necessarily contain
 *        any DNA sequence. When someone askes for the gene sequence,
 *        via get_Genomic_from_Gene(), it first sees if there
 *        is anything in the Genomic * 'cache'. If this is null,
 *        it then looks at parent (the genomic region), and if
 *        that is null, complains and returns null. Otherwise it
 *        truncates its parent's dna in the correct way, places
 *        the data structure into the genomic * cache, and returns
 *        it.
 *
 *        The name, bits and seqname have put into this datastructure
 *        for convience of carrying around this information into some
 *        of the gene prediction output formats. Probabaly
 *          o they should be in transcript, not gene
 *          o they shouldn't be here at all.
 *
 *        <sigh>
 *
 *
 */
struct bp_sw_Gene {  
    int dynamite_hard_link;  
    int start;   
    int end;     
    GenomicRegion * parent; /*  may not be here */ 
    Genomic * genomic;  /*  may not be here! */ 
    Transcript ** transcript;    
    int len;/* len for above transcript  */ 
    int maxlen; /* maxlen for above transcript */ 
    char * name;    /*  ugly . Need a better system */ 
    double bits;    /*  ditto... */ 
    char * seqname; /*  very bad! this is for keeping track of what sequence was used to make the gene */ 
    } ;  
/* Gene defined */ 
#ifndef DYNAMITE_DEFINED_Gene
typedef struct bp_sw_Gene bp_sw_Gene;
#define Gene bp_sw_Gene
#define DYNAMITE_DEFINED_Gene
#endif




    /***************************************************/
    /* Callable functions                              */
    /* These are the functions you are expected to use */
    /***************************************************/



/* Function:  reversed_Gene(g)
 *
 * Descrip:    is this gene reversed?
 *
 *
 * Arg:        g [UNKN ] Undocumented argument [Gene *]
 *
 * Return [UNKN ]  Undocumented return value [boolean]
 *
 */
boolean bp_sw_reversed_Gene(Gene * g);
#define reversed_Gene bp_sw_reversed_Gene


/* Function:  copy_Gene(g)
 *
 * Descrip:    Makes a completely fresh copy of a
 *             gene
 *
 *
 * Arg:        g [UNKN ] Undocumented argument [Gene *]
 *
 * Return [UNKN ]  Undocumented return value [Gene *]
 *
 */
Gene * bp_sw_copy_Gene(Gene * g);
#define copy_Gene bp_sw_copy_Gene


/* Function:  is_simple_prediction_Gene(g)
 *
 * Descrip:    Does this gene have 
 *             	a single transcript
 *             	that transcript with translation start/end 
 *             	at the ends
 *
 *
 * Arg:        g [UNKN ] Undocumented argument [Gene *]
 *
 * Return [UNKN ]  Undocumented return value [boolean]
 *
 */
boolean bp_sw_is_simple_prediction_Gene(Gene * g);
#define is_simple_prediction_Gene bp_sw_is_simple_prediction_Gene


/* Function:  get_Genomic_from_Gene(gene)
 *
 * Descrip:    Gives back a Genomic sequence type
 *             from a gene.
 *
 *
 * Arg:        gene [READ ] gene to get Genomic from [Gene *]
 *
 * Return [SOFT ]  Genomic DNA data structure [Genomic *]
 *
 */
Genomic * bp_sw_get_Genomic_from_Gene(Gene * gene);
#define get_Genomic_from_Gene bp_sw_get_Genomic_from_Gene


/* Function:  read_EMBL_feature_Gene(buffer,maxlen,ifp)
 *
 * Descrip:    Reads in an EMBL feature table.
 *
 *             It expects to be passed a buffer with 'FT   CDS'.
 *             or 'FT   mRNA' in it. It will then 
 *             use the buffer to read successive lines of the Feature table
 *             until it comes to the next 'meta' feature line (ie, 3 place point).
 *
 *             It will use functions in /embl module for the reading.
 *
 *
 * Arg:        buffer [UNKN ] a string with FT  CDS line in it [char *]
 * Arg:        maxlen [UNKN ] length of the buffer [int]
 * Arg:           ifp [UNKN ] file stream with the rest of the feature table in it [FILE *]
 *
 * Return [UNKN ]  Undocumented return value [Gene *]
 *
 */
Gene * bp_sw_read_EMBL_feature_Gene(char * buffer,int maxlen,FILE * ifp);
#define read_EMBL_feature_Gene bp_sw_read_EMBL_feature_Gene


/* Function:  show_pretty_Gene(ge,ofp)
 *
 * Descrip:    Shows a gene in the biologically accepted form
 *
 *
 * Arg:         ge [UNKN ] Undocumented argument [Gene *]
 * Arg:        ofp [UNKN ] Undocumented argument [FILE *]
 *
 */
void bp_sw_show_pretty_Gene(Gene * ge,FILE * ofp);
#define show_pretty_Gene bp_sw_show_pretty_Gene


/* Function:  show_Gene(ge,ofp)
 *
 * Descrip:    shows a gene in a vaguely human readable form
 *
 *
 * Arg:         ge [UNKN ] Undocumented argument [Gene *]
 * Arg:        ofp [UNKN ] Undocumented argument [FILE *]
 *
 */
void bp_sw_show_Gene(Gene * ge,FILE * ofp);
#define show_Gene bp_sw_show_Gene


/* Function:  add_Gene(obj,add)
 *
 * Descrip:    Adds another object to the list. It will expand the list if necessary
 *
 *
 * Arg:        obj [UNKN ] Object which contains the list [Gene *]
 * Arg:        add [OWNER] Object to add to the list [Transcript *]
 *
 * Return [UNKN ]  Undocumented return value [boolean]
 *
 */
boolean bp_sw_add_Gene(Gene * obj,Transcript * add);
#define add_Gene bp_sw_add_Gene


/* Function:  flush_Gene(obj)
 *
 * Descrip:    Frees the list elements, sets length to 0
 *             If you want to save some elements, use hard_link_xxx
 *             to protect them from being actually destroyed in the free
 *
 *
 * Arg:        obj [UNKN ] Object which contains the list  [Gene *]
 *
 * Return [UNKN ]  Undocumented return value [int]
 *
 */
int bp_sw_flush_Gene(Gene * obj);
#define flush_Gene bp_sw_flush_Gene


/* Function:  Gene_alloc_std(void)
 *
 * Descrip:    Equivalent to Gene_alloc_len(GeneLISTLENGTH)
 *
 *
 *
 * Return [UNKN ]  Undocumented return value [Gene *]
 *
 */
Gene * bp_sw_Gene_alloc_std(void);
#define Gene_alloc_std bp_sw_Gene_alloc_std


/* Function:  Gene_alloc_len(len)
 *
 * Descrip:    Allocates len length to all lists
 *
 *
 * Arg:        len [UNKN ] Length of lists to allocate [int]
 *
 * Return [UNKN ]  Undocumented return value [Gene *]
 *
 */
Gene * bp_sw_Gene_alloc_len(int len);
#define Gene_alloc_len bp_sw_Gene_alloc_len


/* Function:  hard_link_Gene(obj)
 *
 * Descrip:    Bumps up the reference count of the object
 *             Meaning that multiple pointers can 'own' it
 *
 *
 * Arg:        obj [UNKN ] Object to be hard linked [Gene *]
 *
 * Return [UNKN ]  Undocumented return value [Gene *]
 *
 */
Gene * bp_sw_hard_link_Gene(Gene * obj);
#define hard_link_Gene bp_sw_hard_link_Gene


/* Function:  Gene_alloc(void)
 *
 * Descrip:    Allocates structure: assigns defaults if given 
 *
 *
 *
 * Return [UNKN ]  Undocumented return value [Gene *]
 *
 */
Gene * bp_sw_Gene_alloc(void);
#define Gene_alloc bp_sw_Gene_alloc


/* Function:  free_Gene(obj)
 *
 * Descrip:    Free Function: removes the memory held by obj
 *             Will chain up to owned members and clear all lists
 *
 *
 * Arg:        obj [UNKN ] Object that is free'd [Gene *]
 *
 * Return [UNKN ]  Undocumented return value [Gene *]
 *
 */
Gene * bp_sw_free_Gene(Gene * obj);
#define free_Gene bp_sw_free_Gene


  /* Unplaced functions */
  /* There has been no indication of the use of these functions */


    /***************************************************/
    /* Internal functions                              */
    /* you are not expected to have to call these      */
    /***************************************************/
GenomicRegion * bp_sw_access_parent_Gene(Gene * obj);
#define access_parent_Gene bp_sw_access_parent_Gene
boolean bp_sw_replace_genomic_Gene(Gene * obj,Genomic * genomic);
#define replace_genomic_Gene bp_sw_replace_genomic_Gene
Genomic * bp_sw_access_genomic_Gene(Gene * obj);
#define access_genomic_Gene bp_sw_access_genomic_Gene
Transcript * bp_sw_access_transcript_Gene(Gene * obj,int i);
#define access_transcript_Gene bp_sw_access_transcript_Gene
boolean bp_sw_replace_start_Gene(Gene * obj,int start);
#define replace_start_Gene bp_sw_replace_start_Gene
int bp_sw_length_transcript_Gene(Gene * obj);
#define length_transcript_Gene bp_sw_length_transcript_Gene
boolean bp_sw_replace_end_Gene(Gene * obj,int end);
#define replace_end_Gene bp_sw_replace_end_Gene
boolean bp_sw_replace_name_Gene(Gene * obj,char * name);
#define replace_name_Gene bp_sw_replace_name_Gene
boolean bp_sw_replace_parent_Gene(Gene * obj,GenomicRegion * parent);
#define replace_parent_Gene bp_sw_replace_parent_Gene
char * bp_sw_access_name_Gene(Gene * obj);
#define access_name_Gene bp_sw_access_name_Gene
int bp_sw_access_start_Gene(Gene * obj);
#define access_start_Gene bp_sw_access_start_Gene
boolean bp_sw_replace_bits_Gene(Gene * obj,double bits);
#define replace_bits_Gene bp_sw_replace_bits_Gene
char * bp_sw_access_seqname_Gene(Gene * obj);
#define access_seqname_Gene bp_sw_access_seqname_Gene
double bp_sw_access_bits_Gene(Gene * obj);
#define access_bits_Gene bp_sw_access_bits_Gene
int bp_sw_access_end_Gene(Gene * obj);
#define access_end_Gene bp_sw_access_end_Gene
boolean bp_sw_replace_seqname_Gene(Gene * obj,char * seqname);
#define replace_seqname_Gene bp_sw_replace_seqname_Gene
void bp_sw_swap_Gene(Transcript ** list,int i,int j) ;
#define swap_Gene bp_sw_swap_Gene
void bp_sw_qsort_Gene(Transcript ** list,int left,int right,int (*comp)(Transcript * ,Transcript * ));
#define qsort_Gene bp_sw_qsort_Gene
void bp_sw_sort_Gene(Gene * obj,int (*comp)(Transcript *, Transcript *));
#define sort_Gene bp_sw_sort_Gene
boolean bp_sw_expand_Gene(Gene * obj,int len);
#define expand_Gene bp_sw_expand_Gene

#ifdef _cplusplus
}
#endif

#endif
