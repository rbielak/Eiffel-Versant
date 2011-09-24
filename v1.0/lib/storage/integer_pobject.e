-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class INTEGER_POBJECT

inherit
	POBJECT

creation
	make

feature
	
	make (n : INTEGER) is
		do
			value := n;
		end
	
	value : INTEGER;

invariant

end -- INTEGER_POBJECT
