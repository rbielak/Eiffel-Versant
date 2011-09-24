-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class CONNECT_DB_ACTION

inherit

	DBA_ACTION

feature

	name_of_db: STRING

	set_connect_db (db_nm: STRING) is
		do
			name_of_db := db_nm
		end


	sub_action is
		local
			db: DATABASE
		do
			!!db.make (name_of_db)
			db.connect
			io.putstring ("...connected %N")
			sess.set_current_database (db)
			io.putstring ("Setting default db to the new database...%N")
		end
	
	error_msg : STRING is "Cannot connect to this database";

end -- class
