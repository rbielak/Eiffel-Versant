-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Access rights for databases
--

class DATABASE_RIGHTS

inherit
	
	POBJECT

creation
	
	make,
	make_with_rights

feature
	
	db_name_pattern : STRING
			-- name pattern for dbs that will have these rights
	
	rights : ROOT_RIGHTS_SET
			-- set of rights for matching databases
	
	set_rights (new_rights : ROOT_RIGHTS_SET) is
		do
			rights := new_rights
		end

	make_with_rights (new_pattern: STRING; new_rights : ROOT_RIGHTS_SET) is
		do
			db_name_pattern := new_pattern.twin
			rights := new_rights
		end

feature -- {SUB_DISPATCHER_D}
	
	make (new_pattern : STRING) is
		require
			new_pattern /= Void
		do
			db_name_pattern := new_pattern.twin
			!!rights.make
		end

invariant

end -- DATABASE_RIGHTS
