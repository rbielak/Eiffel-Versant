-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- This table associates Eiffel object IDs with Persistent object IDs.
-- This way we can find an 
--

class POBJECT_TABLE

inherit

	VERSANT_EXTERNALS

	VERSANT_POINTER_EXTERNALS
	
	EIF_VERS_EXTERNALS

	DB_GLOBAL_INFO

feature

	item (pobject_id : INTEGER) : POBJECT is
		require
			not_zero : pobject_id /= 0;
		local
			eif_id: INTEGER
			obj_ptr: POINTER
			err: INTEGER
		do
			if is_pinned (pobject_id) then

				obj_ptr := c_ptrfromcod (pobject_id)
				-- eif_id := get_db_int_o_ptr (obj_ptr, 8)
				eif_id := c_get_peif_id (obj_ptr)

				Result ?= identifier.id_object (eif_id);
				if (Result = Void) and (eif_id /= 0) then
					-- Object must have been garbage
					-- collected, unpin the entry

					-- This case should NEVER occur !!!!!!
					io.putstring ("Problem with pobject_table.item ")
					io.putstring ("eif_id = ");io.putint (eif_id); io.new_line
					io.putstring ("Pin count: ")
					io.putint (nbpins (pobject_id))
					io.putstring (" LOID=")
					io.putstring (c_get_loid (pobject_id))
					io.new_line
					io.putstring ("Please report to Richie or JP !!%N")

					-- set_db_int_o_ptr (obj_ptr, 8, 0)
					c_set_peif_id_and_clear_wm (obj_ptr, 0)

					if is_dirty (pobject_id) then
						err := o_unpinobj (pobject_id, 1)
					else
						err := o_unpinobj (pobject_id, 0)
					end
					count := count - 1
				end

				debug ("pobject_table")
					io.putstring ("poobject_table.item --> eif_id =");
					io.putint (eif_id); 
					io.putstring (" db_id= ");
					io.putint (pobject_id);
					io.new_line;
				end
			end
		ensure
			(Result /= Void) implies (Result.pobject_id = pobject_id)
		end;
	
	put (object : POBJECT; pobject_id : INTEGER) is
		require
			valid_pobject: object /= Void ;
			valid_id: (pobject_id /= 0);
		local
			obj_ptr: POINTER
		do
			obj_ptr := c_ptrfromcod (pobject_id)
			-- set_db_int_o_ptr (obj_ptr, 8, object.object_id)
			c_set_peif_id_and_clear_wm (obj_ptr, object.object_id)
			count := count + 1

			debug ("pobject_table")
				io.putstring ("pobject_table.put --> eif_id=");
				io.putint (object.object_id);
				io.putstring (" db_id= ");
				io.putint (pobject_id);
				io.new_line;
			end
		end;

	count: INTEGER

	dispose_object (pobject_id: INTEGER) is
		require
			not_zero : pobject_id /= 0
			session_active: db_interface.session_is_active
		local
			obj_ptr: POINTER
			err: INTEGER
		do
			if is_pinned (pobject_id) then
				debug ("pobject_table")
					io.putstring ("Unpining: ")
					io.putint (pobject_id)
					io.new_line
				end
				obj_ptr := c_ptrfromcod (pobject_id)
				-- set_db_int_o_ptr (obj_ptr, 8, 0)
				c_set_peif_id_and_clear_wm (obj_ptr, 0)
				if is_dirty (pobject_id) then
					err := o_unpinobj (pobject_id, 1)
				else
					err := o_unpinobj (pobject_id, 0)
					-- Release the memory for this object from cache 
					-- (only works properly in Versant 5.0.8)
					err := o_releaseobj (pobject_id)
				end
				count := count - 1
			elseif is_session_active then
				debug ("pobject_table")
					io.putstring ("Not pinned: ")
					io.putint (pobject_id)
					io.putstring (" and undisposed%N")
				end
			end
		end

feature
	
	identifier : IDENTIFIED is
		once
			!!Result
		end;

end -- POBJECT_TABLE
