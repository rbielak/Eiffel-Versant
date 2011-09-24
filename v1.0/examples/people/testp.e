-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class TESTP
	
inherit

	MEMORY

	SHARED_TEST_CONNECTION
	
creation

	make

feature
	
	
	junk_man: JUNK_MAN
			-- compile only 

	g: GROUP_RLIST [NAMED_MANAGEABLE]
	
	a_finder: ATTRIBUTE_FINDER
	
	other_db : DATABASE is
		do
			Result := connected_databases.item (2)
		end
	
	root_server : ROOT_SERVER is
		once
			!!Result.make
		end
	
	
	feed_man is
		local
			root : PERSISTENCY_ROOT [POBJECT]

		do
			if (root_server.root_by_name ("People") = Void) then
				root_server.create_new_root (session.session_database,
											 "People", "PERSON", 
											 "NAMED_MAN[PERSON]", 
											 "person", Void,
											 True);
			end
			if root_server.root_from_db (session.session_database, "Others") = Void then
				root_server.create_new_root (session.session_database,
							     "Others", "PERSON", 
							     "NAMED_MAN[PERSON]", Void,
							     Void, True);
			end
			if root_server.root_from_db (other_db, "OtherPeople") = Void then
				root_server.create_new_root (other_db,
							     "OtherPeople", "PERSON", 
							     "NAMED_MAN[PERSON]", "person", 
							     Void, True);
			end
		end

	pl : PLIST_LOCK;
	

	person_man : NAMED_MAN [PERSON] is
		once
			--			Result ?= root_server.root_from_db (session.default_db, "People")
--			Result ?= root_server.root_by_name ("People")
			Result ?= root_server.root_group_by_names ("People", "PERSON", 
													   <<"People", "Tribes">>)
		end;
	
	other_db_man : NAMED_MAN [PERSON] is
		once
			--			Result ?= root_server.root_from_db (other_db, "OtherPeople")
			Result ?= root_server.root_group_by_names ("OtherPeople", "PERSON", 
													   <<"OtherPeople">>)
		end
	
	others : NAMED_MAN [PERSON] is
		once
			Result ?= root_server.root_from_db (session.session_database, "Others")
		end
	
	
	all_people : NAMED_MAN [PERSON] is
		once
			Result ?= root_server.root_group_by_names ("People", "PERSON",
													   <<"People", "Others", "OtherPeople">>)
--			!!Result.init (<<person_man, other_db_man, others>>)
--			Result.set_add_target (person_man)
		end

	sr : SIMPLE_MAN [PERSON]
			-- here just for catching compilation changes
		
	
	pai : PARRAY_INTEGER;
	pad : PARRAY_DOUBLE;
	
	pls : PLIST_STRING;
	ll : PLIST_OBJ[PERSON];
	pli : PLIST_INTEGER;
	
	
	proots : PERSISTENT_ROOTS;

	rights_list : ROOT_RIGHTS_SET
	
	db_rights_set : DATABASE_RIGHTS_SET
	
	set_up_rights is
		local
			right : ROOT_RIGHTS
			db_rights : DATABASE_RIGHTS
		do
			!!rights_list.make
			!!right.make ("*", False, False, False, False, False, 100);
			rights_list.add_rights (right);
			!!right.make ("People", True, True, True, True, True, 1)
			rights_list.add_rights (right);
			!!right.make ("Others", True, True, True, True, True, 2)
			rights_list.add_rights (right);
			
			!!db_rights.make ("people*");
			db_rights.set_rights (rights_list);
			!!db_rights_set.make
			db_rights_set.append_database_rights (db_rights)
			
			!!rights_list.make
			!!right.make ("*", True, True, True, True, True, 100);
			rights_list.add_rights (right);
			!!right.make ("People", True, True, True, True, True, 10);
			rights_list.add_rights (right);

			!!db_rights.make ("testdb");
			db_rights.set_rights (rights_list);
			db_rights_set.append_database_rights (db_rights)
			db_rights_set.store

			!!proots
			proots.set_rights_list (db_rights_set);
		end
	
	last_person : PERSON;
	last_spouse : PERSON;
	last_child : PERSON;
	
	put_others is
		local
			p : PERSON
			c : PERSON
		do
			!!p.make ("Weirdo", 102);
			!!c.make ("Weirder", 5);
			p.add_child (c, 1)
			others.extend (p);
			person_man.transfer_element (p, others)
		end
	
	add_person is
		local
			pname : STRING;
			man : NAMED_MAN [PERSON]
		do
			man ?= root_server.root_by_name ("People");
			io.putstring ("Enter first name :");
			io.readline;
			io.putstring ("Enter age: ");
			io.readint;
			!!last_person.make (io.laststring, io.lastint);
			last_person.set_lucky_numbers (1.2, 2.4, 0.000010);
			session.start_transaction
			if all_people.has_item (last_person.name) then
				io.putstring ("Person already there....%N")
			else
				-- person_man.put (last_person);
				all_people.extend (last_person);
				if person_man.has (last_person) then
					io.putstring ("ADded OK....%N");
				end
			end
			session.end_transaction
			last_person.display;
		end;
	
	retrieve_person : PERSON is
		local
			st: STAMPED;
		do
			io.putstring ("Enter first name :");
			io.readline;			
			if all_people.has_item (io.laststring) then
				Result := all_people.get_item (io.laststring) 
			else
				io.putstring ("No such person %N");
			end
			if Result /= Void then
				io.putstring ("Found this person...%N");
				Result.display;
			end
		end;
	
	add_child is 
		local
			parent : PERSON;
			child : PERSON;
		do
			io.putstring ("First find a parent. %N");
			parent := retrieve_person;
			if parent /= Void then
				io.putstring("Enter child's name: ");
				io.readline;
				if person_man.has_item (io.laststring) then
					child := person_man.get_item (io.laststring)
				elseif others.has_item (io.last_string) then
					child := others.get_item (io.laststring);
				elseif other_db_man.has_item (io.last_string) then
					child := other_db_man.get_item (io.laststring);
				else
					io.putstring ("Creating new child.%N")
					io.putstring ("Enter child's age: ");
					io.readint;
					!!child.make (clone(io.laststring), io.lastint);
					person_man.extend (child);
				end;
				io.putstring ("Enter child's number: ");
				io.readint;
				parent.add_child (child, io.lastint);
				parent.relatives.put(child, io.lastint)
				parent.store_difference
				-- person_man.update (parent)
				
			end;
		end;

	
	add_spouse is
		local
			person, spouse : PERSON;
		do
			person := retrieve_person;
			if person /= Void then
				io.putstring ("Let's get a spouse%N");
				spouse := retrieve_person
				if spouse = Void then
					io.putstring ("Enter name of new spouse:")
					io.readline;
					io.putstring ("Enter spouse's age: ");
					io.readint;
					!!spouse.make (clone (io.laststring), io.lastint);
					person_man.extend (spouse);
				end;
				person.set_spouse (spouse);
				person.store;
			end;
		end;
	
	add_name is
		local
			person : PERSON;
		do
			person := retrieve_person;
			if person /= Void then
				io.putstring ("Enter another name: ");
				io.readline;
				person.names.extend (io.laststring);
				--person.store;
			end
		end;

	remove_child is
		local 
			person : PERSON;
		do
			person := retrieve_person
			if person /= Void then
				if person.children.count > 0 then
					io.putstring ("Removing the first child...%N");
					person.children.remove_i_th (1);
					person.store;
				end
			end
		end;

	remove_person is
		local
			person: PERSON
			man: NAMED_MAN [PERSON]
		do
			person := retrieve_person
			if person  /= Void then
				man ?= root_server.root_by_id (person.pobject_root_id)
				man.remove_item (person)
				print ("Removed... %N")
				
			else
				print ("Person doesn't exist%N")
			end
		end

	
	add_friend is
		local
			guy1, guy2 : PERSON
		do
			io.putstring ("Get one person...%N");
			guy1 := retrieve_person;
			io.putstring ("Get another person...%N");
			guy2 := retrieve_person;
			if (guy1 /= Void) and (guy2 /= Void) then
				guy1.friends.extend (guy2);
				guy1.fiddle_flags;
				guy2.fiddle_flags
				guy1.store_difference;
			else
				io.putstring ("One of the people doesn't exists....%N")
			end
			
		end

	change_password is
		local
			person : PERSON
		do
			person := retrieve_person;
			if person /= Void then
				io.putstring ("E)rase password N)ew password: ");
				io.readline;	
				inspect io.laststring.item(1)
				when 'e', 'E' then
					-- person.set_password (Void);
					person.set_password ("")
				when 'n', 'N' then
					io.putstring ("Enter new password: ");
					io.readline;
					person.set_password (io.laststring);
				end;
				person.store_shallow;
			end;
		end;
	
	
	test_abort is
		do
			session.start_transaction
			io.put_string ("Add first child%N")
			add_child
			io.putstring ("**** ABORT Transaction ***%N")
			session.abort_transaction
		end

	print_list (list : PLIST [PERSON]) is
		local
			i : INTEGER
		do
		
			from i := 1
			until i > list.count
			loop
				io.putstring ("**************************%N");
				list.i_th(i).display;
				i := i + 1
			end
		end
	
	
	migrate is
		local
			one, pclone : PERSON
		do
			io.putstring ("Enter person to migrate: ")
			one := retrieve_person
			-- for now keep in one db
			other_db_man.contents.import (one, person_man.contents)
			-- There is a problem here, as the MAN will
			-- still keep the reference to the old object.
			-- This is because we manipulate contents
			-- directly here
			io.putstring ("All done....%N");
		end
	
	divorce is
		local
			person : PERSON;
		do
			person := retrieve_person;
			if person /= Void then
				person.divorce;
				person.store;
			end;
		end;
	
	add_best_friend is
		local
			p1, f1 : PERSON
		do
			p1 := retrieve_person
			io.putstring ("Get best friend...");
			f1 := retrieve_person
			p1.set_best_friend (f1)
			p1.store_difference
		end
	
	test_store_new is
		local
			p1, p2, p3: PERSON
		do
			io.putstring ("First person. ")
			p1 := retrieve_person
			io.putstring ("Second person. ")
			p2 := retrieve_person
			if p2 = Void then
				p2 := other_db_man.get_item (io.laststring)
			end
			p1.friends.extend (p2)
			-- create new guy
			!!p3.make ("bozo", 100)
			p2.friends.extend (p3)
		--	p1.store_new
			p1.store_difference
		end


	query1 : SELECT_QUERY[PERSON] is
		once
			!!Result.make ("name = $1 and spouse.name = $2");
--			Result.set_evaluation_in_client
		end;
	
	
	query2 :SELECT_QUERY[PERSON] is
		once
			!!Result.make ("name = $1 and children[0] = $2");
		end
	
	query3 : SELECT_QUERY [PERSON] is
		once
			!!Result.make ("age > $1");
		end;
	
	query4 : SELECT_QUERY [PERSON] is
		once
			!!Result.make ("married = False");
		end;
	
	query5 : SELECT_QUERY [PERSON] is
		once
			!!Result.make("");
			Result.set_sorting_criteria (<<"age", "name">>);
		end;
	
	query6 : SELECT_QUERY [PERSON] is
		once
			!!Result.make("married = True");
			Result.set_sorting_criteria (<<"age", "spouse.name">>);
		end;
	
	query7 :  SELECT_QUERY [PERSON] is
		once
			!!Result.make ("name like $1");
		end;
	
	query8 :  SELECT_QUERY [PERSON] is
		once
			!!Result.make ("spouse = $1");
		end;
	
	query9 : SELECT_QUERY [PERSON] is
		once
			!!Result.make ("password = $1");
		end;
	
	query11 : SELECT_QUERY [PERSON] is
		once
			!!Result.make ("children /= $1");
		end;
	
	query12 : SELECT_QUERY [PERSON] is
			-- FInd parents of one person
		once
			!!Result.make ("(children /= $1) and ($2 in children)");
		end;

	query13 : SELECT_QUERY [PERSON] is
		once
			!!Result.make ("password >= $1");
		end;
	
	query14 : SELECT_QUERY [PERSON] is
		once
			!!Result.make ("password > $1");
		end;
	
	query15 : SELECT_QUERY [PERSON] is
		once
			!!Result.make ("password <= $1");
		end;
	
	query16 : SELECT_QUERY [PERSON] is
		once
			!!Result.make ("password < $1");
		end;
	
	query17 : SELECT_QUERY [PERSON] is
		once
			!!Result.make ("password = $1");
		end;
	
	query18 : SELECT_QUERY[PERSON] is
		once
			!!Result.make ("age > -25 and age < +40");
		end;
 
	query19 : SELECT_QUERY[PERSON] is
		once
			!!Result.make ("name = $1 and children[0].spouse.children[1].name = $2"
);
		end
	
	query20: SELECT_QUERY [PERSON] is
		once
			-- OK --!!Result.make ("(spouse /= $1) and ((spouse.name = $2)")
			-- OK --!!Result.make ("(spouse /= $1) and (spouse.name = %"kitty%")")
		--	!!Result.make ("(best_friend = $1) and (spouse /= $2) and (spouse.name = $3)")
			-- OK -- !!Result.make ("(best_friend /= $1) and (best_friend.name = $2)")
			-- OK --!!Result.make ("(best_friend /= $1) and (best_friend.age > $2)")
			-- OK --!!Result.make ("(spouse /= $1) and (spouse.age > $2)")
			-- OK -- !!Result.make ("(best_friend = $1) and (best_friend.spouse.age < $2)")
			-- OK --!!Result.make ("(best_friend /= $1) and (best_friend.married = True)")
			-- OK -- !!Result.make ("(best_friend = $1) and (spouse.best_friend = $2)")
			-- !!Result.make ("(best_friend = $1) and (spouse.best_friend.age > 10)")
			-- !!Result.make ("(children /= $1) and (children[0].age > $2)")
			!!Result.make ("spouse = $1")
		end

	timer : SIMPLE_TIMER;
	
	
	results_list : PLIST[PERSON];

	queries is
		local
			name, spouse_name : STRING;
			query_result : PLIST[PERSON];
			child, person, person2 : PERSON;
		do
			io.putstring ("Enter a number of the query: ");
			io.readint;
			timer.start;
			inspect io.lastint
			when 1 then
				io.putstring ("Enter person's name: ");
				io.readline;
				name := clone (io.laststring);
				io.putstring ("Enter spouse's name: ");
				io.readline;
				spouse_name := clone (io.laststring);
				query1.execute (person_man.contents,
						<<name, spouse_name>>);
				query_result := query1.last_result;
			when 2 then
				io.putstring ("First let's find a child....%N");
				child := retrieve_person;
				io.putstring ("Enter name: ");
				io.readline;
				query2.execute (person_man.contents,
						<<io.laststring, child>>);
				query_result := query2.last_result;
			when 3 then
				io.putstring ("Enter age: ");
				io.readint;
				query3.execute (person_man.contents, <<io.lastint>>);
				query_result := query3.last_result;
			when 4 then
				io.putstring ("Getting all unmarried people. %N");
				query4.execute (person_man.contents, Void);
				query_result := query4.last_result;
			when 5 then
				io.putstring ("Getting all sorting by %
                                              %age and name. %N");
				query5.execute (person_man.contents, Void);
				query_result := query5.last_result;				
			when 6 then
				io.putstring ("Getting all married people and sorting by %
                                              %age and spouses name. %N");
				query6.execute (person_man.contents, Void);
				query_result := query6.last_result;				
			when 7 then
				io.putstring ("Wildcard matching query %N");
				query7.execute (person_man.contents, << "*r*">>);
				query_result := query7.last_result; 
			when 8 then
				person := retrieve_person;
				query8.execute (person_man.contents, <<person>>);
				query_result := query8.last_result; 				
			when 9 then
				io.putstring ("Enter password: ");
				io.readline;
				query9.execute (person_man.contents, <<io.laststring>>);
				query_result := query9.last_result;
			when 10 then
				io.putstring ("Quering with Void string....%N");
				query9.execute (person_man.contents, <<Void>>);
				query_result := query9.last_result;
			when 11 then
				io.putstring ("Quering for people with children...%N");
				query11.execute (person_man.contents, <<Void>>);
				query_result := query11.last_result;
			when 12 then
				io.putstring ("Finding parents of this person...%N");
				person := retrieve_person;
				query12.execute (person_man.contents, <<Void, person>>);
				query_result := query12.last_result;
			when 13 then
				io.putstring ("Quering with >= Void string....%N");
				query13.execute (person_man.contents, <<Void>>);
				query_result := query13.last_result;
			when 14 then
				io.putstring ("Quering with > Void string....%N");
				query14.execute (person_man.contents, <<Void>>);
				query_result := query14.last_result;
			when 15 then
				io.putstring ("Quering with <= Void string....%N");
				query15.execute (person_man.contents, <<Void>>);
				query_result := query15.last_result;
			when 16 then
				io.putstring ("Quering with < Void string....%N");
				query16.execute (person_man.contents, <<Void>>);
				query_result := query16.last_result;
			when 17 then
				io.putstring ("Quering with = Void string....%N");
				query17.execute (person_man.contents, <<Void>>);
				query_result := query17.last_result;
			when 18 then
				io.putstring ("Quering with age and signed constant....%N");
--				query18.dump_parser
				query18.execute (person_man.contents, <<Void>>);
				query_result := query18.last_result;
			when 19 then
				io.putstring ("Quering with complex [] string....%N");
--				query19.dump_parser
				query19.execute (person_man.contents, <<"rob", "am">>);
				query_result := query19.last_result;
			when 20 then
				io.putstring ("Get a person....%N")
				person := retrieve_person
				--				person2 := retrieve_person
				io.putstring ("**** QUERY 20 *****...%N")
				query20.execute (person_man.contents, <<person>>)
				query_result := query20.last_result
			else
				io.putstring ("Not a valid choice%N");
			end;
			timer.stop;
			if query_result /= Void then
				io.putstring ("******* ");
				io.putint (query_result.count);
				io.putstring (" objects were retrieved. *******%N");
				print_list (query_result);
--				if results_list.count = 0 then
--					results_list.append_list (query_result);
--				else
--					results_list.difference_with (query_result);
--				end
			else
				io.putstring ("Nothing found...%N");
			end;
			io.putstring (">>> Query took: ");
			io.putdouble (timer.seconds_used);
			io.putstring (" seconds. %N");
			io.putstring (">>> Results_list has ");
			io.putint (results_list.count);
			io.putstring (" elements. %N");
		end;
	
	
	
	diff : LIST [POBJECT];
	
	make_random_changes is
		local
			p1, p2 : PERSON;
		do
			session.start_transaction
			p1 := person_man.i_th(1); 
			if p1 /= Void then
				p2 := person_man.i_th (2);
				p1.friends.extend (p2);
			end;
			!!p1.make ("bar", 1);
			p2.add_child (p1, 1);
			session.end_transaction
			!!p1.make ("generic_spouse", 1);
			p2.set_spouse (p1);
		end;
	
	print_class_class_id (db : DATABASE) is
		do
			io.putstring ("--> class_id of 'class' in db <");
			io.putstring (db.name)
			io.putstring ("> is : ");
			io.putint (db.find_class_id ("class"))
			io.new_line
		end
	
	test_store_new_multi_db is
			-- Test store_new with many databases
		local
			troop: TROOP
			p: PERSON
		do
			!!troop.make (1,5)
			!!p.make ("Scount", 10)
	--		p.store_new
			troop.put (p, 1);
			!!p.make ("The Leader", 23)
			troop.set_leader (p)
			io.putstring ("Before store new ....%N")
			-- troop.store_new
			session.set_current_database (other_db)
			io.putstring ("before store_diff %N")
			troop.store_difference
		end
	
	lock_twice is
		local
			p: PERSON
		do
			p := retrieve_person
			if p /= Void then
				p.write_lock_twice
			end
		end
	
	test_multi_man_key is
		local
			p1, p2: PERSON
		do
			p1 := person_man.get_item ("richie")
			p2 := other_db_man.get_item ("kitty")
			if p2 = Void then
				!!p2.make ("kitty", 33)
				others.extend (p2)
			end
			p1.set_best_friend (p2)
			p1.store_difference
		end
	
	test_migrate is
			-- move a root between databases
		
		do
			io.putstring ("Trying top move People to other db%N")
			other_db.migrate (person_man)
		end
	
	
	add_many_people is
		local
			i, index: INTEGER
			p: PERSON
			name: STRING
		do
			index := person_man.count
			session.start_transaction
			print ("starting transaction ...%N")
			from i := 1
			until i > 1000
			loop
				name := "person_"
				name.append (index.out)
				name.append (i.out)
				!!p.make (name, i)
				person_man.extend (p)
				if (i \\ 50 = 0) then
					session.end_transaction
--					print ("Sleeping....%N")
--					sleep (10)
					print ("starting transaction ...%N")
					session.start_transaction
				end
				i := i + 1
			end
			if	session.in_transaction then		
				session.end_transaction
			end
		end

	test_path_query is
			-- test query with path that goes across two databases
		local
			query: SELECT_QUERY [PERSON]
		do
			!!query.make ("best_friend.spouse.name = $1")
			print ("Starting query... %N")
			query.execute (person_man.contents, <<"henry">>)
			print ("Query done found ")
			if query.last_result /= Void then
				print (query.last_result.count)
				print (" items %N")
				query.last_result.i_th (1).dump
			else
				print ("0  %N")
			end

			
		end

	test_segmented_plist is
		local
			m, w: MARTIAN
			i, count: INTEGER
			name: STRING
		do
			if not all_people.has_item ("lots_of_wives") then
				print ("Adding two martians with lots of relatives %N")
				session.start_transaction
				!!m.make ("lots_of_wives", 1000)
				person_man.extend (m)
				timer.start
				-- add lots of wives
				from i := 1 
				until i > 10000
				loop
					name := "wife_"
					name.append (i.out)
					!!w.make (name, i)
					m.wives.extend (w)
					i := i + 1
				end
				m.store_difference
				timer.stop
				print ("Done wives: ")
				timer.print_time
				!!m.make ("lots_of_kids", 100)
				session.end_transaction
				session.start_transaction
				person_man.extend (m)	
				-- add lots of wives
				timer.start
				from i := 1 
				until i > 10000
				loop
					name := "kid_"
					name.append (i.out)
					!!w.make (name, i)
					m.offsprings.extend (w)
					i := i + 1
				end
				m.store_difference
				timer.stop
				session.end_transaction
				print ("Done kids: ")
				timer.print_time
				print ("All done %N")
			else
				print ("Already in there... testing timing...%N")
				print ("How many siblings to add?: ")
				io.readint
				count := io.lastint
				
				m ?= all_people.get_item ("lots_of_wives")
				print ("wives.count=")
				print (m.wives.count)
				print ("%N")
				timer.start
				session.start_transaction
				from i := 1
				until i > count
				loop
					!!w.make ("wife_xxx", 2001)
					m.wives.extend (w)
					i := i + 1
				end
				print ("Doing store diff and commit %N")
				m.store_difference		
				session.end_transaction
				timer.stop
				print ("Time to add a wives:")
				timer.print_time

				m ?= all_people.get_item ("lots_of_kids")
				print ("kids.count=")
				print (m.offsprings.count)
				print ("%N")

				timer.start
				session.start_transaction
				from i := 1
				until i > count
				loop
					!!w.make ("kid_xxxx", 1)
					m.offsprings.extend (w)
					i := i + 1
				end
				print ("Doing store diff and commit %N")
				m.store_difference
				session.end_transaction
				timer.stop
				print ("Time to add kids:")
				timer.print_time
			end
		end

	test_append_array is
		local
			p, c1, c2: PERSON
		do
			p := retrieve_person
			!!c1.make ("child1", 10)
			!!c2.make ("child2", 30)
			p.add_children (<<c1, c2>>)
			print ("Finished %N")
		end

	make is
		local
			finished : BOOLEAN;
			database : DATABASE
		do
			!!results_list.make ("PLIST[PERSON]");;
			!!timer;
			start_connection;
			
			feed_man;
			set_up_rights
			
			from
			until finished
			loop
				io.putstring ("A)dd R)etrieve C)hild S)pouse K)ill person D)elete child)%
                                              % F)riend Q)euery N)ame P)assword dI)vorce M)%
                                              %igrate B)est friend eX)it: ");
				io.readline;
				inspect io.laststring.item(1)
				when 'a', 'A' then
					add_person;
				when 'R', 'r' then
					last_person := retrieve_person;
				when 'k', 'K' then
					remove_person
				when 's', 'S' then
					add_spouse
				when 'x', 'X' then
					finished := True
				when 'c', 'C' then
					add_child;
				when 'd', 'D'  then
					remove_child
				when 'n', 'N' then
					add_name
				when 'q', 'Q' then
					queries
				when 'p', 'P' then
					change_password
				when 'i', 'I' then
					divorce
				when 'f', 'F' then
					add_friend
				when 'm', 'M' then
					migrate
				when 't', 'T' then
					-- test_store_new
					-- test_abort
					-- add_many_people
					-- test_migrate
					-- test_path_query
					-- test_segmented_plist
					test_append_array
				when 'b', 'B' then
					add_best_friend
				else
					io.putstring ("Bad choice. Try again...%N");
				end; -- inspect
			end; -- loop
			-- make_random_changes;
			-- test_multi_man_key
			diff := proots.check_all;
			if diff /= Void then
				io.putstring ("Found ");
				io.putint (diff.count);
				io.putstring (" different objects....%N");
				if diff.count > 0 then
					proots.store_differences
				end
			end
			io.putstring ("Database cache used: ")
			io.putint (session.database_cache_in_use)
			io.putstring ("K %N")
			end_connection;
		rescue
			io.putstring ("Exception. Last error=");
			io.putint (session.last_error);
			io.new_line;
			if session.active then
				if session.in_transaction then
					session.abort_transaction
				end
				session.finish;
			end;
		end;

feature { NONE}

--	sleep (time: INTEGER) is
--		external "C"
--		end
	
invariant

end -- TESTP
