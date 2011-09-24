-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class BEST_FRIEND_COMMAND

inherit

	DB_TEST_COMMAND

feature

	completion_message: STRING is "Best friends will always be true %N"

	run_action is
		do
			get_men
			if man1 /= Void and man2 /= Void then
				get_people			
				if person1 /= Void and person2/= Void then
					person1.set_best_friend (person2)
					person2.set_best_friend (person1)
					man1.update (person1)
				else
					io.putstring (" These people do not exist!!%N")
				end
			else
				io.putstring ("These are not valid types of people .. %N")
			end			
		end

	verify_msg : STRING is 
		do
			Result := clone (args @ 3)
			Result.append (" and ")
			Result.append (clone (args @ 5))
			Result.append ("'s long-life-friendship is ")
		end

	verify is
		do
			get_men
			if man1 /= Void and man2 /= Void then
				get_people
				if person1 /= Void and person2 /= Void then
					verified := ((person1.best_friend = person2) and 
								 (person2.best_friend = person1))
				end
			end
			print_verified_msg
		end
	
	print_failure_info is
		do
			print_one_man (man1, args @ 2)
			if man1 /= man2 then
				print_one_man (man2, args @ 4)
			end
			print_one_person (person1, args @ 3)
			io.putstring (" and best friend ")
			if person1 /= Void then
				print_one_person (person1.best_friend,"")
			end
			io.new_line						  
			print_one_person (person2,args @ 5)		
			io.putstring (" and their best friend ")
			if person2 /= Void then
				print_one_person (person2.best_friend,"")
			end			
		end

end -- class



