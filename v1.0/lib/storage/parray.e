-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Persistent array
--

class PARRAY [T->POBJECT]

inherit

	POBJECT
		undefine
			setup, consistent,  generator
		redefine
			store_obj, retrieve_obj, store_shallow_obj,
			check_diff_obj, refresh_obj, reset_stamp_obj, change_root_obj,
			copy, dispose, is_equal, ref_count, ith_ref, ith_mem_ref, set_ith_ref,
			refresh_shallow
		end

	ARRAY [T]
		undefine
			copy, is_equal
		redefine
			generator
		end

	VSTR
		rename
			area as db_area,
			make as vstr_make
		undefine
			setup, consistent, generator, is_equal, dispose, copy
		redefine
			union_with, intersect_with, difference_with 
		end

creation

	make, make_from_array

feature

	copy (other: like Current) is
		do
			dispose_area
			pobject_copy (other)
			set_area (standard_clone (other.area))
			db_area := default_pointer
		end

	is_equal (other: like Current): BOOLEAN is
		local
			saved_db_area: POINTER
			saved_area: SPECIAL [T]
		do
			saved_area := area
			saved_db_area := db_area
			area := other.area
			db_area := other.db_area
			Result := pobject_is_equal (other)
			db_area := saved_db_area
			area := saved_area
			if Result then
				Result := area.is_equal (other.area)
			end
		end

	generator: STRING is
		do
			Result := generator_string
		end

	append (new_item: T) is
			-- Append new item to the array - resize the
			-- array as needed
		require
			not_void: new_item /= Void
		local
			last: INTEGER
		do
			last := count + 1
			resize (1, last)
			put (new_item, last)
		end -- append

	remove_void_entries is
		local
			i, j, ec: INTEGER
		do
			-- copy in place, removing Void entries
			from
				i := lower
				j := lower
			until i > upper
			loop
				if i /= j then
					put (item (i), j)
				end
				if item (i) /= Void then
					j := j + 1
				else
					-- count empty entries
					ec := ec + 1
				end
				i := i + 1
			end
			-- re-adjust the bounds
			if ec > 0 then
				if upper > ec then
					upper := upper - ec
					-- refit (upper - ec)
				else
					-- the array becomes empty
					upper := 0
				end
			end
		ensure
			-- no void entries left, array shrunk
		end

feature {POBJECT}

	store_obj (context: DB_OPERATION_CONTEXT) is
			-- Store a Parray
		local
			i, weak_link_id: INTEGER;
			obj: POBJECT
		do
			if allowed_to_store and then not db_operation_in_progress then
				dispose_area
				-- make sure the array has a valid "pobject_id" as one of the elements
				-- may reference this array
				pobject_store_obj (context)				
				-- Simply store any non-void entry in a vstr
				from i := lower
				until i > upper 
				loop
					obj := item (i)
					if obj /= Void then
						obj.store_obj (context)
						-- If the object is in another database create weak-link
--						if obj.database /= database then
--							weak_link_id := make_weak_link (obj)
--							db_area := c_build_int_vstr (db_area, weak_link_id)
--						else
							db_area := c_build_int_vstr (db_area, obj.pobject_id)

--						end
						debug ("parray")
							io.putstring ("Eiffel: Objid=")
							io.putint (obj.pobject_id)
							io.putstring (" db_area=")
							io.putstring (db_area.out)
							io.new_line
						end
					else
						db_area := c_build_int_vstr (db_area, 0)
					end
					i := i + 1
				end
				-- now store "db_area"
				db_interface.set_db_vstr_attr (pobject_id, $(("db_area").to_c), db_area);
			end
		end

	store_shallow_obj (context: DB_OPERATION_CONTEXT) is
			-- Shallow store the array and the elements
		local
			i: INTEGER
			obj: POBJECT
			weak_link_id: INTEGER
		do
			if allowed_to_store and then not db_operation_in_progress then
				-- Shallow store vstr
				dispose_area
				from i := lower
				until i > upper 
				loop
					obj := item(i)
					if obj /= Void then
--						if obj.database /= database then
--							weak_link_id := make_weak_link (obj)
--							db_area := c_build_int_vstr (db_area, weak_link_id)
--						else
							db_area := c_build_int_vstr (db_area, obj.pobject_id)
							
--						end
					else
						db_area := c_build_int_vstr (db_area, 0)
					end
					i := i + 1
				end
				-- Shallow store attributes
				pobject_store_shallow_obj (context)
			end
		end

	retrieve_obj is
			-- Retrieve an array (resize accordingly)
		local
			u_area: POINTER
		do
			debug ("parray")
				io.putstring ("Array retrieve_obj. Classname= ")
				io.putstring (generator)
				io.new_line
			end
			dispose_area
			pobject_retrieve_obj
			remake_from_db_area
		end

	refresh_shallow is
		do
			dispose_area
			pobject_refresh_shallow
			remake_from_db_area
		end

	refresh_obj (context: DB_OPERATION_CONTEXT) is
		local
			i: INTEGER
		do
			if not db_operation_in_progress then
				dispose_area
				pobject_refresh_obj (context)
				-- Remake the area and reload the objects
				remake_from_db_area
				-- Now refresh the objects
				from i := lower
				until i > upper
				loop
					if item(i) /= Void then
						item(i).refresh_obj (context)
					end
					i := i + 1
				end
			end
		end

	check_diff_obj (make_new_persistent: BOOLEAN; context: DB_OPERATION_CONTEXT) is
		local
			obj: POBJECT
			obj_id, i, vstr_count: INTEGER
			is_different, elements_differ, unset: BOOLEAN
		do
			if not db_operation_in_progress then
				pobject_check_diff_obj (make_new_persistent, context)
				if (pobject_id /= 0) and then
					(pobject_root_id /= db_interface.current_root_id)
				 then
					set_root_id_and_database
					unset := True
				end
				is_different := not context.diff_stack.empty
					and then context.diff_stack.item = Current;
				-- Check all the elements 
				vstr_count := integer_count
				from i := lower
				until i > upper
				loop
					obj := item (i)
					if i <= vstr_count then
						obj_id := c_get_entry (db_area, i - 1)
					else
						obj_id := 0
					end
					if obj /= Void then
						obj.check_diff_obj (make_new_persistent, context)
						-- If object ID is different
						-- or the item is brand new then we are different
						if (obj.pobject_id /= obj_id) or else
							(obj.pobject_id = 0) 
						 then
							elements_differ := True
						end
					end
					i := i + 1
				end
				if not is_different and elements_differ then
					context.diff_stack.put (Current)
				end
				if unset then
					unset_root_id_and_database
				end
			end
		end

	reset_stamp_obj (context: DB_OPERATION_CONTEXT) is
		local
			i: INTEGER
			obj: POBJECT
		do
			if not db_operation_in_progress then
				pobject_reset_stamp_obj (context)
				from i := lower
				until i > upper
				loop
					obj := item (i)
					if obj /= Void then
						obj.reset_stamp_obj (context)
					end
					i := i + 1
				end
			end
		end

	change_root_obj (new_root_id, old_root_id: INTEGER; context: DB_OPERATION_CONTEXT) is
		local
			i: INTEGER
			obj: POBJECT
		do
			if not db_operation_in_progress then
				pobject_change_root_obj (new_root_id, old_root_id, context)
				from i := lower
				until i > upper
				loop
					obj := item (i)
					if obj /= Void then
						obj.change_root_obj (new_root_id, old_root_id, context)
					end
					i := i + 1
				end
			end
		end

feature {DATABASE, POBJECT, POBJECT_CLOSURE_SCANNER, POBJECT_ACTION_COMMAND} 
	-- computation of closures	
	
	ref_count: INTEGER is
		do
			Result := count + pobject_ref_count
		end

	ith_ref (i: INTEGER): POBJECT is
		do
			if i <= count then
				Result := item (i)
			else
				Result := pobject_ith_ref (i - count)
			end
		end

	ith_mem_ref (i: INTEGER): POBJECT is
		do
			if i <= count then
				Result := item (i)
			else
				Result := pobject_ith_mem_ref (i - count)
			end
		end

	set_ith_ref (i: INTEGER; object: T) is
		do
			if i <= count then
				put (object, i)
			else
				pobject_set_ith_ref (i - count, object)
			end
		end

feature {NONE}

	remake_from_db_area is
			-- recreate the array from the db_area vstr
		local
			i: INTEGER
			pobj_id: INTEGER
			pobj: POBJECT
			pobj_cell: CELL[POBJECT]
			t_cell: CELL [T]
		do
			!!t_cell.put (Void)
			pobj_cell := t_cell
			make (lower, upper)
			from i := lower
			until i > upper 
			loop
				pobj_id := c_get_entry (db_area, i - 1)
				if pobj_id /= 0 then
					pobj := db_interface.rebuild_eiffel_object (pobj_id)
					pobj_cell.put (pobj)
					put (t_cell.item, i)
				else
					put (void, i)
				end
				i := i + 1
			end
		end

	dispose is
		do
			pobject_dispose
			c_dispose_delete_vstr (db_area)
		end

	generator_string: STRING is "PARRAY[POBJECT]"

feature{NONE}
	
	union_with, intersect_with, difference_with (other: like Current) is	
		do
			except.raise ("Not implemented for PARRAY")
		end

end -- PARRAY
