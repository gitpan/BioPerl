#ifdef _cplusplus
extern "C" {
#endif
#include "codonmatrix.h"


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
# line 26 "codonmatrix.dy"
CodonMatrixScore * naive_CodonMatrixScore(CodonTable * ct,CompMat * comp)
{
  int i;
  int j;
  CodonMatrixScore * out;


  out = CodonMatrixScore_alloc();

  for(i=0;i<125;i++)
    for(j=i;j<125;j++) {
      if( has_random_bases(i) == TRUE || has_random_bases(j) == TRUE ) 
	out->score[i][j] = out->score[j][i] = 0;
      else 
	out->score[i][j] = out->score[j][i] = fail_safe_CompMat_access(comp,aminoacid_no_from_codon(ct,i),aminoacid_no_from_codon(ct,i));
    }

  return out;
}



# line 41 "codonmatrix.c"
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
CodonMatrixScore * hard_link_CodonMatrixScore(CodonMatrixScore * obj) 
{
    if( obj == NULL )    {  
      warn("Trying to hard link to a CodonMatrixScore object: passed a NULL object");    
      return NULL;   
      }  
    obj->dynamite_hard_link++;   
    return obj;  
}    


/* Function:  CodonMatrixScore_alloc(void)
 *
 * Descrip:    Allocates structure: assigns defaults if given 
 *
 *
 *
 * Return [UNKN ]  Undocumented return value [CodonMatrixScore *]
 *
 */
CodonMatrixScore * CodonMatrixScore_alloc(void) 
{
    CodonMatrixScore * out; /* out is exported at end of function */ 


    /* call ckalloc and see if NULL */ 
    if((out=(CodonMatrixScore *) ckalloc (sizeof(CodonMatrixScore))) == NULL)    {  
      warn("CodonMatrixScore_alloc failed ");    
      return NULL;  /* calling function should respond! */ 
      }  
    out->dynamite_hard_link = 1; 
    /* score[125][125] is an array: no default possible */ 


    return out;  
}    


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
CodonMatrixScore * free_CodonMatrixScore(CodonMatrixScore * obj) 
{


    if( obj == NULL) {  
      warn("Attempting to free a NULL pointer to a CodonMatrixScore obj. Should be trappable");  
      return NULL;   
      }  


    if( obj->dynamite_hard_link > 1)     {  
      obj->dynamite_hard_link--; 
      return NULL;   
      }  


    ckfree(obj); 
    return NULL; 
}    



#ifdef _cplusplus
}
#endif
