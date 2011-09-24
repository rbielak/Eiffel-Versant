-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Mismatch handler that does nothing
--

class NULL_VERSION_MISMATCH_HANDLER

inherit
	
	VERSION_MISMATCH_HANDLER

feature
	
	handle (object: POBJECT): BOOLEAN is
		do
			Result := True
		end


end -- NULL_VERSION_MISMATCH_HANDLER
