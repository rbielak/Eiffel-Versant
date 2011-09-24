-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
--  A hash table with INTEGER key
--

class INTEGER_KEYED_HASH_TABLE [T]

inherit
	
	HASH_TABLE [T, INTEGER]
		redefine
			valid_key
		end

creation
	
	make

feature
	
	valid_key (key : INTEGER) : BOOLEAN is
		do
			Result := key /= 0
		end

end -- INTEGER_KEYED_HASH_TABLE
