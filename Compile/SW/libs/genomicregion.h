#ifndef DYNAMITEgenomicregionHEADERFILE
#define DYNAMITEgenomicregionHEADERFILE
#ifdef _cplusplus
extern "C" {
#endif
#include "dyna.h"

#define GenomicRegionLISTLENGTH 16
#define GenomicOverlapResultsLISTLENGTH 16

#ifndef DYNAMITE_DEFINED_Gene
typedef struct bp_sw_Gene bp_sw_Gene;
#define Gene bp_sw_Gene
#define DYNAMITE_DEFINED_Gene
#endif

/* Object GenomicRegion
 *
 * Descrip: GenomicRegion is structure which represents
 *        information on a region of genomic DNA. It
 *        *may not* have the actual DNA sequence in there,
 *        and it is important to realise that.
 *
 *        The numbering scheme of many other things (eg,
 *        genes) are going to be represented in this 
 *        guys coordinates
 *
 *
 */
struct bp_sw_GenomicRegion {  
    int dynamite_hard_link;  
    Gene ** gene;    
    int len;/* len for above gene  */ 
    int maxlen; /* maxlen for above gene */ 
    Genomic * genomic;  /*  NB, may not be here. Be careful! */ 
    } ;  
/* GenomicRegion defined */ 
#ifndef DYNAMITE_DEFINED_GenomicRegion
typedef struct bp_sw_GenomicRegion bp_sw_GenomicRegion;
#define GenomicRegion bp_sw_GenomicRegion
#define DYNAMITE_DEFINED_GenomicRegion
#endif


struct bp_sw_GenomicOverlapGene {  
    int dynamite_hard_link;  
    int exon_perfect;    
    int exon_truncated;  
    int exon_partial;    
    int exon_missed_internal;    
    int exon_missed_external;    
    int exon_mispredicted;   
    Gene * truth;   /*  NB hard-linked */ 
    Gene * test;     
    } ;  
/* GenomicOverlapGene defined */ 
#ifndef DYNAMITE_DEFINED_GenomicOverlapGene
typedef struct bp_sw_GenomicOverlapGene bp_sw_GenomicOverlapGene;
#define GenomicOverlapGene bp_sw_GenomicOverlapGene
#define DYNAMITE_DEFINED_GenomicOverlapGene
#endif


struct bp_sw_GenomicOverlapResults {  
    int dynamite_hard_link;  
    int gene_overlap;    
    GenomicOverlapGene ** gog;   
    int len;/* len for above gog  */ 
    int maxlen; /* maxlen for above gog */ 
    } ;  
/* GenomicOverlapResults defined */ 
#ifndef DYNAMITE_DEFINED_GenomicOverlapResults
typedef struct bp_sw_GenomicOverlapResults bp_sw_GenomicOverlapResults;
#define GenomicOverlapResults bp_sw_GenomicOverlapResults
#define DYNAMITE_DEFINED_GenomicOverlapResults
#endif




    /***************************************************/
    /* Callable functions                              */
    /* These are the functions you are expected to use */
    /***************************************************/



/* Function:  show_GenomicOverlapResults(gor,ofp)
 *
 * Descrip:    shows overlap resuls vaguely humanely
 *
 *
 * Arg:        gor [UNKN ] Undocumented argument [GenomicOverlapResults *]
 * Arg:        ofp [UNKN ] Undocumented argument [FILE *]
 *
 */
void bp_sw_show_GenomicOverlapResults(GenomicOverlapResults * gor,FILE * ofp);
#define show_GenomicOverlapResults bp_sw_show_GenomicOverlapResults


/* Function:  Genomic_overlap(query,truth)
 *
 * Descrip:    Gives the overlap of query in target. It is reported
 *             back in the GenomicOverlapResults structure
 *
 *
 * Arg:        query [UNKN ] Undocumented argument [GenomicRegion *]
 * Arg:        truth [UNKN ] Undocumented argument [GenomicRegion *]
 *
 * Return [UNKN ]  Undocumented return value [GenomicOverlapResults *]
 *
 */
GenomicOverlapResults * bp_sw_Genomic_overlap(GenomicRegion * query,GenomicRegion * truth);
#define Genomic_overlap bp_sw_Genomic_overlap


/* Function:  Gene_overlap_forward(test,truth)
 *
 * Descrip:    Works out a gene overlap for two forward genes
 *
 *
 * Arg:         test [UNKN ] Undocumented argument [Gene *]
 * Arg:        truth [UNKN ] Undocumented argument [Gene *]
 *
 * Return [UNKN ]  Undocumented return value [GenomicOverlapGene *]
 *
 */
GenomicOverlapGene * bp_sw_Gene_overlap_forward(Gene * test,Gene * truth);
#define Gene_overlap_forward bp_sw_Gene_overlap_forward


/* Function:  Gene_overlap_backward(test,truth)
 *
 * Descrip:    Works out a gene overlap for two backward genes
 *
 *
 * Arg:         test [UNKN ] Undocumented argument [Gene *]
 * Arg:        truth [UNKN ] Undocumented argument [Gene *]
 *
 * Return [UNKN ]  Undocumented return value [GenomicOverlapGene *]
 *
 */
GenomicOverlapGene * bp_sw_Gene_overlap_backward(Gene * test,Gene * truth);
#define Gene_overlap_backward bp_sw_Gene_overlap_backward


/* Function:  simple_merged_GenomicRegion(gr,bits_cutoff,max_ext)
 *
 * Descrip:    Makes a new genomic region from the given
 *             genomic region, trying to merge close
 *             gene predictions that can be made by
 *             extending open reading frames
 *
 *
 * Arg:                 gr [UNKN ] Undocumented argument [GenomicRegion *]
 * Arg:        bits_cutoff [UNKN ] Undocumented argument [double]
 * Arg:            max_ext [UNKN ] Undocumented argument [int]
 *
 * Return [UNKN ]  Undocumented return value [GenomicRegion *]
 *
 */
GenomicRegion * bp_sw_simple_merged_GenomicRegion(GenomicRegion * gr,double bits_cutoff,int max_ext);
#define simple_merged_GenomicRegion bp_sw_simple_merged_GenomicRegion


/* Function:  sort_GenomicRegion_absolute(gr)
 *
 * Descrip:    sorts the genomicregion by absolute start points.
 *
 *
 * Arg:        gr [UNKN ] Undocumented argument [GenomicRegion *]
 *
 */
void bp_sw_sort_GenomicRegion_absolute(GenomicRegion * gr);
#define sort_GenomicRegion_absolute bp_sw_sort_GenomicRegion_absolute


/* Function:  compare_Gene_absolute(one,two)
 *
 * Descrip:    internal sort function
 *
 *
 * Arg:        one [UNKN ] Undocumented argument [Gene *]
 * Arg:        two [UNKN ] Undocumented argument [Gene *]
 *
 * Return [UNKN ]  Undocumented return value [int]
 *
 */
int bp_sw_compare_Gene_absolute(Gene * one,Gene * two);
#define compare_Gene_absolute bp_sw_compare_Gene_absolute


/* Function:  get_Genomic_from_GenomicRegion(gr)
 *
 * Descrip:    gives back genomic sequence from a genomic region. This is *soft
 *             linked* - ie, don't free it and use /hard_link_Genomic if you do want to...
 *
 *
 * Arg:        gr [UNKN ] genomic region input [GenomicRegion *]
 *
 * Return [SOFT ]  a Genomic sequence [Genomic *]
 *
 */
Genomic * bp_sw_get_Genomic_from_GenomicRegion(GenomicRegion * gr);
#define get_Genomic_from_GenomicRegion bp_sw_get_Genomic_from_GenomicRegion


/* Function:  read_EMBL_GenomicRegion_efetch(efetch)
 *
 * Descrip:    Reads both feature table and sequence
 *
 *
 * Arg:        efetch [UNKN ] Undocumented argument [char *]
 *
 * Return [UNKN ]  Undocumented return value [GenomicRegion *]
 *
 */
GenomicRegion * bp_sw_read_EMBL_GenomicRegion_efetch(char * efetch) ;
#define read_EMBL_GenomicRegion_efetch bp_sw_read_EMBL_GenomicRegion_efetch


/* Function:  read_EMBL_GenomicRegion_SRS(srsquery)
 *
 * Descrip:    Reads both feature table and sequence
 *
 *
 * Arg:        srsquery [UNKN ] Undocumented argument [char *]
 *
 * Return [UNKN ]  Undocumented return value [GenomicRegion *]
 *
 */
GenomicRegion * bp_sw_read_EMBL_GenomicRegion_SRS(char * srsquery) ;
#define read_EMBL_GenomicRegion_SRS bp_sw_read_EMBL_GenomicRegion_SRS


/* Function:  read_EMBL_GenomicRegion_file(filename)
 *
 * Descrip:    Reads in both EMBL sequence and features 
 *
 *
 * Arg:        filename [UNKN ] Undocumented argument [char *]
 *
 * Return [UNKN ]  Undocumented return value [GenomicRegion *]
 *
 */
GenomicRegion * bp_sw_read_EMBL_GenomicRegion_file(char * filename);
#define read_EMBL_GenomicRegion_file bp_sw_read_EMBL_GenomicRegion_file


/* Function:  read_EMBL_GenomicRegion(ifp)
 *
 * Descrip:    Reads in both EMBL sequence and features 
 *
 *
 * Arg:        ifp [UNKN ] Undocumented argument [FILE *]
 *
 * Return [UNKN ]  Undocumented return value [GenomicRegion *]
 *
 */
GenomicRegion * bp_sw_read_EMBL_GenomicRegion(FILE * ifp);
#define read_EMBL_GenomicRegion bp_sw_read_EMBL_GenomicRegion


/* Function:  read_EMBL_FT_into_GenomicRegion(buffer,maxlen,gr,ifp)
 *
 * Descrip:    Reads in EMBL *features*, not sequence.
 *
 *
 * Arg:        buffer [UNKN ] Undocumented argument [char *]
 * Arg:        maxlen [UNKN ] Undocumented argument [int]
 * Arg:            gr [UNKN ] Undocumented argument [GenomicRegion *]
 * Arg:           ifp [UNKN ] Undocumented argument [FILE *]
 *
 * Return [UNKN ]  Undocumented return value [boolean]
 *
 */
boolean bp_sw_read_EMBL_FT_into_GenomicRegion(char * buffer,int maxlen,GenomicRegion * gr,FILE * ifp);
#define read_EMBL_FT_into_GenomicRegion bp_sw_read_EMBL_FT_into_GenomicRegion


/* Function:  show_GenomicRegion(gr,ofp)
 *
 * Descrip:    dumps genomic region in vaguely human form
 *
 *
 * Arg:         gr [UNKN ] Undocumented argument [GenomicRegion *]
 * Arg:        ofp [UNKN ] Undocumented argument [FILE *]
 *
 */
void bp_sw_show_GenomicRegion(GenomicRegion * gr,FILE * ofp);
#define show_GenomicRegion bp_sw_show_GenomicRegion


/* Function:  dump_translations_GenomicRegion(gr,ct,ofp)
 *
 * Descrip:    shows all the translations in this genomic region
 *
 *
 * Arg:         gr [UNKN ] Undocumented argument [GenomicRegion *]
 * Arg:         ct [UNKN ] Undocumented argument [CodonTable *]
 * Arg:        ofp [UNKN ] Undocumented argument [FILE *]
 *
 */
void bp_sw_dump_translations_GenomicRegion(GenomicRegion * gr,CodonTable * ct,FILE * ofp);
#define dump_translations_GenomicRegion bp_sw_dump_translations_GenomicRegion


/* Function:  dump_transcripts_GenomicRegion(gr,ofp)
 *
 * Descrip:    shows all the transcripts in this genomic region
 *
 *
 * Arg:         gr [UNKN ] Undocumented argument [GenomicRegion *]
 * Arg:        ofp [UNKN ] Undocumented argument [FILE *]
 *
 */
void bp_sw_dump_transcripts_GenomicRegion(GenomicRegion * gr,FILE * ofp);
#define dump_transcripts_GenomicRegion bp_sw_dump_transcripts_GenomicRegion


/* Function:  new_GenomicRegion(gen)
 *
 * Descrip:    makes a genomicregion from a genomic sequence
 *
 *
 * Arg:        gen [UNKN ] Undocumented argument [Genomic *]
 *
 * Return [UNKN ]  Undocumented return value [GenomicRegion *]
 *
 */
GenomicRegion * bp_sw_new_GenomicRegion(Genomic * gen);
#define new_GenomicRegion bp_sw_new_GenomicRegion


/* Function:  add_Gene_to_GenomicRegion(gr,gene)
 *
 * Descrip:    adds a Gene to this GenomicRegion, making
 *             sure that it parent/son relationship is ok
 *
 *
 * Arg:          gr [UNKN ] GenomicRegion to be added to [GenomicRegion *]
 * Arg:        gene [UNKN ] Gene to be added [Gene *]
 *
 * Return [UNKN ]  Undocumented return value [boolean]
 *
 */
boolean bp_sw_add_Gene_to_GenomicRegion(GenomicRegion * gr,Gene * gene);
#define add_Gene_to_GenomicRegion bp_sw_add_Gene_to_GenomicRegion


/* Function:  show_ace_GenomicRegion(gr,seq_name,ofp)
 *
 * Descrip:    shows ACeDB subsequence source.
 *
 *             Assummes
 *               a only one transcript per gene
 *               b only cds exons are used
 *
 *
 * Arg:              gr [UNKN ] Undocumented argument [GenomicRegion *]
 * Arg:        seq_name [UNKN ] Undocumented argument [char *]
 * Arg:             ofp [UNKN ] Undocumented argument [FILE *]
 *
 */
void bp_sw_show_ace_GenomicRegion(GenomicRegion * gr,char * seq_name,FILE * ofp);
#define show_ace_GenomicRegion bp_sw_show_ace_GenomicRegion


/* Function:  show_GFF_GenomicRegion(gr,seq_name,source,ofp)
 *
 * Descrip:    shows GFF output
 *
 *             Assummes
 *               a only cds exons are used
 *
 *
 * Arg:              gr [UNKN ] Undocumented argument [GenomicRegion *]
 * Arg:        seq_name [UNKN ] Undocumented argument [char *]
 * Arg:          source [UNKN ] Undocumented argument [char *]
 * Arg:             ofp [UNKN ] Undocumented argument [FILE *]
 *
 */
void bp_sw_show_GFF_GenomicRegion(GenomicRegion * gr,char * seq_name,char * source,FILE * ofp);
#define show_GFF_GenomicRegion bp_sw_show_GFF_GenomicRegion


/* Function:  show_pretty_GenomicRegion(gr,ofp)
 *
 * Descrip: No Description
 *
 * Arg:         gr [UNKN ] Undocumented argument [GenomicRegion *]
 * Arg:        ofp [UNKN ] Undocumented argument [FILE *]
 *
 */
void bp_sw_show_pretty_GenomicRegion(GenomicRegion * gr,FILE * ofp);
#define show_pretty_GenomicRegion bp_sw_show_pretty_GenomicRegion


/* Function:  add_GenomicRegion(obj,add)
 *
 * Descrip:    Adds another object to the list. It will expand the list if necessary
 *
 *
 * Arg:        obj [UNKN ] Object which contains the list [GenomicRegion *]
 * Arg:        add [OWNER] Object to add to the list [Gene *]
 *
 * Return [UNKN ]  Undocumented return value [boolean]
 *
 */
boolean bp_sw_add_GenomicRegion(GenomicRegion * obj,Gene * add);
#define add_GenomicRegion bp_sw_add_GenomicRegion


/* Function:  flush_GenomicRegion(obj)
 *
 * Descrip:    Frees the list elements, sets length to 0
 *             If you want to save some elements, use hard_link_xxx
 *             to protect them from being actually destroyed in the free
 *
 *
 * Arg:        obj [UNKN ] Object which contains the list  [GenomicRegion *]
 *
 * Return [UNKN ]  Undocumented return value [int]
 *
 */
int bp_sw_flush_GenomicRegion(GenomicRegion * obj);
#define flush_GenomicRegion bp_sw_flush_GenomicRegion


/* Function:  GenomicRegion_alloc_std(void)
 *
 * Descrip:    Equivalent to GenomicRegion_alloc_len(GenomicRegionLISTLENGTH)
 *
 *
 *
 * Return [UNKN ]  Undocumented return value [GenomicRegion *]
 *
 */
GenomicRegion * bp_sw_GenomicRegion_alloc_std(void);
#define GenomicRegion_alloc_std bp_sw_GenomicRegion_alloc_std


/* Function:  GenomicRegion_alloc_len(len)
 *
 * Descrip:    Allocates len length to all lists
 *
 *
 * Arg:        len [UNKN ] Length of lists to allocate [int]
 *
 * Return [UNKN ]  Undocumented return value [GenomicRegion *]
 *
 */
GenomicRegion * bp_sw_GenomicRegion_alloc_len(int len);
#define GenomicRegion_alloc_len bp_sw_GenomicRegion_alloc_len


/* Function:  hard_link_GenomicRegion(obj)
 *
 * Descrip:    Bumps up the reference count of the object
 *             Meaning that multiple pointers can 'own' it
 *
 *
 * Arg:        obj [UNKN ] Object to be hard linked [GenomicRegion *]
 *
 * Return [UNKN ]  Undocumented return value [GenomicRegion *]
 *
 */
GenomicRegion * bp_sw_hard_link_GenomicRegion(GenomicRegion * obj);
#define hard_link_GenomicRegion bp_sw_hard_link_GenomicRegion


/* Function:  GenomicRegion_alloc(void)
 *
 * Descrip:    Allocates structure: assigns defaults if given 
 *
 *
 *
 * Return [UNKN ]  Undocumented return value [GenomicRegion *]
 *
 */
GenomicRegion * bp_sw_GenomicRegion_alloc(void);
#define GenomicRegion_alloc bp_sw_GenomicRegion_alloc


/* Function:  free_GenomicRegion(obj)
 *
 * Descrip:    Free Function: removes the memory held by obj
 *             Will chain up to owned members and clear all lists
 *
 *
 * Arg:        obj [UNKN ] Object that is free'd [GenomicRegion *]
 *
 * Return [UNKN ]  Undocumented return value [GenomicRegion *]
 *
 */
GenomicRegion * bp_sw_free_GenomicRegion(GenomicRegion * obj);
#define free_GenomicRegion bp_sw_free_GenomicRegion


/* Function:  hard_link_GenomicOverlapGene(obj)
 *
 * Descrip:    Bumps up the reference count of the object
 *             Meaning that multiple pointers can 'own' it
 *
 *
 * Arg:        obj [UNKN ] Object to be hard linked [GenomicOverlapGene *]
 *
 * Return [UNKN ]  Undocumented return value [GenomicOverlapGene *]
 *
 */
GenomicOverlapGene * bp_sw_hard_link_GenomicOverlapGene(GenomicOverlapGene * obj);
#define hard_link_GenomicOverlapGene bp_sw_hard_link_GenomicOverlapGene


/* Function:  GenomicOverlapGene_alloc(void)
 *
 * Descrip:    Allocates structure: assigns defaults if given 
 *
 *
 *
 * Return [UNKN ]  Undocumented return value [GenomicOverlapGene *]
 *
 */
GenomicOverlapGene * bp_sw_GenomicOverlapGene_alloc(void);
#define GenomicOverlapGene_alloc bp_sw_GenomicOverlapGene_alloc


/* Function:  free_GenomicOverlapGene(obj)
 *
 * Descrip:    Free Function: removes the memory held by obj
 *             Will chain up to owned members and clear all lists
 *
 *
 * Arg:        obj [UNKN ] Object that is free'd [GenomicOverlapGene *]
 *
 * Return [UNKN ]  Undocumented return value [GenomicOverlapGene *]
 *
 */
GenomicOverlapGene * bp_sw_free_GenomicOverlapGene(GenomicOverlapGene * obj);
#define free_GenomicOverlapGene bp_sw_free_GenomicOverlapGene


/* Function:  add_GenomicOverlapResults(obj,add)
 *
 * Descrip:    Adds another object to the list. It will expand the list if necessary
 *
 *
 * Arg:        obj [UNKN ] Object which contains the list [GenomicOverlapResults *]
 * Arg:        add [OWNER] Object to add to the list [GenomicOverlapGene *]
 *
 * Return [UNKN ]  Undocumented return value [boolean]
 *
 */
boolean bp_sw_add_GenomicOverlapResults(GenomicOverlapResults * obj,GenomicOverlapGene * add);
#define add_GenomicOverlapResults bp_sw_add_GenomicOverlapResults


/* Function:  flush_GenomicOverlapResults(obj)
 *
 * Descrip:    Frees the list elements, sets length to 0
 *             If you want to save some elements, use hard_link_xxx
 *             to protect them from being actually destroyed in the free
 *
 *
 * Arg:        obj [UNKN ] Object which contains the list  [GenomicOverlapResults *]
 *
 * Return [UNKN ]  Undocumented return value [int]
 *
 */
int bp_sw_flush_GenomicOverlapResults(GenomicOverlapResults * obj);
#define flush_GenomicOverlapResults bp_sw_flush_GenomicOverlapResults


/* Function:  GenomicOverlapResults_alloc_std(void)
 *
 * Descrip:    Equivalent to GenomicOverlapResults_alloc_len(GenomicOverlapResultsLISTLENGTH)
 *
 *
 *
 * Return [UNKN ]  Undocumented return value [GenomicOverlapResults *]
 *
 */
GenomicOverlapResults * bp_sw_GenomicOverlapResults_alloc_std(void);
#define GenomicOverlapResults_alloc_std bp_sw_GenomicOverlapResults_alloc_std


/* Function:  GenomicOverlapResults_alloc_len(len)
 *
 * Descrip:    Allocates len length to all lists
 *
 *
 * Arg:        len [UNKN ] Length of lists to allocate [int]
 *
 * Return [UNKN ]  Undocumented return value [GenomicOverlapResults *]
 *
 */
GenomicOverlapResults * bp_sw_GenomicOverlapResults_alloc_len(int len);
#define GenomicOverlapResults_alloc_len bp_sw_GenomicOverlapResults_alloc_len


/* Function:  hard_link_GenomicOverlapResults(obj)
 *
 * Descrip:    Bumps up the reference count of the object
 *             Meaning that multiple pointers can 'own' it
 *
 *
 * Arg:        obj [UNKN ] Object to be hard linked [GenomicOverlapResults *]
 *
 * Return [UNKN ]  Undocumented return value [GenomicOverlapResults *]
 *
 */
GenomicOverlapResults * bp_sw_hard_link_GenomicOverlapResults(GenomicOverlapResults * obj);
#define hard_link_GenomicOverlapResults bp_sw_hard_link_GenomicOverlapResults


/* Function:  GenomicOverlapResults_alloc(void)
 *
 * Descrip:    Allocates structure: assigns defaults if given 
 *
 *
 *
 * Return [UNKN ]  Undocumented return value [GenomicOverlapResults *]
 *
 */
GenomicOverlapResults * bp_sw_GenomicOverlapResults_alloc(void);
#define GenomicOverlapResults_alloc bp_sw_GenomicOverlapResults_alloc


/* Function:  free_GenomicOverlapResults(obj)
 *
 * Descrip:    Free Function: removes the memory held by obj
 *             Will chain up to owned members and clear all lists
 *
 *
 * Arg:        obj [UNKN ] Object that is free'd [GenomicOverlapResults *]
 *
 * Return [UNKN ]  Undocumented return value [GenomicOverlapResults *]
 *
 */
GenomicOverlapResults * bp_sw_free_GenomicOverlapResults(GenomicOverlapResults * obj);
#define free_GenomicOverlapResults bp_sw_free_GenomicOverlapResults


  /* Unplaced functions */
  /* There has been no indication of the use of these functions */


    /***************************************************/
    /* Internal functions                              */
    /* you are not expected to have to call these      */
    /***************************************************/
Genomic * bp_sw_access_genomic_GenomicRegion(GenomicRegion * obj);
#define access_genomic_GenomicRegion bp_sw_access_genomic_GenomicRegion
boolean bp_sw_replace_genomic_GenomicRegion(GenomicRegion * obj,Genomic * genomic);
#define replace_genomic_GenomicRegion bp_sw_replace_genomic_GenomicRegion
int bp_sw_length_gene_GenomicRegion(GenomicRegion * obj);
#define length_gene_GenomicRegion bp_sw_length_gene_GenomicRegion
Gene * bp_sw_access_gene_GenomicRegion(GenomicRegion * obj,int i);
#define access_gene_GenomicRegion bp_sw_access_gene_GenomicRegion
void bp_sw_show_GenomicOverlapGene(GenomicOverlapGene * gog,FILE * ofp);
#define show_GenomicOverlapGene bp_sw_show_GenomicOverlapGene
void bp_sw_swap_GenomicRegion(Gene ** list,int i,int j) ;
#define swap_GenomicRegion bp_sw_swap_GenomicRegion
void bp_sw_qsort_GenomicRegion(Gene ** list,int left,int right,int (*comp)(Gene * ,Gene * ));
#define qsort_GenomicRegion bp_sw_qsort_GenomicRegion
void bp_sw_sort_GenomicRegion(GenomicRegion * obj,int (*comp)(Gene *, Gene *));
#define sort_GenomicRegion bp_sw_sort_GenomicRegion
boolean bp_sw_expand_GenomicRegion(GenomicRegion * obj,int len);
#define expand_GenomicRegion bp_sw_expand_GenomicRegion
void bp_sw_swap_GenomicOverlapResults(GenomicOverlapGene ** list,int i,int j) ;
#define swap_GenomicOverlapResults bp_sw_swap_GenomicOverlapResults
void bp_sw_qsort_GenomicOverlapResults(GenomicOverlapGene ** list,int left,int right,int (*comp)(GenomicOverlapGene * ,GenomicOverlapGene * ));
#define qsort_GenomicOverlapResults bp_sw_qsort_GenomicOverlapResults
void bp_sw_sort_GenomicOverlapResults(GenomicOverlapResults * obj,int (*comp)(GenomicOverlapGene *, GenomicOverlapGene *));
#define sort_GenomicOverlapResults bp_sw_sort_GenomicOverlapResults
boolean bp_sw_expand_GenomicOverlapResults(GenomicOverlapResults * obj,int len);
#define expand_GenomicOverlapResults bp_sw_expand_GenomicOverlapResults

#ifdef _cplusplus
}
#endif

#endif
