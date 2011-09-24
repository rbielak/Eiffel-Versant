-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class RETRIEVE_CLASS_ACTION

inherit

	DBA_ACTION
	META_PCLASS_SERVER
	
feature

	display_class (cls : PCLASS) is
			-- print a class
		local
			i : INTEGER;
			att : PATTRIBUTE;
			attributes : ARRAY [PATTRIBUTE];
		do
			io.putstring ("Class --> ");
			io.putstring (cls.name);
			io.new_line;

			if cls.ancestors /= Void then
				from
					io.putstring ("     %NAncestors:%N");
					i := 1
				until i > cls.ancestors.count
				loop
					io.putstring ("       --> ");
					io.putstring (cls.ancestors.item (i));
					io.new_line;
					i := i + 1;
				end;
			end;

			io.putstring ("     %NAttributes:%N");
			if cls.attributes /= Void then
				attributes := cls.attributes.array_representation;
				from 
					i := 1;
				until i > attributes.count
				loop					
					att := attributes.item (i);
					if not att.name.is_equal("peif_id") then
						io.putstring ("       --> ");						
						io.putstring (att.name);
						io.putstring (" : ");
						--	  	key_att ?= att
						-- 	 if key_att /= Void then
						-- 	io.putstring (key_att.referenced_object_type)
						--		  	io.putstring (" from '")
						-- 			io.putstring (key_att.name_of_man)
						--			 	io.putstring ("'")
						--			  	else
						if att.type = Void then
							io.putstring ("(NULL DOMAIN)");
						else
							io.putstring (att.type);
						end;
						if att.repetition > 1 then
							io.putstring (" [");
							io.putint (att.repetition);
							io.putstring ("]");
						elseif att.repetition = -1 then
							io.putstring (" []");
						elseif att.repetition = -2 then
							io.putstring (" <list>");
						end;
						--				end
						if att.is_key_attribute then
							io.putstring (" (key_path=")
							io.putstring (att.aux_info)
							io.putstring (")")
						end
						io.new_line;
					end
					i := i + 1;					
				end;
			end;
			io.putstring (" ------------------------------ %N");
			
		end;
   
	error_msg : STRING is "Retrieval failed";
   
	input_class : PCLASS

	set_class (new_class : STRING ) is
		do
			new_class.to_lower
			input_class := sess.retrieve_class (new_class)
		end

	sub_action is
			-- Retrieve a class from database
	
		do
			if input_class = Void then
				io.putstring ("Class not in database.%N")
			else
				display_class (input_class)
			end;
		end;


end


