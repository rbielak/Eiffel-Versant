-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
deferred class COMPARABLE_POBJECT

inherit
	POBJECT
		undefine
			is_equal
		end
	
	COMPARABLE
		undefine
			copy
		end

invariant

end -- COMPARABLE_POBJECT
