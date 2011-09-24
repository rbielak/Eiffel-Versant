-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- test class to verify inheritance
--

deferred class JUNK_MAN 

inherit
	
	MAN [PERSON]

feature
	
	junk: INTEGER

	has_item (t, spouse: PERSON): BOOLEAN is
		do
		end
	
	

invariant

end -- JUNK_MAN
