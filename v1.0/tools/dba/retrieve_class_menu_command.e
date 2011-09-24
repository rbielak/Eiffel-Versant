-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class RETRIEVE_CLASS_MENU_COMMAND

inherit

	RETRIEVE_CLASS_ACTION
	CMD

feature

	execute is
		local
			new_name: STRING
		do
			io.putstring ("Enter class name: ")
			io.readline
			set_class (io.laststring)
			action
		end

end

