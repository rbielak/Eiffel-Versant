-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- This list keeps all the elements in memory and only
--

class PLIST_OBJ[T->POBJECT]

inherit

	FAST_RLIST [T]
		undefine
			generator, copy, is_equal
		redefine
			tags, item_from_tag, twin, is_valid_element
		end
	
	POBJECT 
		undefine
			out, generator
		redefine
			store_obj, retrieve_obj, 
			 store_shallow_obj, check_diff_obj,
			refresh_obj, reset_stamp_obj, change_root_obj,
			ref_count, set_ith_ref, ith_ref, ith_mem_ref,
			copy, is_equal, twin, refresh_shallow, dispose
		end
	
	VSTR
		rename
			area as db_area,
			make as vstr_make
		undefine
			dispose, copy, is_equal, out, twin,  generator
		redefine
			union_with, intersect_with, difference_with
		end
	

creation

	make,
	make_from_array

feature 
	
	generator : STRING is
		once
			Result := "PLIST_OBJ[POBJECT]";
		end;
	
	copy (other : like Current) is
		do
			dispose_area
			pobject_copy (other)
			db_area := default_pointer
		end
	
	twin : like Current is
		local
			l_active: FL_LINKABLE[T]
		do
			!!Result.make
			Result.copy (Current)
			Result.wipe_out
			-- Now insert elements of the current into the twin
			from 
				l_active := first_element
			until 
				l_active = Void
			loop
				Result.extend (l_active.item)
				l_active := l_active.right
			end
		ensure then
			cursor_stays: position = old position
		end
	
	is_equal (other : like Current) : BOOLEAN is
		local
			saved_area : POINTER
		do
			saved_area := db_area
			db_area := other.db_area
			Result := pobject_is_equal (other)
			db_area := saved_area
		end

	is_valid_element (litem: T): BOOLEAN is
		do
			Result := litem /= Void
		end

	store_obj (context: DB_OPERATION_CONTEXT) is
		local
			el : T;
			l_active: FL_LINKABLE [T]
			weak_link_id: INTEGER
		do
			if allowed_to_store and then not db_operation_in_progress then
				dispose_area
				pobject_store_obj (context)
				from
					l_active := first_element
				until
					l_active = Void
				loop
					el := l_active.item;
					if el /= Void then
						el.store_obj (context)
						db_area := c_build_int_vstr (db_area, el.pobject_id)
					end;
					l_active := l_active.right
				end;
				-- store the new vstr
				db_interface.set_db_vstr_attr (pobject_id, $(("db_area").to_c), db_area);
			end;
		ensure then
			cursor_stays: position = old position
		end;

	store_shallow_obj (context: DB_OPERATION_CONTEXT) is
		local
			el : T;
			l_active: FL_LINKABLE [T]
			weak_link_id: INTEGER
		do
			if allowed_to_store and then not db_operation_in_progress then
				dispose_area
				pobject_store_shallow_obj (context)
				from
					l_active := first_element
				until
					l_active = Void
				loop
					el := l_active.item
					if el /= Void then
						if el.pobject_id = 0 then
							el.store_shallow_obj (context)
						end
--						if el.database = database then
							db_area := c_build_int_vstr (db_area, el.pobject_id)
--						else
--							weak_link_id := make_weak_link (el)
--							db_area := c_build_int_vstr (db_area, weak_link_id)
--						end
					end
					l_active := l_active.right
				end
				db_interface.set_db_vstr_attr (pobject_id, $(("db_area").to_c), db_area)

			end
		ensure then
			cursor_stays: position = old position
		end;
	
--	find_new_obj (context: DB_OPERATION_CONTEXT) is
--		local
--			el: T;
--			l_active: FL_LINKABLE [T]
--			unset, depends_on_new: BOOLEAN
--		do
--			if not db_operation_in_progress then
--				pobject_find_new_obj (context)
--				-- Set the default root_id, if it's different
--				if (pobject_root_id /= 0) and then
--					(pobject_root_id /= db_interface.current_root_id) then
--					set_root_id_and_database
--					unset := True
--				end;
--				-- Find new objects in the current list
--				from
--					-- start
--					l_active := first_element
--				until
--					-- after
--					l_active = Void
--				loop
--					el := l_active.item
--					if el /= Void then
--						el.find_new_obj (context)
--						if el.pobject_id = 0 then
--							depends_on_new := True
--						end
--					end;
--					-- forth
--					l_active := l_active.right
--				end;
--				if depends_on_new and (pobject_id /= 0) then
--					context.old_objects.put (Current); 
--				end
--				if unset then
--					unset_root_id_and_database
--				end
--			end
--		ensure then
--			cursor_stays: position = old position
--		end;
	
	reset_stamp_obj (context: DB_OPERATION_CONTEXT) is
		local
			el : T; 
			l_active: FL_LINKABLE [T]
		do
			if not db_operation_in_progress then
				pobject_reset_stamp_obj (context)
				from
					-- start
					l_active := first_element
				until
					-- after
					l_active = Void
				loop
					el := l_active.item;
					if el /= Void then
						el.reset_stamp_obj (context)
					end;
					-- forth
					l_active := l_active.right
				end;
			end
		ensure then
			cursor_stays: position = old position
		end;
	
	change_root_obj (new_root_id, old_root_id: INTEGER; context: DB_OPERATION_CONTEXT) is
		local
			el : T
			l_active: FL_LINKABLE [T]
		do
			if not db_operation_in_progress then
				pobject_change_root_obj (new_root_id, old_root_id, context)
				from
					-- start
					l_active := first_element
				until
					-- after
					l_active = Void
				loop
					el := l_active.item;
					if el /= Void then
						el.change_root_obj  (new_root_id, old_root_id, context);
					end;
					-- forth
					l_active := l_active.right
				end;
			end
		ensure then
			cursor_stays: position = old position
		end;
	
	retrieve_obj is -- (context: DB_OPERATION_CONTEXT) is
		local
			i: INTEGER
			el: T
			el_obj_id: INTEGER
			pcell: CELL[POBJECT]
			tcell: CELL[T]
			pobj: POBJECT
		do
			pobject_retrieve_obj -- (context)
			-- now make the bc_rlist from Plist
			make
			remake_from_area
		end;
	
	check_diff_obj (make_new_persistent: BOOLEAN; context: DB_OPERATION_CONTEXT) is
		local
			el : T;
			i : INTEGER;
			is_different, elements_differ, unset : BOOLEAN;
			l_active: FL_LINKABLE[T]
		do
			if not db_operation_in_progress then
				pobject_check_diff_obj (make_new_persistent, context);
				if (pobject_id /= 0) and then 
					(pobject_root_id /= db_interface.current_root_id)
				 then
					set_root_id_and_database
					unset := True
				end
				is_different := not context.diff_stack.empty and then
						     context.diff_stack.item = Current;
				-- If counts are different then the objects changed
				if (count /= integer_count) then
					elements_differ := True
				end
				from 
					-- start
					l_active := first_element
					i := 1;
				until 
					-- after
					l_active = Void
				loop
					el := l_active.item;
					el.check_diff_obj (make_new_persistent, context);
					if not elements_differ then
						-- Check that in memory list matches  the persistent
						-- list. Make sure to notice new elements
						-- Worry about weak-links
						-- first get the object_id in the vstr
						if el.pobject_id = 0 then
							-- New object in the list, but not in vstr
							elements_differ := True
						else
							elements_differ := el.pobject_id /= i_th_integer (i)
						end
					end
					-- forth
					l_active := l_active.right
					i := i + 1
				end; --- loop
				-- Shallow attributes are the same,but elements differ, so we 
				-- have to store this object again
				if not is_different and elements_differ then
					context.diff_stack.put (Current); 
					debug ("diff_scanner")
						io.putstring (generator);
						io.putstring (" - difference found in elements...%N");
					end
				end
				if unset then
					unset_root_id_and_database
				end
			end
		ensure then
			cursor_stays: position = old position
		end
	
	refresh_shallow is
		do
			pobject_refresh_shallow
			-- Now rebuild the list
			remake_from_area
		end

	refresh_obj (context: DB_OPERATION_CONTEXT) is
		do
			if not db_operation_in_progress then
				pobject_refresh_obj (context)
				-- Now rebuild the list
				remake_from_area
			end
		end

	
	tags: FAST_RLIST [STRING]  is
		local
			an_object: POBJECT;
			tagable: POBJECT_TAGABLE;
			aborted: BOOLEAN;
			l_active: FL_LINKABLE [T]
		do
			from
				!!Result.make
				-- start
				l_active := first_element
			until
				(l_active = Void) or aborted
			loop
				an_object := l_active.item
				if an_object /= Void then
					tagable ?= an_object
					if tagable = Void then
						aborted := true
					else
						Result.extend (tagable.tag)
					end
				end
				-- forth
				l_active := l_active.right
			end
			if aborted then
				Result := Void
			end
		ensure then
			cursor_stays: position = old position
		end -- tags
	
	item_from_tag (a_tag: STRING): T is
			-- From RLIST.
		local
			an_object: POBJECT;
			tagable: POBJECT_TAGABLE;
			aborted: BOOLEAN
			l_active: FL_LINKABLE [T]
		do
			from
				-- start
				l_active := first_element
			until
				(l_active = Void) or aborted or Result /= Void
			loop
				an_object := l_active.item
				if an_object /= Void then
					tagable ?= an_object
					if tagable = Void then
						aborted := true
					elseif tagable.tag.is_equal (a_tag) then
						Result := l_active.item
					end
				end
				-- forth
				l_active := l_active.right
			end
			if aborted then
				Result := Void
			end
		ensure then
			cursor_stays: position = old position
		end -- item_from_tag
	
feature {DATABASE, POBJECT, POBJECT_CLOSURE_SCANNER, POBJECT_ACTION_COMMAND} -- computation of closures	
	
	ref_count : INTEGER is
		do
			Result := count
		end
	
	ith_ref, ith_mem_ref (i : INTEGER) : T is
		do
			Result := i_th(i)
		end
	
	set_ith_ref (i : INTEGER; object : T) is
		do
			put_i_th (object, i)
		end

feature {NONE}
	
	dispose is
		do
			pobject_dispose
			c_dispose_delete_vstr (db_area)
		end

feature {PLIST_OBJ}

	remake_from_area is
		local
			i: INTEGER
			pcell: CELL[POBJECT]
			tcell: CELL[T]
			pobj: POBJECT
			pobj_id: INTEGER
		do			
			wipe_out;
			if db_area /= default_pointer then
				!!tcell.put (Void)
				pcell := tcell
				from i := 1
				until i > integer_count
				loop
					pobj_id := i_th_integer (i)
					pobj := db_interface.rebuild_eiffel_object (pobj_id)
					pcell.put (pobj)
					extend (tcell.item)
					i := i + 1
				end;
			end

		end

feature{NONE}
	
	union_with, intersect_with, difference_with (other: like Current) is	
		do
			except.raise ("Not implemented for PLIST_OBJ")
		end

end -- PLIST_OBJ
