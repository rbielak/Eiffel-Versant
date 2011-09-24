-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Routines from this class are used to handle object version mismatch
-- errors during store operations
--

deferred class VERSION_MISMATCH_HANDLER

feature
	
	handle (object: POBJECT): BOOLEAN is
			-- Called for every object with a version conflict.
			-- Returns true if mismatch was resolved
		require
			object_there: (object /= Void) and then (object.pobject_id /= 0)
		deferred
		end
	
	prepare is
			-- Called once at the start of the store operation
		do
		end
	

end -- VERSION_MISMATCH_HANDLER
