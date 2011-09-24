-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class SCHEMA_CLASS

creation
	
	make 

feature
	
	name : STRING;
			-- name of this class
	
	parents : LINKED_LIST [STRING]
			-- names of parents
	
	attributes : LINKED_LIST [SCHEMA_ATTR]
			-- text lines describing the attributes
	
	renames : LINKED_LIST [SCHEMA_RENAME]
			-- text lines describing renames
	
	
	dump is
		do
			io.putstring ("CLASS --> ");
			io.putstring (name);
			io.new_line;
			from parents.start
			until parents.off
			loop
				io.putstring ("    Inherits --> ");
				io.putstring (parents.item);
				io.new_line;
				parents.forth
			end
			io.putstring ("END <-- %N");
		end
	

feature {NONE}
	
	make (new_name : STRING) is
		require
			new_name /= Void
		do
			new_name.to_lower;
			name := new_name;
			!!parents.make;
			!!attributes.make;
			!!renames.make;
		end


invariant
	
	name /= Void

end -- SCHEMA_CLASS
