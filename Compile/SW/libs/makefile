


OBJS =	aln.o\
	alnconvert.o\
	alnrange.o\
	asciibtcanvas.o\
	basematrix.o\
	btcanvas.o\
	cdna.o\
	cdnadb.o\
	codon.o\
	codonmapper.o\
	codonmatrix.o\
	commandline.o\
	complexconsensi.o\
	complexevalset.o\
	complexsequence.o\
	compmat.o\
	dna.o\
	dnamatrix.o\
	dpenvelope.o\
	dynlibcross.o\
	embl.o\
	gene.o\
	genomic.o\
	genomicdb.o\
	genomicregion.o\
	histogram.o\
	hscore.o\
	linesubs.o\
	packaln.o\
	probability.o\
	protein.o\
	proteindb.o\
	proteinsw.o\
	seqaligndisplay.o\
	sequence.o\
	sequencedb.o\
	sw_wrap.o\
	transcript.o\
	translation.o\
	wiseerror.o\
	wisefile.o\
	wisememman.o\
	wiseoverlay.o\
	wiserandom.o\
	wisestring.o\
	wisetime.o

libsw.a : $(OBJS)
	ar ru libsw.a $(OBJS)

wisefile.o : wisefile.c
	$(CC) $(CFLAGS) -DNOERROR wisefile.c

CFLAGS = -c -O
CC     = cc
