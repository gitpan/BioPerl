#ifndef DYNAMITEtranslationHEADERFILE
#define DYNAMITEtranslationHEADERFILE
#ifdef _cplusplus
extern "C" {
#endif
#include "dyna.h"

#ifndef DYNAMITE_DEFINED_Transcript
typedef struct bp_sw_Transcript bp_sw_Transcript;
#define Transcript bp_sw_Transcript
#define DYNAMITE_DEFINED_Transcript
#endif

/* Object Translation
 *
 * Descrip: No Description
 *
 */
struct bp_sw_Translation {  
    int dynamite_hard_link;  
    int start;   
    int end;     
    Transcript * parent;     
    Protein * protein;   
    } ;  
/* Translation defined */ 
#ifndef DYNAMITE_DEFINED_Translation
typedef struct bp_sw_Translation bp_sw_Translation;
#define Translation bp_sw_Translation
#define DYNAMITE_DEFINED_Translation
#endif




    /***************************************************/
    /* Callable functions                              */
    /* These are the functions you are expected to use */
    /***************************************************/



/* Function:  copy_Translation(t)
 *
 * Descrip:    Makes a complete clean copy of the translation
 *
 *
 * Arg:        t [UNKN ] Undocumented argument [Translation *]
 *
 * Return [UNKN ]  Undocumented return value [Translation *]
 *
 */
Translation * bp_sw_copy_Translation(Translation * t);
#define copy_Translation bp_sw_copy_Translation


/* Function:  get_Protein_from_Translation(ts,ct)
 *
 * Descrip:    Gets the protein
 *
 *
 * Arg:        ts [UNKN ] translation [Translation *]
 * Arg:        ct [UNKN ] codon table to use [CodonTable *]
 *
 * Return [SOFT ]  Protein sequence [Protein *]
 *
 */
Protein * bp_sw_get_Protein_from_Translation(Translation * ts,CodonTable * ct);
#define get_Protein_from_Translation bp_sw_get_Protein_from_Translation


/* Function:  show_Translation(*ts,ofp)
 *
 * Descrip:    shows a translation in vaguely human form
 *
 *
 * Arg:        *ts [UNKN ] Undocumented argument [Translation]
 * Arg:        ofp [UNKN ] Undocumented argument [FILE *]
 *
 */
void bp_sw_show_Translation(Translation *ts,FILE * ofp);
#define show_Translation bp_sw_show_Translation


/* Function:  hard_link_Translation(obj)
 *
 * Descrip:    Bumps up the reference count of the object
 *             Meaning that multiple pointers can 'own' it
 *
 *
 * Arg:        obj [UNKN ] Object to be hard linked [Translation *]
 *
 * Return [UNKN ]  Undocumented return value [Translation *]
 *
 */
Translation * bp_sw_hard_link_Translation(Translation * obj);
#define hard_link_Translation bp_sw_hard_link_Translation


/* Function:  Translation_alloc(void)
 *
 * Descrip:    Allocates structure: assigns defaults if given 
 *
 *
 *
 * Return [UNKN ]  Undocumented return value [Translation *]
 *
 */
Translation * bp_sw_Translation_alloc(void);
#define Translation_alloc bp_sw_Translation_alloc


/* Function:  free_Translation(obj)
 *
 * Descrip:    Free Function: removes the memory held by obj
 *             Will chain up to owned members and clear all lists
 *
 *
 * Arg:        obj [UNKN ] Object that is free'd [Translation *]
 *
 * Return [UNKN ]  Undocumented return value [Translation *]
 *
 */
Translation * bp_sw_free_Translation(Translation * obj);
#define free_Translation bp_sw_free_Translation


  /* Unplaced functions */
  /* There has been no indication of the use of these functions */


    /***************************************************/
    /* Internal functions                              */
    /* you are not expected to have to call these      */
    /***************************************************/
boolean bp_sw_replace_start_Translation(Translation * obj,int start);
#define replace_start_Translation bp_sw_replace_start_Translation
boolean bp_sw_replace_parent_Translation(Translation * obj,Transcript * parent);
#define replace_parent_Translation bp_sw_replace_parent_Translation
int bp_sw_access_start_Translation(Translation * obj);
#define access_start_Translation bp_sw_access_start_Translation
Transcript * bp_sw_access_parent_Translation(Translation * obj);
#define access_parent_Translation bp_sw_access_parent_Translation
int bp_sw_access_end_Translation(Translation * obj);
#define access_end_Translation bp_sw_access_end_Translation
boolean bp_sw_replace_protein_Translation(Translation * obj,Protein * protein);
#define replace_protein_Translation bp_sw_replace_protein_Translation
boolean bp_sw_replace_end_Translation(Translation * obj,int end);
#define replace_end_Translation bp_sw_replace_end_Translation
Protein * bp_sw_access_protein_Translation(Translation * obj);
#define access_protein_Translation bp_sw_access_protein_Translation

#ifdef _cplusplus
}
#endif

#endif
