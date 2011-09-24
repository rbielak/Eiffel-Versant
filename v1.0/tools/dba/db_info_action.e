-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class DB_INFO_ACTION

inherit

	DBA_ACTION

feature
	
	error_msg : STRING is "Can't get the into";
	
	sub_action is
		local
			free_kb : INTEGER_REF;
			percentage : INTEGER;
		do
			if not sess.active then
				io.putstring ("First you must start a session.  %N");
			else
				free_kb := 0;
				percentage := o_diskfree ($(sess.current_database.name.to_c), 
							  $free_kb);
				io.putstring (">>> Database ");
				io.putstring (sess.current_database.name);
				io.putstring (" has ");
				io.putint (percentage);
				io.putstring ("%% space free. The free space has ");
				io.putint(free_kb.item);
				io.putstring ("KB. %N%N");
			end;
		end;
	
feature {NONE}	
	
	o_diskfree (dbname : POINTER; freekb : POINTER) : INTEGER is
		external "C"
		end;

end
