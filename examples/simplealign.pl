#!/usr/bin/perl

# PROGRAM  : simplealign.pl
# PURPOSE  : Simple driver for Bio::SimpleAlign
# AUTHOR   : Ewan Birney birney@sanger.ac.uk 
# CREATED  : Tue Oct 27 1998
# REVISION : $Id: simplealign.pl,v 1.2.14.1 2001/03/30 07:42:00 lapp Exp $
#
# INSTALLATION
#    If you have installed bioperl using the standard
#    makefile system everything should be fine and 
#    dandy.
#
#    if not edit the use lib "...." line to point the directory
#    containing your Bioperl modules.
#

#use lib "/nfs/disk21/birney/prog/bioperl/";

# Modified 3/5/01 to use AlignIO by Peter Schattner schattner@alum.mit.edu

#
# This uses the internal DATA stream (past the end of this
# file, on the __END__ tag) to load in the data. We then
# do some reformats, sort in a different way and a quick
# getting into the alignment. All pretty simple ;)
#

#
# The simplealign module does not do the following things
#    a) give you sensible ways of asking if residues are a
#       column of gaps or conservation 
#    b) provide ways of editing the alignment
#    c) making alignments
#

# 
# a) and b) are probably best done by UnivAlign from Georg Fuellen
# c) is done for pairwise alignments in Bio::Tools::pSW; and
# also you can read in stuff from programs like clustal and hmmer
# into this.
#

use strict;
use Bio::SimpleAlign;
use Bio::AlignIO;

# read from a stream
my $str = Bio::AlignIO->newFh('-fh'=> \*DATA, '-format' => 'pfam' );
my $al = <$str>;

# write out a MSF file
my $out = Bio::AlignIO->newFh('-fh'=> \*STDOUT,  '-format' => 'msf');
my $status = print $out $al;

# order by alphabetically then start end
$al->sort_alphabetically();

# write in Pfam format now...
my $out2=Bio::AlignIO->newFh( '-fh'=> \*STDOUT, '-format' => 'pfam');
$status = print $out2 $al;

# now set the display name to be 
# name_# like roa1_human_1, roa1_human_2 etc
# This **doesn't** change the underlying names of the
# sequences you'll be glad to hear.

$al->set_displayname_count();

# dump again... bored of this yet?

$status = print $out2 $al;

# get into the alignment and get things out
# we just want to see how many unique names
# there are in this alignment

my ($seq, $id, %hash) ;

# loop over the alignment
foreach  $seq ( $al->eachSeq() ) {
    # increment a hash on the name by one each time
    $hash{$seq->id()}++;
}

# disgorge the hash

foreach $id ( keys %hash ) {
    print "$id has $hash{$id} subsequences in this alignment\n";
}

__END__
GR10_BRANA/8-79     CFVGGL......AWATGDAELERTFS.....Q.FGEV..IDSKIIND.............RETGRSRGFGFVTFKDEKSMKDAIDEMNG.K...ELDGRTITV
HUD_HUMAN/48-119    LIVNYL......PQNMTQEEFRSLFG.....S.IGEI..ESCKLVRD.............KITGQSLGYGFVNYIDPKDAEKAINTLNG.L...RLQTKTIKV
IF32_SCHPO/41-124   VVIEGAP....VVEEAKQQDFFRFLSSKVLAK.IGKVKENGFYMPFE.........EKNGK..KMSLGLVFADFENVDGADLCVQELDGKQ...ILKNHTFVV
IF32_YEAST/79-157   IVVNGAPVIPSAKVPVLKKALTSLFS.....K.AGKV..VNMEFPID.............EATGKTKGFLFVECGSMNDAKKIIKSFHGKR...LDLKHRLFL
IF4B_HUMAN/98-168   AFLGNL......PYDVTEESIKEFFR.....G.LNIS...AVRLPR............EPSNPERLKGFGYAEFEDLDSLLSALS.LNE.E...SLGNRRIRV
LA_DROME/151-225    AYAKGF......PLDSQISELLDFTA.....N.YDKV..VNLTMRNS.........YDKPTKSYKFKGSIFLTFETKDQAKAFLE.QEK.I...VYKERELLR
LA_HUMAN/113-182    VYIKGF......PTDATLDDIKEWLE.....D.KGQV..LNIQMRR..............TLHKAFKGSIFVVFDSIESAKKFVE.TPG.Q...KYKETDLLI
MEI2_SCHPO/197-265  LFVTNL......PRIVPYATLLELFS.....K.LGDV..KGIDTSSL.................STDGICIVAFFDIRQAIQAAKSLRSQR...FFNDRLLYF
MODU_DROME/177-246  VFVTNL......PNEYLHKDLVALFA.....K.FGRL..SALQRFTN................LNGNKSVLIAFDTSTGAEAVLQAKPKAL...TLGDNVLSV
MODU_DROME/260-326  VVVGLI......GPNITKDDLKTFFE.....K.VAPV..EAVTISSN.................RLMPRAFVRLASVDDIPKALK.LHS.T...ELFSRFITV
MODU_DROME/342-410  LVVENVG....KHESYSSDALEKIFK.....K.FGDV..EEIDVVC..................SKAVLAFVTFKQSDAATKALAQLDG.K...TVNKFEWKL
MODU_DROME/422-484  ILVTNL......TSDATEADLRKVFN.....D.SGEI..ESIIMLG.....................QKAVVKFKDDEGFCKSFL.ANE.S...IVNNAPIFI
MSSP_HUMAN/31-102   LYIRGL......PPHTTDQDLVKLCQ.....P.YGKI..VSTKAILD.............KTTNKCKGYGFVDFDSPAAAQKAVSALKA.S...GVQAQKAKQ
NAM8_YEAST/165-237  IFVGDL......APNVTESQLFELFI.....NRYAST..SHAKIVHD.............QVTGMSKGYGFVKFTNSDEQQLALSEMQG.V...FLNGRAIKV
NONA_DROME/304-369  LYVGNL......TNDITDDELREMFK.....P.YGEI..SEIFSNLD...................KNFTFLKVDYHPNAEKAKRALDG.S...MRKGRQLRV
NONA_DROME/378-448  LRVSNL......TPFVSNELLYKSFE.....I.FGPI..ERASITVD..............DRGKHMGEGIVEFAKKSSASACLRMCNE.K...CFFLTASLR
NOP3_YEAST/127-190  LFVRPF......PLDVQESELNEIFG.....P.FGPM..KEVKILN.....................GFAFVEFEEAESAAKAIEEVHG.K...SFANQPLEV
NOP3_YEAST/202-270  ITMKNL......PEGCSWQDLKDLAR.....E.NSLE..TTFSSVN................TRDFDGTGALEFPSEEILVEALERLNN.I...EFRGSVITV
NOP4_YEAST/28-98    LFVRSI......PQDVTDEQLADFFS.....N.FAPI..KHAVVVKD..............TNKRSRGFGFVSFAVEDDTKEALAKARK.T...KFNGHILRV
NOP4_YEAST/292-363  VFVRNV......PYDATEESLAPHFS.....K.FGSV..KYALPVID.............KSTGLAKGTAFVAFKDQYTYNECIKNAPA.A...GSTSLLIGD
NSR1_YEAST/170-241  IFVGRL......SWSIDDEWLKKEFE.....H.IGGV..IGARVIYE.............RGTDRSRGYGYVDFENKSYAEKAIQEMQG.K...EIDGRPINC
NSR1_YEAST/269-340  LFLGNL......SFNADRDAIFELFA.....K.HGEV..VSVRIPTH.............PETEQPKGFGYVQFSNMEDAKKALDALQG.E...YIDNRPVRL
NUCL_CHICK/283-352  LFVKNL......TPTKDYEELRTAIK.....EFFGKK...NLQVSEV..............RIGSSKRFGYVDFLSAEDMDKALQ.LNG.K...KLMGLEIKL
PABP_DROME/4-75     LYVGDL......PQDVNESGLFDKFS.....S.AGPV..LSIRVCRD.............VITRRSLGYAYVNFQQPADAERALDTMNF.D...LVRNKPIRI
PABP_DROME/92-162   VFIKNL......DRAIDNKAIYDTFS.....A.FGNI..LSCKVATD..............EKGNSKGYGFVHFETEEAANTSIDKVNG.M...LLNGKKVYV
PABP_DROME/183-254  VYVKNF......TEDFDDEKLKEFFE.....P.YGKI..TSYKVMS..............KEDGKSKGFGFVAFETTEAAEAAVQALNGKD...MGEGKSLYV
PABP_SCHPO/249-319  VYIKNL......DTEITEQEFSDLFG.....Q.FGEI..TSLSLVKD..............QNDKPRGFGFVNYANHECAQKAVDELND.K...EYKGKKLYV
PES4_YEAST/93-164   LFIGDL......HETVTEETLKGIFK.....K.YPSF..VSAKVCLD.............SVTKKSLGHGYLNFEDKEEAEKAMEELNY.T...KVNGKEIRI
PES4_YEAST/305-374  IFIKNL......PTITTRDDILNFFS.....E.VGPI..KSIYLSN...............ATKVKYLWAFVTYKNSSDSEKAIKRYNN.F...YFRGKKLLV
PR24_YEAST/43-111   VLVKNL......PKSYNQNKVYKYFK.....H.CGPI..IHVDVAD...............SLKKNFRFARIEFARYDGALAAIT.KTH.K...VVGQNEIIV
PR24_YEAST/119-190  LWMTNF......PPSYTQRNIRDLLQ.....D.INVV.ALSIRLPSL..............RFNTSRRFAYIDVTSKEDARYCVEKLNG.L...KIEGYTLVT
PR24_YEAST/212-284  IMIRNL.....STELLDENLLRESFE.....G.FGSI..EKINIPAG............QKEHSFNNCCAFMVFENKDSAERALQ.MNR.S...LLGNREISV
PSF_HUMAN/373-443   LSVRNL......SPYVSNELLEEAFS.....Q.FGPI..ERAVVIVD..............DRGRSTGKGIVEFASKPAARKAFERCSE.G...VFLLTTTPR
PTB_HUMAN/61-128    IHIRKL......PIDVTEGEVISLGL.....P.FGKV..TNLLMLKG...................KNQAFIEMNTEEAANTMVN.YYT.SVTPVLRGQPIYI
PTB_HUMAN/186-253   IIVENL......FYPVTLDVLHQIFS.....K.FGTV....LKIIT...............FTKNNQFQALLQYADPVSAQHAKLSLDG.Q...NIYNACCTL
PUB1_YEAST/76-146   LYVGNL......DKAITEDILKQYFQ.....V.GGPI..ANIKIMID..............KNNKNVNYAFVEYHQSHDANIALQTLNG.K...QIENNIVKI
PUB1_YEAST/163-234  LFVGDL......NVNVDDETLRNAFK.....D.FPSY..LSGHVMWD.............MQTGSSRGYGFVSFTSQDDAQNAMDSMQG.Q...DLNGRPLRI
PUB1_YEAST/342-407  AYIGNI......PHFATEADLIPLFQ.....N.FGFI..LDFKHYPE...................KGCCFIKYDTHEQAAVCIVALAN.F...PFQGRNLRT
RB97_DROME/34-104   LFIGGL......APYTTEENLKLFYG.....Q.WGKV..VDVVVMRD.............AATKRSRGFGFITYTKSLMVDRAQE..NRPH...IIDGKTVEA
RN12_YEAST/200-267  IVIKFQ......GPALTEEEIYSLFR.....R.YGTI....IDIFP...............PTAANNNVAKVRYRSFRGAISAKNCVSG.I...EIHNTVLHI
RN15_YEAST/20-91    VYLGSI......PYDQTEEQILDLCS.....N.VGPV..INLKMMFD.............PQTGRSKGYAFIEFRDLESSASAVRNLNG.Y...QLGSRFLKC
RNP1_YEAST/37-109   LYVGNL......PKNCRKQDLRDLFE.....PNYGKI..TINMLKKK.............PLKKPLKRFAFIEFQEGVNLKKVKEKMNG.K...IFMNEKIVI
RO28_NICSY/99-170   LFVGNL......PYDIDSEGLAQLFQ.....Q.AGVV..EIAEVIYN.............RETDRSRGFGFVTMSTVEEADKAVELYSQ.Y...DLNGRLLTV
RO33_NICSY/116-187  LYVGNL......PFSMTSSQLSEIFA.....E.AGTV..ANVEIVYD.............RVTDRSRGFAFVTMGSVEEAKEAIRLFDG.S...QVGGRTVKV
RO33_NICSY/219-290  LYVANL......SWALTSQGLRDAFA.....D.QPGF..MSAKVIYD.............RSSGRSRGFGFITFSSAEAMNSALDTMNE.V...ELEGRPLRL
ROA1_BOVIN/106-176  IFVGGI......KEDTEEHHLRDYFE.....Q.YGKI..EVIEIMTD.............RGSGKKRGFAFVTFDDHDSVDKIVI.QKY.H...TVNGHNCEV
ROC_HUMAN/18-82     VFIGNL.....NTLVVKKSDVEAIFS.....K.YGKI..VGCSVHK.....................GFAFVQYVNERNARAAVAGEDG.R...MIAGQVLDI
ROF_HUMAN/113-183   VRLRGL......PFGCTKEEIVQFFS.....G.LEIV.PNGITLPVD..............PEGKITGEAFVQFASQELAEKALG.KHK.E...RIGHRYIEV
ROG_HUMAN/10-81     LFIGGL......NTETNEKALEAVFG.....K.YGRI..VEVLLMKD.............RETNKSRGFAFVTFESPADAKDAARDMNG.K...SLDGKAIKV
RT19_ARATH/33-104   LYIGGL......SPGTDEHSLKDAFS.....S.FNGV..TEARVMTN.............KVTGRSRGYGFVNFISEDSANSAISAMNG.Q...ELNGFNISV
RU17_DROME/104-175  LFIARI......NYDTSESKLRREFE.....F.YGPI..KKIVLIHD.............QESGKPKGYAFIEYEHERDMHAAYKHADG.K...KIDSKRVLV
RU1A_HUMAN/12-84    IYINNLNE..KIKKDELKKSLYAIFS.....Q.FGQI..LDILVSR................SLKMRGQAFVIFKEVSSATNALRSMQG.F...PFYDKPMRI
RU1A_HUMAN/210-276  LFLTNL......PEETNELMLSMLFN.....Q.FPGF..KEVRLVPG..................RHDIAFVEFDNEVQAGAARDALQG.F...KITQNNAMK
RU1A_YEAST/229-293  LLIQNL......PSGTTEQLLSQILG.....N.EALV...EIRLVSV...................RNLAFVEYETVADATKIKNQLGS.T...YKLQNNDVT
RU2B_HUMAN/9-81     IYINNMND..KIKKEELKRSLYALFS.....Q.FGHV..VDIVALK................TMKMRGQAFVIFKELGSSTNALRQLQG.F...PFYGKPMRI
RU2B_HUMAN/153-220  LFLNNL......PEETNEMMLSMLFN.....Q.FPGF..KEVRLVPG..................RHDIAFVEFENDGQAGAARDALQGFK...ITPSHAMKI
SC35_CHICK/16-87    LKVDNL......TYRTSPDTLRRVFE.....K.YGRV..GDVYIPRD.............RYTKESRGFAFVRFHDKRDAEDAMDAMDG.A...VLDGRELRV
SP33_HUMAN/17-85    IYVGNL......PPDIRTKDIEDVFY.....K.YGAI..RDIDLKNR................RGGPPFAFVEFEDPRDAEDAVYGRDG.Y...DYDGYRLRV
SP33_HUMAN/122-186  VVVSGL......PPSGSWQDLKDHMR.....E.AGDV..CYADVYRD....................GTGVVEFVRKEDMTYAVRKLDN.T...KFRSHEGET
SQD_DROME/58-128    LFVGGL......SWETTEKELRDHFG.....K.YGEI..ESINVKTD.............PQTGRSRGFAFIVFTNTEAIDKVSA.ADE.H...IINSKKVDP
SQD_DROME/138-208   IFVGGL......TTEISDEEIKTYFG.....Q.FGNI..VEVEMPLD.............KQKSQRKGFCFITFDSEQVVTDLLK.TPK.Q...KIAGKEVDV
SR55_DROME/5-68     VYVGGL......PYGVRERDLERFFK.....G.YGRT..RDILIKN.....................GYGFVEFEDYRDADDAVYELNG.K...ELLGERVVV
SSB1_YEAST/39-114   IFIGNV......AHECTEDDLKQLFV.....EEFGDE..VSVEIPIK..........EHTDGHIPASKHALVKFPTKIDFDNIKENYDT.K...VVKDREIHI
SXLF_DROME/127-198  LIVNYL......PQDMTDRELYALFR.....A.IGPI..NTCRIMRD.............YKTGYSFGYAFVDFTSEMDSQRAIKVLNG.I...TVRNKRLKV
SXLF_DROME/213-285  LYVTNL......PRTITDDQLDTIFG.....K.YGSI..VQKNILRD.............KLTGRPRGVAFVRYNKREEAQEAISALNNVI...PEGGSQPLS
TIA1_HUMAN/9-78     LYVGNL......SRDVTEALILQLFS.....Q.IGPC..KNCKMIMD...............TAGNDPYCFVEFHEHRHAAAALAAMNG.R...KIMGKEVKV
TIA1_HUMAN/97-168   VFVGDL......SPQITTEDIKAAFA.....P.FGRI..SDARVVKD.............MATGKSKGYGFVSFFNKWDAENAIQQMGG.Q...WLGGRQIRT
TIA1_HUMAN/205-270  VYCGGV......TSGLTEQLMRQTFS.....P.FGQI..MEIRVFPD...................KGYSFVRFNSHESAAHAIVSVNG.T...TIEGHVVKC
TRA2_DROME/99-170   IGVFGL......NTNTSQHKVRELFN.....K.YGPI..ERIQMVID.............AQTQRSRGFCFIYFEKLSDARAAKDSCSG.I...EVDGRRIRV
U2AF_HUMAN/261-332  LFIGGL......PNYLNDDQVKELLT.....S.FGPL..KAFNLVKD.............SATGLSKGYAFCEYVDINVTDQAIAGLNG.M...QLGDKKLLV
U2AF_SCHPO/312-383  IYISNL......PLNLGEDQVVELLK.....P.FGDL..LSFQLIKN.............IADGSSKGFCFCEFKNPSDAEVAISGLDG.K...DTYGNKLHA
U2AG_HUMAN/67-142   CAVSDVEM..QEHYDEFFEEVFTEME.....EKYGEV..EEMNVCDN..............LGDHLVGNVYVKFRREEDAEKAVIDLNN.R...WFNGQPIHA
WHI3_YEAST/540-614  LYVGNL......PSDATEQELRQLFS.....G.QEGF..RRLSFRNK..........NTTSNGHSHGPMCFVEFDDVSFATRALAELYG.R...QLPRSTVSS
X16_HUMAN/12-78     VYVGNL......GNNGNKTELERAFG.....Y.YGPL..RSVWVARN..................PPGFAFVEFEDPRDAADAVRELDG.R...TLCGCRVRV
YHC4_YEAST/348-415  IFVGQL......DKETTREELNRRFS.....T.HGKI..QDINLIFK.................PTNIFAFIKYETEEAAAAALESENH.A...IFLNKTMHV
YHH5_YEAST/315-384  ILVKNL......PSDTTQEEVLDYFS.....T.IGPI..KSVFISEK...............QANTPHKAFVTYKNEEESKKAQKCLNK.T...IFKNHTIWV
YIS1_YEAST/66-136   IFVGNI......TPDVTPEQIEDHFK.....D.CGQI..KRITLLYD.............RNTGTPKGYGYIEFESPAYREKALQ.LNG.G...ELKGKKIAV
YIS5_YEAST/33-104   IYIGNL......NRELTEGDILTVFS.....E.YGVP..VDVILSRD.............ENTGESQGFAYLKYEDQRSTILAVDNLNG.F...KIGGRALKI
ARP2_PLAFA/364-438  VEVTYLF....STYLVNGQTL..IYS.....N.ISVV....LVILY........HQKFKETVLGRNSGFGFVSYDNVISAQHAIQFMNG.Y...FVNNKYLKV
CABA_MOUSE/77-147   MFVGGL......SWDTSKKDLKDYFT.....K.FGEV..VDCTIKMD.............PNTGRSRGFGFILFKDSSSVEKVLD.QKE.H...RLDGRVIDP
CABA_MOUSE/161-231  IFVGGL......NPEATEEKIREYFG.....Q.FGEI..EAIELPID.............PKLNKRRGFVFITFKEEDPVKKVLE.KKF.H...TVSGSKCEI
CPO_DROME/453-526   LFVSGL......PMDAKPRELYLLFR.....A.YEGY..EGSLLKV............TSKNGKTASPVGFVTFHTRAGAEAAKQDLQGVR...FDPDMPQTI
CST2_HUMAN/18-89    VFVGNI......PYEATEEQLKDIFS.....E.VGPV..VSFRLVYD.............RETGKPKGYGFCEYQDQETALSAMRNLNG.R...EFSGRALRV
D111_ARATH/281-360  LLLRNMVG.PGQVDDELEDEVGGECA.....K.YGTV..TRVLIFE..........ITEPNFPVHEAVRIFVQFSRPEETTKALVDLDG.R...YFGGRTVRA
ELAV_DROME/250-322  LYVSGL......PKTMTQQELEAIFA.....P.FGAI..ITSRILQN............AGNDTQTKGVGFIRFDKREEATRAIIALNG.T...TPSSCTDPI
ELAV_DROME/404-475  IFIYNL......APETEEAALWQLFG.....P.FGAV..QSVKIVKD.............PTTNQCKGYGFVSMTNYDEAAMAIRALNG.Y...TMGNRVLQV
EWS_HUMAN/363-442   IYVQGL......NDSVTLDDLADFFK.....Q.CGVV..K.MNKRTG....QPMIHIYLDKETGKPKGDATVSYEDPPTAKAAVEWFDG.K...DFQGSKLKV
GBP2_YEAST/124-193  IFVRNL......TFDCTPEDLKELFG.....T.VGEV..VEADIIT...............SKGHHRGMGTVEFTKNESVQDAISKFDG.A...LFMDRKLMV
GBP2_YEAST/221-291  VFIINL......PYSMNWQSLKDMFK.....E.CGHV..LRADVELD..............FNGFSRGFGSVIYPTEDEMIRAIDTFNG.M...EVEGRVLEV
GBP2_YEAST/351-421  IYCSNL......PFSTARSDLFDLFG.....P.IGKI..NNAELKP..............QENGQPTGVAVVEYENLVDADFCIQKLNN.Y...NYGGCSLQI
