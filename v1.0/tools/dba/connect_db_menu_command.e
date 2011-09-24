-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class CONNECT_DB_MENU_COMMAND

inherit

	CONNECT_DB_ACTION
	CMD


feature


	execute is
		do
			io.putstring ("Enter the name of a database:")
			io.readline
			set_connect_db (io.laststring)
			action
		end

end  -- class
