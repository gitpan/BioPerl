# testing Bio::DB::HIV
#$Id: HIV.t 232 2008-12-11 14:51:51Z maj $#
use strict;
use warnings;

BEGIN {
    use Bio::Root::Test;
    test_begin(
        -tests => 29,
        -requires_modules => [qw( XML::Simple HTTP::Request::Common)],
	);
    use_ok('Bio::DB::HIV');
    use_ok('Bio::DB::WebDBSeqI');
    use_ok('Bio::DB::HIV::HIVAnnotProcessor');
}

my $tobj= Bio::DB::HIV->new();

$tobj->ua->timeout(90);

#object tests
isa_ok($tobj, 'Bio::DB::HIV');

#compliance tests
isa_ok($tobj, 'Bio::Root::Root');
can_ok($tobj, qw( get_request postprocess_data ));

#methods
can_ok($tobj, qw( get_seq_stream get_Stream_by_acc get_Stream_by_query _request ));

#internals
can_ok($tobj, qw( lanl_base map_db make_search_if search_ _map_db_uri _make_search_if_uri _search_uri _session_id _sorry ));

# defaults tests
ok($tobj->lanl_base, 'lanl_base set in default object');
ok($tobj->map_db, 'map_db set in default object');
ok($tobj->make_search_if, 'make_search_if set in default object');
ok($tobj->search_, 'search_ set in default object');
ok($tobj->url_base_address, 'url_base_address set in default object');
is(($tobj->request_format)[0], "fasta", 'default sequence request format (fasta)');

#todos
throws_ok { $tobj->get_request('mode'=>'version', 'uids'=>['K03455.1']) } qr/Bio::HIVSorry::Exception/, 'sorry till implemented';

throws_ok {$tobj->get_request('mode'=>'gi', 'uids'=>['1906382'])} qr/Bio::HIVSorry::Exception/, 'sorry till implemented';

#exception tests
my $badq = bless({}, "Not::A::Query");
throws_ok {$tobj->get_Stream_by_query($badq)} qr/HIVQuery required/, 'HIVQuery type exception check';

# network tests
SKIP: {
    test_skip(-tests => 12,
          -requires_networking => 1);
    
    # WebDBSeqI compliance-
    # (this requires network access, since request is built after establishing
    # the LANL session...)
    my $req;
    eval {$req = $tobj->get_request('mode'=>'single','uids'=>['17756'])};
    if ($@) {
        diag("Error: $@");
        skip("Network problems, skipping all tests: $@", 12)
    }
    isa_ok($req, 'HTTP::Request', 'Object returned from get_request');
    # get_... functionality
    ok($tobj->get_Seq_by_id('17756'), 'get HXB2 by LANL id');
    ok($tobj->get_Seq_by_acc('K03455'), 'get HXB2 by GB accession');
    my ($seqio, $hxb2);
    ok($seqio = $tobj->get_Stream_by_id(['17756']), 'get HXB2 in a stream');
    ok($seqio = $tobj->get_Stream_by_acc(['K03455']), 'get HXB2 in a stream by accession');
    $hxb2 =  $seqio->next_seq;
    is($hxb2->primary_id, 'K03455', 'checking returned stream');
    is($hxb2->alphabet,'dna', 'checking returned stream');
    ok(!($hxb2->seq !~ /atgc/i), 'checking returned sequence');
    #network exceptions
    
    # bad id exception
    throws_ok { $tobj->get_Seq_by_id('XXXXXX') } qr/no sequences found/i, 'bad id exception check';
    # session id exception
    $tobj->_session_id('555-1212');
    throws_ok {$tobj->get_Seq_by_id('17756')} qr/request failed/, 'bad session exception check';
    # bad url exception
    $tobj->_session_id('');
    $tobj->map_db('');
    $tobj->url_base_address('http://socrates_jones_et_cie.us');
    throws_ok {$tobj->get_Seq_by_id('17756')} qr/Connect failed/, 'bad url exception check';
    # wrong url exception 
    $tobj->url_base_address('http://fortinbras.us');
    throws_ok {$tobj->get_Seq_by_id('17756')} qr/Session not established/, 'wrong url exception check';
    
# check ..._by_query functions in HIVQuery.t
}


