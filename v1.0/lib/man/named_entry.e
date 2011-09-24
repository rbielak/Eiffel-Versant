-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
indexing

	description: "An entry for a MAN where arbitrary objects can be inserted by name"
	date: "Created: 12/12/97"
	
class NAMED_ENTRY

inherit

	NAMED_MANAGEABLE

creation

	make 

feature

	make (lname: STRING; lobject: POBJECT) is
		require
			name_valid: lname /= Void
			object_valid: (lobject /= Void)
		do
			name := lname.twin
			entry := lobject
		end

	entry: POBJECT
			-- entry associated with the name

	dump is
		do
			io.putstring ("NAME: ")
			io.putstring (name)
			io.putstring ("%NObject:")
			io.putstring (entry.external_object_id)
			io.new_line
		end

end
								   
						  
