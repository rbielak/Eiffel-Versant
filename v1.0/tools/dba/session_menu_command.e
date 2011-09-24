-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class SESSION_MENU_COMMAND

inherit

	CMD
	SESSION_ACTION

feature

	execute is
		do
			io.putstring ("Enter name of a database:  ");
			io.readline;
			set_db_name (io.laststring)
			action
		end

end
