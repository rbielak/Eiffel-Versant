-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class QUERY_COMMAND

inherit

	DB_TEST_COMMAND


feature

	completion_message : STRING is ""

	list_of_lists : LINKED_LIST [PLIST [PERSON]] 
	
	prepared_for_action : BOOLEAN

	query_result : PLIST [PERSON]

	run_action is
		local
			s_query : SELECT_QUERY [PERSON] 		
			i, index : INTEGER
			s, temp_string : STRING
			local_man : NAMED_MAN [PERSON]
			larray : ARRAY [ANY]
			lperson : PERSON
			fails : BOOLEAN
		do
			if not prepared_for_action then
				!!list_of_lists.make								
				prepared_for_action := True
				io.putstring ("Query results from DATABASE :%N")
			end
			man1 ?= root_server.root_by_name (args @ 2)
			if man1 /= Void then				
				!!s_query.make (args @ 3)
				!!larray.make (1, args.count - 3)
				from
					i := 4
				until
					i > args.count  or fails
				loop
					s:= args @ i
					if (s @ 1).is_equal ('(')  then
						index := s.index_of (':',2)						
						temp_string := s.substring (2,index - 1)
						s := s.substring (index + 1, s.count - 1)
						local_man ?= root_server.root_by_name (temp_string)
						if local_man /= Void then
							lperson := local_man.get_item (s)
							larray.put (lperson, i-3)
						else
							io.putstring ("person doesn't exist.. %N")
							fails := True
						end						
					else
						if (s @ 1).is_equal ('%"') then
							s := s.substring (2,s.count-1) 
							larray.put (s,i-3)
						else
							if s.is_equal ("Void") then
								larray.put(Void,i-3)
							else
								index := s.to_integer
								larray.put (index,i-3)
							end
						end
					end										
					i := i + 1
					-- increment and get next token
				end  --  loop until
				if not fails then
					s_query.execute (man1.contents,larray)
					query_result := s_query.last_result
					list_of_lists.extend (query_result)
					if query_result /= Void then					
						io.putstring ("******* ");
						io.putint (query_result.count);
						io.putstring (" objects were retrieved. *******%N")
						-- print_list (query_result);
					else
						io.putstring ("Nothing found...%N");
					end
				end
			else
				io.putstring ("Query fails .. man doesn't exist%N")
			end						
		end
	
feature 

	prepared_for_verification : BOOLEAN

	dummy_linked_list : LINKED_LIST [PERSON]

	verify is		
		do
			if not prepared_for_verification then
				prepare_to_verify
				prepared_for_verification := True
				list_of_lists.start
				io.putstring ("%N----------------------------------------")
				io.putstring ("%N----------------------------------------%N")
				io.putstring ("%NQuery results from MEMORY -> %N")
			end
			execute		
			if query_result /= Void then
				verified := query_result.is_equal (list_of_lists.item)	
			else
				verified := (list_of_lists.item = query_result)
			end
			list_of_lists.forth
		end
		
	verify_msg : STRING is ""				
	
	print_failure_info is
		do
			io.putstring ("Plists..  were not equal for query%N")
			io.putstring (args @ 2)
			print_list (query_result)
			list_of_lists.back
			print_list (list_of_lists.item)
			list_of_lists.forth
		end

feature --  {extras}
	
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

	prepare_to_verify is
		local
			local_list : PLIST [PERSON]
			i: INTEGER
		do
			!!dummy_linked_list.make
			from 
				list_of_lists.start
			until
				list_of_lists.off
			loop
				local_list := list_of_lists.item
				if local_list /= Void then
					from
						i := 1
					until
						i > local_list.count
					loop
						dummy_linked_list.extend (local_list.item (i))
						i := i + 1
					end					   
				end
				list_of_lists.forth
			end
		end

end --class 

