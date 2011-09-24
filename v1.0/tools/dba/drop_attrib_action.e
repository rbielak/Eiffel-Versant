-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class DROP_ATTRIB_ACTION

inherit 

	DBA_TRANSACTION
	META_PCLASS_SERVER

feature
	
	error_msg : STRING is "Can't drop attribute";
   
	cls_name : STRING

	attr_name : STRING

	sub_action is
			-- Drop an attribute from a class
		local
			cls : META_PCLASS;
		do
			cls_name.to_lower		
			attr_name.to_lower
			cls := meta_pclass_by_name (cls_name)
			if cls = Void then
				io.putstring ("Class not found in database.%N")
			else			
				cls.remove_attribute (attr_name)
				cls.update_pclass
				cls_name.to_upper
				io.putstring ("Dropped ")
				io.putstring (attr_name)
				io.putstring (" from class ")
				io.putstring (cls_name)
				io.new_line
			end
		 end

end -- class

 
