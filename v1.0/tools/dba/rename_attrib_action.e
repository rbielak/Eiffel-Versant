-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class RENAME_ATTRIB_ACTION

inherit

	DBA_TRANSACTION
	META_PCLASS_SERVER

feature

	error_msg : STRING is "Can't rename attribute";	

	old_name : STRING
	
	new_name : STRING

	cls_name : STRING

	cls : META_PCLASS

	set_cls : BOOLEAN is
		do
			cls_name.to_lower
			cls := meta_pclass_by_name (cls_name)
			if cls = Void then
				io.putstring ("No such class in database.%N")
				Result := False
			else
				Result:= True
			end
		end

	sub_action is		  
		do
			new_name.to_lower
			old_name.to_lower					
			io.putstring ("Renaming  ")
			io.putstring (old_name)
			io.putstring (" --> ")
			io.putstring (new_name)
			io.new_line
			cls.rename_attribute (old_name, new_name) 
			cls.update_pclass
		end

end --class


