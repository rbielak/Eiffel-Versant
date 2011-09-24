-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- test storing of objects
--

class TEST_STORE
	
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

	
	simple_person : PERSON;
	
	make_simple is
		local
			friend : PERSON;
		do
			!!simple_person.make ("Simpleton", 101);
			-- add some friends
			!!friend.make ("friend1", 12);
			simple_person.friends.add_item (friend);
			!!friend.make ("friend2", 12);
			simple_person.friends.add_item (friend);
		end;	

	complex_person : PERSON;
	
	make_complex is 
		local
			other : PERSON;
			friend : PERSON;
			i : INTEGER;
		do
			!!complex_person.make ("Complexton", 50);
			!!other.make ("complex_spouce", 18);
			complex_person.set_spouse (other);
			-- now add some children
			from i := 1 
			until i > 50
			loop
				!!other.make (i.out, i);
				other.names.append ("complexton jr.");
				other.set_password ("rainbow");
				complex_person.add_child (other, i);
				i := i + 1
			end;
			-- now add some relatives
			from i := 100
			until i > 200
			loop
				!!other.make (i.out, 44);
				complex_person.relatives.append (other);
				other.relatives.append (complex_person);
				other.relatives.append (complex_person.spouse);
				complex_person.spouse.relatives.append (other);
				i := i + 1
			end;
		end;
	
	timer : expanded TIMER;

	make is
		do
			start_connection
			io.putstring ("Testing store...%N");
			io.putstring ("Creating simple object...%N");
			make_simple;
--			io.putstring ("Storing simple object...%N");
--			timer.start;
--			simple_person.store;
--			timer.stop;
			io.putstring ("Simple store used ");
			io.putdouble (timer.seconds_used);
			io.putstring (" seconds of CPU time. %N");
			person_man.put (simple_person);
			io.putstring ("Creating complex object...%N");
			make_complex;
			io.putstring ("Storing complex object...%N"); 
			timer.start;
			complex_person.store;
			timer.stop;
			io.putstring ("Simple store used ");
			io.putdouble (timer.seconds_used);
			io.putstring (" seconds of CPU time. %N");
			person_man.put (complex_person);
			session.finish;
		end;

invariant

end -- TEST_STORE
