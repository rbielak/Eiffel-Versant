-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
deferred class SUBSCRIPT_ARGUMENT_AS

inherit

	SHARED_BYTE_CODE_AS
		undefine
			out
		end

feature

	subscript: INTEGER is
		deferred
		end
 
	is_dynamic_subscript: BOOLEAN is
		deferred
		end
 
end
