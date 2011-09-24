-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class TEST_STORE_DIFFS

inherit
	
	SHARED_TEST_CONNECTION

creation
	
	make

feature

	root_server: ROOT_SERVER is
		once
			!!Result.make
		end
	
	person_man : NAMED_MAN [PERSON] is
		once
			Result ?= root_server.root_from_db (session.default_db, "People")
		end;
	
	proots: PERSISTENT_ROOTS is
		once
			!!Result
		end
	
	random_person: PERSON
	
	make is
		do
			start_connection
			
			random_person := person_man.i_th (1)
			if random_person = Void then
				io.putstring ("No person found, can't perform tests %N")
			else
				io.putstring ("Random person is: ")
				io.putstring (random_person.name)
				io.new_line
				test_pobject
				proots.store_differences
				verify_store

				test_plist
				proots.store_differences
				verify_store

				test_plist_double
				proots.store_differences
				verify_store

				test_plist_integer
				proots.store_differences
				verify_store

				test_parray
				proots.store_differences 
				verify_store

				test_parray_boolean
				proots.store_differences
				verify_store

				test_parray_integer
				proots.store_differences
				verify_store

				test_plist_obj
				proots.store_differences
				verify_store
			end

			end_connection
		end
	
	verify_store is
		local
			diff: LIST[POBJECT]
		do
			diff := proots.check_all
			if diff.count > 0 then
				io.putstring ("***** PROBLEM *****%N")
				io.putstring ("  these didn't get stored right: %N")
				from diff.start
				until diff.off
				loop
					io.putstring (diff.item.tagged_out)
					io.new_line
					diff.forth
				end
			end
		end
	
feature -- tests
	
	test_pobject is
		local
			spouse: PERSON
		do
			io.putstring ("TEST_POBJECT - changing some objects%N")
			-- If the person has a spouse, change the spouse
			spouse := random_person.spouse
			if spouse /= Void then
				io.putstring ("TEST_POBJECT - one object changes%N")
				spouse.set_age (spouse.age + 1)
			else
				spouse := person_man.i_th (1)
				if spouse /= Void then
					random_person.set_spouse (spouse)
				end
			end
			io.putstring ("Should have 1 or 2 differences %N")
		end
	
	test_plist is
		local
			child: PERSON
		do
			io.putstring ("TEST_PLIST - adding a child %N")
			!!child.make ("child 1", 4)
			random_person.add_child (child, 1)
			child.set_age (5)
			io.putstring ("Should be 1 diff %N")
		end
	
	test_plist_double is
		do
			io.putstring ("TEST_PLIST_DOUBLE - adding a number %N")
			if random_person.numbers = Void then
				random_person.set_lucky_numbers (1, 2, 3)
			else
				random_person.numbers.append (3.14)
			end
			io.putstring ("Should be 0 or 2 diffs %N")
		end
	
	test_plist_integer is
		do
			io.putstring ("TEST_PLIST_INTEGER - not implemented %N")
		end
	
	test_parray is
		local
			cusin: PERSON
		do
			io.putstring ("TEST_PARRAY - adding relatives %N")
			!!cusin.make ("Fred", 99)
			cusin.store
			random_person.relatives.put (cusin, 1)
			io.putstring ("Should be at 1 diff %N")
		end
	
	test_parray_boolean is
		local
			cusin: PERSON
		do
			io.putstring ("TEST_PARRAY_BOOLEAN - fiddling flags %N")
			cusin := random_person.relatives @ 1
			cusin.flags.put (not (cusin.flags @ 1), 1)
			io.putstring ("Should be just one difference %N")
		end
	
	test_parray_integer is
		do
			io.putstring ("TEST_PARRAY_INTEGER - not implemented %N")
		end
	
	test_plist_obj is
		local
			friend: PERSON
		do
			io.putstring ("TEST_PLIST_OBJ - add friends %N")
			!!friend.make ("good guy", 44)
			friend.store
			random_person.friends.extend (friend)
			io.putstring ("Should be just one diff %N")
		end

end -- TEST_STORE_DIFFS
