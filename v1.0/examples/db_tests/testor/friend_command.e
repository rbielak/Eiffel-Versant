-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class FRIEND_COMMAND

inherit

	DB_TEST_COMMAND

feature

	completion_message: STRING is "You are now befriended%N"

	run_action is
		do
			get_men
			if man1 /= Void and man2 /= Void then
				get_people			
				if person1 /= Void and person2/= Void then
					person1.friends.extend (person2)
					person2.friends.extend (person1)
					man1.update (person1)				
					io.putstring ("good friends are the best.%N")  
				else
					io.putstring ("One (or both) of these ")
					io.putstring (args @ 2)
					io.putstring (" do not exist. (can't be friends..)")
				end
			else
				io.putstring (args @ 2)
				io.putstring (" -> not a valid type of people.")
			end
			io.new_line
		end

	verify_msg : STRING is 	
		do
			Result := clone (args @ 3)
			Result.append (" and ")
			Result.append (clone (args @ 5))
			Result.append ("'s friendship is ")
		end

	verify is
		do
			get_men
			if man1 /= Void and man2 /= Void then
				get_people
				if person1 /= Void and person2 /= Void then
					verified := (person1.friends.has (person2))
					verified := (person2.friends.has (person1))
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
			io.putstring (" and friend ")
			if person1 /= Void then
				print_one_person (person1.friends.item_from_tag (args @ 5)
								  ,args @ 5)
			end
			io.new_line						  
			print_one_person (person2,args @ 5)		
			io.putstring (" and their friend ")
			if person2 /= Void then
				print_one_person (person2.friends.item_from_tag (args @ 3)
								  ,args @ 3)
			end			
		end

end



	
