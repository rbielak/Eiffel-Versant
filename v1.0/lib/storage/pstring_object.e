-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class PSTRING_OBJECT

inherit
	POBJECT
	
creation
	make

feature
	
	make (new_string : STRING) is
		do
			value := new_string
		end
	
	value : STRING;

invariant

end -- PSTRING_OBJECT
