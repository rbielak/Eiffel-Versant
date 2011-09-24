-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class DROP_CLASS_MENU_COMMAND

inherit

	DROP_CLASS_ACTION
	CMD

feature

	execute is
		local
			new_name: STRING
		do
			io.putstring ("---> Dropping a class. %N");
			io.putstring ("Enter class name: ");
			io.readline;
			new_name := io.laststring;
			set_class (new_name)
			action
		end

end



	
