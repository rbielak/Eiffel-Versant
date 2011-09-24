-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class SHARED_ROOT_SERVER

feature
	
	root_server : ROOT_SERVER is
		once 
			!!Result.make
		end

invariant

end -- SHARED_ROOT_SERVER
