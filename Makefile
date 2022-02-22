all:
	rm -rf */*.beam *~ */*~ test/*.beam;
	rm -rf _build;
	echo DONE
unit_test:
	rm -rf */*.beam *~ */*~ *.dump *.html;
	cp priv/*.html ebin;
#	common
	erlc -o ebin ../common/src/appfile.erl;
#	test
	cp test_src/*.app test_ebin;
	erlc -o test_ebin test_src/*.erl;
#	service
	cp src/*.app ebin;
	erlc -o ebin src/*.erl;
	cp deps/cowboy/ebin/* ebin;
	cp deps/cowlib/ebin/* ebin;
	cp deps/ranch/ebin/* ebin;
	erl -pa ebin -pa test_ebin\
	    -setcookie cookie\
	    -sname test\
	    -unit_test monitor_node test\
	    -unit_test cluster_id test\
	    -unit_test cookie cookie\
	    -run unit_test start_test test_src/test.config
