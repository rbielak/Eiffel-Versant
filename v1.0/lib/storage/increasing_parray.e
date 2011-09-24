-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
indexing

	description: "Increasing persistent array";
	database: "Versant"

class INCREASING_PARRAY [T->COMPARABLE_POBJECT]

inherit

	PARRAY [T]
		rename
			make as array_make,
			upper as dimension,
			remove_double as vstr_remove_double
		undefine
			make_from_array,
			subarray
		redefine
			generator
		end

	INCREASING_ARRAY [T]
		undefine
			generator, copy, is_equal
		end

creation

	make, make_from_array

feature
	
	generator : STRING is 
		do
			Result := "INCREASING_PARRAY[POBJECT]";
		end

end -- INCREASING_PARRAY

