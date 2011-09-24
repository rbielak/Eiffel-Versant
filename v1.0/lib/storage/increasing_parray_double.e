-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
indexing

	description: "Increasing, persistent array of doubles"

class INCREASING_PARRAY_DOUBLE

inherit

	PARRAY_DOUBLE
		rename
			make as array_make,
			upper as dimension,
			remove_double as vstr_remove_double
		undefine
			make_from_array, subarray
		redefine
			generator
		end

	INCREASING_ARRAY [DOUBLE]
		undefine
			generator, copy, is_equal
		end

creation

	make, make_from_array

feature
	
	generator : STRING is 
		do
			Result := "INCREASING_PARRAY_DOUBLE"
		end;
	
end -- INCREASING_PARRAY_DOUBLE
