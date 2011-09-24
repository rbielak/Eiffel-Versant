-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class SWITCH_DB_ACTION

inherit

	DBA_ACTION

feature

	error_msg : STRING is "Cannot switch database";
	
	sub_action is
		local
			db : DATABASE;
		do
			io.putstring ("Enter database name: ");
			io.readline;
			db := sess.find_database (io.laststring);
			if db = Void then
				io.putstring ("You are not connected to this database. %N");
			else
				sess.set_current_database (db)
			end
		end


end -- class switch db
