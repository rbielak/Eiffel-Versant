-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class VERBOSE_COMMAND

inherit
	
	ARGUMENT_COMMAND

feature
	
	verbose_flag: BOOLEAN

	execute is
		do
			verbose_flag := True
		end

end -- VERBOSE_COMMAND
