-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class RENAME_CLASS_MENU_COMMAND

inherit

	RENAME_CLASS_ACTION
	CMD

feature

	execute is
		local
			prev_name, the_new_name : STRING
		do
			io.putstring ("Enter old class name: ");
			io.readline;
			prev_name := clone (io.laststring);
			io.putstring ("Enter new class name: ");
			io.readline;
			the_new_name := clone (io.laststring);			
			set_names (prev_name, the_new_name)
			action
		end

end -- class
