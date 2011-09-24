-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
--  A parent class for things stored in a database that have root_ids
--

deferred class ROOTED

feature
	
	root_id : INTEGER is
		require
			false
		deferred
		end
	
	database : DATABASE is
		require
			false
		deferred
		end

invariant

end -- ROOTED
