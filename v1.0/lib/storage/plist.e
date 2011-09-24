-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class PLIST [T->POBJECT]

inherit

	POBJECT
		redefine
			store_obj, store_shallow_obj, generator,
			copy, is_equal, check_diff_obj, retrieve_obj,
			refresh_obj, refresh_shallow, dispose,
			reset_stamp_obj, change_root_obj, ith_ref, ith_mem_ref,
			ref_count, set_ith_ref, recover_after_abort
		end

	RLIST [T]
		undefine
			generator, copy, is_equal
		redefine
			has, tags, item_from_tag, type_from_tag, is_valid_element
		end

	VSTR
		rename
			make as vstr_make,
			integer_count as count,
			copy_area as re_make_from_vstr
		undefine
			generator, is_equal, dispose
		redefine
			copy, union_with, intersect_with, difference_with
		end
	
	SHARED_PRIMARY_CONTAINER
		undefine
			generator, copy, is_equal
		end

	SHARED_ROOT_SERVER
		undefine
			generator, copy, is_equal
		end
	
	DB_INTERNAL
		undefine
			generator, copy, is_equal
		end

creation

	make,
	make_from_array,
	make_from_plist_obj

creation {SELECT_QUERY, CLASS_SELECT_QUERY, DB_QUERY, DB_PATH_QUERY, PLIST_OBJ, MAN_SPEC, DB_INTERNAL}

	make_from_vstr

feature -- copy and equality

	copy (other: like Current) is
		do
			debug ("plist")
				io.putstring ("PLIST.copy called %N")
			end

			dispose_area
			pobject_copy (other)
			area := default_pointer
			vstr_copy (other)
			eiffel_area := other.eiffel_area.twin
		end

	is_equal (other: like Current): BOOLEAN is
		local
			saved_area: POINTER
			saved_eiffel_area: VSTR
			i, my_i_th, other_i_th: INTEGER
			obj: POBJECT
		do
			saved_area := area
			saved_eiffel_area := eiffel_area
			area := other.area
			eiffel_area := other.eiffel_area

			Result := pobject_is_equal (other)

			area := saved_area
			eiffel_area := saved_eiffel_area

			if Result and then (count = other.count) then
				-- now compare the areas, since they are of the same size
				from i := 1
				until (i > count) or not Result
				loop
					my_i_th := i_th_integer (i)
					other_i_th := other.i_th_integer (i)
					if (my_i_th /= 0) and (other_i_th /= 0) then
						-- Both pobject IDs are present
						Result := my_i_th = other_i_th
					elseif (my_i_th = 0) and (other_i_th /= 0) then
						-- our pobject ID is missing, but other is there
						obj ?= id_object (eiffel_area.i_th_integer (i))
						if obj /= Void then
							Result := obj.pobject_id = other_i_th
						else
							Result := False
						end
					elseif (my_i_th /= 0) and (other_i_th = 0) then
						obj ?= id_object (other.eiffel_area.i_th_integer (i))
						if obj /= Void then
							Result := obj.pobject_id = my_i_th
						else
							Result := False
						end
					else
						-- both ID are still 0, check Eiffel object IDs
						Result := eiffel_area.i_th_integer (i) = other.eiffel_area.i_th_integer (i)
					end
					i := i + 1
				end
			else
				Result := false
			end
		end

feature 

	generator: STRING is
		do
			Result := plist_generator
		end

	is_valid_element (litem: T): BOOLEAN is
		do
			Result := litem /= Void
		end

	empty: BOOLEAN is
			-- True if list is empty
		do
			Result := count = 0
		end

feature -- adding items

	extend (litem: T) is
			-- Add new item to the end list
		do
			if (pobject_id /= 0) and then not write_allowed then
				-- Check for add access
				except.raise ("Not allowed to add to PLIST")
			end
			if pobject_id /= 0 then
				-- set the  PCLASS and root id in the item if not yet set
				if litem.pobject_class = Void then
					db_interface.force_class_on_new_object (litem, pobject_class.db)
					litem.set_root_id (pobject_root_id)
				end
			end
			-- add Eiffel ID object ID vstr
			eiffel_area.extend_integer (litem.object_id)
			-- also append to the POBJECT ID vstr
			extend_integer (litem.pobject_id)
			memorize_item (litem)
			publish (Void)
			debug ("plist")
				io.putstring ("POBJECTID: ")
				io.putint (pobject_id)
				io.putstring (" ...end of Extend%N")
				io.putstring ("area: ")
				dump_integer
				io.putstring ("Eiffelarea:")
				eiffel_area.dump_integer
			end
		ensure then
			-- count = old count + 1
			has (litem)
		end -- extend

	insert_i_th (litem: T; index: INTEGER) is
			-- If index is less that 1 then insert will
			-- happen at the head, if it's more than
			-- "count" then the new element will go at the
			-- tail
		require
			item_is_valid: is_valid_element (litem)
		do
			if (pobject_id /= 0) and then not write_allowed then
				except.raise ("Not allowed to add to PLIST")
			end
			if index > count then
				extend (litem)
			else
				if pobject_id /= 0 then
					-- set the PCLASS and root id in the item if not yet set
					if litem.pobject_class = Void then
						db_interface.force_class_on_new_object (litem, pobject_class.db)
						litem.set_root_id (pobject_root_id)
					end
				end
				-- Here "index <= count"
				eiffel_area.insert_i_th_integer (litem.object_id, index)
				insert_i_th_integer (litem.pobject_id, index)
			end
			memorize_item (litem)
			publish(void)
		end -- insert_i_th
	
	put_i_th (litem: T; index: INTEGER) is
			-- Replace the i-th item of the list
		require
			index_ok: (index > 0) and (index <= count)
			item_is_valid: is_valid_element (litem)
		local
			eif_id: INTEGER
		do
			if (pobject_id /= 0) and then not write_allowed then
				except.raise ("Not allowed to update to PLIST")
			end
			-- Replace the i_th entry in the vstr
			-- make sure index still valid (could have
			-- been changed by someone else)
			if (index > count) then
				except.raise ("PLIST.put_i_th - index out of range")
			end
			if pobject_id /= 0 then
				-- set the PCLASS and root id in the item if not yet set
				if litem.pobject_class = Void then
					db_interface.force_class_on_new_object (litem, pobject_class.db)
					litem.set_root_id (pobject_root_id)
				end
			end
			eiffel_area.put_i_th_integer (litem.object_id, index)
			put_i_th_integer (litem.pobject_id, index)
			memorize_item (litem)
			-- publish (Void) ???????
		end -- put_i_th

feature -- removing items

	remove_i_th (i: INTEGER) is
			-- Not a particularly efficient implementation of
			-- remove_i_th. You'd be better of using "remove_item"
		require
			index_valid: (i > 0) and (i <= count)
			write_allowed: write_allowed
		local
			item_object_id: INTEGER
		do
			debug ("plist")
				io.putstring ("PLIST.remove_i_th_called%N")
			end
			if (pobject_id /= 0) and then not write_allowed then
				except.raise ("Not allowed to remove items")
			end
			-- transient area
			eiffel_area.remove_i_th_integer (i)
			-- persistent area
			remove_i_th_integer (i)
			publish (void)
		end

	remove_all, wipe_out is
		do
			if (pobject_id /= 0) and then not write_allowed then
				except.raise ("Not allowed to remove items")
			end
			dispose_area
			!!eiffel_area.make (default_pointer)
			publish (void)
		ensure then
			no_elements: count = 0
		end -- remove_all

	remove_item (litem: T) is
		local
			lindex: INTEGER
		do
			debug ("plist")
				io.putstring ("PLIST.remove_item called%N")
				if count /= eiffel_area.integer_count then
					io.putstring ("POBJECTID: ")
					io.putint (pobject_id)
					io.new_line
					io.putstring ("area: ")
					dump_integer
					io.putstring ("Eiffelarea:")
					eiffel_area.dump_integer
					except.raise ("count inconsistent")
				end
			end
			if (pobject_id /= 0) and then not write_allowed then
				except.raise ("Not allowed to remove items")
			end
			if litem.pobject_id /= 0 then
				lindex := index_of_integer (litem.pobject_id)
			end
			if (lindex = 0) then
				lindex := eiffel_area.index_of_integer (litem.object_id) 
			end
			if lindex /= 0 then
				eiffel_area.remove_i_th_integer (lindex)
				remove_i_th_integer (lindex)
			end
			publish (void)
			debug ("plist")
				io.putstring ("POBJECTID: ")
				io.putint (pobject_id)
				io.putstring (" ...end of remove%N ")
				io.putstring ("area: ")
				dump_integer
				io.putstring ("Eiffelarea:")
				eiffel_area.dump_integer
			end
		end -- remove_item

feature -- membership tests

	has (litem: T): BOOLEAN is
		do
			if (pobject_id /= 0) and then not read_allowed then
				except.raise ("Not allowed to read PLIST")
			end
			Result := eiffel_area.has_integer (litem.object_id)
			if (not Result) and then (litem.pobject_id /= 0) then
				Result := has_integer (litem.pobject_id)
			end
		end -- has

	index_of (litem: T): INTEGER is
		require
			read_allowed: read_allowed
		do
			if (pobject_id /= 0) and then not read_allowed then
				except.raise ("Not allowed to read PLIST")
			end
			Result := eiffel_area.index_of_integer (litem.object_id)
			if (Result = 0) and then (litem.pobject_id /= 0) then
				Result := index_of_integer (litem.pobject_id)
			end
		end -- index_of

feature -- operations with object_ids

	i_th_object_id (i: INTEGER): INTEGER is
			-- persistent object_id of the i_th object
		require
			i > 0 and i <= count
		do
			Result := i_th_integer (i)
		end -- i_th_object_id
	
	put_i_th_object_id (obj_id: INTEGER; i: INTEGER) is
			-- Insert an object ID into the list
		require
			valid_id: obj_id /= 0
			valid_index: (0 < i) and (i <= count)
		do
			-- Erase the corresponding Eiffel entry
			eiffel_area.put_i_th_integer (0, i)
			put_i_th_integer (obj_id, i)
		end
	
	i_th_type (i: INTEGER): STRING is
			-- Type name of the i-th entry in the list
		require
			i > 0 and i <= count
		local
			eif_id: INTEGER
			obj: POBJECT
		do
			eif_id := eiffel_area.i_th_integer (i)
			if eif_id /= 0 then
				-- object is in memory
				obj ?= id_object (eif_id)
				if obj /= Void then
					Result := obj.generator
				end
			end
			if Result = Void then
				Result := db_interface.c_get_class_name (i_th_integer (i))
			end
		end


feature {NONE}  -- tags

	name_string: STRING is "name"

feature -- tags

	tags: BOUNDED_RLIST [STRING] is
			-- Return a list of values of the "name" attribute of
			-- the objects contained in the list. If those
			-- objects don't have a name atribute, Void is returned.
		local
			list: BOUNDED_RLIST [STRING]
			ct, i, one_pid: INTEGER
			no_name_attribute: BOOLEAN
			one_name: STRING
			one_obj: NAMED_MANAGEABLE
		do
			if count > 0 then
				from
					i := 1
					ct := count
					!!list.make (ct)
				until
					i > ct or no_name_attribute
				loop
					one_pid := eiffel_area.i_th_integer (i)
					if one_pid /= 0 then
						one_obj ?= id_object (one_pid)
					else
						one_pid :=i_th_integer (i)
						-- See if we already have this in memory
						one_obj ?= db_interface.object_table.item (one_pid)
					end
					if one_obj /= Void then
						one_name := one_obj.name
					else
						one_name := db_interface.get_db_string_attr (one_pid,
								$(name_string.to_c))
						if db_interface.c_get_error = 6005 then
							one_name := Void
							no_name_attribute := True
						end
					end
					if one_name /= Void then
						list.arrayed_list_extend (one_name)
					end
					i := i + 1
				end
				if not no_name_attribute then
					Result := list
				end
			end
		ensure then
			consistent: (Result /= Void) implies (Result.count = count)
		end -- tags

	type_from_tag (a_tag: STRING): STRING is
			-- type of an item with the specific tag
		do
			if count < 1000 then
				query.set_evaluation_in_client
			else
				query.set_evaluation_in_server
			end
			query.execute (Current, <<a_tag>>)
			if query.last_result /= Void then
				Result ?= query.last_result.i_th_type (1)
				query.reset_last_result
			end
		end -- type_from_tag

	item_from_tag (a_tag: STRING): T is
		local
			pcell: CELL [POBJECT]
			temp_cell: CELL [T]
		do
			if (pobject_id /= 0) and then not read_allowed then
				except.raise ("Not allowed to read PLIST")
			end
			if count < 1000 then
				query.set_evaluation_in_client
			else
				query.set_evaluation_in_server
			end
			query.execute (Current, <<a_tag>>)
			if query.last_result /= Void then
				!!temp_cell.put (Void)
				pcell := temp_cell
				pcell.put (query.last_result.i_th (1))
				Result := temp_cell.item
				query.reset_last_result
			end
		end -- item_from_tag


feature -- operations with other lists

	append_list (other: PLIST[T]) is
		require
			not_void: other /= Void
		local
			object: T
		do
			if (pobject_id /= 0) and then not write_allowed then
				except.raise ("Not allow to append_list")
			end
			concat_area (other)
			eiffel_area.concat_area (other.eiffel_area)
		ensure
			count = (old count) + other.count
		end

	append_array (items: ARRAY [T]) is
			-- append items from an array at the end of the list
		require
			items_not_void: items /= Void
			items_not_empty: items.count > 0
		local
			i: INTEGER
		do
			if (pobject_id /= 0) and then not write_allowed then
				-- Check for add access
				except.raise ("Not allowed to add to PLIST")
			end
			from i := items.lower
			until i > items.upper
			loop
				if pobject_id /= 0 then
					-- set the  PCLASS and root id in the item if not yet set
					if (items @ i).pobject_class = Void then
						db_interface.force_class_on_new_object (items @ i, pobject_class.db)
						(items @ i).set_root_id (pobject_root_id)
					end
				end
				-- add Eiffel ID object ID vstr
				eiffel_area.extend_integer ((items @ i).object_id)
				-- also append to the POBJECT ID vstr
				extend_integer ((items @ i).pobject_id)
				memorize_item (items @ i)
				i := i + 1
			end
			publish (Void)
		ensure
			valid_count: count = old count + items.count
		end

	refresh_list is
		do
			debug ("plist")
				io.putstring ("PLIST.refresh_list called !!!@&**&( %N")
			end
			refresh
			dispose_area
			area := db_interface.get_db_ptr_attr (pobject_id, $(area_string.to_c))
		end

	union_with (other: PLIST [T]) is
		local
			ea: VSTR
			a_count, i, obj_id : INTEGER
			obj: POBJECT
		do
			debug ("plist")
				io.putstring ("PLIST.union_with called%N")
			end
			-- If we are empty just copy other
			if count = 0 then
				re_make_from_vstr (other)
				!!eiffel_area.make_a_copy (other.eiffel_area)
			elseif other.count /= 0 then
				-- Note: If the other is empty, there is no work to do
				--
				-- compute the union the areas
				vstr_union_with (other)
				-- make new Eiffel area
				!!ea.make_a_copy (eiffel_area)
				ea.integer_union_with (other.eiffel_area)
				!!eiffel_area.make_empty (byte_count)
				add_transients_to_area (ea)
			end
			debug ("plist")
				io.putstring ("PLIST.union_with exiting%N")
			end
		end

	intersect_with (other: PLIST [T]) is
		local
			ea: VSTR
		do
			debug ("plist")
				io.putstring ("PLIST.intersect_with called%N")
			end
			if other.count = 0 then
				-- make current list empty
				dispose_area
				!!eiffel_area.make (default_pointer)
			elseif count /= 0 then
				-- Do persistent vstr
				vstr_intersect_with (other)
				-- compute intersection of transient
				!!ea.make_a_copy (eiffel_area)
				ea.integer_intersect_with (other.eiffel_area)
				!!eiffel_area.make_empty (byte_count)
				add_transients_to_area (ea)
			end
		end
	
	difference_with (other: PLIST [T]) is
		local
			ea: VSTR
		do
			debug ("plist")
				io.putstring ("PLIST.difference_with called%N")
			end
			if (other.count /= 0) and (count /= 0) then
				vstr_difference_with (other)
				!!ea.make_a_copy (eiffel_area)
				ea.integer_difference_with (other.eiffel_area)
				!!eiffel_area.make_empty (byte_count)
				add_transients_to_area (ea)
			end
		end
	
feature {NONE}
	
	add_transients_to_area (vstr: VSTR) is
			-- add any transient objects to the areas
		require
			vstr /= Void
		local
			i, a_count, obj_id: INTEGER
			obj: POBJECT
		do
			-- now add anything that as transient to the union
			from 
				i := 1
				a_count := vstr.integer_count
			until i > a_count
			loop
				obj_id := vstr.i_th_integer (i)
				obj ?= id_object (obj_id) 
				if obj /= Void then
					-- If the transient object is not already in the
					-- "area" add it to the end
					if (obj.pobject_id = 0) or else (not has_integer (obj.pobject_id))
					 then
						eiffel_area.extend_integer (obj_id)
						extend_integer (0)
					end
				end
				i := i + 1
			end
		end

feature -- creation

	make (new_gen: STRING) is
		do
			plist_generator := clone (new_gen)
			plist_generator.prune_all (' ')
			if plist_generator.index_of ('[', 1) = 0 then
				except.raise ("Invalid generator for PLIST")
			end
			db_interface.list_manager.add (Current)
			parent_container := default_container
			-- New lists are writeable
			rights_stamp := db_interface.read_write_allowed
			-- make empty transient area
			!!eiffel_area.make (default_pointer)
		end -- make

	make_from_array (new_gen: STRING; arr: ARRAY [T]) is
		local
			i: INTEGER
		do
			db_interface.start_transaction
			make (new_gen)
			from
				i := arr.lower
			until
				i > arr.upper
			loop
				extend (arr @ i)
				i:= i + 1
			end
			db_interface.end_transaction
		end

	make_from_plist_obj (new_gen: STRING; plo: PLIST_OBJ [T]) is
		do
			make (new_gen)
			if plo /= Void then
				from plo.start
				until plo.after
				loop
					extend (plo.item)
					plo.forth
				end
			end
		end

feature -- import

	import (litem: T; source_list: PLIST[T]) is
			-- Import an item into this list. If the item
			-- resides in another database it will be
			-- copied into the list's database
		require
			litem_exists: litem /= Void and (litem.pobject_id /= 0)
			list_exists: (source_list /= Void) implies source_list.has (litem)
		local
			copied_item: T
		do
			db_interface.start_transaction
			if source_list /= Void then
				source_list.remove_item (litem)
			end
			if litem.database = database then
				extend (litem)
			else
				-- Give the new objects our root id
				copied_item := database.imported (litem, pobject_root_id)
				extend (copied_item)
			end
			db_interface.end_transaction
		ensure
			not db_operation_in_progress
		end


feature -- item access

	i_th, item (i: INTEGER): T is
		do
			if (pobject_id /= 0) and then not read_allowed then
				except.raise ("Not allowed to retrieve from PLIST")
			end
			Result := i_th_obj (i)
			if Result /= Void then
				memorize_item (Result)
			end
		end -- i_th
	
	first: T is
		do
			if count > 0 then
				Result := item (1)
			end
		ensure
			(count > 0) implies (Result /= Void)
		end
	
	last: T is
		do
			if count > 0 then
				Result := item (count)
			end
		ensure
			(count > 0) implies (Result /= Void)
		end


	preload is
			-- load all the elements of the PLIST into memory
		local
			one_item: POBJECT
			i, err: INTEGER
			to_load: VSTR
		do
			-- make a vstr of objects that need to be pulled into the 
			-- cache
			!!to_load.make (default_pointer)
			from 
				i := 1
			until i > count 
			loop
				if (eiffel_area.i_th_integer (i) = 0) and
				 i_th_integer (i) /= 0 
				 then
					-- not already in memory
					to_load.extend_integer (i_th_integer (i))
				end
				i := i + 1
			end
			-- do a group read, but don't pin
			err := db_interface.o_greadobjs (to_load.area, $(database.name.to_c), False, 0)
			check_error
			from i := 1
			until i > count
			loop
				one_item := i_th_obj (i)
				i := i + 1
			end	
		end


feature {DB_INTERFACE_INFO}

	set_generator (new_gen: STRING) is
		do
			plist_generator := new_gen
		end

feature {POBJECT, DB_INTERNAL}

	plist_generator: STRING
			-- generator string

	i_th_obj (i: INTEGER): T is
		local
			obj_id: INTEGER
			pcell: CELL [POBJECT]
			temp_cell: CELL[T]
			object: POBJECT
		do
			debug ("plist")
				if count /= eiffel_area.integer_count then
					io.putstring ("POBJECTID: ")
					io.putint (pobject_id)
					io.putstring ("area: ")
					dump_integer
					io.putstring ("Eiffelarea:")
					eiffel_area.dump_integer
					except.raise ("count inconsistent")
				end
			end
			obj_id := eiffel_area.i_th_integer (i)
			if obj_id /= 0 then
				object ?= id_object (obj_id)
			end
			if object = Void then
				obj_id := i_th_integer (i)
				if obj_id /= 0 then
					object := db_interface.rebuild_eiffel_object (obj_id)
				end
			end
			if object /= Void then
				eiffel_area.put_i_th_integer (object.object_id, i)
				-- *** WARNING ****
				-- The use of "temp_cell" must be always done after the call
				-- to "rebuild_eiffel_object"
				-- no other calls must be done, since this code is not re-entrant
				!!temp_cell.put (Void)
				pcell := temp_cell
				pcell.put (object)
				Result := temp_cell.item
			end
		end

	retrieve_obj is
		do
			if not db_operation_in_progress then
				pobject_retrieve_obj 
				db_interface.list_manager.add (Current)
				if pobject_class /= Void then
					plist_generator := pobject_class.name
				end
				if area /= default_pointer then
					!!eiffel_area.make_empty (byte_count)
				else
					!!eiffel_area.make (default_pointer)
				end
			end
		end

	store_obj (context: DB_OPERATION_CONTEXT) is
		local
			obj_id: INTEGER
			object: POBJECT
			i: INTEGER
			unset: BOOLEAN
		do
			debug ("plist")
				io.putstring ("PLIST.store_obj. count=")
				io.putint (count); io.putstring ( " type=")
				io.putstring (generator); io.new_line
			end

			if allowed_to_store then
				if not db_operation_in_progress then
					pobject_store_obj (context)
					if pobject_id /= 0 and then
							pobject_root_id /= db_interface.current_root_id then
						set_root_id_and_database
						unset := True
					end

					debug ("plist")
						io.putstring ("PLIST.store_obj - no operation in progress%N")
					end

					-- Now go through the list and store
					-- each element
					from
						i := 1
					until
						i > count
					loop
						obj_id := eiffel_area.i_th_integer (i)
						if obj_id /= 0 then
							object ?= id_object (obj_id)
						else
							obj_id := i_th_integer (i)
							-- See if this object is in memory
							object := db_interface.object_table.item (obj_id)
						end
						if object /= Void then
							object.store_obj (context)
							put_i_th_integer (object.pobject_id, i)
							debug ("plist")
								io.putstring ("PLIST. stored type: ")
								io.putstring (object.generator)
								io.new_line
							end
						end
						i := i + 1
					end
					-- store area
					db_interface.set_db_vstr_attr (pobject_id, $(area_string.to_c), area)

					debug ("plist")
						io.putstring ("PLIST.store_obj - count =")
						io.putint(count); io.putstring (" type=")
						io.putstring (generator); io.new_line
					end
					if unset then
						unset_root_id_and_database
					end
				end
			end
		end

	store_shallow_obj (context: DB_OPERATION_CONTEXT) is
		local
			i: INTEGER
			obj: POBJECT
			obj_id: INTEGER
		do
			if not db_operation_in_progress then
				-- build new persistent area from eiffel_area
				from i := 1
				until i > count 
				loop
					obj_id := eiffel_area.i_th_integer (i)
					if obj_id /= 0 then
						obj ?= id_object (obj_id)
						if obj /= Void then
							if obj.pobject_id = 0 then
								-- This error should never happen
								except.raise ("Attemp to store PLIST with non-persistent elements")
							end
							put_i_th_integer (obj.pobject_id, i)
						end
					end
					i := i + 1
				end
				pobject_store_shallow_obj (context)
			end
		end

	check_diff_obj (make_new_persistent: BOOLEAN;
						context: DB_OPERATION_CONTEXT) is
		local
			i, obj_id: INTEGER
			object: POBJECT
			unset: BOOLEAN
		do
			if not db_operation_in_progress then
				pobject_check_diff_obj (make_new_persistent, context)
				if pobject_id /= 0 and then
						pobject_root_id /= db_interface.current_root_id then
					set_root_id_and_database
					unset := True
				end
				-- Next go though all the objects in
				-- the list check if they are different
				from
					i := 1
				until
					i > count
				loop
					obj_id := eiffel_area.i_th_integer (i)
					if obj_id /= 0 then
						object ?= id_object (obj_id)
					else
						obj_id := i_th_integer (i)
						-- See if this object is in memory
						object := db_interface.object_table.item (obj_id)
					end
					if object /= Void then
						object.check_diff_obj (make_new_persistent, context)
					end
					i := i + 1
				end
				if unset then
					unset_root_id_and_database
				end
			end
		rescue
			if unset then
				unset_root_id_and_database
			end
		end

	refresh_obj (context: DB_OPERATION_CONTEXT) is
		local
			i: INTEGER
			object: POBJECT
			obj_id: INTEGER
			err: INTEGER
			changed: BOOLEAN
		do
			if not db_operation_in_progress then
				pobject_refresh_obj (context)
				-- remake the eiffel area
				!!eiffel_area.make_empty (byte_count)
				-- Now go through the list and refresh
				-- any objects that are in memory
				from
					i := 1
				until
					i > count
				loop
					-- only look at the persistent area, since we just
					-- initialized the eiffel area
					obj_id := i_th_integer (i)
					-- See if this object is in memory
					object := db_interface.object_table.item (obj_id)
					if object /= Void then
						if object.pobject_id /= 0 then
							-- Only refresh objects that are persistent
							object.refresh_obj (context)
						end
					elseif db_interface.is_cached (obj_id) then
						-- refresh the object in Versant cache
						db_interface.o_refreshobj (obj_id, 0, $changed)
						if db_interface.nbpins (obj_id) > 1 then
							-- Undo the pin done by refresh
							-- Only called when needed.
							err  := db_interface.o_unpinobj (obj_id, 0)
						end
					end
					i := i + 1
				end
				publish (Void)
			end
		end -- refresh_obj
	
	refresh_shallow is
			-- on shallow refresh we have to remake the eiffel_area
		do
			pobject_refresh_shallow
			-- remake the Eiffel area
			!!eiffel_area.make_empty (byte_count)
		end

	reset_stamp_obj (context: DB_OPERATION_CONTEXT) is
		local
			i: INTEGER
			object: POBJECT
			obj_id: INTEGER
		do
			if not db_operation_in_progress then
				pobject_reset_stamp_obj (context)
				-- Now go through the list and refresh
				-- any objects that are in memory
				from
					i := 1
				until
					i > count
				loop
					obj_id := eiffel_area.i_th_integer (i)
					if obj_id /= 0 then
						object ?= id_object (obj_id)
					else
						obj_id := i_th_integer (i)
						-- See if this object is in memory
						object := db_interface.object_table.item (obj_id)
					end
					if object /= Void then
						object.reset_stamp_obj (context)
					end
					i := i + 1
				end
			end
		end -- reset_stamp_obj

	change_root_obj (new_root_id, old_root_id: INTEGER;
						context: DB_OPERATION_CONTEXT) is
		local
			i: INTEGER
			obj_id: INTEGER
			object: POBJECT
		do
			if not db_operation_in_progress then
				pobject_change_root_obj (new_root_id, old_root_id, context)
				-- Now go through the list and refresh
				-- any objects that are in memory
				from
					i := 1
				until
					i > count
				loop
					obj_id := eiffel_area.i_th_integer (i)
					if obj_id /= 0 then
						object ?= id_object (obj_id)
					else
						obj_id := i_th_integer (i)
						-- See if this object is in memory
						object := db_interface.object_table.item (obj_id)
					end
					if object /= Void then
						object.change_root_obj (new_root_id, old_root_id, context)
					end
					i := i + 1
				end
			end
		end -- change_root_obj
	
	recover_after_abort is
		do
			pobject_recover_after_abort
			if pobject_id = 0 then
				area := default_pointer
			else
				-- refresh the area from the database
				area := db_interface.get_db_ptr_attr (pobject_id, $(area_string.to_c))
				-- make new Eiffel area
				!!eiffel_area.make_empty (byte_count)
			end
		end


feature {DATABASE, POBJECT, POBJECT_CLOSURE_SCANNER, POBJECT_ACTION_COMMAND}
			-- computation of closures

	ref_count: INTEGER is
		do
			Result := count
		end

	ith_ref (i: INTEGER): T is
		do
			Result := i_th (i)
		end

	ith_mem_ref (i: INTEGER): T is
		do
			except.raise ("Not implemented yet")
		end

	set_ith_ref (i: INTEGER; object: T) is
		do
			if object.pobject_id = 0 then
				object.make_persistent
			end
			if i > count then
				except.raise ("PLIST.set_ith - index out of range")
			end
			set_ith_int_entry (area, object.pobject_id, i - 1)
			memorize_item (object)
		end

feature {PERSISTENCY_ROOT, DB_QUERY, SELECT_QUERY, PLIST, PLIST_OBJ}

	append_object_id (obj_id: INTEGER) is
		require
			object_not_null: obj_id /= 0
		do
			extend_integer (obj_id)
			eiffel_area.extend_integer (0)
		end

feature {PLIST}	

	eiffel_area: VSTR
			-- transient VSTR of eiffel IDs

feature {DB_INTERNAL}

	make_from_vstr (new_area: VSTR; new_gen: STRING) is
			-- Create a new list from a vstr that's a
			-- result of a query
		require
			new_gen /= Void
		do
			plist_generator := clone (new_gen)
			plist_generator.to_lower
			plist_generator.prune_all (' ')
			if plist_generator.index_of ('[', 1) = 0 then
				except.raise ("Invalid generator for PLIST")
			end
			re_make_from_vstr (new_area)
			!!eiffel_area.make_empty (byte_count)
			db_interface.list_manager.add (Current)
			rights_stamp := db_interface.read_write_allowed
		end

feature {NONE}
	
	area_string: STRING is "area"

	query: SELECT_QUERY [POBJECT] is
			-- Query to get elements of the list by name
		once
			!!Result.make ("name = $1")
		end

	dispose is
		do
			pobject_dispose
			c_dispose_delete_vstr (area)
		end

feature {DB_INTERNAL, SELECT_QUERY} -- keeping Eiffel references

	parent_container: PRIMARY_CONTAINER

	set_parent_container (parent: like parent_container) is
		do
			parent_container := parent
		end

	memorize_item (it: T) is
		do
			if parent_container = Void then
				if pobject_root_id /= 0 then
					parent_container := root_server.root_by_id (pobject_root_id)
				else
					parent_container := default_container
				end
			end
			parent_container.memorize_item (it)
		end

	
invariant
	
	count_consistent: (eiffel_area /= Void) implies (count = eiffel_area.integer_count)

end -- PLIST
