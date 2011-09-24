-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

deferred class DB_TEST_COMMAND

inherit
	
	CMD
	SHARED_ROOT_SERVER
	SHARED_TEST_SESSION

feature

	man1, man2 : NAMED_MAN [PERSON]

	person1, person2 : PERSON


	get_men  is			
		do
			man1 ?= root_server.root_by_name (args @ 2)
			if (args @ 2).is_equal (args @ 4) then 
				man2 := man1
			else
			    man2 ?= root_server.root_by_name (args @ 4)
			end		
		end
	
	get_people is
		do
			person1 := man1.get_item (args @ 3)
		    person2 := man2.get_item (args @ 5)		
		end
		
	set_args (largs: ARRAY [STRING]) is
		do
			args := largs
		end

	
	args : ARRAY [STRING]
			-- the first argument is the name of the
			-- command, the following items are parameters
	
	timer: expanded SIMPLE_TIMER

	execute is
		do
			timer.start
			run_action
			timer.stop
			print_time
		end
	
	print_time is
		do
			io.putstring (completion_message)
			io.putstring (": CPU time=")
			io.putdouble (timer.seconds_used)
			io.putstring (" / Real time=")
			io.putint(timer.elapsed_seconds)
			io.putstring (" seconds. %N")
		end
	
	verified : BOOLEAN

	verify_msg : STRING is 
		deferred 
		end

	print_failure_info is
		deferred
		end

	print_one_man (man_name: NAMED_MAN [PERSON]; local_string : STRING) is
		do
			io.putstring (local_string)
			io.putstring (" has named_man with root id = ")
			if man_name = Void then
				io.putint (man_name.root_id)
				io.putstring (" and root name = ")
				io.putstring (man_name.root_name) 
			else
				io.putstring (" non-existant..  ")
			end
			io.new_line
		end

	print_one_person (lperson : PERSON; local_string : STRING) is
		do
			io.putstring (local_string)			
			if lperson = Void then
				io.putstring (" has NO PERSON in the database with %
                              %the same name")				
			else
				io.putstring ("-> has a PERSON with name = ")
				io.putstring (lperson.name)
			end
		end

	print_verified_msg  is
		do
			io.putstring (verify_msg)
			if verified then
				io.putstring (" sucessfull!%N")
			else
				io.putstring (" not sucessfull%N")
				io.readchar
				print_failure_info
			end
		end

	verify is
		deferred
		end

	
	completion_message: STRING is
		deferred
		end
	
	run_action is
		deferred
		end

invariant

end -- DB_TEST_COMMAND
