-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class SORTED_PARRAY_DOUBLE

inherit

	SORTED_ARRAY[DOUBLE]
		rename
			remove_double as vstr_remove_double
		undefine
			is_equal, copy
		end
	
	PARRAY_DOUBLE
		undefine
			make_from_array
		end
       

creation
	make, make_from_array


end -- SORTED_ARRAY_DOUBLE
