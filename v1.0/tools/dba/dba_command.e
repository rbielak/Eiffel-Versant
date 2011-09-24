-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
deferred class DBA_COMMAND
   
inherit

	PRIORITY_ARG_COMMAND
			
   
feature
	
	sess : DB_SESSION is
			-- db context used by all DBA commands
		once
			!!Result
		end;
	
--	database_was_modified : BOOLEAN_REF is
--		once
--			!!Result
--		end;
	
	
--	verify (msg : STRING) : BOOLEAN is
--		do
--			io.putstring ("*** WARMING: ");
--			io.putstring (msg);
--			io.putstring ("%N Are you sure? [y/n] ");
--			io.readline;
--			Result := io.laststring.item (1) = 'y';
--		end

	error_report is
		do
			io.putstring ("***** ERROR: ");
			io.putstring (error_msg);
			io.putstring ("%N***** Error code: ");
			io.putint (sess.last_error);
			io.putstring ("%N-------%N");
		end; -- error_report
   
	
	execute is
		local
			crashed : BOOLEAN
		do
			if not crashed then
				cmd_execute
			else
				error_report
			end
		rescue
			if not crashed then
				crashed := True
				retry
			end
		end
			
	
	error_msg : STRING is
		deferred
		end
	
	cmd_execute is 
		deferred
		end
	
end -- class dba_command
