#ifdef _cplusplus
extern "C" {
#endif
#include "genomic.h"



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
# line 45 "genomic.dy"
Genomic * truncate_Genomic(Genomic * gen,int start,int stop)
{
  return Genomic_from_Sequence(magic_trunc_Sequence(gen->baseseq,start,stop));
}

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
# line 56 "genomic.dy"
Genomic * read_fasta_file_Genomic(char * filename)
{
  Sequence * seq;

  seq = read_fasta_file_Sequence(filename);
  if( seq == NULL ) {
    return NULL;
  }

  return Genomic_from_Sequence(seq);
}


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
# line 75 "genomic.dy"
Genomic * read_fasta_Genomic (FILE * ifp)
{
  Sequence * seq;

  seq = read_fasta_Sequence(ifp);
  if( seq == NULL ) {
    return NULL;
  }

  return Genomic_from_Sequence(seq);
}

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
# line 93 "genomic.dy"
Genomic * read_efetch_Genomic(char * estr)
{
  return Genomic_from_Sequence(read_efetch_Sequence(estr));
}

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
# line 105 "genomic.dy"
Genomic * read_SRS_Genomic(char * srsquery)
{
  return Genomic_from_Sequence(read_SRS_Sequence(srsquery));
}


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
# line 115 "genomic.dy"
char * Genomic_name(Genomic * gen)
{
  return gen->baseseq->name;
}

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
# line 124 "genomic.dy"
int Genomic_length(Genomic * gen)
{
  return gen->baseseq->len;
}

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
# line 135 "genomic.dy"
char Genomic_seqchar(Genomic * gen,int pos)
{
  return gen->baseseq->seq[pos];
}


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
# line 158 "genomic.dy"
Genomic * Genomic_from_Sequence(Sequence * seq)
{
  Genomic * out;
  int conv;

  if( seq == NULL ) {
    warn("Cannot make a genomic sequence from a NULL sequence");
    return NULL;
  }


  if( is_dna_Sequence(seq) == FALSE ) {
    warn("Trying to make a genomic sequence from a non genomic base sequence [%s] Type is %d.",seq->name,seq->type);
    return NULL;
  }

  uppercase_Sequence(seq);

  force_to_dna_Sequence(seq,1.0,&conv);
 
  if( conv != 0 ) {
    log_full_error(INFO,0,"In making %s a genomic sequence, converted %d bases (%2.1f%%) to N's from non ATGCN",seq->name,conv,(double)conv*100/(double)seq->len);
  }

  out = Genomic_alloc();

  out->baseseq = seq;

  return out;
}




# line 203 "genomic.c"
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
Genomic * hard_link_Genomic(Genomic * obj) 
{
    if( obj == NULL )    {  
      warn("Trying to hard link to a Genomic object: passed a NULL object"); 
      return NULL;   
      }  
    obj->dynamite_hard_link++;   
    return obj;  
}    


/* Function:  Genomic_alloc(void)
 *
 * Descrip:    Allocates structure: assigns defaults if given 
 *
 *
 *
 * Return [UNKN ]  Undocumented return value [Genomic *]
 *
 */
Genomic * Genomic_alloc(void) 
{
    Genomic * out;  /* out is exported at end of function */ 


    /* call ckalloc and see if NULL */ 
    if((out=(Genomic *) ckalloc (sizeof(Genomic))) == NULL)  {  
      warn("Genomic_alloc failed "); 
      return NULL;  /* calling function should respond! */ 
      }  
    out->dynamite_hard_link = 1; 
    out->baseseq = NULL; 


    return out;  
}    


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
Genomic * free_Genomic(Genomic * obj) 
{


    if( obj == NULL) {  
      warn("Attempting to free a NULL pointer to a Genomic obj. Should be trappable");   
      return NULL;   
      }  


    if( obj->dynamite_hard_link > 1)     {  
      obj->dynamite_hard_link--; 
      return NULL;   
      }  
    if( obj->baseseq != NULL)    
      free_Sequence(obj->baseseq);   


    ckfree(obj); 
    return NULL; 
}    


/* Function:  replace_baseseq_Genomic(obj,baseseq)
 *
 * Descrip:    Replace member variable baseseq
 *             For use principly by API functions
 *
 *
 * Arg:            obj [UNKN ] Object holding the variable [Genomic *]
 * Arg:        baseseq [OWNER] New value of the variable [Sequence *]
 *
 * Return [SOFT ]  member variable baseseq [boolean]
 *
 */
boolean replace_baseseq_Genomic(Genomic * obj,Sequence * baseseq) 
{
    if( obj == NULL)     {  
      warn("In replacement function baseseq for object Genomic, got a NULL object"); 
      return FALSE;  
      }  
    obj->baseseq = baseseq;  
    return TRUE; 
}    


/* Function:  access_baseseq_Genomic(obj)
 *
 * Descrip:    Access member variable baseseq
 *             For use principly by API functions
 *
 *
 * Arg:        obj [UNKN ] Object holding the variable [Genomic *]
 *
 * Return [SOFT ]  member variable baseseq [Sequence *]
 *
 */
Sequence * access_baseseq_Genomic(Genomic * obj) 
{
    if( obj == NULL)     {  
      warn("In accessor function baseseq for object Genomic, got a NULL object");    
      return NULL;   
      }  
    return obj->baseseq;     
}    



#ifdef _cplusplus
}
#endif
