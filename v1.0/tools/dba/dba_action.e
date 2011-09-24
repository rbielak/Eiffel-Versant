-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
deferred class DBA_ACTION 

inherit

	SHARED_SESSION

feature

	name: STRING is
		do
			Result := generator
		end

	help: ARRAY [STRING] is
		do
		end

	error_report is
		do
			io.putstring ("***** ERROR: ");
			io.putstring (error_msg);
			io.putstring ("%N***** Error code: ");
			io.putstring (sess.error_msg);
			io.putstring ("%N-------%N");
		end; -- error_report

	action is
		local
			crashed: BOOLEAN
		do
			if not crashed then
				sub_action
			else
				error_report
			end
		rescue
			if not crashed then
				crashed := True
				retry
			end
		end

	sub_action is
		deferred
		end

	error_msg: STRING is 
		deferred
		end

end
