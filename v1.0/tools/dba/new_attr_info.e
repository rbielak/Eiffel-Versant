-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class NEW_ATTR_INFO

inherit

	META_PCLASS_SERVER

feature

	ti : TYPE_INFO;
	
	line : WORD_STRING

	type_mapper : TYPE_MAPPER is
		once
			!!Result.make
		end;

	make_pattribute_obj (attr_name, new_attr_type : STRING) : PATTRIBUTE is
		local
			rep : INTEGER
			attr_type : STRING
		do
			attr_type := new_attr_type
			attr_type.to_lower;
			if equal (attr_type, "list") then
				attr_type := line.remove_word;
				rep := -1;
				--else
				--nextw := line.remove_word
				--if (nextw /= Void) and then (nextw.is_equal("from")) then
				-- man_name := line.remove_word
				--	end
			end;
			ti := type_mapper.item (attr_type);
			if ti /= Void then
				attr_type := ti.versant_name;
				if rep = 0 then
					rep := ti.repeat_count
				end
			end;
			-- If repeat count wasn't set yet, default it
			-- to 1
			if rep = 0 then
				rep := 1
			end;
			-- Create appriate PATTRIBUTE object
			if rep /= -1 then
				if attr_type.is_equal ("boolean") then
					!BOOLEAN_PATTRIBUTE!Result.make_new (attr_name, attr_type, rep)
				elseif attr_type.is_equal ("integer") then
					!INTEGER_PATTRIBUTE!Result.make_new (attr_name, attr_type, rep)
				elseif attr_type.is_equal ("double") then
					!DOUBLE_PATTRIBUTE!Result.make_new (attr_name, attr_type, rep)
				elseif attr_type.is_equal ("char")  then
					!CHARACTER_PATTRIBUTE!Result.make_new (attr_name, attr_type, rep) 
				elseif attr_type.is_equal ("string")  then
					!STRING_PATTRIBUTE!Result.make_new (attr_name, attr_type, rep) 
				else
					--					if man_name = Void then
					!OBJECT_PATTRIBUTE!Result.make_new (attr_name, attr_type, rep) 
					--					else
--						!KEY_PATTRIBUTE!Result.make_new (attr_name, attr_type, man_name)
					--					end
				end
			else
				!OBJECT_PATTRIBUTE!Result.make_new (attr_name, attr_type, rep) 
			end
		end

	get_one_attribute : PATTRIBUTE is
			-- Get info about attributes
		local
			attr_name, man_name, attr_type, nextw : STRING;
			rep : INTEGER;
			done, finished : BOOLEAN;
		do
			from
			until done
			loop		
				io.putstring ("Attribute name -> ");
				io.readline;
				attr_name := clone(io.laststring);
				if not attr_name.is_equal ("") then
					done := True
				end
			end		
			
			from	 
				done := false			
			until 
				done
			loop
				from
					finished := false
				until
					finished
				loop												   
					io.putstring ("Attribute type ('?' for list) -> ");
					io.readline;
					finished := not io.laststring.is_equal ("") 	            
				end
				
				if io.laststring.item (1) = '?' then
					io.putstring ("  integer, %N");
					io.putstring ("  string, %N"); 
					io.putstring ("  double, %N");
					io.putstring ("  boolean, %N");
					io.putstring ("  char, %N");
					io.putstring ("  <valid-class-name>,  %N");
					io.putstring ("  list ( <any-valid-type> ) %N")
				else
					done := True
				end;
			end
			!!line.make (20);
			line.set_delimiters (" %T()");
			line.set_word_string (clone(io.laststring));
			attr_type := line.remove_word;
			Result := make_pattribute_obj (attr_name, attr_type)
			
			
		end

	
--feature to use
	
	get_the_attributes : LINKED_LIST [PATTRIBUTE] is
		local
			local_list : LINKED_LIST [PATTRIBUTE]
			done: BOOLEAN
		do
		   	!!local_list.make
			
			from
			until done
			loop
				io.putstring ("More attributes? [y/n]: ");
				io.readchar;
				done := (io.lastchar = 'n') or (io.lastchar = 'N');
				io.next_line;
				if not done then
					local_list.put_right (get_one_attribute);
				end
			end
			Result := local_list
		
			
		end

end -- class
	
