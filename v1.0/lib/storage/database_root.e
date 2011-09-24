-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Objects of this type contain information about the contents of a database
--

class DATABASE_ROOT

inherit
	
	POBJECT
	
creation
	
	{DATABASE} make

feature {DATABASE, DB_INTERNAL}
	
	name : STRING
			-- name of this database
	
	set_name (new_name: STRING) is
		do
			name := new_name
		end
	
	closed : BOOLEAN
			-- True if all the objects in the database
			-- form a closure (that is no object in this
			-- database references objects in other databases)
	
	set_closed (value : BOOLEAN) is
		do
			closed := value
		ensure
			closed = value
		end
	
	production: BOOLEAN
			-- true, if a production database
	
	set_production (value: BOOLEAN) is
		do
			production := value
		end
	
	database_id: INTEGER 
			-- ID of this database. Could be different than the
			-- Versant DB_ID
	
feature {DATABASE, ROOT_SERVER, DB_INTERNAL}

	roots : PLIST [ROOT_INFO]
			-- List of persistent roots found in this database


feature {NONE}

	
	make (lname : STRING; db_id: INTEGER) is
		require
			name_not_void: lname /= Void
			not_persistent: pobject_id = 0
		do
			name := lname.twin
			database_id := db_id
			!!roots.make ("PLIST[ROOT_INFO]")
		ensure
			name.is_equal (lname)		
		end

end -- DATABASE_INFO
