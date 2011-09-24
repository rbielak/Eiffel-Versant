-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class MARRY_COMMAND

inherit

	DB_TEST_COMMAND

feature

	completion_message: STRING is "I know pronounce.. %N";
		

	run_action is
		do
			get_men
			if man1 /= Void and man2 /= Void then
				get_people			
				if person1 /= Void and person2/= Void then
					person1.set_spouse (person2)
					man1.update (person1)				
					io.putstring ("Newlyweds..")				   
				else
					io.putstring ("One (or both of these) in the couple do not exist. (Can't get married)")
				end
			else
				io.putstring (args @ 2)
				io.putstring (" -> not a valid type of people.")
			end
			io.new_line
		end

	verify_msg : STRING is "The Marriage was "

	verify is	
		do
			get_men
			if man1 /= Void and man2 /= Void then
				get_people
				if person1 /= Void and person2 /= Void then
				    verified := ((person1.spouse = person2) and 
								 (person2.spouse = person1))
				end
			end		
			print_verified_msg
		end

	print_failure_info is
		do
			print_one_man (man1, args @ 2)
			if man1 /= man2 then
				print_one_man (man2, args @ 2)
			end
			print_one_person (person1, args @ 3)
			io.putstring (" with a spouse named ")
			print_one_person (person1.spouse,"")
			io.putstring("%N and ")
			print_one_person (person2,args @ 5)
			io.putstring (" with a spouse named ")
			print_one_person (person2.spouse,"")
			io.new_line			
		end

end -- class


