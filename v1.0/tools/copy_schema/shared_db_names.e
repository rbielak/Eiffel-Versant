-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class SHARED_DB_NAMES
	
	source_db: STRING is
		once
			!!Result.make (10)
		end
	
	target_db: STRING is
		once
			!!Result.make (10)
		end


end -- SHARED_DB_NAMES
