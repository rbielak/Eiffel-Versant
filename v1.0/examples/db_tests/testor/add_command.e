-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class ADD_COMMAND

inherit
	
	DB_TEST_COMMAND

feature
	
	completion_message: STRING is "Add to MAN";
	
	get_man (name: STRING) : NAMED_MAN[PERSON] is
			-- Get a NAMED_MAN, create one if not there
		require
			name /= Void
		do
			Result ?= root_server.root_by_name (name)
			if Result = Void then
				root_server.create_new_root (session.current_database,
							     name, "PERSON",
							     "NAMED_MAN[PERSON]", Void,
							     Void, True)
				Result ?= root_server.last_created
			end
		ensure
			Result /= Void
		end	      
		
	age: INTEGER

	run_action is	
		do
			man1 := get_man (args @ 2)
			age := (args @ 4).to_integer
			!!person1.make (args @ 3, age)
			man1.extend (person1)
		end

	verify_msg : STRING is 
		do
			Result := "Addition of "
			Result.append (args @ 3)
			Result.append (" was")
		end
 

	verify is	
		do
			man1 ?= root_server.root_by_name (args @ 2) 
			if man1 /= Void then						   
				person1 := man1.get_item (args @ 3)
				if person1 /= Void then
					verified := (person1.age = ((args @ 4).to_integer))
				end
			end
			print_verified_msg		   
		end

	print_failure_info is
		do 			
			print_one_man (man1, args @ 2)
			io.putstring (args @ 3)
			io.putstring (" with age = ")
			io.putstring (args @ 4)
			print_one_person (person1, args @ 3)
			io.putstring (" and age = ")
			if person1 /= Void then
				io.putint (person1.age)		   				
			end
			io.new_line
		end
			
			

end -- ADD_COMMAND
