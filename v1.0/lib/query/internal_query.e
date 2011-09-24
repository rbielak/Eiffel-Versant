-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Spec for internal query used by SELECT_QUERY
--

deferred class INTERNAL_QUERY

inherit	

	DB_GLOBAL_INFO

feature

	execute (in_vstr: VSTR; parms: ARRAY[ANY]) : VSTR is
			-- execute the query given the parameters and
			-- return a VSTR of found objects
		require
			valid_vstr: in_vstr /= Void
		deferred
		end

end -- INTERNAL_QUERY
