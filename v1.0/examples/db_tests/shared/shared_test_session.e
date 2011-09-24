-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class SHARED_TEST_SESSION

feature
	
	
	session: DB_SESSION is
		once
			!!Result
		end

end -- SHARED_TEST_SESSION
