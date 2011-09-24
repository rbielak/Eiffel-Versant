-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class SORTED_PARRAY [G->COMPARABLE_POBJECT]
	
inherit

	PARRAY [G]
		rename
			remove_double as vstr_remove_double
		undefine
			make_from_array
		redefine
			generator
		end

	SORTED_ARRAY [G]
		undefine
			is_equal, copy, generator
		end

creation

	make, make_from_array

feature

	generator : STRING is 
		do
			Result := "SORTED_PARRAY[POBJECT]";
		end;

end -- SORTED_PARRAY
