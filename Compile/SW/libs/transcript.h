#ifndef DYNAMITEtranscriptHEADERFILE
#define DYNAMITEtranscriptHEADERFILE
#ifdef _cplusplus
extern "C" {
#endif
#include "dyna.h"

#define TranscriptLISTLENGTH 32

struct bp_sw_Exon {  
    int dynamite_hard_link;  
    int start;   
    int end;     
    boolean used;   /*  used by some prediction programs etc */ 
    double score;    
    } ;  
/* Exon defined */ 
#ifndef DYNAMITE_DEFINED_Exon
typedef struct bp_sw_Exon bp_sw_Exon;
#define Exon bp_sw_Exon
#define DYNAMITE_DEFINED_Exon
#endif


#ifndef DYNAMITE_DEFINED_Translation
typedef struct bp_sw_Translation bp_sw_Translation;
#define Translation bp_sw_Translation
#define DYNAMITE_DEFINED_Translation
#endif

#ifndef DYNAMITE_DEFINED_Gene
typedef struct bp_sw_Gene bp_sw_Gene;
#define Gene bp_sw_Gene
#define DYNAMITE_DEFINED_Gene
#endif

/* Object Transcript
 *
 * Descrip: No Description
 *
 */
struct bp_sw_Transcript {  
    int dynamite_hard_link;  
    Exon ** exon;    
    int ex_len; /* len for above exon  */ 
    int ex_maxlen;  /* maxlen for above exon */ 
    Gene * parent;   
    Translation ** translation;  
    int len;/* len for above translation  */ 
    int maxlen; /* maxlen for above translation */ 
    cDNA * cDNA;    /*  may not be here! */ 
    } ;  
/* Transcript defined */ 
#ifndef DYNAMITE_DEFINED_Transcript
typedef struct bp_sw_Transcript bp_sw_Transcript;
#define Transcript bp_sw_Transcript
#define DYNAMITE_DEFINED_Transcript
#endif




    /***************************************************/
    /* Callable functions                              */
    /* These are the functions you are expected to use */
    /***************************************************/



/* Function:  copy_Transcript(t)
 *
 * Descrip:    Makes a completely new copy 
 *             of the transcript
 *
 *
 * Arg:        t [UNKN ] Undocumented argument [Transcript *]
 *
 * Return [UNKN ]  Undocumented return value [Transcript *]
 *
 */
Transcript * bp_sw_copy_Transcript(Transcript * t);
#define copy_Transcript bp_sw_copy_Transcript


/* Function:  get_cDNA_from_Transcript(trs)
 *
 * Descrip:    gets the cDNA associated with this transcript,
 *             if necessary, building it from the exon information
 *             provided.
 *
 *             returns a soft-linked object. If you want to ensure
 *             that this cDNA object remains in memory use
 *             /hard_link_cDNA on the object.
 *
 *
 * Arg:        trs [READ ] transcript to get cDNA from [Transcript *]
 *
 * Return [SOFT ]  cDNA of the transcript [cDNA *]
 *
 */
cDNA * bp_sw_get_cDNA_from_Transcript(Transcript * trs);
#define get_cDNA_from_Transcript bp_sw_get_cDNA_from_Transcript


/* Function:  length_Transcript(tr)
 *
 * Descrip:    returns the length by looking at the
 *             exon lengths
 *
 *
 * Arg:        tr [UNKN ] Undocumented argument [Transcript *]
 *
 * Return [UNKN ]  Undocumented return value [int]
 *
 */
int bp_sw_length_Transcript(Transcript * tr);
#define length_Transcript bp_sw_length_Transcript


/* Function:  show_Transcript(tr,ofp)
 *
 * Descrip:    shows a transcript in vaguely human form
 *
 *
 * Arg:         tr [UNKN ] Undocumented argument [Transcript *]
 * Arg:        ofp [UNKN ] Undocumented argument [FILE *]
 *
 */
void bp_sw_show_Transcript(Transcript * tr,FILE * ofp);
#define show_Transcript bp_sw_show_Transcript


/* Function:  hard_link_Exon(obj)
 *
 * Descrip:    Bumps up the reference count of the object
 *             Meaning that multiple pointers can 'own' it
 *
 *
 * Arg:        obj [UNKN ] Object to be hard linked [Exon *]
 *
 * Return [UNKN ]  Undocumented return value [Exon *]
 *
 */
Exon * bp_sw_hard_link_Exon(Exon * obj);
#define hard_link_Exon bp_sw_hard_link_Exon


/* Function:  Exon_alloc(void)
 *
 * Descrip:    Allocates structure: assigns defaults if given 
 *
 *
 *
 * Return [UNKN ]  Undocumented return value [Exon *]
 *
 */
Exon * bp_sw_Exon_alloc(void);
#define Exon_alloc bp_sw_Exon_alloc


/* Function:  free_Exon(obj)
 *
 * Descrip:    Free Function: removes the memory held by obj
 *             Will chain up to owned members and clear all lists
 *
 *
 * Arg:        obj [UNKN ] Object that is free'd [Exon *]
 *
 * Return [UNKN ]  Undocumented return value [Exon *]
 *
 */
Exon * bp_sw_free_Exon(Exon * obj);
#define free_Exon bp_sw_free_Exon


/* Function:  add_ex_Transcript(obj,add)
 *
 * Descrip:    Adds another object to the list. It will expand the list if necessary
 *
 *
 * Arg:        obj [UNKN ] Object which contains the list [Transcript *]
 * Arg:        add [OWNER] Object to add to the list [Exon *]
 *
 * Return [UNKN ]  Undocumented return value [boolean]
 *
 */
boolean bp_sw_add_ex_Transcript(Transcript * obj,Exon * add);
#define add_ex_Transcript bp_sw_add_ex_Transcript


/* Function:  flush_ex_Transcript(obj)
 *
 * Descrip:    Frees the list elements, sets length to 0
 *             If you want to save some elements, use hard_link_xxx
 *             to protect them from being actually destroyed in the free
 *
 *
 * Arg:        obj [UNKN ] Object which contains the list  [Transcript *]
 *
 * Return [UNKN ]  Undocumented return value [int]
 *
 */
int bp_sw_flush_ex_Transcript(Transcript * obj);
#define flush_ex_Transcript bp_sw_flush_ex_Transcript


/* Function:  add_Transcript(obj,add)
 *
 * Descrip:    Adds another object to the list. It will expand the list if necessary
 *
 *
 * Arg:        obj [UNKN ] Object which contains the list [Transcript *]
 * Arg:        add [OWNER] Object to add to the list [Translation *]
 *
 * Return [UNKN ]  Undocumented return value [boolean]
 *
 */
boolean bp_sw_add_Transcript(Transcript * obj,Translation * add);
#define add_Transcript bp_sw_add_Transcript


/* Function:  flush_Transcript(obj)
 *
 * Descrip:    Frees the list elements, sets length to 0
 *             If you want to save some elements, use hard_link_xxx
 *             to protect them from being actually destroyed in the free
 *
 *
 * Arg:        obj [UNKN ] Object which contains the list  [Transcript *]
 *
 * Return [UNKN ]  Undocumented return value [int]
 *
 */
int bp_sw_flush_Transcript(Transcript * obj);
#define flush_Transcript bp_sw_flush_Transcript


/* Function:  Transcript_alloc_std(void)
 *
 * Descrip:    Equivalent to Transcript_alloc_len(TranscriptLISTLENGTH)
 *
 *
 *
 * Return [UNKN ]  Undocumented return value [Transcript *]
 *
 */
Transcript * bp_sw_Transcript_alloc_std(void);
#define Transcript_alloc_std bp_sw_Transcript_alloc_std


/* Function:  Transcript_alloc_len(len)
 *
 * Descrip:    Allocates len length to all lists
 *
 *
 * Arg:        len [UNKN ] Length of lists to allocate [int]
 *
 * Return [UNKN ]  Undocumented return value [Transcript *]
 *
 */
Transcript * bp_sw_Transcript_alloc_len(int len);
#define Transcript_alloc_len bp_sw_Transcript_alloc_len


/* Function:  hard_link_Transcript(obj)
 *
 * Descrip:    Bumps up the reference count of the object
 *             Meaning that multiple pointers can 'own' it
 *
 *
 * Arg:        obj [UNKN ] Object to be hard linked [Transcript *]
 *
 * Return [UNKN ]  Undocumented return value [Transcript *]
 *
 */
Transcript * bp_sw_hard_link_Transcript(Transcript * obj);
#define hard_link_Transcript bp_sw_hard_link_Transcript


/* Function:  Transcript_alloc(void)
 *
 * Descrip:    Allocates structure: assigns defaults if given 
 *
 *
 *
 * Return [UNKN ]  Undocumented return value [Transcript *]
 *
 */
Transcript * bp_sw_Transcript_alloc(void);
#define Transcript_alloc bp_sw_Transcript_alloc


/* Function:  free_Transcript(obj)
 *
 * Descrip:    Free Function: removes the memory held by obj
 *             Will chain up to owned members and clear all lists
 *
 *
 * Arg:        obj [UNKN ] Object that is free'd [Transcript *]
 *
 * Return [UNKN ]  Undocumented return value [Transcript *]
 *
 */
Transcript * bp_sw_free_Transcript(Transcript * obj);
#define free_Transcript bp_sw_free_Transcript


  /* Unplaced functions */
  /* There has been no indication of the use of these functions */


    /***************************************************/
    /* Internal functions                              */
    /* you are not expected to have to call these      */
    /***************************************************/
int bp_sw_access_start_Exon(Exon * obj);
#define access_start_Exon bp_sw_access_start_Exon
boolean bp_sw_replace_used_Exon(Exon * obj,boolean used);
#define replace_used_Exon bp_sw_replace_used_Exon
boolean bp_sw_replace_score_Exon(Exon * obj,double score);
#define replace_score_Exon bp_sw_replace_score_Exon
double bp_sw_access_score_Exon(Exon * obj);
#define access_score_Exon bp_sw_access_score_Exon
boolean bp_sw_replace_start_Exon(Exon * obj,int start);
#define replace_start_Exon bp_sw_replace_start_Exon
Exon * bp_sw_access_exon_Transcript(Transcript * obj,int i);
#define access_exon_Transcript bp_sw_access_exon_Transcript
boolean bp_sw_replace_end_Exon(Exon * obj,int end);
#define replace_end_Exon bp_sw_replace_end_Exon
int bp_sw_length_exon_Transcript(Transcript * obj);
#define length_exon_Transcript bp_sw_length_exon_Transcript
boolean bp_sw_access_used_Exon(Exon * obj);
#define access_used_Exon bp_sw_access_used_Exon
boolean bp_sw_replace_parent_Transcript(Transcript * obj,Gene * parent);
#define replace_parent_Transcript bp_sw_replace_parent_Transcript
boolean bp_sw_replace_cDNA_Transcript(Transcript * obj,cDNA * cDNA);
#define replace_cDNA_Transcript bp_sw_replace_cDNA_Transcript
Gene * bp_sw_access_parent_Transcript(Transcript * obj);
#define access_parent_Transcript bp_sw_access_parent_Transcript
cDNA * bp_sw_access_cDNA_Transcript(Transcript * obj);
#define access_cDNA_Transcript bp_sw_access_cDNA_Transcript
Translation * bp_sw_access_translation_Transcript(Transcript * obj,int i);
#define access_translation_Transcript bp_sw_access_translation_Transcript
int bp_sw_access_end_Exon(Exon * obj);
#define access_end_Exon bp_sw_access_end_Exon
int bp_sw_length_translation_Transcript(Transcript * obj);
#define length_translation_Transcript bp_sw_length_translation_Transcript
void bp_sw_swap_ex_Transcript(Exon ** list,int i,int j) ;
#define swap_ex_Transcript bp_sw_swap_ex_Transcript
void bp_sw_qsort_ex_Transcript(Exon ** list,int left,int right,int (*comp)(Exon * ,Exon * ));
#define qsort_ex_Transcript bp_sw_qsort_ex_Transcript
void bp_sw_sort_ex_Transcript(Transcript * obj,int (*comp)(Exon *, Exon *));
#define sort_ex_Transcript bp_sw_sort_ex_Transcript
boolean bp_sw_expand_ex_Transcript(Transcript * obj,int len);
#define expand_ex_Transcript bp_sw_expand_ex_Transcript
void bp_sw_swap_Transcript(Translation ** list,int i,int j) ;
#define swap_Transcript bp_sw_swap_Transcript
void bp_sw_qsort_Transcript(Translation ** list,int left,int right,int (*comp)(Translation * ,Translation * ));
#define qsort_Transcript bp_sw_qsort_Transcript
void bp_sw_sort_Transcript(Transcript * obj,int (*comp)(Translation *, Translation *));
#define sort_Transcript bp_sw_sort_Transcript
boolean bp_sw_expand_Transcript(Transcript * obj,int len);
#define expand_Transcript bp_sw_expand_Transcript

#ifdef _cplusplus
}
#endif

#endif
