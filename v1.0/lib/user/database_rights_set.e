-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Set of rights for databases 
--

class DATABASE_RIGHTS_SET

inherit
	
	POBJECT

	TAGABLE
		undefine
			copy,
			is_equal
		end

creation
	
	make,
	make_from_list

feature
	
	tag: STRING is
		do
			Result := generator
		end
	
	get_stamp_from_db_with_root (db_name : STRING; root_name : STRING): INTEGER is
		-- returns the bit stamp of root
		local
			database_rights : DATABASE_RIGHTS
		do
			database_rights := rights_for_database (db_name)
			if database_rights /= Void then
				Result := database_rights.rights.get_root_rights_stamp (root_name)
			else
				Result := -1
			end
		end

	rights_for_database (db_name : STRING) : DATABASE_RIGHTS is
		require
			db_name_ok: db_name /= Void
		local
			i: INTEGER
			db_right : DATABASE_RIGHTS
		do
			if db_rights /= Void then
				from i := 1 
				until (Result /= Void) or (i > db_rights.count)
				loop
					db_right := db_rights.i_th (i)
					if match_wild_card ($(db_name.to_c), $(db_right.db_name_pattern.to_c)) 
					 then
						Result := db_right
					end
					i := i + 1
				end
			end
		end
	
	append_database_rights (new_rights : DATABASE_RIGHTS) is
		require
			rights_ok: new_rights /= Void 
		do
			db_rights.extend (new_rights)
		ensure
			db_rights.has (new_rights)
		end
	
	remove_database_rights (old_rights : DATABASE_RIGHTS) is
		require
			rights_ok: old_rights /= Void
		do
			if db_rights.has (old_rights) then
				db_rights.remove_item (old_rights)
			end
		end
	

	db_rights : PLIST [DATABASE_RIGHTS]
			-- list of rights for all databases
	
feature {NONE}
	
	
	make is
		do
			!!db_rights.make ("PLIST[DATABASE_RIGHTS]")
		end

	make_from_list (list: like db_rights) is
		require
			list_exists: list /= Void
		do
			db_rights := list
		end
	
	match_wild_card (str, pattern : POINTER) : BOOLEAN is
		external "C"
		end


end -- DATABASE_RIGHTS_SET
