-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class DISCONNECT_DB_ACTION

inherit

	DBA_ACTION

feature

	error_msg : STRING is "Cannot disconnect from this database";

	sub_action is
		local
			db : DATABASE;
		do
			io.putstring ("Enter the name of a database: ");
			io.readline;
			db := sess.find_database (io.laststring);
			if db = Void then
				io.putstring ("This database is not connected. %N%N");
			else 
				if db = sess.current_database then
					io.putstring ("error: Can't disconnect from main database")
				else
					db.disconnect;
					io.putstring ("...disconnected %N%N" )		   			
				end
			end
		end -- sub_action

end -- class

