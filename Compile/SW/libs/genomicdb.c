#ifdef _cplusplus
extern "C" {
#endif
#include "genomicdb.h"


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
# line 73 "genomicdb.dy"
void show_Hscore_GenomicDB(Hscore * hs,FILE * ofp)
{
  int i;

  for(i=0;i<hs->len;i++)
    fprintf(ofp,"Query [%20s] Target [%20s] %d\n",hs->ds[i]->query->name,hs->ds[i]->target->name,hs->ds[i]->score);
}

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
# line 86 "genomicdb.dy"
Genomic * get_Genomic_from_GenomicDB(GenomicDB * gendb,DataEntry * de)
{
  Sequence * seq;
  Sequence * temp;
  /* we need to get out the Sequence from seqdb */

  if( gendb == NULL || de == NULL ) {
    warn("Cannot get a genomic sequence from NULL objects. Ugh!");
    return NULL;
  }

  if( gendb->is_single_seq) {
    if( de->is_reversed == TRUE ) 
      return Genomic_from_Sequence(hard_link_Sequence(gendb->rev->seq));
    else
      return Genomic_from_Sequence(hard_link_Sequence(gendb->forw->seq));
  }

  seq = get_Sequence_from_SequenceDB(gendb->sdb,de);
  if( seq == NULL ) {
    warn("Cannot get entry for %s from Genomic db",de->name);
  }

  if( de->is_reversed == TRUE ) {
    temp = reverse_complement_Sequence(seq);
    free_Sequence(seq);
    seq = temp;
  }

  return Genomic_from_Sequence(seq);
}



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
# line 125 "genomicdb.dy"
boolean dataentry_add_GenomicDB(DataEntry * de,ComplexSequence * cs,GenomicDB * gendb)
{
  de->name = stringalloc(cs->seq->name);
  de->is_reversed = is_reversed_Sequence(cs->seq);

  if( gendb->is_single_seq ) {
    return TRUE;
  }

  add_SequenceDB_info_DataEntry(gendb->sdb,de);
  return TRUE;
}


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
# line 145 "genomicdb.dy"
ComplexSequence * init_GenomicDB(GenomicDB * gendb,int * return_status)
{
  ComplexSequence * cs;
  Sequence * seq;

  if( gendb->is_single_seq == TRUE) {
    *return_status = DB_RETURN_OK;
    gendb->done_forward = TRUE;
    return gendb->forw;
    
  }

  /* is a seq db */

  seq = init_SequenceDB(gendb->sdb,return_status);

  if( seq == NULL || *return_status == DB_RETURN_ERROR || *return_status == DB_RETURN_END ) {
    return NULL; /** error already reported **/
  }

  gendb->current = seq;
  gendb->done_forward = TRUE;
  cs = new_ComplexSequence(seq,gendb->cses);
  if( cs == NULL ) {
    warn("Cannot make initial ComplexSequence. Unable to error catch this. Failing!");
    *return_status = DB_RETURN_ERROR;
    return NULL;
  }



  return cs;
}

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
# line 185 "genomicdb.dy"
ComplexSequence * reload_GenomicDB(ComplexSequence * last,GenomicDB * gendb,int * return_status)
{
  ComplexSequence * cs;
  Sequence * seq,*temp;
  

  
  /** NB - notice that we don't do silly things with free's. Maybe we should **/

  if( gendb->is_single_seq == TRUE ) {
    if( gendb->done_forward == TRUE ) {
      *return_status = DB_RETURN_OK;
      gendb->done_forward = FALSE;
      return gendb->rev;
    } else {
      *return_status = DB_RETURN_END;
      return NULL;
    }
  }

  /** standard database **/

  /** free Complex Sequence **/

  if ( last != NULL ) {
    free_ComplexSequence(last);
  }

  if( gendb->done_forward == TRUE ) {
    if( gendb->current == NULL ) {
      warn("A bad internal genomic db error - unable to find current sequence in db reload");
      *return_status = DB_RETURN_ERROR;
      return NULL;
    }

    temp = reverse_complement_Sequence(gendb->current);


    if( temp == NULL ) {
      warn("A bad internal genomic db error - unable to reverse complements current");
      *return_status = DB_RETURN_ERROR;
      return NULL;
    }

    cs = new_ComplexSequence(temp,gendb->cses);

    if( cs == NULL ) {
      warn("A bad internal genomic db error - unable to make complex sequence in db reload");
      *return_status = DB_RETURN_ERROR;
      return NULL;
    }

    free_Sequence(temp);
    gendb->done_forward = FALSE;
    return cs;
  }


  /* otherwise we have to get a new sequence */

  seq = reload_SequenceDB(NULL,gendb->sdb,return_status);

  if( seq == NULL || *return_status == DB_RETURN_ERROR || *return_status == DB_RETURN_END ) {
    return NULL; /** error already reported **/
  }

  uppercase_Sequence(seq);

  if( force_to_dna_Sequence(seq,0.1,NULL) == FALSE ) {
    if( gendb->error_handling == GENDB_READ_THROUGH ) {
      warn("Unable to map %s sequence to a genomic sequence, but ignoring that for the moment...",seq->name);
      free_Sequence(seq);
      return reload_GenomicDB(NULL,gendb,return_status);
    } else {
      warn("Unable to map %s sequence to a genomic sequence. Failing",seq->name);
      *return_status = DB_RETURN_ERROR;
      return NULL;
    }
  }


  cs = new_ComplexSequence(seq,gendb->cses);
  if( cs == NULL ) {
    if( gendb->error_handling == GENDB_READ_THROUGH ) {
      warn("Unable to map %s sequence to a genomic sequence, but ignoring that for the moment...",seq->name);
      free_Sequence(seq);
      return reload_GenomicDB(NULL,gendb,return_status);
    } else {
      warn("Unable to map %s sequence to a genomic sequence. Failing",seq->name);
      *return_status = DB_RETURN_ERROR;
      return NULL;
    }
  }

  gendb->current = free_Sequence(gendb->current);
  gendb->current = seq;
  gendb->done_forward= TRUE;

  return cs;
}
  


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
# line 294 "genomicdb.dy"
boolean close_GenomicDB(ComplexSequence * cs,GenomicDB * gendb) 
{
  if( gendb->is_single_seq == TRUE ) {
    return TRUE;
  }

  if( cs != NULL)
    free_ComplexSequence(cs);

  if( gendb->current != NULL)
    gendb->current = free_Sequence(gendb->current);

  return close_SequenceDB(NULL,gendb->sdb);
}

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
# line 315 "genomicdb.dy"
GenomicDB * new_GenomicDB_from_single_seq(Genomic * seq,ComplexSequenceEvalSet * cses)
{
  ComplexSequence * cs,*cs_rev;
  Sequence * temp;
  GenomicDB * out;
  
  
  cs = new_ComplexSequence(seq->baseseq,cses);
  temp = reverse_complement_Sequence(seq->baseseq);
  cs_rev = new_ComplexSequence(temp,cses);
  free_Sequence(temp);

  out = new_GenomicDB_from_forrev_cseq(cs,cs_rev);
  out->single = hard_link_Genomic(seq);
  return out;
}
  

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
# line 339 "genomicdb.dy"
GenomicDB * new_GenomicDB_from_forrev_cseq(ComplexSequence * cs,ComplexSequence * cs_rev)
{
  GenomicDB * out;


  out = GenomicDB_alloc();
  out->is_single_seq = TRUE;
  out->forw = cs;
  out->rev = cs_rev;
  
  return out;
}


  
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
# line 360 "genomicdb.dy"
GenomicDB * new_GenomicDB(SequenceDB * seqdb,ComplexSequenceEvalSet * cses)
{
  GenomicDB * out;

  if( seqdb == NULL || cses == NULL ) {
    warn("Attempting to make GenomicDB from some NULL objects.");
    return NULL;
  }

  /** should check sequence database **/

  if( cses->type != SEQUENCE_GENOMIC ) {
    warn("You can't make a genomic database with a non SEQUENCE_GENOMIC cses type [%d]",cses->type);
    return NULL;
  }


  out = GenomicDB_alloc();

  out->is_single_seq = FALSE;
  out->sdb  = hard_link_SequenceDB(seqdb);
  out->cses = hard_link_ComplexSequenceEvalSet(cses);

  return out;
}

 
# line 371 "genomicdb.c"
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
GenomicDB * hard_link_GenomicDB(GenomicDB * obj) 
{
    if( obj == NULL )    {  
      warn("Trying to hard link to a GenomicDB object: passed a NULL object");   
      return NULL;   
      }  
    obj->dynamite_hard_link++;   
    return obj;  
}    


/* Function:  GenomicDB_alloc(void)
 *
 * Descrip:    Allocates structure: assigns defaults if given 
 *
 *
 *
 * Return [UNKN ]  Undocumented return value [GenomicDB *]
 *
 */
GenomicDB * GenomicDB_alloc(void) 
{
    GenomicDB * out;/* out is exported at end of function */ 


    /* call ckalloc and see if NULL */ 
    if((out=(GenomicDB *) ckalloc (sizeof(GenomicDB))) == NULL)  {  
      warn("GenomicDB_alloc failed ");   
      return NULL;  /* calling function should respond! */ 
      }  
    out->dynamite_hard_link = 1; 
    out->is_single_seq = FALSE;  
    out->done_forward = FALSE;   
    out->forw = NULL;    
    out->rev = NULL; 
    out->sdb = NULL; 
    out->current = NULL; 
    out->cses = NULL;    
    out->error_handling = GENDB_READ_THROUGH;    
    out->single = NULL;  


    return out;  
}    


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
GenomicDB * free_GenomicDB(GenomicDB * obj) 
{


    if( obj == NULL) {  
      warn("Attempting to free a NULL pointer to a GenomicDB obj. Should be trappable"); 
      return NULL;   
      }  


    if( obj->dynamite_hard_link > 1)     {  
      obj->dynamite_hard_link--; 
      return NULL;   
      }  
    if( obj->forw != NULL)   
      free_ComplexSequence(obj->forw);   
    if( obj->rev != NULL)    
      free_ComplexSequence(obj->rev);    
    if( obj->sdb != NULL)    
      free_SequenceDB(obj->sdb);     
    if( obj->current != NULL)    
      free_Sequence(obj->current);   
    if( obj->cses != NULL)   
      free_ComplexSequenceEvalSet(obj->cses);    
    if( obj->single != NULL) 
      free_Genomic(obj->single);     


    ckfree(obj); 
    return NULL; 
}    


/* Function:  replace_is_single_seq_GenomicDB(obj,is_single_seq)
 *
 * Descrip:    Replace member variable is_single_seq
 *             For use principly by API functions
 *
 *
 * Arg:                  obj [UNKN ] Object holding the variable [GenomicDB *]
 * Arg:        is_single_seq [OWNER] New value of the variable [boolean]
 *
 * Return [SOFT ]  member variable is_single_seq [boolean]
 *
 */
boolean replace_is_single_seq_GenomicDB(GenomicDB * obj,boolean is_single_seq) 
{
    if( obj == NULL)     {  
      warn("In replacement function is_single_seq for object GenomicDB, got a NULL object"); 
      return FALSE;  
      }  
    obj->is_single_seq = is_single_seq;  
    return TRUE; 
}    


/* Function:  access_is_single_seq_GenomicDB(obj)
 *
 * Descrip:    Access member variable is_single_seq
 *             For use principly by API functions
 *
 *
 * Arg:        obj [UNKN ] Object holding the variable [GenomicDB *]
 *
 * Return [SOFT ]  member variable is_single_seq [boolean]
 *
 */
boolean access_is_single_seq_GenomicDB(GenomicDB * obj) 
{
    if( obj == NULL)     {  
      warn("In accessor function is_single_seq for object GenomicDB, got a NULL object");    
      return FALSE;  
      }  
    return obj->is_single_seq;   
}    


/* Function:  replace_done_forward_GenomicDB(obj,done_forward)
 *
 * Descrip:    Replace member variable done_forward
 *             For use principly by API functions
 *
 *
 * Arg:                 obj [UNKN ] Object holding the variable [GenomicDB *]
 * Arg:        done_forward [OWNER] New value of the variable [boolean]
 *
 * Return [SOFT ]  member variable done_forward [boolean]
 *
 */
boolean replace_done_forward_GenomicDB(GenomicDB * obj,boolean done_forward) 
{
    if( obj == NULL)     {  
      warn("In replacement function done_forward for object GenomicDB, got a NULL object");  
      return FALSE;  
      }  
    obj->done_forward = done_forward;    
    return TRUE; 
}    


/* Function:  access_done_forward_GenomicDB(obj)
 *
 * Descrip:    Access member variable done_forward
 *             For use principly by API functions
 *
 *
 * Arg:        obj [UNKN ] Object holding the variable [GenomicDB *]
 *
 * Return [SOFT ]  member variable done_forward [boolean]
 *
 */
boolean access_done_forward_GenomicDB(GenomicDB * obj) 
{
    if( obj == NULL)     {  
      warn("In accessor function done_forward for object GenomicDB, got a NULL object"); 
      return FALSE;  
      }  
    return obj->done_forward;    
}    


/* Function:  replace_forw_GenomicDB(obj,forw)
 *
 * Descrip:    Replace member variable forw
 *             For use principly by API functions
 *
 *
 * Arg:         obj [UNKN ] Object holding the variable [GenomicDB *]
 * Arg:        forw [OWNER] New value of the variable [ComplexSequence *]
 *
 * Return [SOFT ]  member variable forw [boolean]
 *
 */
boolean replace_forw_GenomicDB(GenomicDB * obj,ComplexSequence * forw) 
{
    if( obj == NULL)     {  
      warn("In replacement function forw for object GenomicDB, got a NULL object");  
      return FALSE;  
      }  
    obj->forw = forw;    
    return TRUE; 
}    


/* Function:  access_forw_GenomicDB(obj)
 *
 * Descrip:    Access member variable forw
 *             For use principly by API functions
 *
 *
 * Arg:        obj [UNKN ] Object holding the variable [GenomicDB *]
 *
 * Return [SOFT ]  member variable forw [ComplexSequence *]
 *
 */
ComplexSequence * access_forw_GenomicDB(GenomicDB * obj) 
{
    if( obj == NULL)     {  
      warn("In accessor function forw for object GenomicDB, got a NULL object"); 
      return NULL;   
      }  
    return obj->forw;    
}    


/* Function:  replace_rev_GenomicDB(obj,rev)
 *
 * Descrip:    Replace member variable rev
 *             For use principly by API functions
 *
 *
 * Arg:        obj [UNKN ] Object holding the variable [GenomicDB *]
 * Arg:        rev [OWNER] New value of the variable [ComplexSequence *]
 *
 * Return [SOFT ]  member variable rev [boolean]
 *
 */
boolean replace_rev_GenomicDB(GenomicDB * obj,ComplexSequence * rev) 
{
    if( obj == NULL)     {  
      warn("In replacement function rev for object GenomicDB, got a NULL object");   
      return FALSE;  
      }  
    obj->rev = rev;  
    return TRUE; 
}    


/* Function:  access_rev_GenomicDB(obj)
 *
 * Descrip:    Access member variable rev
 *             For use principly by API functions
 *
 *
 * Arg:        obj [UNKN ] Object holding the variable [GenomicDB *]
 *
 * Return [SOFT ]  member variable rev [ComplexSequence *]
 *
 */
ComplexSequence * access_rev_GenomicDB(GenomicDB * obj) 
{
    if( obj == NULL)     {  
      warn("In accessor function rev for object GenomicDB, got a NULL object");  
      return NULL;   
      }  
    return obj->rev;     
}    


/* Function:  replace_sdb_GenomicDB(obj,sdb)
 *
 * Descrip:    Replace member variable sdb
 *             For use principly by API functions
 *
 *
 * Arg:        obj [UNKN ] Object holding the variable [GenomicDB *]
 * Arg:        sdb [OWNER] New value of the variable [SequenceDB *]
 *
 * Return [SOFT ]  member variable sdb [boolean]
 *
 */
boolean replace_sdb_GenomicDB(GenomicDB * obj,SequenceDB * sdb) 
{
    if( obj == NULL)     {  
      warn("In replacement function sdb for object GenomicDB, got a NULL object");   
      return FALSE;  
      }  
    obj->sdb = sdb;  
    return TRUE; 
}    


/* Function:  access_sdb_GenomicDB(obj)
 *
 * Descrip:    Access member variable sdb
 *             For use principly by API functions
 *
 *
 * Arg:        obj [UNKN ] Object holding the variable [GenomicDB *]
 *
 * Return [SOFT ]  member variable sdb [SequenceDB *]
 *
 */
SequenceDB * access_sdb_GenomicDB(GenomicDB * obj) 
{
    if( obj == NULL)     {  
      warn("In accessor function sdb for object GenomicDB, got a NULL object");  
      return NULL;   
      }  
    return obj->sdb;     
}    


/* Function:  replace_current_GenomicDB(obj,current)
 *
 * Descrip:    Replace member variable current
 *             For use principly by API functions
 *
 *
 * Arg:            obj [UNKN ] Object holding the variable [GenomicDB *]
 * Arg:        current [OWNER] New value of the variable [Sequence *]
 *
 * Return [SOFT ]  member variable current [boolean]
 *
 */
boolean replace_current_GenomicDB(GenomicDB * obj,Sequence * current) 
{
    if( obj == NULL)     {  
      warn("In replacement function current for object GenomicDB, got a NULL object");   
      return FALSE;  
      }  
    obj->current = current;  
    return TRUE; 
}    


/* Function:  access_current_GenomicDB(obj)
 *
 * Descrip:    Access member variable current
 *             For use principly by API functions
 *
 *
 * Arg:        obj [UNKN ] Object holding the variable [GenomicDB *]
 *
 * Return [SOFT ]  member variable current [Sequence *]
 *
 */
Sequence * access_current_GenomicDB(GenomicDB * obj) 
{
    if( obj == NULL)     {  
      warn("In accessor function current for object GenomicDB, got a NULL object");  
      return NULL;   
      }  
    return obj->current;     
}    


/* Function:  replace_cses_GenomicDB(obj,cses)
 *
 * Descrip:    Replace member variable cses
 *             For use principly by API functions
 *
 *
 * Arg:         obj [UNKN ] Object holding the variable [GenomicDB *]
 * Arg:        cses [OWNER] New value of the variable [ComplexSequenceEvalSet *]
 *
 * Return [SOFT ]  member variable cses [boolean]
 *
 */
boolean replace_cses_GenomicDB(GenomicDB * obj,ComplexSequenceEvalSet * cses) 
{
    if( obj == NULL)     {  
      warn("In replacement function cses for object GenomicDB, got a NULL object");  
      return FALSE;  
      }  
    obj->cses = cses;    
    return TRUE; 
}    


/* Function:  access_cses_GenomicDB(obj)
 *
 * Descrip:    Access member variable cses
 *             For use principly by API functions
 *
 *
 * Arg:        obj [UNKN ] Object holding the variable [GenomicDB *]
 *
 * Return [SOFT ]  member variable cses [ComplexSequenceEvalSet *]
 *
 */
ComplexSequenceEvalSet * access_cses_GenomicDB(GenomicDB * obj) 
{
    if( obj == NULL)     {  
      warn("In accessor function cses for object GenomicDB, got a NULL object"); 
      return NULL;   
      }  
    return obj->cses;    
}    



#ifdef _cplusplus
}
#endif
