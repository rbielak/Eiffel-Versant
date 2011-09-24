-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--

class STRING_POBJECT

inherit
	POBJECT

creation
	make

feature
	
	make (n : STRING) is
		do
			value := n;
		end
	
	value : STRING;

invariant

end -- STRING_POBJECT
