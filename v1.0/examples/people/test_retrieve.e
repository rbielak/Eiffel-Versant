-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class TEST_RETRIEVE

inherit

	SHARED_ROOT_SERVER

creation
	make

feature
	session : expanded DB_SESSION;
	
	start_connection is
		local
			env : expanded ENVIRONMENT_VARIABLES
			db_name : STRING;
		do
			db_name := env.get ("O_DBNAME");
			if db_name = Void then
				io.putstring ("*** Could not get env %
                                              %variable O_DBNAME. Using 'rainbow' as db_name. %N");
				db_name := "rainbow";
			end;
			io.putstring ("Connecting to database: ");
			io.putstring (db_name);
			io.new_line;
			session.begin (db_name);
		end
	
	end_connection is
		do
			session.finish
		end

	
	person_man : NAMED_MAN [PERSON] is
		once
			if root_server.root_from_db (session.default_db, "ComplexPeople") = Void then
				root_server.create_new_root (session.default_db,
							     "ComplexPeople", "PERSON", 
							     "NAMED_MAN[PERSON]", 
							     "person", Void,
							     True);
			end
			Result ?= root_server.root_from_db (session.default_db, "ComplexPeople")
		end;
	
	person: PERSON;
	
	
	timer : expanded TIMER;

	make is
		do
			start_connection
			io.putstring ("Retrieving a simple object...%N");
			timer.start;
			person := person_man.get_item ("Simpleton");
			timer.stop;
			io.putstring ("Simple retrieve used ");
			io.putdouble (timer.seconds_used);
			io.putstring (" seconds of CPU time. %N");
			
			timer.start;
			person := person_man.get_item ("Complexton");
			timer.stop;
			io.putstring ("Complex retrieve used ");
			io.putdouble (timer.seconds_used);
			io.putstring (" seconds of CPU time. %N");
			session.finish;
		end;

invariant

end -- TEST_RETRIEVE
