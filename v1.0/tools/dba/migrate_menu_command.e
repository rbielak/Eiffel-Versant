-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class MIGRATE_MENU_COMMAND

inherit
	
	CMD
	MIGRATE_ACTION

feature

	execute is
		local
			t_db, f_db, lo_id: STRING
			b: BOOLEAN
		do
			b:= true
			io.putstring  ("Move one object from one database to another...%N")
			io.putstring ("Enter FROM database: ")
			io.readline
			f_db := io.laststring.twin
			io.putstring ("Enter TO database: ")
			io.readline
			t_db := io.laststring.twin
			io.putstring ("Enter LOID of the object to move: ");
			io.readline
			lo_id := io.laststring.twin
			set_the_info (f_db, t_db, lo_id,b)
			action
			if io.lastint /= -1 then
				set_db_int_attr (object_id, $(("pobject_root_id").to_c), io.lastint)
			end
		end

end --class
