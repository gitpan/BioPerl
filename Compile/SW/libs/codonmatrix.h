#ifndef DYNAMITEcodonmatrixHEADERFILE
#define DYNAMITEcodonmatrixHEADERFILE
#ifdef _cplusplus
extern "C" {
#endif
#include "dyna.h"


struct bp_sw_CodonMatrixScore {  
    int dynamite_hard_link;  
    Score score[125][125];   
    } ;  
/* CodonMatrixScore defined */ 
#ifndef DYNAMITE_DEFINED_CodonMatrixScore
typedef struct bp_sw_CodonMatrixScore bp_sw_CodonMatrixScore;
#define CodonMatrixScore bp_sw_CodonMatrixScore
#define DYNAMITE_DEFINED_CodonMatrixScore
#endif




    /***************************************************/
    /* Callable functions                              */
    /* These are the functions you are expected to use */
    /***************************************************/



/* Function:  naive_CodonMatrixScore(ct,comp)
 *
 * Descrip:    Builds a codon matrix from CompMat which assummes:
 *               No codon Bias
 *               No errors
 *             N codons score 0, stop codons score ??
 *
 *
 * Arg:          ct [UNKN ] CodonTable for codon->aa mapping [CodonTable *]
 * Arg:        comp [UNKN ] Comparison matrix for the score of the individual access [CompMat *]
 *
 * Return [UNKN ]  Undocumented return value [CodonMatrixScore *]
 *
 */
CodonMatrixScore * bp_sw_naive_CodonMatrixScore(CodonTable * ct,CompMat * comp);
#define naive_CodonMatrixScore bp_sw_naive_CodonMatrixScore


/* Function:  hard_link_CodonMatrixScore(obj)
 *
 * Descrip:    Bumps up the reference count of the object
 *             Meaning that multiple pointers can 'own' it
 *
 *
 * Arg:        obj [UNKN ] Object to be hard linked [CodonMatrixScore *]
 *
 * Return [UNKN ]  Undocumented return value [CodonMatrixScore *]
 *
 */
CodonMatrixScore * bp_sw_hard_link_CodonMatrixScore(CodonMatrixScore * obj);
#define hard_link_CodonMatrixScore bp_sw_hard_link_CodonMatrixScore


/* Function:  CodonMatrixScore_alloc(void)
 *
 * Descrip:    Allocates structure: assigns defaults if given 
 *
 *
 *
 * Return [UNKN ]  Undocumented return value [CodonMatrixScore *]
 *
 */
CodonMatrixScore * bp_sw_CodonMatrixScore_alloc(void);
#define CodonMatrixScore_alloc bp_sw_CodonMatrixScore_alloc


/* Function:  free_CodonMatrixScore(obj)
 *
 * Descrip:    Free Function: removes the memory held by obj
 *             Will chain up to owned members and clear all lists
 *
 *
 * Arg:        obj [UNKN ] Object that is free'd [CodonMatrixScore *]
 *
 * Return [UNKN ]  Undocumented return value [CodonMatrixScore *]
 *
 */
CodonMatrixScore * bp_sw_free_CodonMatrixScore(CodonMatrixScore * obj);
#define free_CodonMatrixScore bp_sw_free_CodonMatrixScore


  /* Unplaced functions */
  /* There has been no indication of the use of these functions */


    /***************************************************/
    /* Internal functions                              */
    /* you are not expected to have to call these      */
    /***************************************************/

#ifdef _cplusplus
}
#endif

#endif
