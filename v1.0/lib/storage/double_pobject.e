-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class DOUBLE_POBJECT

inherit
	POBJECT

creation
	make

feature
	
	make (n : DOUBLE) is
		do
			value := n;
		end
	
	value : DOUBLE;

invariant

end -- DOUBLE_POBJECT
