-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
indexing

	description: "Set of stamps for a list of persistent roots"

class RIGHTS_STAMP_SET

inherit

	DB_CONSTANTS

	LOW_LEVEL_DB_OPERATIONS

feature

	compute_rights_stamps (rights_set : ROOT_RIGHTS_SET;
						   roots : PLIST [ROOT_INFO]) is
		require
			rights_ok : (rights_set /= Void) 
			list_ok: roots /= Void
			database_has_persistent_roots: (roots.count > 0)
		local
			i : INTEGER
			root_index: INTEGER
			ri : ROOT_INFO
			stamp : INTEGER
			obj_id: INTEGER
			root_name: STRING
		do
			if roots.count = 0 then
				io.putstring ("No persistent roots in db: ")
				io.putstring (roots.database.name)
				io.putstring (" Most likely database wasn't fed. %N")
				except.raise ("no persistent roots in database")
			end
			obj_id := roots.i_th_object_id (roots.count)
			!!stamps_array.make (0, get_integer (obj_id, "root_index"))
			stamps_array.put (read_write_allowed, 0)

			from i := 1
			until i > roots.count
			loop
				-- Get the i-th root entry
				obj_id := roots.i_th_object_id (i)
				-- Check that numbers are consistent
				root_name := get_string (obj_id, "root_name")
				stamp := rights_set.get_root_rights_stamp (root_name)
				if stamp = -1 then
					stamp := 0
					io.putstring ("*** Warning: no rights for root: ")
					io.putstring (root_name)
					io.new_line
				end
				stamps_array.put (stamp, get_integer (obj_id, "root_index"))
				i := i + 1
			end
		end

	update_rights_stamps (rights_set : ROOT_RIGHTS_SET;
						   roots : PLIST [ROOT_INFO]) is
		require
			rights_set_valid: rights_set /= Void
			roots_valid: (roots /= Void) and then (roots.count > 0)
		local
			i: INTEGER 
			root_name: STRING
			stamp: INTEGER
			obj_id: INTEGER
		do
			from i := 1
			until i > roots.count
			loop
				-- Get the i-th root entry
				obj_id := roots.i_th_object_id (i)
				-- Check that numbers are consistent
				root_name := get_string (obj_id, "root_name")
				stamp := rights_set.get_root_rights_stamp (root_name)
				-- update the stamp if it exists
				if stamp /= -1 then
					io.putstring ("Updating stamp for root: ")
					io.putstring (root_name)
					io.new_line
					stamps_array.put (stamp, get_integer (obj_id, "root_index"))
				end
				i := i + 1
			end
		end

	rights_stamp_by_index (root_index : INTEGER) : INTEGER is
		do
			if (stamps_array = Void) or else (root_index > stamps_array.upper) then
				Result := read_write_allowed
			else
				Result := stamps_array @ root_index
			end
		end

feature {NONE}

	stamps_array : ARRAY [INTEGER]
			-- array of access stamps, indexed by root ID

end -- RIGHTS_STAMP_SET
