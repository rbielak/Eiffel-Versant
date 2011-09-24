-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class IN_DB_CLOSURE_ACTION

inherit
	
	POBJECT_ACTION_COMMAND
		redefine
			execute
		end
	
	DB_GLOBAL_INFO
	

creation
	
	make

feature
	
	execute (closure : TWO_WAY_LIST [POBJECT]; object : POBJECT) is
		do
			-- Object must be new or n the same database
			if (object.pobject_id = 0) or else (object.database = root.database) then
				-- Object must not be under restricted management
				if (object.pobject_class = Void) or else 
					(object.pobject_class.my_manager = Void) 
				 then
					closure.extend (object);
					object.set_closure_position (closure.count)
				end
			end
		end

end -- IN_DB_CLOSURE_ACTION
