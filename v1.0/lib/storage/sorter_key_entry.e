-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Object and it's keys needed for sorting
--

class SORTER_KEY_ENTRY [T -> POBJECT]


feature {SORTER}
	
	keys: ARRAY [COMPARABLE]
			-- keys to sort on
	
	set_keys (new_keys: ARRAY[COMPARABLE]) is
		require
			valid_keys: new_keys /= Void
		do
			keys := new_keys
		ensure
			keys = new_keys
		end

	pobject: T
			-- object whose keys these are
	
	set_pobject (new_object: T) is
		require
			valid_object: new_object /= Void
		do
			pobject := new_object
		ensure
			pobject = new_object
		end

	pobject_id: INTEGER
			-- persistent object_id on the object whose keys these are
	
	set_pobject_id (new_id: INTEGER) is
		require
			valid_id: new_id /= 0
		do
			pobject_id := new_id
		ensure
			pobject_id = new_id
		end


end -- SORTER_KEY_ENTRY
