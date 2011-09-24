-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class COMMAND_PROCESSOR_WITH_PRIORITY [T -> PRIORITY_ARG_COMMAND]

inherit
	
	CMD_PROCESSOR [T]
		redefine
			execution_list 
		end

creation
	
	make

feature {NONE}
	
	execution_list : SORTED_TWO_WAY_LIST [PRIORITY_ARG_COMMAND]

end
