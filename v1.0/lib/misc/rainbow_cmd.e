-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

deferred class RAINBOW_CMD

inherit

	PRIORITY_ARG_COMMAND


feature
	
	command_make (new_priority : INTEGER) is
		require
			new_priority >= 0
		do
			priority := new_priority
		end
	


invariant

end -- RAINBOW_CMD
