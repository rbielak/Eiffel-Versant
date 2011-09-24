-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
--  PLIST with locks that allow concurrent updates from different processes
--

class CONCURRENT_PLIST [T -> POBJECT]

inherit
	
	PLIST [T]
		rename
			extend as plist_extend,
			insert_i_th as plist_insert_i_th,
			put_i_th as plist_put_i_th,
			put_i_th_object_id as plist_put_i_th_object_id,
			remove_all as plist_remove_all,
			remove_item as plist_remove_item,
			append_list as plist_append_list,
			append_array as plist_append_array,
			union_with as plist_union_with,
			intersect_with as plist_intersect_with,
			difference_with as plist_difference_with,
			make as plist_make,
			is_equal as plist_is_equal,
			retrieve_obj as plist_retrieve_obj
		end
	
	PLIST [T] 
		redefine
			extend, insert_i_th,
			put_i_th, remove_all, remove_item, append_list,
			append_array, union_with, intersect_with, difference_with,
			make, is_equal, put_i_th_object_id, retrieve_obj
		select
			extend, insert_i_th, put_i_th, remove_all, remove_item, 
			append_list, append_array,
			union_with, intersect_with, difference_with, make,
			is_equal, put_i_th_object_id, retrieve_obj
		end

creation
	
	make,
	make_from_vstr

feature
	
	make (new_gen: STRING) is
		do
			plist_make (new_gen)
			!!lock.make (Current)
		end
	
	is_equal (other: like Current): BOOLEAN is
		local
			llock: PLIST_LOCK
		do
			llock := lock
			lock := other.lock
			Result := plist_is_equal (other)
			lock := llock
		end

	extend (litem : T) is
		do
			db_interface.start_transaction
			write_lock_list
			if litem.pobject_id = 0 then
				store_item (litem)
			end
			plist_extend (litem)
			store_area_with_context
			publish_concurrent_plist_event ("extend")
			db_interface.end_transaction
		end

	insert_i_th (litem : T; index : INTEGER) is
		do
			db_interface.start_transaction
			write_lock_list
			if litem.pobject_id = 0 then
				store_item (litem)
			end
			plist_insert_i_th (litem, index)
			store_area_with_context
			publish_concurrent_plist_event ("insert_i_th")
			db_interface.end_transaction		
		end

	put_i_th (litem : T; index : INTEGER) is
		do
			db_interface.start_transaction
			write_lock_list
			if litem.pobject_id = 0 then
				store_item (litem)
			end
			plist_put_i_th (litem, index);
			store_area_with_context
			publish_concurrent_plist_event ("put_i_th")
			db_interface.end_transaction
		end

	put_i_th_object_id (litem : INTEGER; index : INTEGER) is
		do
			db_interface.start_transaction
			write_lock_list
			plist_put_i_th_object_id (litem, index);
			store_area_with_context
			publish_concurrent_plist_event ("put_i_th_object_id")
			db_interface.end_transaction
		end

	remove_all is
		do
			db_interface.start_transaction
			write_lock_list
			plist_remove_all
			store_area_with_context
			publish_concurrent_plist_event ("remove_all")
			db_interface.end_transaction
		end

	remove_item (litem : T) is
		do
			db_interface.start_transaction
			write_lock_list
			plist_remove_item (litem)
			store_area_with_context
			publish_concurrent_plist_event ("remove_item")
			db_interface.end_transaction
		end

	append_list (other : PLIST[T]) is
		do
			db_interface.start_transaction
			write_lock_list
			if other.pobject_id = 0 then
				-- this code is not correct. We may wind up storing 
				-- in wrong db
				other.store_difference
			end
			plist_append_list (other)
			store_area_with_context
			publish_concurrent_plist_event ("append_list")
			db_interface.end_transaction
		end

	append_array (items: ARRAY [T]) is
		local
			context: DB_OPERATION_CONTEXT
			i: INTEGER
		do

			db_interface.start_transaction
			write_lock_list
			plist_append_array (items)
			if pobject_id /= 0 then
				-- if this list is persistent do a store diff on the items
				db_interface.set_current_database (database)
				db_interface.set_current_root_id (pobject_root_id)
				!!context.make_for_store_difference
				from i := items.lower
				until i > items.upper
				loop
					(items @ i).check_diff_obj (True, context)
					i := i + 1
				end
				context.mark_objects_not_in_progress
				from 
				until context.diff_stack.empty
				loop
					context.diff_stack.item.store_shallow_obj (context)
					context.diff_stack.remove
				end
				context.mark_objects_not_in_progress
				-- reset database and root
				db_interface.unset_current_database
				db_interface.unset_current_root_id
			end
			store_area_with_context
			publish_concurrent_plist_event ("append_list")
			db_interface.end_transaction
		end

	union_with (other : PLIST [T]) is
		do
			db_interface.start_transaction
			write_lock_list
			if other.pobject_id = 0 then
				other.store_difference
			end
			plist_union_with (other)
			store_area_with_context
			publish_concurrent_plist_event ("union_with")
			db_interface.end_transaction
		end

	intersect_with (other : PLIST [T]) is
		do
			db_interface.start_transaction
			write_lock_list
			if other.pobject_id = 0 then
				other.store_difference
			end
			plist_intersect_with (other)
			store_area_with_context
			publish_concurrent_plist_event ("intersect_with")
			db_interface.end_transaction
		end

	difference_with (other : PLIST [T]) is
		do
			db_interface.start_transaction
			write_lock_list
			if other.pobject_id = 0 then
				-- must store, otherwise the operation is too complex
				other.store_difference
			end
			plist_difference_with (other)
			store_area_with_context
			publish_concurrent_plist_event ("difference_with")
			db_interface.end_transaction
		end

	write_lock_list is
		do
			if pobject_id /= 0 then
				lock.write_lock
			end
		end

	read_lock_list is
		do
			if pobject_id /= 0 then
				lock.read_lock
			end
		end
	
	has_write_lock: BOOLEAN is
		do
			if pobject_id /= 0 then
				Result := lock.has_write_lock
			end			
		end
	
	has_read_lock: BOOLEAN is
		do
			if pobject_id /= 0 then
				Result := lock.has_read_lock
			end			
		end

feature {CONCURRENT_PLIST}
	
	lock : PLIST_LOCK

feature {NONE}

	retrieve_obj is
		do
			if not db_operation_in_progress then
				plist_retrieve_obj 
				!!lock.make (Current)
			end
		end

	store_item (litem: T) is
		local
			unset_db, unset_root_id: BOOLEAN
		do
			if pobject_id /= 0 then
				if not write_allowed then
					-- Check for add access
					except.raise ("Not allowed to add to PLIST")
				else
					-- Always store with current list's database and root id:
					unset_db := True
					unset_root_id := True
					db_interface.set_current_database (database)
					db_interface.set_current_root_id (pobject_root_id)
				end
			end
			litem.store_difference
			if unset_db then
				db_interface.unset_current_database
			end
			if unset_root_id then
				db_interface.unset_current_root_id
			end
		end
	
	store_area_with_context is
		local
			context: DB_OPERATION_CONTEXT
		do
			!!context.make_for_store
			db_interface.operation_context_stack.put (context)
			store_area (context)
			context.mark_objects_not_in_progress
			db_interface.operation_context_stack.remove
			
		end

	store_area (context: DB_OPERATION_CONTEXT) is
		do
			if pobject_id /= 0 then
				-- Store the list but not the contents of the vstr
				pobject_store_obj (context)
				if parent_container = default_container then
					if pobject_root_id /= 0 then
						parent_container := root_server.root_by_id (pobject_root_id)
					end
				end
			end
		end

	publish_concurrent_plist_event (event_name: STRING) is
		local
			event: DB_EVENT
		do
			if pobject_id /= 0 then
				-- Object has to be persistent before we publish the event
				if db_interface.events_active then
					!!event.make (event_name, Current)
					db_interface.publish_db_event (event)
				end
			end
		end

end -- CONCURRENT_PLIST
