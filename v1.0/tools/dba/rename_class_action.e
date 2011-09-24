-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class RENAME_CLASS_ACTION

inherit

	META_PCLASS_SERVER
	DBA_TRANSACTION

feature

	error_msg : STRING is "Cannot rename the class";
	
	old_name, new_name: STRING

	set_names (o_name, n_name : STRING) is
		do
			old_name := o_name
			new_name := n_name
		end


	sub_action is
		do	
			if rename_class ($(old_name.to_c), 
					 $(sess.current_database.name.to_c),
					 $(new_name.to_c)) /= 0 then
				error_report
			else
				old_name.to_lower
				new_name.to_lower
				io.putstring (old_name)
				io.putstring ("  has been changed to -> ")
				io.putstring (new_name)
				io.new_line
				--			database_was_modified.set_item (True);	
			end
		end
	
	rename_class (the_old_name, db, the_new_name : POINTER) : INTEGER is
		external "C"
		alias "c_rename_class"
		end;

end -- class	
