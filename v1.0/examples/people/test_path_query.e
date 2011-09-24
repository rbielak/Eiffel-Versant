-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class TEST_PATH_QUERY

inherit
	
	SHARED_ROOT_SERVER
	SHARED_TEST_CONNECTION

creation
	
	make

feature
	
	
	q1: IN_MEMORY_QUERY
	q2: IN_DB_PATH_QUERY
	
	
	c_query: CLASS_SELECT_QUERY [PERSON] is
		once
			!!Result.make ("(age < 10) and not (children[0].name = $1)")
			-- !!Result.make ("(name >= $1)")
			Result.set_class_name ("person")
			Result.set_database (session.current_database)
		end
	
	plist_query: DB_PLIST_PATH_QUERY [PERSON]

	pb: DB_QUERY_PREDICATE_BLOCK is
		once
			!!Result.make_as_or;
			Result.add_predicate_term (pt1)
			--			Result.add_predicate_term (pt2)
		end
	
	pt1: DB_STRING_PREDICATE is
		once
			!!Result.make ("name", "steve")
		end

	pt2: DB_STRING_PREDICATE is
		once
			!!Result.make ("name", "jayne")
		end
	
	
	person_man : NAMED_MAN [PERSON] is
		once
			Result ?= root_server.root_from_db (session.default_db, "People")
		end;
	
	
	qr: PLIST [PERSON]
	
	
	check_results (list1, list2 : PLIST[PERSON]) is
		local
			i: INTEGER
			diff_found: BOOLEAN
		do
			if (list1 /= Void) and (list2 /= Void) then
				if list1.count /= list2.count then
					io.putstring ("Counts differ!!! %N")
					io.putstring ("Count 1=")
					io.putint (list1.count)
					io.putstring ("  Count 2=")
					io.putint (list2.count)
					dump_list (list1)
				else
					from i := 1
					until i > list1.count
					loop
						if list1.i_th_object_id (i) /= list2.i_th_object_id (i) then
							io.putstring (" Contents differ!!!%N")
							diff_found := True
						end
						i := i + 1
					end
					if not diff_found then
						io.putstring ("Results of two queries the same. %N")
					else
						io.putstring ("Contents is different!!!! %N")
						dump_list (list1)
					end
				end
			else
				if list1 /= list2 then
					io.putstring ("One list is Void %N")
				else
					io.putstring ("Result same: both lists Void %N")
				end
			end
		end
	
	dump_list (a_list: PLIST[PERSON]) is
		local
			i: INTEGER
		do
			io.putstring ("--> Dumping ")
			io.putint (a_list.count)
			io.putstring (" items....%N")
			from i := 1
			until i > a_list.count
			loop
				a_list.i_th (i).display
				i := i + 1
			end
		end
	
	run_query is
		do
			--			sq.execute (person_man.contents, <<"chris">>)
			c_query.execute (<<"steve">>)
		end
		
	last_person: PERSON

	sq : SELECT_QUERY [PERSON] is
		once
--			!!Result.make ("children[0].name = $1")
--			!!Result.make ("name = $1")
			--			!!Result.make ("(spouse.name = $1) or (age > $2)")
			!!Result.make ("(age < 10) and not (children[0].name = $1)")
		end
	
	
	test_query_in_a_transaction is
		local
			p1, p2: PERSON
			query: SELECT_QUERY [PERSON]
		do
			session.start_transaction
			!!p1.make ("mark", 30)
			!!p2.make ("mork", 21)
			p1.set_spouse (p2)
			person_man.add_item (p1)
			!!query.make ("spouse.name = $1")
			query.execute (person_man.contents, <<"mork">>)
			if query.last_result /= Void then
				io.putstring ("---> Result of the query....%N")
				dump_list (query.last_result)
			end
			session.end_transaction
		end
	

	make is
		local
			i: INTEGER
			db: DATABASE
		do
			start_connection
			!!db.make ("testdb@sioux")
			db.connect
--			!!query.make; -- ("person")
--			query.set_predicate_block (pb)
--			query.set_list_to_query (person_man.contents)
--			query.execute
			--			qr := query.last_result
--			test_query_in_a_transaction
			io.putstring ("First query....%N")
			run_query
			--			qr := sq.last_result
			qr := c_query.last_result
			if qr /= Void then
				dump_list (qr)
			else
				io.putstring ("No objects found....%N")
			end
			-- Do the query again and make sure the
			-- results equal
--			io.putstring ("Second query....%N")
--			last_person := person_man.get_item ("richie")

--			run_query
--			if sq.last_result /= Void then
--				dump_list (sq.last_result)
--			end
			
--			check_results (sq.last_result, qr)
			end_connection
		end
	

invariant

end -- TEST_PATH_QUERY
