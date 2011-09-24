-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class NEW_ATTRIB_ACTION

inherit
	
	DBA_TRANSACTION
	META_PCLASS_SERVER

feature

	 error_msg : STRING is "Add attribute failed."

	 attributes : LINKED_LIST [PATTRIBUTE]
	 
	 last_class : META_PCLASS

	 cls_name : STRING

	 sub_action is
		local
			done: BOOLEAN
		do
			cls_name.to_lower
			last_class := meta_pclass_by_name (cls_name);
			if last_class = Void then
				io.putstring ("Class not in database...%N");
			else
				from attributes.start
				until attributes.off
				loop
					last_class.add_attribute (attributes.item)
					attributes.forth
				end
			 -- if else
			io.putstring ("Attribute(s) added to class -> ")
			cls_name.to_upper
			io.putstring (cls_name)			
			last_class.update_pclass
			io.new_line
			end
		end

end --class

