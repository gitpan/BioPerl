#ifndef DYNAMITEcodonmapperHEADERFILE
#define DYNAMITEcodonmapperHEADERFILE
#ifdef _cplusplus
extern "C" {
#endif
#include "codon.h"



/* Object CodonMapper
 *
 * Descrip: CodonMapper holds a matrix of 125 by 26
 *        to provide a mapping between a probabilities
 *        calculated on amino acids to triplet codon
 *        probabilities. This mapping takes into account
 *        3 things
 *          1) The CodonTable
 *          2) The distribution of synonmous codons (codon bias)
 *          3) substitution errors
 *
 *
 */
struct bp_sw_CodonMapper {  
    int dynamite_hard_link;  
    CodonTable * ct;    /*  hard-linked! */ 
    double codon_map[125][26];   
    } ;  
/* CodonMapper defined */ 
#ifndef DYNAMITE_DEFINED_CodonMapper
typedef struct bp_sw_CodonMapper bp_sw_CodonMapper;
#define CodonMapper bp_sw_CodonMapper
#define DYNAMITE_DEFINED_CodonMapper
#endif


/* Object CodonFrequency
 *
 * Descrip: CodonFrequency is a very much internal object for
 *        CodonMapper. It provides the frequency of synomous
 *        codons, ie, an amino acid with only one codon will
 *        have 1.0 in the frequency table
 *
 *        Rarely used outside of CodonMapper construction
 *
 *
 */
struct bp_sw_CodonFrequency {  
    int dynamite_hard_link;  
    double freq[64];     
    } ;  
/* CodonFrequency defined */ 
#ifndef DYNAMITE_DEFINED_CodonFrequency
typedef struct bp_sw_CodonFrequency bp_sw_CodonFrequency;
#define CodonFrequency bp_sw_CodonFrequency
#define DYNAMITE_DEFINED_CodonFrequency
#endif




    /***************************************************/
    /* Callable functions                              */
    /* These are the functions you are expected to use */
    /***************************************************/



/* Function:  show_CodonMapper(cm,ofp)
 *
 * Descrip:    Shows codon mapper in vaguely human form
 *
 *
 * Arg:         cm [UNKN ] Undocumented argument [CodonMapper *]
 * Arg:        ofp [UNKN ] Undocumented argument [FILE *]
 *
 */
void bp_sw_show_CodonMapper(CodonMapper * cm,FILE * ofp);
#define show_CodonMapper bp_sw_show_CodonMapper


/* Function:  show_CodonFrequency(cf,ct,ofp)
 *
 * Descrip:    Shows codon frequency in vaguely human form
 *
 *
 * Arg:         cf [UNKN ] Undocumented argument [CodonFrequency *]
 * Arg:         ct [UNKN ] Undocumented argument [CodonTable *]
 * Arg:        ofp [UNKN ] Undocumented argument [FILE *]
 *
 */
void bp_sw_show_CodonFrequency(CodonFrequency * cf,CodonTable * ct,FILE * ofp);
#define show_CodonFrequency bp_sw_show_CodonFrequency


/* Function:  flat_CodonMapper(ct)
 *
 * Descrip:    Makes a CodonMapper with no codon bias
 *             or error possiblities from codon table
 *
 *
 *
 * Arg:        ct [UNKN ] Codon Table giving codon->aa info [CodonTable *]
 *
 * Return [UNKN ]  Undocumented return value [CodonMapper *]
 *
 */
CodonMapper * bp_sw_flat_CodonMapper(CodonTable * ct);
#define flat_CodonMapper bp_sw_flat_CodonMapper


/* Function:  flat_CodonFrequency(ct)
 *
 * Descrip:    Makes a no-biased codon Frequency.
 *             Probabaly most used in /flat_CodonMapper
 *
 *
 *
 * Arg:        ct [UNKN ] Undocumented argument [CodonTable *]
 *
 * Return [UNKN ]  Undocumented return value [CodonFrequency *]
 *
 */
CodonFrequency * bp_sw_flat_CodonFrequency(CodonTable * ct);
#define flat_CodonFrequency bp_sw_flat_CodonFrequency


/* Function:  true_map_codon_array_CodonMapper(codon_array,protein_array,cm)
 *
 * Descrip:    Takes an array of probabilities from 0-26 in protein array
 *             and writes into codon_array the adjusted probability from the
 *             codon mapper. Ie, maps a protein emission line to a codon emission
 *             line. This is the main use of CodonMapper.
 *
 *
 *
 * Arg:          codon_array [WRITE] array (0-124) for the codon probabilities to be placed [double *]
 * Arg:        protein_array [READ ] array (0-25) for the protein probabilities to be read from [const double *]
 * Arg:                   cm [UNKN ] Codon Mapper that provides the protein->codon mapping [CodonMapper *]
 *
 */
void bp_sw_true_map_codon_array_CodonMapper(double * codon_array,const double * protein_array,CodonMapper * cm);
#define true_map_codon_array_CodonMapper bp_sw_true_map_codon_array_CodonMapper


/* Function:  sprinkle_errors_over_CodonMapper(cm,error)
 *
 * Descrip:    Takes a codon mapper and assummes that the majority of errors
 *             are due to a single base change in the codon at probability error.
 *             Therefore, for each codon it adds error * prob(codon) * 0.25 to each 
 *             other codon one base away, taking away therefore the result.
 *
 *
 *
 * Arg:           cm [READ ] CodonMapper to be sprinkled [CodonMapper *]
 * Arg:        error [UNKN ] substitution error rate [double]
 *
 */
void bp_sw_sprinkle_errors_over_CodonMapper(CodonMapper * cm,double error);
#define sprinkle_errors_over_CodonMapper bp_sw_sprinkle_errors_over_CodonMapper


/* Function:  new_CodonMapper(ct,cf)
 *
 * Descrip:    The only way you should make a CodonMapper!
 *
 *             Makes a codon mapper from CodonTable and frequency
 *
 *
 * Arg:        ct [UNKN ] Undocumented argument [CodonTable *]
 * Arg:        cf [UNKN ] Undocumented argument [CodonFrequency *]
 *
 * Return [UNKN ]  Undocumented return value [CodonMapper *]
 *
 */
CodonMapper * bp_sw_new_CodonMapper(CodonTable * ct,CodonFrequency * cf);
#define new_CodonMapper bp_sw_new_CodonMapper


/* Function:  hard_link_CodonMapper(obj)
 *
 * Descrip:    Bumps up the reference count of the object
 *             Meaning that multiple pointers can 'own' it
 *
 *
 * Arg:        obj [UNKN ] Object to be hard linked [CodonMapper *]
 *
 * Return [UNKN ]  Undocumented return value [CodonMapper *]
 *
 */
CodonMapper * bp_sw_hard_link_CodonMapper(CodonMapper * obj);
#define hard_link_CodonMapper bp_sw_hard_link_CodonMapper


/* Function:  CodonMapper_alloc(void)
 *
 * Descrip:    Allocates structure: assigns defaults if given 
 *
 *
 *
 * Return [UNKN ]  Undocumented return value [CodonMapper *]
 *
 */
CodonMapper * bp_sw_CodonMapper_alloc(void);
#define CodonMapper_alloc bp_sw_CodonMapper_alloc


/* Function:  free_CodonMapper(obj)
 *
 * Descrip:    Free Function: removes the memory held by obj
 *             Will chain up to owned members and clear all lists
 *
 *
 * Arg:        obj [UNKN ] Object that is free'd [CodonMapper *]
 *
 * Return [UNKN ]  Undocumented return value [CodonMapper *]
 *
 */
CodonMapper * bp_sw_free_CodonMapper(CodonMapper * obj);
#define free_CodonMapper bp_sw_free_CodonMapper


/* Function:  hard_link_CodonFrequency(obj)
 *
 * Descrip:    Bumps up the reference count of the object
 *             Meaning that multiple pointers can 'own' it
 *
 *
 * Arg:        obj [UNKN ] Object to be hard linked [CodonFrequency *]
 *
 * Return [UNKN ]  Undocumented return value [CodonFrequency *]
 *
 */
CodonFrequency * bp_sw_hard_link_CodonFrequency(CodonFrequency * obj);
#define hard_link_CodonFrequency bp_sw_hard_link_CodonFrequency


/* Function:  CodonFrequency_alloc(void)
 *
 * Descrip:    Allocates structure: assigns defaults if given 
 *
 *
 *
 * Return [UNKN ]  Undocumented return value [CodonFrequency *]
 *
 */
CodonFrequency * bp_sw_CodonFrequency_alloc(void);
#define CodonFrequency_alloc bp_sw_CodonFrequency_alloc


/* Function:  free_CodonFrequency(obj)
 *
 * Descrip:    Free Function: removes the memory held by obj
 *             Will chain up to owned members and clear all lists
 *
 *
 * Arg:        obj [UNKN ] Object that is free'd [CodonFrequency *]
 *
 * Return [UNKN ]  Undocumented return value [CodonFrequency *]
 *
 */
CodonFrequency * bp_sw_free_CodonFrequency(CodonFrequency * obj);
#define free_CodonFrequency bp_sw_free_CodonFrequency


  /* Unplaced functions */
  /* There has been no indication of the use of these functions */


    /***************************************************/
    /* Internal functions                              */
    /* you are not expected to have to call these      */
    /***************************************************/
CodonTable * bp_sw_access_ct_CodonMapper(CodonMapper * obj);
#define access_ct_CodonMapper bp_sw_access_ct_CodonMapper
boolean bp_sw_replace_ct_CodonMapper(CodonMapper * obj,CodonTable * ct);
#define replace_ct_CodonMapper bp_sw_replace_ct_CodonMapper
void bp_sw_construct_amino_number_array(int * number,CodonTable * ct);
#define construct_amino_number_array bp_sw_construct_amino_number_array
void bp_sw_map_codon_array_CodonMapper(double * codon_array,double * protein_array,double stop,CodonMapper * cm);
#define map_codon_array_CodonMapper bp_sw_map_codon_array_CodonMapper
double bp_sw_map_codon_CodonMapper(int codon,const double * protein_array,CodonMapper * cm);
#define map_codon_CodonMapper bp_sw_map_codon_CodonMapper

#ifdef _cplusplus
}
#endif

#endif
