-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class CHILD_COMMAND


inherit

	DB_TEST_COMMAND

feature

	completion_message: STRING is "You are now parents%N";

	run_action is	
		do
			get_men
			if man1 /= Void and man2 /= Void then  
				get_people
				if person1 /= Void and person2 /= Void then				   
					sig_other := person2.spouse
					if sig_other /= Void then
						if sig_other.children = Void then
							sig_other.add_child (person1,1)
						else
							sig_other.children.extend (person1)
						end
					end
					if person2.children = Void then
						person2.add_child (person1,1)
					else
						person2.children.extend (person1) 
					end
					man2.update (person2)
					io.putstring ("Child born..%N")
				else
					io.putstring("People not valid ( or fertile)%N")
				end
			else
				io.putstring ("Type of person not valid to have kids%N")
			end
		end

	verify_msg : STRING is
		do 
			Result := args @ 3
			Result.append ("'s schooling was ")
		end

	sig_other : PERSON

	verify is			
		do
			get_men
			if man1 /= Void and man2 /= Void then
				get_people				
				if person1 /= Void and person2 /= Void and then person2.children/= Void then
					sig_other := person2.spouse
					verified := (person2.children.has (person1))
					if sig_other /= Void then
						if sig_other.children /= Void then
							verified :=	(verified and 
										 sig_other.children.has (person1))	  
						else
							verified := (1 = 2)
						end
					end
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
			print_one_person (person2, args @ 5)
			if sig_other /= Void then
				io.putstring (" and ")
				print_one_person (sig_other, sig_other.name)
				io.putstring (" have a child named ->%N")
			else
				io.putstring (" has a child named ->%N")
			end
			print_one_person (person1, args @ 3)
			io.new_line			
		end

end

