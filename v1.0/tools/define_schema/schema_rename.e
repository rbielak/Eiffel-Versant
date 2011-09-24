-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class SCHEMA_RENAME

creation
	
	make

feature
	
	new_name : STRING
	
	old_name : STRING
	
	make (new_nm, old_nm : STRING) is
		require
			(new_nm /= Void) and (old_nm /= Void)
		do
			new_name := new_nm;
			old_name := old_nm;
		end

invariant

end -- SCHEMA_RENAME
