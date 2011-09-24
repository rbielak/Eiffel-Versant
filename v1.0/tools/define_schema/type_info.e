-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class TYPE_INFO


creation
	make

feature
	
	versant_name : STRING;
	
	repeat_count : INTEGER;
	
	make (new_name : STRING; new_count : INTEGER) is
		do
			versant_name := new_name;
			repeat_count := new_count;
		end;

invariant

end -- TYPE_INFO
